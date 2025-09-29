import 'package:simagestor_app/enum/model_enum.dart';

class ServiceSync {
  Map<ModelEnum, bool> _synced_model = {
    ModelEnum.combustivel: false,
    ModelEnum.despesa: false,
    ModelEnum.checklist: false,
  };

  Future<void> syncAllModel() async {
    for (var key in _synced_model.keys) {
      syncModel(key);
    };
  }

  Future<void> syncModel(ModelEnum model) async {
    try {
      _synced_model[model] = true;

    } catch(e) {
      
    }
  }
}