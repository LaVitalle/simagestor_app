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
      if(!isSynced) return false;
    }
    return false;
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
          Map<String, dynamic> dadosParaEnviar = _limparDadosParaAPI(model, data);
          
          if (model == Model.combustivel) {
            await ServiceApi().postJsonWithAuth(model.api, dadosParaEnviar);
          } else {
            await ServiceApi().postFormDataWithAuth(model.api, dadosParaEnviar);
          }
          
          await _instace.marcarComoSincronizado(tabela, data[idField]);
          
          if (i < datas.length - 1) {
            await Future.delayed(Duration(milliseconds: 500));
          }
        } catch (e) {
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

  Map<String, dynamic> _limparDadosParaAPI(Model model, Map<String, dynamic> data) {
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
        
        if (dadosLimpos.containsKey('data_hora')) {
          String dataHora = dadosLimpos['data_hora'].toString();
          if (dataHora.contains('T')) {
            dataHora = dataHora.replaceAll('T', ' ').split('.')[0];
            dadosLimpos['data_hora'] = dataHora;
          }
        }
        break;
        
      case Model.checklist:
        dadosLimpos.remove('id_checklist');
        dadosLimpos.remove('sync');
        dadosLimpos.remove('configuracoes_id_usuario');
        
        if (dadosLimpos.containsKey('data_hora')) {
          String dataHora = dadosLimpos['data_hora'].toString();
          if (dataHora.contains('T')) {
            dataHora = dataHora.replaceAll('T', ' ').split('.')[0];
            dadosLimpos['data_hora'] = dataHora;
          }
        }
        break;
    }
    
    return dadosLimpos;
  }

}