class Despesa {
  final int idDespesa;
  final double valor;
  final String observacao;
  final DateTime dataHora;
  final bool recorrente;
  final String tipoDespesa;
  final int configuracoesIdUsuario;

  Despesa({
    required this.idDespesa,
    required this.valor,
    required this.observacao,
    required this.dataHora,
    required this.recorrente,
    required this.tipoDespesa,
    required this.configuracoesIdUsuario,
  });

  factory Despesa.fromJson(Map<String, dynamic> json) {
    return Despesa(
      idDespesa: json['id_despesa'] as int,
      valor: (json['valor'] as num).toDouble(),
      observacao: json['observacao'] as String? ?? '',
      dataHora: DateTime.parse(json['data_hora'] as String),
      recorrente: json['recorrente'] == 1,
      tipoDespesa: json['tipo_despesa'] as String? ?? '',
      configuracoesIdUsuario: json['configurações_id_usuario'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_despesa': idDespesa,
      'valor': valor,
      'observacao': observacao,
      'data_hora': dataHora.toIso8601String(),
      'recorrente': recorrente ? 1 : 0,
      'tipo_despesa': tipoDespesa,
      'configurações_id_usuario': configuracoesIdUsuario,
    };
  }

  String get idFormatado => idDespesa.toRadixString(16).toUpperCase();

  String get dataHoraFormatada {
    final day = dataHora.day.toString().padLeft(2, '0');
    final month = dataHora.month.toString().padLeft(2, '0');
    final year = dataHora.year.toString();
    final hour = dataHora.hour.toString().padLeft(2, '0');
    final minute = dataHora.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  @override
  String toString() {
    return 'Despesa{idDespesa: $idDespesa, valor: $valor, observacao: $observacao, dataHora: $dataHora, recorrente: $recorrente, tipoDespesa: $tipoDespesa, configuracoesIdUsuario: $configuracoesIdUsuario}';
  }
}
