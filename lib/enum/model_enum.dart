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
        return "api_checklist.php";

      case Model.despesa:
        return "api_despesas.php";

      case Model.combustivel:
        return "api_abastecimento.php";
    }
  }
}