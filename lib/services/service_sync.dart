import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
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
        String vehicleId = data['vehicle_id']?.toString() ?? '';
        String driverId = data['driver_id']?.toString() ?? '';
        String signature = data['campo_assinatura']?.toString() ?? '';
        
        // Se a assinatura não estiver no formato correto, usa uma imagem PNG transparente em base64
        if (!signature.startsWith('data:image/png;base64,')) {
          // Imagem PNG transparente 1x1 em base64
          signature = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
        }
        
        // Busca o nome do motorista para o campo checker_name
        String checkerName = '';
        if (driverId.isNotEmpty) {
          final motoristas = await _instace.getAllMotoristas();
          final motorista = motoristas.where((m) => m['id'].toString() == driverId).firstOrNull;
          if (motorista != null) {
            checkerName = motorista['nome'] ?? '';
          }
        }
        
        // Mapeia os campos do checklist para items[N][result] e items[N][comments]
        // Ordem: 1=freios, 2=pneus, 3=nivel_oleo, 4=farois_lanterna, 5=documentacao_veiculo,
        //        6=CNH_motorista, 7=limpadores_parabrisa, 8=cintos_de_seguranca, 
        //        9=fluido_de_arrefecimento, 10=suspensao
        
        Map<String, Map<String, String>> camposChecklist = {
          'freios': {'num': '1', 'comentario': 'freios_comentario', 'foto': 'freios_foto'},
          'pneus': {'num': '2', 'comentario': 'pneus_comentario', 'foto': 'pneus_foto'},
          'nivel_oleo': {'num': '3', 'comentario': 'nivel_oleo_comentario', 'foto': 'nivel_oleo_foto'},
          'farois_lanterna': {'num': '4', 'comentario': 'farois_lanterna_comentario', 'foto': 'farois_lanterna_foto'},
          'documentacao_veiculo': {'num': '5', 'comentario': 'documentacao_veiculo_comentario', 'foto': 'documentacao_veiculo_foto'},
          'CNH_motorista': {'num': '6', 'comentario': 'CNH_motorista_comentario', 'foto': 'CNH_motorista_foto'},
          'limpadores_parabrisa': {'num': '7', 'comentario': 'limpadores_parabrisa_comentario', 'foto': 'limpadores_parabrisa_foto'},
          'cintos_de_seguranca': {'num': '8', 'comentario': 'cintos_de_seguranca_comentario', 'foto': 'cintos_de_seguranca_foto'},
          'fluido_de_arrefecimento': {'num': '9', 'comentario': 'fluido_de_arrefecimento_comentario', 'foto': 'fluido_de_arrefecimento_foto'},
          'suspensao': {'num': '10', 'comentario': 'suspensao_comentario', 'foto': 'suspensao_foto'},
        };
        
        // Limpa todos os campos antigos
        dadosLimpos.clear();
        
        // Adiciona campos principais com os IDs
        dadosLimpos['vehicle_id'] = vehicleId;
        dadosLimpos['driver_id'] = driverId;
        dadosLimpos['checker_name'] = checkerName;
        dadosLimpos['signature'] = signature;
        
        // Transforma os campos em items usando os valores originais de 'data'
        for (var entry in camposChecklist.entries) {
          String campo = entry.key;
          String itemNum = entry.value['num']!;
          String campoComentario = entry.value['comentario']!;
          String campoFoto = entry.value['foto']!;
          
          String valor = data[campo]?.toString() ?? 'not_ok';
          String comentario = data[campoComentario]?.toString() ?? '';
          String? fotoPath = data[campoFoto]?.toString();
          
          // Converte 'ok'/'not_ok' para o formato esperado
          dadosLimpos['items[$itemNum][result]'] = valor;
          dadosLimpos['items[$itemNum][comments]'] = comentario;
          
          // Se o item for not_ok, adiciona a foto (real ou mockada)
          if (valor == 'not_ok') {
            MultipartFile? photoFile;
            
            // Tenta carregar a foto real se o caminho existir e o arquivo existir
            if (fotoPath != null && fotoPath.isNotEmpty) {
              try {
                final file = File(fotoPath);
                if (await file.exists()) {
                  final bytes = await file.readAsBytes();
                  final extension = fotoPath.split('.').last.toLowerCase();
                  final mimeType = extension == 'jpg' || extension == 'jpeg' ? 'jpeg' : extension;
                  
                  photoFile = MultipartFile.fromBytes(
                    bytes,
                    filename: 'item_$itemNum.$extension',
                    contentType: MediaType('image', mimeType),
                  );
                  debugPrint('Foto real carregada para item $itemNum: $fotoPath');
                }
              } catch (e) {
                debugPrint('Erro ao carregar foto real para item $itemNum: $e');
              }
            }
            
            // Se não conseguiu carregar foto real, usa mockada
            if (photoFile == null) {
              debugPrint('Usando foto mockada para item $itemNum');
              final bytes = base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==');
              photoFile = MultipartFile.fromBytes(
                bytes,
                filename: 'item_$itemNum.png',
                contentType: MediaType('image', 'png'),
              );
            }
            
            dadosLimpos['items[$itemNum][photo]'] = photoFile;
          }
        }
        
        break;
    }
    
    return dadosLimpos;
  }

}