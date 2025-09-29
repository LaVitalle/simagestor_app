import 'package:simagestor_app/models/despesa.dart';

class DespesaService {
  // Dados mockados para demonstração
  static final List<Despesa> _despesasMockadas = [
    Despesa(
      idDespesa: 195123456,
      valor: 25.50,
      observacao: 'Almoço no restaurante',
      dataHora: DateTime(2025, 1, 15, 12, 30),
      recorrente: false,
      tipoDespesa: 'Alimentação',
      configuracoesIdUsuario: 1,
    ),
    Despesa(
      idDespesa: 195123457,
      valor: 150.00,
      observacao: 'Combustível para viagem',
      dataHora: DateTime(2025, 1, 14, 18, 45),
      recorrente: false,
      tipoDespesa: 'Transporte',
      configuracoesIdUsuario: 1,
    ),
    Despesa(
      idDespesa: 195123458,
      valor: 89.90,
      observacao: 'Medicamentos na farmácia',
      dataHora: DateTime(2025, 1, 13, 16, 20),
      recorrente: true,
      tipoDespesa: 'Saúde',
      configuracoesIdUsuario: 1,
    ),
    Despesa(
      idDespesa: 195123459,
      valor: 45.00,
      observacao: 'Lanche da tarde',
      dataHora: DateTime(2025, 1, 12, 15, 10),
      recorrente: false,
      tipoDespesa: 'Alimentação',
      configuracoesIdUsuario: 1,
    ),
    Despesa(
      idDespesa: 195123460,
      valor: 200.00,
      observacao: 'Conta de luz do mês',
      dataHora: DateTime(2025, 1, 11, 9, 0),
      recorrente: true,
      tipoDespesa: 'Utilidades',
      configuracoesIdUsuario: 1,
    ),
    Despesa(
      idDespesa: 195123461,
      valor: 75.30,
      observacao: 'Taxi para o aeroporto',
      dataHora: DateTime(2025, 1, 10, 6, 30),
      recorrente: false,
      tipoDespesa: 'Transporte',
      configuracoesIdUsuario: 1,
    ),
    Despesa(
      idDespesa: 195123462,
      valor: 320.00,
      observacao: 'Compras no supermercado',
      dataHora: DateTime(2025, 1, 9, 19, 15),
      recorrente: true,
      tipoDespesa: 'Alimentação',
      configuracoesIdUsuario: 1,
    ),
    Despesa(
      idDespesa: 195123463,
      valor: 120.00,
      observacao: 'Consulta médica',
      dataHora: DateTime(2025, 1, 8, 14, 0),
      recorrente: false,
      tipoDespesa: 'Saúde',
      configuracoesIdUsuario: 1,
    ),
    Despesa(
      idDespesa: 195123464,
      valor: 65.00,
      observacao: 'Cinema com amigos',
      dataHora: DateTime(2025, 1, 7, 20, 30),
      recorrente: false,
      tipoDespesa: 'Entretenimento',
      configuracoesIdUsuario: 1,
    ),
    Despesa(
      idDespesa: 195123465,
      valor: 180.00,
      observacao: 'Conta de internet',
      dataHora: DateTime(2025, 1, 6, 10, 0),
      recorrente: true,
      tipoDespesa: 'Utilidades',
      configuracoesIdUsuario: 1,
    ),
  ];

  static Future<List<Despesa>> buscarDespesas() async {
    // Simula delay de rede
    await Future.delayed(const Duration(seconds: 1));

    // Simula possível erro (descomente para testar)
    // if (DateTime.now().millisecond % 10 == 0) {
    //   throw Exception('Erro simulado na rede');
    // }

    // Retorna os dados mockados
    return List.from(_despesasMockadas);
  }

  static Future<Despesa> buscarDespesaPorId(int id) async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 500));

    // Busca a despesa pelos dados mockados
    final despesa = _despesasMockadas.firstWhere(
      (d) => d.idDespesa == id,
      orElse: () => throw Exception('Despesa não encontrada'),
    );

    return despesa;
  }

  // Método para adicionar nova despesa aos dados mockados
  static Future<Despesa> adicionarDespesa(Despesa novaDespesa) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Gera um novo ID baseado no último ID + 1
    final ultimoId = _despesasMockadas
        .map((d) => d.idDespesa)
        .reduce((a, b) => a > b ? a : b);
    final novaDespesaComId = Despesa(
      idDespesa: ultimoId + 1,
      valor: novaDespesa.valor,
      observacao: novaDespesa.observacao,
      dataHora: novaDespesa.dataHora,
      recorrente: novaDespesa.recorrente,
      tipoDespesa: novaDespesa.tipoDespesa,
      configuracoesIdUsuario: novaDespesa.configuracoesIdUsuario,
    );

    _despesasMockadas.insert(0, novaDespesaComId);
    return novaDespesaComId;
  }

  // Método para atualizar despesa nos dados mockados
  static Future<Despesa> atualizarDespesa(Despesa despesaAtualizada) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final index = _despesasMockadas.indexWhere(
      (d) => d.idDespesa == despesaAtualizada.idDespesa,
    );
    if (index == -1) {
      throw Exception('Despesa não encontrada');
    }

    _despesasMockadas[index] = despesaAtualizada;
    return despesaAtualizada;
  }

  // Método para excluir despesa dos dados mockados
  static Future<void> excluirDespesa(int id) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _despesasMockadas.indexWhere((d) => d.idDespesa == id);
    if (index == -1) {
      throw Exception('Despesa não encontrada');
    }

    _despesasMockadas.removeAt(index);
  }
}
