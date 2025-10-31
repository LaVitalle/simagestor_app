import 'package:simagestor_app/models/despesa.dart';
import 'package:simagestor_app/services/service_local_database.dart';

class DespesaService {
  static final ServiceLocalDatabase _db = ServiceLocalDatabase.instance;

  static Future<List<Despesa>> buscarDespesas() async {
    try {
      final List<Map<String, dynamic>> results = await _db.getAllDespesas();
      return results.map((json) => Despesa.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar despesas: $e');
    }
  }

  static Future<Despesa> buscarDespesaPorId(int id) async {
    try {
      final Map<String, dynamic>? result = await _db.getDespesaById(id);
      if (result == null) {
        throw Exception('Despesa não encontrada');
      }
      return Despesa.fromJson(result);
    } catch (e) {
      throw Exception('Erro ao buscar despesa por ID $id: $e');
    }
  }

  static Future<Despesa> adicionarDespesa(Despesa novaDespesa) async {
    try {
      final data = novaDespesa.toJson();
      // Remove o id_despesa se for 0 (novo registro)
      if (data['id_despesa'] == 0) {
        data.remove('id_despesa');
      }

      final int id = await _db.insertDespesa(data);

      // Retorna a despesa com o ID gerado pelo banco
      return Despesa(
        idDespesa: id,
        valor: novaDespesa.valor,
        placa: novaDespesa.placa,
        observacao: novaDespesa.observacao,
        dataHora: novaDespesa.dataHora,
        recorrente: novaDespesa.recorrente,
        tipoDespesa: novaDespesa.tipoDespesa,
        configuracoesIdUsuario: novaDespesa.configuracoesIdUsuario,
      );
    } catch (e) {
      throw Exception('Erro ao adicionar despesa: $e');
    }
  }

  static Future<Despesa> atualizarDespesa(Despesa despesaAtualizada) async {
    try {
      final data = despesaAtualizada.toJson();
      // Remove o id_despesa do update
      data.remove('id_despesa');

      final int rowsAffected = await _db.updateDespesa(
        despesaAtualizada.idDespesa,
        data,
      );

      if (rowsAffected == 0) {
        throw Exception('Despesa não encontrada');
      }

      return despesaAtualizada;
    } catch (e) {
      throw Exception('Erro ao atualizar despesa: $e');
    }
  }

  static Future<void> excluirDespesa(int id) async {
    try {
      final int rowsAffected = await _db.deleteDespesa(id);

      if (rowsAffected == 0) {
        throw Exception('Despesa não encontrada');
      }
    } catch (e) {
      throw Exception('Erro ao excluir despesa: $e');
    }
  }

  /// Busca despesas por tipo
  static Future<List<Despesa>> buscarDespesasPorTipo(String tipo) async {
    try {
      final List<Map<String, dynamic>> results = await _db.getDespesasByTipo(
        tipo,
      );
      return results.map((json) => Despesa.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar despesas por tipo $tipo: $e');
    }
  }

  /// Busca despesas por período
  static Future<List<Despesa>> buscarDespesasPorPeriodo(
    DateTime dataInicio,
    DateTime dataFim,
  ) async {
    try {
      final String inicio = dataInicio.toIso8601String();
      final String fim = dataFim.toIso8601String();

      final List<Map<String, dynamic>> results = await _db.getDespesasByPeriodo(
        inicio,
        fim,
      );
      return results.map((json) => Despesa.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar despesas por período: $e');
    }
  }

  /// Busca despesas por período (usando strings)
  static Future<List<Despesa>> buscarDespesasPorPeriodoString(
    String dataInicio,
    String dataFim,
  ) async {
    try {
      final List<Map<String, dynamic>> results = await _db.getDespesasByPeriodo(
        dataInicio,
        dataFim,
      );
      return results.map((json) => Despesa.fromJson(json)).toList();
    } catch (e) {
      throw Exception(
        'Erro ao buscar despesas por período $dataInicio - $dataFim: $e',
      );
    }
  }

  /// Busca despesas não sincronizadas
  static Future<List<Despesa>> buscarDespesasNaoSincronizadas() async {
    try {
      final List<Map<String, dynamic>> results = await _db
          .getDadosNaoSincronizados('despesa');
      return results.map((json) => Despesa.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar despesas não sincronizadas: $e');
    }
  }

  /// Marca uma despesa como sincronizada
  static Future<void> marcarDespesaComoSincronizada(int id) async {
    try {
      await _db.marcarComoSincronizado('despesa', id);
    } catch (e) {
      throw Exception('Erro ao marcar despesa ID $id como sincronizada: $e');
    }
  }

  /// Calcula o total de despesas
  static Future<double> calcularTotalDespesas() async {
    try {
      final List<Despesa> todasDespesas = await buscarDespesas();
      return todasDespesas.fold<double>(
        0.0,
        (total, despesa) => total + despesa.valor,
      );
    } catch (e) {
      throw Exception('Erro ao calcular total de despesas: $e');
    }
  }

  /// Calcula o total de despesas por tipo
  static Future<double> calcularTotalDespesasPorTipo(String tipo) async {
    try {
      final List<Despesa> despesas = await buscarDespesasPorTipo(tipo);
      return despesas.fold<double>(
        0.0,
        (total, despesa) => total + despesa.valor,
      );
    } catch (e) {
      throw Exception('Erro ao calcular total de despesas por tipo $tipo: $e');
    }
  }

  /// Calcula o total de despesas por período
  static Future<double> calcularTotalDespesasPorPeriodo(
    DateTime dataInicio,
    DateTime dataFim,
  ) async {
    try {
      final List<Despesa> despesas = await buscarDespesasPorPeriodo(
        dataInicio,
        dataFim,
      );
      return despesas.fold<double>(
        0.0,
        (total, despesa) => total + despesa.valor,
      );
    } catch (e) {
      throw Exception('Erro ao calcular total de despesas por período: $e');
    }
  }

  /// Cria uma nova despesa com valores padrão
  static Despesa criarDespesa({
    required double valor,
    required String tipoDespesa,
    String placa = '',
    String observacao = '',
    DateTime? dataHora,
    bool recorrente = false,
    required int configuracoesIdUsuario,
  }) {
    return Despesa(
      idDespesa: 0, // ID será gerado pelo banco
      valor: valor,
      placa: placa,
      observacao: observacao,
      dataHora: dataHora ?? DateTime.now(),
      recorrente: recorrente,
      tipoDespesa: tipoDespesa,
      configuracoesIdUsuario: configuracoesIdUsuario,
    );
  }
}
