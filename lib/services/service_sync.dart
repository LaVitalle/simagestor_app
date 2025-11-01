import 'package:simagestor_app/enum/model_enum.dart';
import 'package:simagestor_app/services/service_api.dart';
import 'package:simagestor_app/services/service_local_database.dart';
import 'package:flutter/foundation.dart';

class ServiceSync {
  final ServiceLocalDatabase _instace = ServiceLocalDatabase.instance;
  final Map<Model, bool> syncedModel = {
    Model.combustivel: false,
    Model.despesa: false,
    Model.checklist: false,
  };

  bool hasSomeAsyncedModel() {
    for (var isSynced in syncedModel.values) {
      if(!isSynced) return true;  // Se encontrou algum não sincronizado, retorna true
    }
    return false;  // Se todos estão sincronizados, retorna false
  }

  Future<void> syncAllModel() async {
    await Future.wait([
      for (var key in syncedModel.keys) syncModel(key),
    ]);
  }

  Future<void> syncModel(Model model) async {
    try {
      await ServiceApi().loadConfigFromDatabase();
      
      String tabela;
      String idField;
      switch (model) {
        case Model.combustivel:
          tabela = 'abastecimento';
          idField = 'id_abastecimento';
          break;
        case Model.despesa:
          tabela = 'despesa';
          idField = 'id_despesa';
          break;
        case Model.checklist:
          tabela = 'checklist';
          idField = 'id_checklist';
          break;
      }

      final datas = await _instace.getDadosNaoSincronizados(tabela);
      
      if (datas.isEmpty) {
        syncedModel[model] = true;
        return;
      }

      for (int i = 0; i < datas.length; i++) {
        var data = datas[i];
        try {
          Map<String, dynamic> dadosParaEnviar = await limparDadosParaAPI(model, data);
          debugPrint("Enviando dados $model para API: $dadosParaEnviar");
          
          if (model == Model.combustivel) {
            await ServiceApi().postJsonWithAuth(model.api, dadosParaEnviar);
          } else {
            await ServiceApi().postFormDataWithAuth(model.api, dadosParaEnviar);
          }
          
          await _instace.marcarComoSincronizado(tabela, data[idField]);
          debugPrint("Dados $model sincronizados com sucesso");
          
          if (i < datas.length - 1) {
            await Future.delayed(Duration(milliseconds: 500));
          }
        } catch (e) {
          debugPrint("Erro ao enviar dados $model: $e");
          bool deveMarcarComoSincronizado = false;
          
          if (e.toString().contains('400')) {
            if (e.toString().contains('duplicat') || 
                e.toString().contains('already exists') ||
                e.toString().contains('já existe') ||
                e.toString().contains('já registrado') ||
                e.toString().contains('Abastecimento já registrado')) {
              deveMarcarComoSincronizado = true;
            }
          }
          
          if (deveMarcarComoSincronizado) {
            await _instace.marcarComoSincronizado(tabela, data[idField]);
          }
        }
      }

      syncedModel[model] = true;
    } catch (e) {
      syncedModel[model] = false;
      debugPrint("Erro ao sincronizar $model: $e");
    }
  }

  Future<Map<String, dynamic>> limparDadosParaAPI(Model model, Map<String, dynamic> data) async {
    Map<String, dynamic> dadosLimpos = Map<String, dynamic>.from(data);
    
    switch (model) {
      case Model.combustivel:
        dadosLimpos.remove('id_abastecimento');
        dadosLimpos.remove('sync');
        dadosLimpos.remove('configuracoes_id_usuario');
        
        if (dadosLimpos.containsKey('total_RS')) {
          dadosLimpos['total_reais'] = dadosLimpos['total_RS'].toString();
          dadosLimpos.remove('total_RS');
        }
        
        if (dadosLimpos.containsKey('placa')) {
          dadosLimpos['placa'] = dadosLimpos['placa'].toString().toUpperCase();
        }
        
        if (dadosLimpos.containsKey('data_hora')) {
          String dataHora = dadosLimpos['data_hora'].toString();
          if (dataHora.contains('T')) {
            dataHora = dataHora.replaceAll('T', ' ').split('.')[0];
            dadosLimpos['data_hora'] = dataHora;
          }
        }
        
        if (dadosLimpos.containsKey('km')) {
          dadosLimpos['km'] = dadosLimpos['km'].toString();
        }
        if (dadosLimpos.containsKey('valor_por_litro')) {
          dadosLimpos['valor_por_litro'] = dadosLimpos['valor_por_litro'].toString();
        }
        if (dadosLimpos.containsKey('litros_abastecidos')) {
          dadosLimpos['litros_abastecidos'] = dadosLimpos['litros_abastecidos'].toString();
        }
        break;
        
      case Model.despesa:
        dadosLimpos.remove('id_despesa');
        dadosLimpos.remove('sync');
        dadosLimpos.remove('configuracoes_id_usuario');
        
        if (dadosLimpos.containsKey('valor')) {
          dadosLimpos['valor'] = dadosLimpos['valor'].toString();
        }
        
        if (dadosLimpos.containsKey('recorrente')) {
          dadosLimpos['recorrente'] = dadosLimpos['recorrente'].toString();
        }
        
        if (dadosLimpos.containsKey('data_hora')) {
          String dataHora = dadosLimpos['data_hora'].toString();
          // Remove milissegundos se existirem
          dataHora = dataHora.split('.')[0];
          
          // Se tiver espaço, converte para T
          if (dataHora.contains(' ')) {
            dataHora = dataHora.replaceAll(' ', 'T');
          }
          
          // Remove segundos (espera formato YYYY-MM-DDTHH:MM:SS ou YYYY-MM-DDTHH:MM)
          if (dataHora.contains('T')) {
            List<String> parts = dataHora.split('T');
            if (parts.length == 2) {
              String hora = parts[1];
              if (hora.split(':').length == 3) {
                // Remove os segundos
                List<String> horaParts = hora.split(':');
                hora = '${horaParts[0]}:${horaParts[1]}';
              }
              dataHora = '${parts[0]}T$hora';
            }
          }
          
          dadosLimpos['data_hora'] = dataHora;
        }
        break;
        
      case Model.checklist:
        // Salva valores originais ANTES de limpar
        String placaVeiculo = dadosLimpos['placa_veiculo']?.toString() ?? '';
        String motorista = dadosLimpos['motorista']?.toString() ?? '';
        String signature = dadosLimpos['campo_assinatura']?.toString() ?? '';
        
        // Busca vehicle_id e driver_id na API
        final serviceApi = ServiceApi();
        String? vehicleId = await serviceApi.buscarVehicleIdPorPlaca(placaVeiculo);
        String? driverId = await serviceApi.buscarDriverIdPorNome(motorista);
        
        // Se não conseguir buscar os IDs, lança erro
        if (vehicleId == null || vehicleId.isEmpty) {
          throw Exception('Não foi possível encontrar vehicle_id para a placa: $placaVeiculo');
        }
        if (driverId == null || driverId.isEmpty) {
          throw Exception('Não foi possível encontrar driver_id para o motorista: $motorista');
        }
        
        // Mapeia os campos do checklist para items[N][result]
        // Ordem: 1=freios, 2=pneus, 3=nivel_oleo, 4=farois_lanterna, 5=documentacao_veiculo,
        //        6=CNH_motorista, 7=limpadores_parabrisa, 8=cintos_de_seguranca, 
        //        9=fluido_de_arrefecimento, 10=suspensao
        
        Map<String, String> camposChecklist = {
          'freios': '1',
          'pneus': '2',
          'nivel_oleo': '3',
          'farois_lanterna': '4',
          'documentacao_veiculo': '5',
          'CNH_motorista': '6',
          'limpadores_parabrisa': '7',
          'cintos_de_seguranca': '8',
          'fluido_de_arrefecimento': '9',
          'suspensao': '10',
        };
        
        // Limpa todos os campos antigos
        dadosLimpos.clear();
        
        // Adiciona campos principais com os IDs encontrados
        dadosLimpos['vehicle_id'] = vehicleId;
        dadosLimpos['driver_id'] = driverId;
        dadosLimpos['checker_name'] = motorista;
        dadosLimpos['signature'] = signature;
        
        // Transforma os campos em items usando os valores originais de 'data'
        for (var entry in camposChecklist.entries) {
          String campo = entry.key;
          String itemNum = entry.value;
          String valor = data[campo]?.toString() ?? 'not_ok';
          
          // Converte 'ok'/'not_ok' para o formato esperado
          dadosLimpos['items[$itemNum][result]'] = valor;
          dadosLimpos['items[$itemNum][comments]'] = '';
        }
        
        break;
    }
    
    return dadosLimpos;
  }

}