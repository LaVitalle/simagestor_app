import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../lib/services/service_local_database.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('ServiceLocalDatabase - Testes Simples', () {
    late ServiceLocalDatabase dbService;

    setUp(() async {
      dbService = ServiceLocalDatabase.instance;
      await _clearDatabase();
    });

    test('Deve inicializar o banco de dados', () async {
      final db = await dbService.database;
      expect(db, isNotNull);
      expect(db.isOpen, isTrue);
    });

    test('Deve criar tabelas corretamente', () async {
      final db = await dbService.database;
      
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
      );
      
      final tableNames = tables.map((table) => table['name'] as String).toList();
      
      expect(tableNames, contains('configuracoes'));
      expect(tableNames, contains('checklist'));
      expect(tableNames, contains('despesa'));
      expect(tableNames, contains('abastecimento'));
    });

    test('Deve inserir e recuperar configuração', () async {
      final configuracao = {
        'id_usuario': 1,
        'url_empresa': 'https://teste.com',
        'data_expiracao': '2024-12-31',
        'token': 'token_teste_123',
        'isAdmin': 1,
      };

      final id = await dbService.insertConfiguracao(configuracao);
      expect(id, greaterThan(0));

      final configuracaoRecuperada = await dbService.getConfiguracaoById(1);
      expect(configuracaoRecuperada, isNotNull);
      expect(configuracaoRecuperada!['url_empresa'], equals('https://teste.com'));
    });

    test('Deve inserir e recuperar despesa', () async {
      final despesa = {
        'valor': 150.50,
        'placa': 'ABC-1234',
        'observacao': 'Teste de despesa',
        'data_hora': '2024-01-15 10:30:00',
        'recorrente': 0,
        'tipo_despesa': 'Combustível',
        'configuracoes_id_usuario': 1,
        'sync': 0,
      };

      final id = await dbService.insertDespesa(despesa);
      expect(id, greaterThan(0));

      final despesaRecuperada = await dbService.getDespesaById(id);
      expect(despesaRecuperada, isNotNull);
      expect(despesaRecuperada!['valor'], equals(150.50));
    });

    test('Deve inserir e recuperar abastecimento', () async {
      final abastecimento = {
        'data_hora': '2024-01-15 14:30:00',
        'km': 50000.0,
        'combustivel': 'Gasolina',
        'valor_por_litro': 5.50,
        'litros_abastecidos': 40.0,
        'total_RS': 220.0,
        'sync': 0,
        'configuracoes_id_usuario': 1,
      };

      final id = await dbService.insertAbastecimento(abastecimento);
      expect(id, greaterThan(0));

      final abastecimentoRecuperado = await dbService.getAbastecimentoById(id);
      expect(abastecimentoRecuperado, isNotNull);
      expect(abastecimentoRecuperado!['combustivel'], equals('Gasolina'));
    });

    test('Deve inserir e recuperar checklist', () async {
      final checklist = {
        'placa_veiculo': 'ABC-1234',
        'motorista': 'João Silva',
        'freios': 'ok',
        'pneus': 'ok',
        'nivel_oleo': 'ok',
        'farois_lanterna': 'ok',
        'documentacao_veiculo': 'ok',
        'CNH_motorista': 'ok',
        'limpadores_parabrisa': 'ok',
        'cintos_de_seguranca': 'ok',
        'fluido_de_arrefecimento': 'ok',
        'suspensao': 'ok',
        'campo_assinatura': 'João Silva',
        'sync': 0,
        'configuracoes_id_usuario': 1,
      };

      final id = await dbService.insertChecklist(checklist);
      expect(id, greaterThan(0));

      final checklistRecuperado = await dbService.getChecklistById(id);
      expect(checklistRecuperado, isNotNull);
      expect(checklistRecuperado!['placa_veiculo'], equals('ABC-1234'));
    });

    test('Deve atualizar dados corretamente', () async {
      final despesa = {
        'valor': 100.0,
        'placa': 'ABC-1234',
        'observacao': 'Original',
        'data_hora': '2024-01-15 10:30:00',
        'recorrente': 0,
        'tipo_despesa': 'Geral',
        'configuracoes_id_usuario': 1,
        'sync': 0,
      };

      final id = await dbService.insertDespesa(despesa);
      
      final updated = await dbService.updateDespesa(id, {
        'valor': 200.0,
        'observacao': 'Atualizada',
      });

      expect(updated, equals(1));

      final despesaAtualizada = await dbService.getDespesaById(id);
      expect(despesaAtualizada!['valor'], equals(200.0));
      expect(despesaAtualizada['observacao'], equals('Atualizada'));
    });

    test('Deve deletar dados corretamente', () async {
      final despesa = {
        'valor': 100.0,
        'placa': 'ABC-1234',
        'observacao': 'Para deletar',
        'data_hora': '2024-01-15 10:30:00',
        'recorrente': 0,
        'tipo_despesa': 'Geral',
        'configuracoes_id_usuario': 1,
        'sync': 0,
      };

      final id = await dbService.insertDespesa(despesa);
      
      final deleted = await dbService.deleteDespesa(id);
      expect(deleted, equals(1));

      final despesaDeletada = await dbService.getDespesaById(id);
      expect(despesaDeletada, isNull);
    });

    test('Deve buscar dados por critérios específicos', () async {
      await dbService.insertDespesa({
        'valor': 100.0,
        'placa': 'ABC-1234',
        'observacao': 'Combustível',
        'data_hora': '2024-01-15 10:30:00',
        'recorrente': 0,
        'tipo_despesa': 'Combustível',
        'configuracoes_id_usuario': 1,
        'sync': 0,
      });

      await dbService.insertDespesa({
        'valor': 200.0,
        'placa': 'ABC-1234',
        'observacao': 'Manutenção',
        'data_hora': '2024-01-15 11:30:00',
        'recorrente': 0,
        'tipo_despesa': 'Manutenção',
        'configuracoes_id_usuario': 1,
        'sync': 0,
      });

      final despesasCombustivel = await dbService.getDespesasByTipo('Combustível');
      expect(despesasCombustivel.length, equals(1));
      expect(despesasCombustivel.first['tipo_despesa'], equals('Combustível'));
    });

    test('Deve gerenciar sincronização', () async {
      final id = await dbService.insertDespesa({
        'valor': 100.0,
        'placa': 'ABC-1234',
        'observacao': 'Não sincronizada',
        'data_hora': '2024-01-15 10:30:00',
        'recorrente': 0,
        'tipo_despesa': 'Geral',
        'configuracoes_id_usuario': 1,
        'sync': 0,
      });

      final dadosNaoSync = await dbService.getDadosNaoSincronizados('despesa');
      expect(dadosNaoSync.length, greaterThanOrEqualTo(1));

      final marcado = await dbService.marcarComoSincronizado('despesa', id);
      expect(marcado, equals(1));

      final despesa = await dbService.getDespesaById(id);
      expect(despesa!['sync'], equals(1));
    });
  });
}

Future<void> _clearDatabase() async {
  final db = await ServiceLocalDatabase.instance.database;
  await db.delete('abastecimento');
  await db.delete('despesa');
  await db.delete('checklist');
  await db.delete('configuracoes');
}
