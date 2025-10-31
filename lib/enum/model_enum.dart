enum Model {
  combustivel,
  despesa,
  checklist
}

extension ModelExtension on Model {
  String get database {
    switch (this) {
      case Model.checklist:
        return "checklist";

      case Model.despesa:
        return "despesa";

      case Model.combustivel:
        return "combustivel";
    }
  }

  String get api {
    switch (this) {
      case Model.checklist:
        return "api_checklist";

      case Model.despesa:
        return "api_despesa";

      case Model.combustivel:
        return "api_abastecimento";
    }
  }
}