import 'package:simagestor_app/enum/model_enum.dart';
import 'package:simagestor_app/services/service_api.dart';
import 'package:simagestor_app/services/service_connection.dart';
import 'package:simagestor_app/services/service_sync.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

class ServiceLocalDatabase {
  static final ServiceLocalDatabase instance = ServiceLocalDatabase._init();
  static Database? _database;
  static final ServiceSync _serviceSync = ServiceSync(); 

  ServiceLocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("app.db");
    await _ensureTablesExist();
    return _database!;
  }

  Future<void> _ensureTablesExist() async {
    if (_database == null) return;
    
    try {
      // Verifica se a tabela veiculos existe
      final veiculosExists = await _database!.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='veiculos'"
      );
      
      if (veiculosExists.isEmpty) {
        debugPrint('Criando tabela veiculos...');
        await _database!.execute('''
          CREATE TABLE veiculos (
            id INTEGER PRIMARY KEY,
            placa TEXT NOT NULL UNIQUE,
            tipo TEXT NOT NULL
          )
        ''');
        debugPrint('Tabela veiculos criada com sucesso');
      }
      
      // Verifica se a tabela motoristas existe
      final motoristasExists = await _database!.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='motoristas'"
      );
      
      if (motoristasExists.isEmpty) {
        debugPrint('Criando tabela motoristas...');
        await _database!.execute('''
          CREATE TABLE motoristas (
            id INTEGER PRIMARY KEY,
            nome TEXT NOT NULL
          )
        ''');
        debugPrint('Tabela motoristas criada com sucesso');
      }
    } catch (e) {
      debugPrint('Erro ao verificar/criar tabelas: $e');
    }
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      final databaseFactory = databaseFactoryFfiWeb;
      final path = join(await getDatabasesPath(), filePath);
      return await databaseFactory.openDatabase(path, options: OpenDatabaseOptions(
        version: 4,
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
      ));
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      return await openDatabase(path, version: 4, onCreate: _createDB, onUpgrade: _onUpgrade);
    }
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
        vehicle_id INTEGER NOT NULL,
        driver_id INTEGER NOT NULL,
        freios TEXT CHECK (freios IN ('ok', 'not_ok')),
        freios_comentario TEXT,
        freios_foto TEXT,
        pneus TEXT CHECK (pneus IN ('ok', 'not_ok')),
        pneus_comentario TEXT,
        pneus_foto TEXT,
        nivel_oleo TEXT CHECK (nivel_oleo IN ('ok', 'not_ok')),
        nivel_oleo_comentario TEXT,
        nivel_oleo_foto TEXT,
        farois_lanterna TEXT CHECK (farois_lanterna IN ('ok', 'not_ok')),
        farois_lanterna_comentario TEXT,
        farois_lanterna_foto TEXT,
        documentacao_veiculo TEXT CHECK (documentacao_veiculo IN ('ok', 'not_ok')),
        documentacao_veiculo_comentario TEXT,
        documentacao_veiculo_foto TEXT,
        CNH_motorista TEXT CHECK (CNH_motorista IN ('ok', 'not_ok')),
        CNH_motorista_comentario TEXT,
        CNH_motorista_foto TEXT,
        limpadores_parabrisa TEXT CHECK (limpadores_parabrisa IN ('ok', 'not_ok')),
        limpadores_parabrisa_comentario TEXT,
        limpadores_parabrisa_foto TEXT,
        cintos_de_seguranca TEXT CHECK (cintos_de_seguranca IN ('ok', 'not_ok')),
        cintos_de_seguranca_comentario TEXT,
        cintos_de_seguranca_foto TEXT,
        fluido_de_arrefecimento TEXT CHECK (fluido_de_arrefecimento IN ('ok', 'not_ok')),
        fluido_de_arrefecimento_comentario TEXT,
        fluido_de_arrefecimento_foto TEXT,
        suspensao TEXT CHECK (suspensao IN ('ok', 'not_ok')),
        suspensao_comentario TEXT,
        suspensao_foto TEXT,
        campo_assinatura TEXT,
        data_hora TEXT NOT NULL,
        sync BOOLEAN NOT NULL,
        configuracoes_id_usuario INTEGER,
        FOREIGN KEY (vehicle_id) REFERENCES veiculos (id),
        FOREIGN KEY (driver_id) REFERENCES motoristas (id),
        FOREIGN KEY (configuracoes_id_usuario) REFERENCES configuracoes (id_usuario)
      )
    ''');

    await db.execute('''
      CREATE TABLE despesa (
        id_despesa INTEGER PRIMARY KEY AUTOINCREMENT,
        valor REAL NOT NULL,
        placa TEXT NOT NULL,
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
        placa TEXT,
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

    await db.execute('''
      CREATE TABLE veiculos (
        id INTEGER PRIMARY KEY,
        placa TEXT NOT NULL UNIQUE,
        tipo TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE motoristas (
        id INTEGER PRIMARY KEY,
        nome TEXT NOT NULL
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('Migrando banco de dados da versão $oldVersion para $newVersion');
    
    if (oldVersion < 2) {
      // Adicionar coluna data_hora na tabela checklist se não existir
      try {
        await db.execute('ALTER TABLE checklist ADD COLUMN data_hora TEXT');
        await db.execute("UPDATE checklist SET data_hora = ? WHERE data_hora IS NULL", 
            [DateTime.now().toIso8601String()]);
        debugPrint('Coluna data_hora adicionada com sucesso');
      } catch (e) {
        debugPrint('Coluna data_hora já existe ou erro ao adicionar: $e');
      }
    }

    // Criar tabelas de veículos e motoristas (se não existirem)
    if (oldVersion < 3) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS veiculos (
            id INTEGER PRIMARY KEY,
            placa TEXT NOT NULL UNIQUE,
            tipo TEXT NOT NULL
          )
        ''');
        debugPrint('Tabela veiculos criada com sucesso');
      } catch (e) {
        debugPrint('Erro ao criar tabela veiculos: $e');
      }

      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS motoristas (
            id INTEGER PRIMARY KEY,
            nome TEXT NOT NULL
          )
        ''');
        debugPrint('Tabela motoristas criada com sucesso');
      } catch (e) {
        debugPrint('Erro ao criar tabela motoristas: $e');
      }

      // Recriar tabela checklist com nova estrutura
      try {
        // Verifica se a tabela antiga existe
        final result = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='checklist'"
        );
        
        if (result.isNotEmpty) {
          // Renomeia a tabela antiga
          await db.execute('ALTER TABLE checklist RENAME TO checklist_old');
          debugPrint('Tabela checklist renomeada para checklist_old');
        }
        
        // Cria a nova tabela com a estrutura atualizada
        await db.execute('''
          CREATE TABLE IF NOT EXISTS checklist (
            id_checklist INTEGER PRIMARY KEY AUTOINCREMENT,
            vehicle_id INTEGER NOT NULL,
            driver_id INTEGER NOT NULL,
            freios TEXT CHECK (freios IN ('ok', 'not_ok')),
            freios_comentario TEXT,
            pneus TEXT CHECK (pneus IN ('ok', 'not_ok')),
            pneus_comentario TEXT,
            nivel_oleo TEXT CHECK (nivel_oleo IN ('ok', 'not_ok')),
            nivel_oleo_comentario TEXT,
            farois_lanterna TEXT CHECK (farois_lanterna IN ('ok', 'not_ok')),
            farois_lanterna_comentario TEXT,
            documentacao_veiculo TEXT CHECK (documentacao_veiculo IN ('ok', 'not_ok')),
            documentacao_veiculo_comentario TEXT,
            CNH_motorista TEXT CHECK (CNH_motorista IN ('ok', 'not_ok')),
            CNH_motorista_comentario TEXT,
            limpadores_parabrisa TEXT CHECK (limpadores_parabrisa IN ('ok', 'not_ok')),
            limpadores_parabrisa_comentario TEXT,
            cintos_de_seguranca TEXT CHECK (cintos_de_seguranca IN ('ok', 'not_ok')),
            cintos_de_seguranca_comentario TEXT,
            fluido_de_arrefecimento TEXT CHECK (fluido_de_arrefecimento IN ('ok', 'not_ok')),
            fluido_de_arrefecimento_comentario TEXT,
            suspensao TEXT CHECK (suspensao IN ('ok', 'not_ok')),
            suspensao_comentario TEXT,
            campo_assinatura TEXT,
            data_hora TEXT NOT NULL,
            sync BOOLEAN NOT NULL,
            configuracoes_id_usuario INTEGER,
            FOREIGN KEY (vehicle_id) REFERENCES veiculos (id),
            FOREIGN KEY (driver_id) REFERENCES motoristas (id),
            FOREIGN KEY (configuracoes_id_usuario) REFERENCES configuracoes (id_usuario)
          )
        ''');
        debugPrint('Tabela checklist criada com nova estrutura');
        
        // Remove a tabela antiga se existir
        await db.execute('DROP TABLE IF EXISTS checklist_old');
        debugPrint('Tabela checklist_old removida');
        
        debugPrint('Migração para versão 3 concluída com sucesso');
      } catch (e) {
        debugPrint('Erro ao atualizar tabela checklist: $e');
        rethrow;
      }
    }

    // Adicionar colunas de foto aos itens do checklist
    if (oldVersion < 4) {
      debugPrint('Migrando para versão 4: Adicionando colunas de foto');
      try {
        final columns = [
          'freios_foto',
          'pneus_foto',
          'nivel_oleo_foto',
          'farois_lanterna_foto',
          'documentacao_veiculo_foto',
          'CNH_motorista_foto',
          'limpadores_parabrisa_foto',
          'cintos_de_seguranca_foto',
          'fluido_de_arrefecimento_foto',
          'suspensao_foto'
        ];

        for (final column in columns) {
          try {
            await db.execute('ALTER TABLE checklist ADD COLUMN $column TEXT');
            debugPrint('Coluna $column adicionada com sucesso');
          } catch (e) {
            debugPrint('Coluna $column já existe ou erro ao adicionar: $e');
          }
        }
        debugPrint('Migração para versão 4 concluída com sucesso');
      } catch (e) {
        debugPrint('Erro ao adicionar colunas de foto: $e');
      }
    }
  }

  Future<bool> insertApiData(Model model, Map<String, dynamic> data) async {
    try {
      debugPrint('insertApiData: Verificando conexão para $model');
      var hasInternet = await ServiceConnection.hasInternetConnection();

      if(hasInternet) {
        debugPrint('insertApiData: Internet disponível para $model');
        debugPrint('insertApiData: Sincronizando apenas o $model atual');
        
        // Carregar configurações antes de enviar dados
        await ServiceApi().loadConfigFromDatabase();
        
        // Limpar dados antes de enviar (mesma lógica da sincronização)
        Map<String, dynamic> dadosLimpos = await _serviceSync.limparDadosParaAPI(model, data);
        
        // Usar o mesmo método que a sincronização
        if (model == Model.combustivel) {
          await ServiceApi().postJsonWithAuth(model.api, dadosLimpos);
        } else {
          await ServiceApi().postFormDataWithAuth(model.api, dadosLimpos);
        }
        
        debugPrint('insertApiData: $model sincronizado com sucesso');
        return true;
      } else {
        debugPrint('insertApiData: Sem internet, salvando $model como não sincronizado');
        _serviceSync.syncedModel[model] = false;
        return false;
      }
    } catch (e) {
      _serviceSync.syncedModel[model] = false;
      debugPrint('Erro ao enviar dados para API (${model.toString()}): $e');
      return false;
    }
  }

  // Métodos para Configurações
  Future<int> insertConfiguracao(Map<String, dynamic> configuracao) async {
    try {
      final db = await instance.database;
      return await db.insert('configuracoes', configuracao);
    } catch (e) {
      debugPrint('Erro ao inserir configuração: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllConfiguracoes() async {
    try {
      final db = await instance.database;
      return await db.query('configuracoes');
    } catch (e) {
      debugPrint('Erro ao buscar todas as configurações: $e');
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
      debugPrint('Erro ao buscar configuração por ID $id: $e');
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
      debugPrint('Erro ao atualizar configuração ID $id: $e');
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
      debugPrint('Erro ao deletar configuração ID $id: $e');
      rethrow;
    }
  }

  /// Valida se existe um token válido no banco de dados
  /// Retorna true se o token existe e não está expirado
  /// Remove automaticamente tokens expirados
  Future<bool> isTokenValid() async {
    try {
      final configs = await getAllConfiguracoes();
      
      if (configs.isEmpty) {
        return false;
      }
      
      final config = configs.first;
      final dataExpiracao = DateTime.parse(config['data_expiracao']);
      final agora = DateTime.now();
      
      // Se expirado, remove do banco
      if (agora.isAfter(dataExpiracao)) {
        await deleteConfiguracao(config['id_usuario']);
        return false;
      }
      
      return true;
    } catch (e) {
      debugPrint('Erro ao validar token: $e');
      return false;
    }
  }

  Future<int> insertChecklist(Map<String, dynamic> checklist) async {
    try {
      final db = await instance.database;
      debugPrint('insertChecklist: Iniciando inserção de checklist');
      
      // Sempre salvar primeiro com sync=0
      checklist['sync'] = 0;
      final id = await db.insert('checklist', checklist);
      debugPrint('insertChecklist: Checklist inserido com ID=$id, sync=0');
      
      // Adicionar o ID ao map para sincronização
      checklist['id_checklist'] = id;
      
      // Tentar sincronizar
      try {
        final sincronizado = await insertApiData(Model.checklist, checklist);
        if (sincronizado) {
          // Atualizar para sync=1 se sincronizou
          await db.update(
            'checklist',
            {'sync': 1},
            where: 'id_checklist = ?',
            whereArgs: [id],
          );
          debugPrint('insertChecklist: Checklist ID=$id sincronizado com sucesso');
        } else {
          debugPrint('insertChecklist: Checklist ID=$id salvo localmente (sem internet)');
        }
      } catch (e) {
        debugPrint('insertChecklist: Erro ao sincronizar, mas dados salvos localmente: $e');
      }
      
      return id;
    } catch (e) {
      debugPrint('Erro ao inserir checklist: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllChecklists() async {
    try {
      final db = await instance.database;
      return await db.query('checklist');
    } catch (e) {
      debugPrint('Erro ao buscar todos os checklists: $e');
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
      debugPrint('Erro ao buscar checklist por ID $id: $e');
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
      debugPrint('Erro ao buscar checklists por placa $placa: $e');
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
      debugPrint('Erro ao atualizar checklist ID $id: $e');
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
      debugPrint('Erro ao deletar checklist ID $id: $e');
      rethrow;
    }
  }

  ///////////////////////////////////////////////Despesa///////////////////////////////////////////////
  Future<int> insertDespesa(Map<String, dynamic> despesa) async {
    try {
      final db = await instance.database;
      var asynced = await insertApiData(Model.despesa, despesa);
      despesa['sync'] = asynced ? 1 : 0;
      return await db.insert('despesa', despesa);
    } catch (e) {
      debugPrint('Erro ao inserir despesa: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllDespesas() async {
    try {
      final db = await instance.database;
      return await db.query('despesa');
    } catch (e) {
      debugPrint('Erro ao buscar todas as despesas: $e');
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
      debugPrint('Erro ao buscar despesa por ID $id: $e');
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
      debugPrint('Erro ao buscar despesas por tipo $tipo: $e');
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
      debugPrint('Erro ao buscar despesas por período $dataInicio - $dataFim: $e');
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
      debugPrint('Erro ao atualizar despesa ID $id: $e');
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
      debugPrint('Erro ao deletar despesa ID $id: $e');
      rethrow;
    }
  }

  /////////////////////////////////////////////// Abastecimento ///////////////////////////////////////////////
  Future<int> insertAbastecimento(Map<String, dynamic> abastecimento) async {
    try {
      final db = await instance.database;
      
      // Adicionar data/hora atual se não foi fornecida ou se está vazia
      if (!abastecimento.containsKey('data_hora') || 
          abastecimento['data_hora'] == null || 
          abastecimento['data_hora'].toString().isEmpty) {
        DateTime agora = DateTime.now();
        abastecimento['data_hora'] = agora.toIso8601String();
      }
      
      var asynced = await insertApiData(Model.combustivel, abastecimento);
      abastecimento['sync'] = asynced ? 1 : 0;
      return await db.insert('abastecimento', abastecimento);
    } catch (e) {
      debugPrint('Erro ao inserir abastecimento: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getLast5Abastecimentos() async {
    try {
      final db = await instance.database;
      return await db.query(
        'abastecimento',
        orderBy: 'id_abastecimento DESC',
        limit: 5,
      );
    } catch (e) {
      debugPrint('Erro ao buscar os últimos 5 abastecimentos: $e');
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
      debugPrint('Erro ao buscar abastecimento por ID $id: $e');
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
      debugPrint('Erro ao buscar abastecimentos por combustível $combustivel: $e');
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
      debugPrint('Erro ao buscar abastecimentos por período $dataInicio - $dataFim: $e');
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
      debugPrint('Erro ao atualizar abastecimento ID $id: $e');
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
      debugPrint('Erro ao deletar abastecimento ID $id: $e');
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
        whereArgs: [0],
      );
    } catch (e) {
      debugPrint('Erro ao buscar dados não sincronizados da tabela $tabela: $e');
      rethrow;
    }
  }

  Future<int> marcarComoSincronizado(String tabela, int id) async {
    try {
      final db = await instance.database;
      return await db.update(
        tabela,
        {'sync': 1},
        where: 'id_$tabela = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('Erro ao marcar como sincronizado na tabela $tabela, ID $id: $e');
      rethrow;
    }
  }

  Future close() async {
    try {
      final db = await instance.database;
      await db.close();
    } catch (e) {
      debugPrint('Erro ao fechar banco de dados: $e');
      rethrow;
    }
  }

  /////////////////////////////////////////////// Veículos ///////////////////////////////////////////////
  Future<int> insertVeiculo(Map<String, dynamic> veiculo) async {
    try {
      final db = await instance.database;
      return await db.insert('veiculos', veiculo, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      debugPrint('Erro ao inserir veículo: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllVeiculos() async {
    try {
      final db = await instance.database;
      return await db.query('veiculos');
    } catch (e) {
      debugPrint('Erro ao buscar todos os veículos: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getVeiculoByPlaca(String placa) async {
    try {
      final db = await instance.database;
      final result = await db.query(
        'veiculos',
        where: 'placa = ?',
        whereArgs: [placa.toUpperCase()],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      debugPrint('Erro ao buscar veículo por placa $placa: $e');
      rethrow;
    }
  }

  Future<void> syncVeiculosFromAPI() async {
    try {
      await ServiceApi().loadConfigFromDatabase();
      final response = await ServiceApi().getWithAuth<Map<String, dynamic>>('api_veiculos.php');
      
      if (response['status'] == 'success' && response['data'] != null) {
        final veiculos = response['data'] as List;
        for (var veiculo in veiculos) {
          await insertVeiculo({
            'id': veiculo['id'],
            'placa': veiculo['placa'].toString().toUpperCase(),
            'tipo': veiculo['tipo'],
          });
        }
        debugPrint('Veículos sincronizados com sucesso: ${veiculos.length} veículos');
      }
    } catch (e) {
      debugPrint('Erro ao sincronizar veículos da API: $e');
    }
  }

  /////////////////////////////////////////////// Motoristas ///////////////////////////////////////////////
  Future<int> insertMotorista(Map<String, dynamic> motorista) async {
    try {
      final db = await instance.database;
      return await db.insert('motoristas', motorista, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      debugPrint('Erro ao inserir motorista: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllMotoristas() async {
    try {
      final db = await instance.database;
      return await db.query('motoristas');
    } catch (e) {
      debugPrint('Erro ao buscar todos os motoristas: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getMotoristaByNome(String nome) async {
    try {
      final db = await instance.database;
      final result = await db.query(
        'motoristas',
        where: 'nome = ?',
        whereArgs: [nome],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      debugPrint('Erro ao buscar motorista por nome $nome: $e');
      rethrow;
    }
  }

  Future<void> syncMotoristasFromAPI() async {
    try {
      await ServiceApi().loadConfigFromDatabase();
      final response = await ServiceApi().getWithAuth<Map<String, dynamic>>('api_motoristas.php');
      
      if (response['status'] == 'success' && response['data'] != null) {
        final motoristas = response['data'] as List;
        for (var motorista in motoristas) {
          await insertMotorista({
            'id': motorista['id'],
            'nome': motorista['nome'],
          });
        }
        debugPrint('Motoristas sincronizados com sucesso: ${motoristas.length} motoristas');
      }
    } catch (e) {
      debugPrint('Erro ao sincronizar motoristas da API: $e');
    }
  }

  /// Sincroniza veículos e motoristas da API
  Future<void> syncVeiculosEMotoristasFromAPI() async {
    await syncVeiculosFromAPI();
    await syncMotoristasFromAPI();
  }
}
