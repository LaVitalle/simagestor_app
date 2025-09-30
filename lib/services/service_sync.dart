import 'package:simagestor_app/enum/model_enum.dart';
import 'package:simagestor_app/services/service_api.dart';
import 'package:simagestor_app/services/service_local_database.dart';

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
      final datas = await _instace.getDadosNaoSincronizados(model.name);

      for (var data in datas) {
        await ServiceApi().postFormData(model.api, data);
        await _instace.marcarComoSincronizado(model.database, data["id"]);
      }

      syncedModel[model] = true;
    } catch (e) {
      syncedModel[model] = false;
      print("Erro ao sincronizar $model: $e");
    }
  }
}