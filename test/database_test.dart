import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../lib/services/service_local_database.dart';

void main() {
  // Configuração para testes
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('ServiceLocalDatabase Tests', () {
    late ServiceLocalDatabase dbService;

    setUp(() async {
      dbService = ServiceLocalDatabase.instance;
      // Limpar banco antes de cada teste
      await _clearDatabase();
    });

    tearDown(() async {
      await dbService.close();
    });

    // ==================== TESTES PARA CONFIGURAÇÕES ====================
    group('Configurações Tests', () {
      test('Deve inserir configuração com sucesso', () async {
        final configuracao = {
          'url_empresa': 'https://empresa.com',
          'data_expiracao': '2024-12-31',
        };

        final id = await dbService.insertConfiguracao(configuracao);
        expect(id, greaterThan(0));
      });

      test('Deve buscar todas as configurações', () async {
        // Inserir dados de teste
        await dbService.insertConfiguracao({
          'url_empresa': 'https://empresa1.com',
          'data_expiracao': '2024-12-31',
        });
        await dbService.insertConfiguracao({
          'url_empresa': 'https://empresa2.com',
          'data_expiracao': '2025-01-31',
        });

        final configuracoes = await dbService.getAllConfiguracoes();
        expect(configuracoes.length, equals(2));
      });

      test('Deve buscar configuração por ID', () async {
        await dbService.insertConfiguracao({
          'url_empresa': 'https://teste.com',
          'data_expiracao': '2024-12-31',
        });

        final configuracao = await dbService.getConfiguracaoById(1);
        expect(configuracao, isNotNull);
        expect(configuracao!['url_empresa'], equals('https://teste.com'));
      });

      test('Deve atualizar configuração', () async {
        await dbService.insertConfiguracao({
          'url_empresa': 'https://original.com',
          'data_expiracao': '2024-12-31',
        });

        final updated = await dbService.updateConfiguracao(1, {
          'url_empresa': 'https://atualizada.com',
          'data_expiracao': '2025-01-31',
        });

        expect(updated, equals(1));

        final configuracao = await dbService.getConfiguracaoById(1);
        expect(configuracao!['url_empresa'], equals('https://atualizada.com'));
      });

      test('Deve deletar configuração', () async {
        await dbService.insertConfiguracao({
          'url_empresa': 'https://deletar.com',
          'data_expiracao': '2024-12-31',
        });

        final deleted = await dbService.deleteConfiguracao(1);
        expect(deleted, equals(1));

        final configuracao = await dbService.getConfiguracaoById(1);
        expect(configuracao, isNull);
      });

      test('Deve retornar null para ID inexistente', () async {
        final configuracao = await dbService.getConfiguracaoById(999);
        expect(configuracao, isNull);
      });
    });

    // ==================== TESTES PARA CHECKLIST ====================
    group('Checklist Tests', () {
      test('Deve inserir checklist com sucesso', () async {
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
      });

      test('Deve buscar checklists por placa', () async {
        await dbService.insertChecklist({
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
        });

        final checklists = await dbService.getChecklistsByPlaca('ABC-1234');
        expect(checklists.length, equals(1));
        expect(checklists.first['placa_veiculo'], equals('ABC-1234'));
      });

      test('Deve atualizar checklist', () async {
        await dbService.insertChecklist({
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
        });

        final updated = await dbService.updateChecklist(1, {
          'motorista': 'Maria Santos',
          'campo_assinatura': 'Maria Santos',
        });

        expect(updated, equals(1));

        final checklist = await dbService.getChecklistById(1);
        expect(checklist!['motorista'], equals('Maria Santos'));
      });

      test('Deve deletar checklist', () async {
        await dbService.insertChecklist({
          'placa_veiculo': 'XYZ-9876',
          'motorista': 'Pedro Costa',
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
          'campo_assinatura': 'Pedro Costa',
          'sync': false,
          'configuracoes_id_usuario': 1,
        });

        final deleted = await dbService.deleteChecklist(1);
        expect(deleted, equals(1));

        final checklist = await dbService.getChecklistById(1);
        expect(checklist, isNull);
      });
    });

    // ==================== TESTES PARA DESPESAS ====================
    group('Despesas Tests', () {
      test('Deve inserir despesa com sucesso', () async {
        final despesa = {
          'valor': 150.50,
          'observacao': 'Combustível',
          'data_hora': '2024-01-15 10:30:00',
          'recorrente': 0,
          'tipo_despesa': 'Combustível',
          'configuracoes_id_usuario': 1,
          'sync': false,
        };

        final id = await dbService.insertDespesa(despesa);
        expect(id, greaterThan(0));
      });

      test('Deve buscar despesas por tipo', () async {
        await dbService.insertDespesa({
          'valor': 100.0,
          'observacao': 'Manutenção',
          'data_hora': '2024-01-15 10:30:00',
          'recorrente': 0,
          'tipo_despesa': 'Manutenção',
          'configuracoes_id_usuario': 1,
          'sync': false,
        });

        await dbService.insertDespesa({
          'valor': 200.0,
          'observacao': 'Combustível',
          'data_hora': '2024-01-15 11:30:00',
          'recorrente': 0,
          'tipo_despesa': 'Combustível',
          'configuracoes_id_usuario': 1,
          'sync': false,
        });

        final despesasManutencao = await dbService.getDespesasByTipo('Manutenção');
        expect(despesasManutencao.length, equals(1));
        expect(despesasManutencao.first['tipo_despesa'], equals('Manutenção'));
      });

      test('Deve buscar despesas por período', () async {
        await dbService.insertDespesa({
          'valor': 100.0,
          'observacao': 'Despesa Janeiro',
          'data_hora': '2024-01-15 10:30:00',
          'recorrente': 0,
          'tipo_despesa': 'Geral',
          'configuracoes_id_usuario': 1,
          'sync': false,
        });

        await dbService.insertDespesa({
          'valor': 200.0,
          'observacao': 'Despesa Fevereiro',
          'data_hora': '2024-02-15 10:30:00',
          'recorrente': 0,
          'tipo_despesa': 'Geral',
          'configuracoes_id_usuario': 1,
          'sync': false,
        });

        final despesasJaneiro = await dbService.getDespesasByPeriodo(
          '2024-01-01 00:00:00',
          '2024-01-31 23:59:59',
        );
        expect(despesasJaneiro.length, equals(1));
        expect(despesasJaneiro.first['observacao'], equals('Despesa Janeiro'));
      });

      test('Deve atualizar despesa', () async {
        await dbService.insertDespesa({
          'valor': 100.0,
          'observacao': 'Original',
          'data_hora': '2024-01-15 10:30:00',
          'recorrente': 0,
          'tipo_despesa': 'Geral',
          'configuracoes_id_usuario': 1,
          'sync': false,
        });

        final updated = await dbService.updateDespesa(1, {
          'valor': 150.0,
          'observacao': 'Atualizada',
        });

        expect(updated, equals(1));

        final despesa = await dbService.getDespesaById(1);
        expect(despesa!['valor'], equals(150.0));
        expect(despesa['observacao'], equals('Atualizada'));
      });

      test('Deve deletar despesa', () async {
        await dbService.insertDespesa({
          'valor': 100.0,
          'observacao': 'Para deletar',
          'data_hora': '2024-01-15 10:30:00',
          'recorrente': 0,
          'tipo_despesa': 'Geral',
          'configuracoes_id_usuario': 1,
          'sync': false,
        });

        final deleted = await dbService.deleteDespesa(1);
        expect(deleted, equals(1));

        final despesa = await dbService.getDespesaById(1);
        expect(despesa, isNull);
      });
    });

    // ==================== TESTES PARA ABASTECIMENTOS ====================
    group('Abastecimentos Tests', () {
      test('Deve inserir abastecimento com sucesso', () async {
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
      });

      test('Deve buscar abastecimentos por combustível', () async {
        await dbService.insertAbastecimento({
          'data_hora': '2024-01-15 14:30:00',
          'km': 50000.0,
          'combustivel': 'Gasolina',
          'valor_por_litro': 5.50,
          'litros_abastecidos': 40.0,
          'total_RS': 220.0,
          'sync': false,
          'configuracoes_id_usuario': 1,
        });

        await dbService.insertAbastecimento({
          'data_hora': '2024-01-16 14:30:00',
          'km': 50100.0,
          'combustivel': 'Diesel',
          'valor_por_litro': 4.50,
          'litros_abastecidos': 50.0,
          'total_RS': 225.0,
          'sync': false,
          'configuracoes_id_usuario': 1,
        });

        final abastecimentosGasolina = await dbService.getAbastecimentosByCombustivel('Gasolina');
        expect(abastecimentosGasolina.length, equals(1));
        expect(abastecimentosGasolina.first['combustivel'], equals('Gasolina'));
      });

      test('Deve buscar abastecimentos por período', () async {
        await dbService.insertAbastecimento({
          'data_hora': '2024-01-15 14:30:00',
          'km': 50000.0,
          'combustivel': 'Gasolina',
          'valor_por_litro': 5.50,
          'litros_abastecidos': 40.0,
          'total_RS': 220.0,
          'sync': false,
          'configuracoes_id_usuario': 1,
        });

        await dbService.insertAbastecimento({
          'data_hora': '2024-02-15 14:30:00',
          'km': 50500.0,
          'combustivel': 'Gasolina',
          'valor_por_litro': 5.60,
          'litros_abastecidos': 35.0,
          'total_RS': 196.0,
          'sync': false,
          'configuracoes_id_usuario': 1,
        });

        final abastecimentosJaneiro = await dbService.getAbastecimentosByPeriodo(
          '2024-01-01 00:00:00',
          '2024-01-31 23:59:59',
        );
        expect(abastecimentosJaneiro.length, equals(1));
      });

      test('Deve atualizar abastecimento', () async {
        await dbService.insertAbastecimento({
          'data_hora': '2024-01-15 14:30:00',
          'km': 50000.0,
          'combustivel': 'Gasolina',
          'valor_por_litro': 5.50,
          'litros_abastecidos': 40.0,
          'total_RS': 220.0,
          'sync': false,
          'configuracoes_id_usuario': 1,
        });

        final updated = await dbService.updateAbastecimento(1, {
          'valor_por_litro': 5.60,
          'total_RS': 224.0,
        });

        expect(updated, equals(1));

        final abastecimento = await dbService.getAbastecimentoById(1);
        expect(abastecimento!['valor_por_litro'], equals(5.60));
        expect(abastecimento['total_RS'], equals(224.0));
      });

      test('Deve deletar abastecimento', () async {
        await dbService.insertAbastecimento({
          'data_hora': '2024-01-15 14:30:00',
          'km': 50000.0,
          'combustivel': 'Gasolina',
          'valor_por_litro': 5.50,
          'litros_abastecidos': 40.0,
          'total_RS': 220.0,
          'sync': false,
          'configuracoes_id_usuario': 1,
        });

        final deleted = await dbService.deleteAbastecimento(1);
        expect(deleted, equals(1));

        final abastecimento = await dbService.getAbastecimentoById(1);
        expect(abastecimento, isNull);
      });
    });

    // ==================== TESTES PARA SINCRONIZAÇÃO ====================
    group('Sincronização Tests', () {
      test('Deve buscar dados não sincronizados', () async {
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

        await dbService.insertDespesa({
          'valor': 200.0,
          'observacao': 'Sincronizada',
          'data_hora': '2024-01-15 11:30:00',
          'recorrente': 0,
          'tipo_despesa': 'Geral',
          'configuracoes_id_usuario': 1,
          'sync': true,
        });

        final dadosNaoSync = await dbService.getDadosNaoSincronizados('despesa');
        expect(dadosNaoSync.length, equals(1));
        expect(dadosNaoSync.first['observacao'], equals('Não sincronizada'));
      });

      test('Deve marcar como sincronizado', () async {
        await dbService.insertDespesa({
          'valor': 100.0,
          'observacao': 'Para sincronizar',
          'data_hora': '2024-01-15 10:30:00',
          'recorrente': 0,
          'tipo_despesa': 'Geral',
          'configuracoes_id_usuario': 1,
          'sync': false,
        });

        final marcado = await dbService.marcarComoSincronizado('despesa', 1);
        expect(marcado, equals(1));

        final despesa = await dbService.getDespesaById(1);
        expect(despesa!['sync'], equals(true));
      });
    });

    // ==================== TESTES DE CENÁRIOS EXTREMOS ====================
    group('Cenários Extremos', () {
      test('Deve lidar com dados nulos', () async {
        final despesa = {
          'valor': 100.0,
          'observacao': null,
          'data_hora': '2024-01-15 10:30:00',
          'recorrente': 0,
          'tipo_despesa': 'Geral',
          'configuracoes_id_usuario': 1,
          'sync': false,
        };

        final id = await dbService.insertDespesa(despesa);
        expect(id, greaterThan(0));
      });

      test('Deve lidar com valores muito grandes', () async {
        final despesa = {
          'valor': 999999999.99,
          'observacao': 'Valor muito grande',
          'data_hora': '2024-01-15 10:30:00',
          'recorrente': 0,
          'tipo_despesa': 'Geral',
          'configuracoes_id_usuario': 1,
          'sync': false,
        };

        final id = await dbService.insertDespesa(despesa);
        expect(id, greaterThan(0));

        final despesaRecuperada = await dbService.getDespesaById(id);
        expect(despesaRecuperada!['valor'], equals(999999999.99));
      });

      test('Deve lidar com strings muito longas', () async {
        final observacaoLonga = 'A' * 1000; // String de 1000 caracteres
        
        final despesa = {
          'valor': 100.0,
          'observacao': observacaoLonga,
          'data_hora': '2024-01-15 10:30:00',
          'recorrente': 0,
          'tipo_despesa': 'Geral',
          'configuracoes_id_usuario': 1,
          'sync': false,
        };

        final id = await dbService.insertDespesa(despesa);
        expect(id, greaterThan(0));

        final despesaRecuperada = await dbService.getDespesaById(id);
        expect(despesaRecuperada!['observacao'], equals(observacaoLonga));
      });

      test('Deve lidar com operações em lote', () async {
        // Inserir múltiplas despesas
        for (int i = 0; i < 100; i++) {
          await dbService.insertDespesa({
            'valor': 100.0 + i,
            'observacao': 'Despesa $i',
            'data_hora': '2024-01-15 10:30:00',
            'recorrente': 0,
            'tipo_despesa': 'Geral',
            'configuracoes_id_usuario': 1,
            'sync': false,
          });
        }

        final todasDespesas = await dbService.getAllDespesas();
        expect(todasDespesas.length, equals(100));
      });

      test('Deve lidar com atualizações de registros inexistentes', () async {
        final updated = await dbService.updateDespesa(999, {
          'valor': 200.0,
        });
        expect(updated, equals(0));
      });

      test('Deve lidar com deleções de registros inexistentes', () async {
        final deleted = await dbService.deleteDespesa(999);
        expect(deleted, equals(0));
      });
    });

    // ==================== TESTES DE INTEGRIDADE REFERENCIAL ====================
    group('Integridade Referencial', () {
      test('Deve manter integridade com chaves estrangeiras', () async {
        // Primeiro inserir configuração
        await dbService.insertConfiguracao({
          'url_empresa': 'https://teste.com',
          'data_expiracao': '2024-12-31',
        });

        // Depois inserir despesa referenciando a configuração
        final despesa = {
          'valor': 100.0,
          'observacao': 'Teste integridade',
          'data_hora': '2024-01-15 10:30:00',
          'recorrente': 0,
          'tipo_despesa': 'Geral',
          'configuracoes_id_usuario': 1,
          'sync': false,
        };

        final id = await dbService.insertDespesa(despesa);
        expect(id, greaterThan(0));

        final despesaRecuperada = await dbService.getDespesaById(id);
        expect(despesaRecuperada!['configuracoes_id_usuario'], equals(1));
      });
    });
  });
}

// Função auxiliar para limpar o banco de dados
Future<void> _clearDatabase() async {
  final db = await ServiceLocalDatabase.instance.database;
  await db.delete('abastecimento');
  await db.delete('despesa');
  await db.delete('checklist');
  await db.delete('configuracoes');
}
