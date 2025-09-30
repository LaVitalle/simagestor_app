import 'package:flutter_test/flutter_test.dart';
import '../lib/services/service_local_database.dart';

void main() {
  group('ServiceLocalDatabase - Testes Simples', () {
    late ServiceLocalDatabase dbService;

    setUp(() async {
      dbService = ServiceLocalDatabase.instance;
    });

    tearDown(() async {
      await dbService.close();
    });

    test('Deve inicializar o banco de dados', () async {
      final db = await dbService.database;
      expect(db, isNotNull);
      expect(db.isOpen, isTrue);
    });

    test('Deve criar tabelas corretamente', () async {
      final db = await dbService.database;
      
      // Verificar se as tabelas existem
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
        'url_empresa': 'https://teste.com',
        'data_expiracao': '2024-12-31',
      };

      final id = await dbService.insertConfiguracao(configuracao);
      expect(id, greaterThan(0));

      final configuracaoRecuperada = await dbService.getConfiguracaoById(id);
      expect(configuracaoRecuperada, isNotNull);
      expect(configuracaoRecuperada!['url_empresa'], equals('https://teste.com'));
    });

    test('Deve inserir e recuperar despesa', () async {
      final despesa = {
        'valor': 150.50,
        'observacao': 'Teste de despesa',
        'data_hora': '2024-01-15 10:30:00',
        'recorrente': 0,
        'tipo_despesa': 'Combustível',
        'configuracoes_id_usuario': 1,
        'sync': false,
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
        'sync': false,
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
        'freios': 1,
        'pneus': 1,
        'nivel_oleo': 1,
        'farois_lanterna': 1,
        'documentacao_veiculo': 1,
        'CNH_motorista': 1,
        'limpadores_parabrisa': 1,
        'cintos_de_seguranca': 1,
        'fluido_de_arrefecimento': 1,
        'suspensao': 1,
        'campo_assinatura': 'João Silva',
        'sync': false,
        'configuracoes_id_usuario': 1,
      };

      final id = await dbService.insertChecklist(checklist);
      expect(id, greaterThan(0));

      final checklistRecuperado = await dbService.getChecklistById(id);
      expect(checklistRecuperado, isNotNull);
      expect(checklistRecuperado!['placa_veiculo'], equals('ABC-1234'));
    });

    test('Deve atualizar dados corretamente', () async {
      // Inserir despesa
      final despesa = {
        'valor': 100.0,
        'observacao': 'Original',
        'data_hora': '2024-01-15 10:30:00',
        'recorrente': 0,
        'tipo_despesa': 'Geral',
        'configuracoes_id_usuario': 1,
        'sync': false,
      };

      final id = await dbService.insertDespesa(despesa);
      
      // Atualizar despesa
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
      // Inserir despesa
      final despesa = {
        'valor': 100.0,
        'observacao': 'Para deletar',
        'data_hora': '2024-01-15 10:30:00',
        'recorrente': 0,
        'tipo_despesa': 'Geral',
        'configuracoes_id_usuario': 1,
        'sync': false,
      };

      final id = await dbService.insertDespesa(despesa);
      
      // Deletar despesa
      final deleted = await dbService.deleteDespesa(id);
      expect(deleted, equals(1));

      final despesaDeletada = await dbService.getDespesaById(id);
      expect(despesaDeletada, isNull);
    });

    test('Deve buscar dados por critérios específicos', () async {
      // Inserir múltiplas despesas
      await dbService.insertDespesa({
        'valor': 100.0,
        'observacao': 'Combustível',
        'data_hora': '2024-01-15 10:30:00',
        'recorrente': 0,
        'tipo_despesa': 'Combustível',
        'configuracoes_id_usuario': 1,
        'sync': false,
      });

      await dbService.insertDespesa({
        'valor': 200.0,
        'observacao': 'Manutenção',
        'data_hora': '2024-01-15 11:30:00',
        'recorrente': 0,
        'tipo_despesa': 'Manutenção',
        'configuracoes_id_usuario': 1,
        'sync': false,
      });

      // Buscar por tipo
      final despesasCombustivel = await dbService.getDespesasByTipo('Combustível');
      expect(despesasCombustivel.length, equals(1));
      expect(despesasCombustivel.first['tipo_despesa'], equals('Combustível'));
    });

    test('Deve gerenciar sincronização', () async {
      // Inserir dados não sincronizados
      await dbService.insertDespesa({
        'valor': 100.0,
        'observacao': 'Não sincronizada',
        'data_hora': '2024-01-15 10:30:00',
        'recorrente': 0,
        'tipo_despesa': 'Geral',
        'configuracoes_id_usuario': 1,
        'sync': false,
      });

      // Buscar dados não sincronizados
      final dadosNaoSync = await dbService.getDadosNaoSincronizados('despesa');
      expect(dadosNaoSync.length, equals(1));

      // Marcar como sincronizado
      final marcado = await dbService.marcarComoSincronizado('despesa', 1);
      expect(marcado, equals(1));

      // Verificar se foi marcado
      final despesa = await dbService.getDespesaById(1);
      expect(despesa!['sync'], equals(true));
    });
  });
}
