import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ServiceLocalDatabase {
  static final ServiceLocalDatabase instance = ServiceLocalDatabase._init();
  static Database? _database;

  ServiceLocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("app.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }


  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE configuracoes (
        id_usuario INTEGER PRIMARY KEY,
        url_empresa TEXT NOT NULL,
        data_expiracao TEXT NOT NULL,
        token TEXT NOT NULL,
        isAdmin BOOLEAN NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE checklist (
        id_checklist INTEGER PRIMARY KEY AUTOINCREMENT,
        placa_veiculo TEXT NOT NULL,
        motorista TEXT NOT NULL,
        freios TEXT CHECK (freios IN ('ok', 'not_ok')),
        pneus TEXT CHECK (pneus IN ('ok', 'not_ok')),
        nivel_oleo TEXT CHECK (nivel_oleo IN ('ok', 'not_ok')),
        farois_lanterna TEXT CHECK (farois_lanterna IN ('ok', 'not_ok')),
        documentacao_veiculo TEXT CHECK (documentacao_veiculo IN ('ok', 'not_ok')),
        CNH_motorista TEXT CHECK (CNH_motorista IN ('ok', 'not_ok')),
        limpadores_parabrisa TEXT CHECK (limpadores_parabrisa IN ('ok', 'not_ok')),
        cintos_de_seguranca TEXT CHECK (cintos_de_seguranca IN ('ok', 'not_ok')),
        fluido_de_arrefecimento TEXT CHECK (fluido_de_arrefecimento IN ('ok', 'not_ok')),
        suspensao TEXT CHECK (suspensao IN ('ok', 'not_ok')),
        campo_assinatura TEXT,
        sync BOOLEAN NOT NULL,
        configuracoes_id_usuario INTEGER,
        FOREIGN KEY (configuracoes_id_usuario) REFERENCES configuracoes (id_usuario)
      )
    ''');

    await db.execute('''
      CREATE TABLE despesa (
        id_despesa INTEGER PRIMARY KEY AUTOINCREMENT,
        valor REAL NOT NULL,
        observacao TEXT,
        data_hora TEXT NOT NULL,
        recorrente INTEGER,
        tipo_despesa TEXT,
        configuracoes_id_usuario INTEGER,
        sync BOOLEAN NOT NULL,
        FOREIGN KEY (configuracoes_id_usuario) REFERENCES configuracoes (id_usuario)
      )
    ''');

    await db.execute('''
      CREATE TABLE abastecimento (
        id_abastecimento INTEGER PRIMARY KEY AUTOINCREMENT,
        data_hora TEXT NOT NULL,
        km REAL,
        combustivel TEXT,
        valor_por_litro REAL,
        litros_abastecidos REAL,
        total_RS REAL,
        sync BOOLEAN NOT NULL,
        configuracoes_id_usuario INTEGER,
        FOREIGN KEY (configuracoes_id_usuario) REFERENCES configuracoes (id_usuario)
      )
    ''');
  }

  // Métodos para Configurações
  Future<int> insertConfiguracao(Map<String, dynamic> configuracao) async {
    try {
      final db = await instance.database;
      return await db.insert('configuracoes', configuracao);
    } catch (e) {
      print('Erro ao inserir configuração: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllConfiguracoes() async {
    try {
      final db = await instance.database;
      return await db.query('configuracoes');
    } catch (e) {
      print('Erro ao buscar todas as configurações: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getConfiguracaoById(int id) async {
    try {
      final db = await instance.database;
      final result = await db.query(
        'configuracoes',
        where: 'id_usuario = ?',
        whereArgs: [id],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Erro ao buscar configuração por ID $id: $e');
      rethrow;
    }
  }

  Future<int> updateConfiguracao(int id, Map<String, dynamic> configuracao) async {
    try {
      final db = await instance.database;
      return await db.update(
        'configuracoes',
        configuracao,
        where: 'id_usuario = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Erro ao atualizar configuração ID $id: $e');
      rethrow;
    }
  }

  Future<int> deleteConfiguracao(int id) async {
    try {
      final db = await instance.database;
      return await db.delete(
        'configuracoes',
        where: 'id_usuario = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Erro ao deletar configuração ID $id: $e');
      rethrow;
    }
  }

  Future<int> insertChecklist(Map<String, dynamic> checklist) async {
    try {
      final db = await instance.database;
      return await db.insert('checklist', checklist);
    } catch (e) {
      print('Erro ao inserir checklist: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllChecklists() async {
    try {
      final db = await instance.database;
      return await db.query('checklist');
    } catch (e) {
      print('Erro ao buscar todos os checklists: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getChecklistById(int id) async {
    try {
      final db = await instance.database;
      final result = await db.query(
        'checklist',
        where: 'id_checklist = ?',
        whereArgs: [id],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Erro ao buscar checklist por ID $id: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getChecklistsByPlaca(String placa) async {
    try {
      final db = await instance.database;
      return await db.query(
        'checklist',
        where: 'placa_veiculo = ?',
        whereArgs: [placa],
      );
    } catch (e) {
      print('Erro ao buscar checklists por placa $placa: $e');
      rethrow;
    }
  }

  Future<int> updateChecklist(int id, Map<String, dynamic> checklist) async {
    try {
      final db = await instance.database;
      return await db.update(
        'checklist',
        checklist,
        where: 'id_checklist = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Erro ao atualizar checklist ID $id: $e');
      rethrow;
    }
  }

  Future<int> deleteChecklist(int id) async {
    try {
      final db = await instance.database;
      return await db.delete(
        'checklist',
        where: 'id_checklist = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Erro ao deletar checklist ID $id: $e');
      rethrow;
    }
  }

  ///////////////////////////////////////////////Despesa///////////////////////////////////////////////
  Future<int> insertDespesa(Map<String, dynamic> despesa) async {
    try {
      final db = await instance.database;
      return await db.insert('despesa', despesa);
    } catch (e) {
      print('Erro ao inserir despesa: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllDespesas() async {
    try {
      final db = await instance.database;
      return await db.query('despesa');
    } catch (e) {
      print('Erro ao buscar todas as despesas: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getDespesaById(int id) async {
    try {
      final db = await instance.database;
      final result = await db.query(
        'despesa',
        where: 'id_despesa = ?',
        whereArgs: [id],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Erro ao buscar despesa por ID $id: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getDespesasByTipo(String tipo) async {
    try {
      final db = await instance.database;
      return await db.query(
        'despesa',
        where: 'tipo_despesa = ?',
        whereArgs: [tipo],
      );
    } catch (e) {
      print('Erro ao buscar despesas por tipo $tipo: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getDespesasByPeriodo(String dataInicio, String dataFim) async {
    try {
      final db = await instance.database;
      return await db.query(
        'despesa',
        where: 'data_hora BETWEEN ? AND ?',
        whereArgs: [dataInicio, dataFim],
      );
    } catch (e) {
      print('Erro ao buscar despesas por período $dataInicio - $dataFim: $e');
      rethrow;
    }
  }

  Future<int> updateDespesa(int id, Map<String, dynamic> despesa) async {
    try {
      final db = await instance.database;
      return await db.update(
        'despesa',
        despesa,
        where: 'id_despesa = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Erro ao atualizar despesa ID $id: $e');
      rethrow;
    }
  }

  Future<int> deleteDespesa(int id) async {
    try {
      final db = await instance.database;
      return await db.delete(
        'despesa',
        where: 'id_despesa = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Erro ao deletar despesa ID $id: $e');
      rethrow;
    }
  }

  /////////////////////////////////////////////// Abastecimento ///////////////////////////////////////////////
  Future<int> insertAbastecimento(Map<String, dynamic> abastecimento) async {
    try {
      final db = await instance.database;
      return await db.insert('abastecimento', abastecimento);
    } catch (e) {
      print('Erro ao inserir abastecimento: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllAbastecimentos() async {
    try {
      final db = await instance.database;
      return await db.query('abastecimento');
    } catch (e) {
      print('Erro ao buscar todos os abastecimentos: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getAbastecimentoById(int id) async {
    try {
      final db = await instance.database;
      final result = await db.query(
        'abastecimento',
        where: 'id_abastecimento = ?',
        whereArgs: [id],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Erro ao buscar abastecimento por ID $id: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAbastecimentosByCombustivel(String combustivel) async {
    try {
      final db = await instance.database;
      return await db.query(
        'abastecimento',
        where: 'combustivel = ?',
        whereArgs: [combustivel],
      );
    } catch (e) {
      print('Erro ao buscar abastecimentos por combustível $combustivel: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAbastecimentosByPeriodo(String dataInicio, String dataFim) async {
    try {
      final db = await instance.database;
      return await db.query(
        'abastecimento',
        where: 'data_hora BETWEEN ? AND ?',
        whereArgs: [dataInicio, dataFim],
      );
    } catch (e) {
      print('Erro ao buscar abastecimentos por período $dataInicio - $dataFim: $e');
      rethrow;
    }
  }

  Future<int> updateAbastecimento(int id, Map<String, dynamic> abastecimento) async {
    try {
      final db = await instance.database;
      return await db.update(
        'abastecimento',
        abastecimento,
        where: 'id_abastecimento = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Erro ao atualizar abastecimento ID $id: $e');
      rethrow;
    }
  }

  Future<int> deleteAbastecimento(int id) async {
    try {
      final db = await instance.database;
      return await db.delete(
        'abastecimento',
        where: 'id_abastecimento = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Erro ao deletar abastecimento ID $id: $e');
      rethrow;
    }
  }

  /////////////////////////////////////////////// sincronização ///////////////////////////////////////////////
  Future<List<Map<String, dynamic>>> getDadosNaoSincronizados(String tabela) async {
    try {
      final db = await instance.database;
      return await db.query(
        tabela,
        where: 'sync = ? OR sync IS NULL',
        whereArgs: [false],
      );
    } catch (e) {
      print('Erro ao buscar dados não sincronizados da tabela $tabela: $e');
      rethrow;
    }
  }

  Future<int> marcarComoSincronizado(String tabela, int id) async {
    try {
      final db = await instance.database;
      return await db.update(
        tabela,
        {'sync': true},
        where: 'id_${tabela} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Erro ao marcar como sincronizado na tabela $tabela, ID $id: $e');
      rethrow;
    }
  }

  Future close() async {
    try {
      final db = await instance.database;
      await db.close();
    } catch (e) {
      print('Erro ao fechar banco de dados: $e');
      rethrow;
    }
  }
}
