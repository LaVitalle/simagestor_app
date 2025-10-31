import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:simagestor_app/services/service_local_database.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('ServiceLocalDatabase Tests', () {
    late ServiceLocalDatabase dbService;

    setUp(() async {
      dbService = ServiceLocalDatabase.instance;
      await _clearDatabase();
    });

    group('Configurações Tests', () {
      test('Deve inserir configuração com sucesso', () async {
        final configuracao = {
          'id_usuario': 1,
          'url_empresa': 'https://empresa.com',
          'data_expiracao': '2024-12-31',
          'token': 'token_teste_123',
          'isAdmin': 1,
        };

        final id = await dbService.insertConfiguracao(configuracao);
        expect(id, greaterThan(0));
      });

      test('Deve buscar todas as configurações', () async {
        await dbService.insertConfiguracao({
          'id_usuario': 1,
          'url_empresa': 'https://empresa1.com',
          'data_expiracao': '2024-12-31',
          'token': 'token1',
          'isAdmin': 0,
        });
        await dbService.insertConfiguracao({
          'id_usuario': 2,
          'url_empresa': 'https://empresa2.com',
          'data_expiracao': '2025-01-31',
          'token': 'token2',
          'isAdmin': 1,
        });

        final configuracoes = await dbService.getAllConfiguracoes();
        expect(configuracoes.length, equals(2));
      });

      test('Deve buscar configuração por ID', () async {
        await dbService.insertConfiguracao({
          'id_usuario': 1,
          'url_empresa': 'https://teste.com',
          'data_expiracao': '2024-12-31',
          'token': 'token_teste',
          'isAdmin': 0,
        });

        final configuracao = await dbService.getConfiguracaoById(1);
        expect(configuracao, isNotNull);
        expect(configuracao!['url_empresa'], equals('https://teste.com'));
      });

      test('Deve atualizar configuração', () async {
        await dbService.insertConfiguracao({
          'id_usuario': 1,
          'url_empresa': 'https://original.com',
          'data_expiracao': '2024-12-31',
          'token': 'token_original',
          'isAdmin': 0,
        });

        final updated = await dbService.updateConfiguracao(1, {
          'id_usuario': 1,
          'url_empresa': 'https://atualizada.com',
          'data_expiracao': '2025-01-31',
          'token': 'token_atualizado',
          'isAdmin': 1,
        });

        expect(updated, equals(1));

        final configuracao = await dbService.getConfiguracaoById(1);
        expect(configuracao!['url_empresa'], equals('https://atualizada.com'));
      });

      test('Deve deletar configuração', () async {
        await dbService.insertConfiguracao({
          'id_usuario': 1,
          'url_empresa': 'https://deletar.com',
          'data_expiracao': '2024-12-31',
          'token': 'token_deletar',
          'isAdmin': 0,
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

    group('Despesas Tests', () {
      test('Deve inserir despesa com sucesso', () async {
        final despesa = {
          'valor': 150.50,
          'placa': 'ABC-1234',
          'observacao': 'Combustível',
          'data_hora': '2024-01-15 10:30:00',
          'recorrente': 0,
          'tipo_despesa': 'Combustível',
          'configuracoes_id_usuario': 1,
          'sync': 0,
        };

        final id = await dbService.insertDespesa(despesa);
        expect(id, greaterThan(0));
      });

      test('Deve buscar despesas por tipo', () async {
        await dbService.insertDespesa({
          'valor': 100.0,
          'placa': 'ABC-1234',
          'observacao': 'Manutenção',
          'data_hora': '2024-01-15 10:30:00',
          'recorrente': 0,
          'tipo_despesa': 'Manutenção',
          'configuracoes_id_usuario': 1,
          'sync': 0,
        });

        await dbService.insertDespesa({
          'valor': 200.0,
          'placa': 'XYZ-5678',
          'observacao': 'Combustível',
          'data_hora': '2024-01-15 11:30:00',
          'recorrente': 0,
          'tipo_despesa': 'Combustível',
          'configuracoes_id_usuario': 1,
          'sync': 0,
        });

        final despesasManutencao = await dbService.getDespesasByTipo('Manutenção');
        expect(despesasManutencao.length, equals(1));
        expect(despesasManutencao.first['tipo_despesa'], equals('Manutenção'));
      });

      test('Deve buscar despesas por período', () async {
        await dbService.insertDespesa({
          'valor': 100.0,
          'placa': 'ABC-1234',
          'observacao': 'Despesa Janeiro',
          'data_hora': '2024-01-15 10:30:00',
          'recorrente': 0,
          'tipo_despesa': 'Geral',
          'configuracoes_id_usuario': 1,
          'sync': 0,
        });

        await dbService.insertDespesa({
          'valor': 200.0,
          'placa': 'ABC-1234',
          'observacao': 'Despesa Fevereiro',
          'data_hora': '2024-02-15 10:30:00',
          'recorrente': 0,
          'tipo_despesa': 'Geral',
          'configuracoes_id_usuario': 1,
          'sync': 0,
        });

        final despesasJaneiro = await dbService.getDespesasByPeriodo(
          '2024-01-01 00:00:00',
          '2024-01-31 23:59:59',
        );
        expect(despesasJaneiro.length, equals(1));
        expect(despesasJaneiro.first['observacao'], equals('Despesa Janeiro'));
      });

      test('Deve atualizar despesa', () async {
        final id = await dbService.insertDespesa({
          'valor': 100.0,
          'placa': 'ABC-1234',
          'observacao': 'Original',
          'data_hora': '2024-01-15 10:30:00',
          'recorrente': 0,
          'tipo_despesa': 'Geral',
          'configuracoes_id_usuario': 1,
          'sync': 0,
        });

        final updated = await dbService.updateDespesa(id, {
          'valor': 150.0,
          'observacao': 'Atualizada',
        });

        expect(updated, equals(1));

        final despesa = await dbService.getDespesaById(id);
        expect(despesa!['valor'], equals(150.0));
        expect(despesa['observacao'], equals('Atualizada'));
      });

      test('Deve deletar despesa', () async {
        final id = await dbService.insertDespesa({
          'valor': 100.0,
          'placa': 'ABC-1234',
          'observacao': 'Para deletar',
          'data_hora': '2024-01-15 10:30:00',
          'recorrente': 0,
          'tipo_despesa': 'Geral',
          'configuracoes_id_usuario': 1,
          'sync': 0,
        });

        final deleted = await dbService.deleteDespesa(id);
        expect(deleted, equals(1));

        final despesa = await dbService.getDespesaById(id);
        expect(despesa, isNull);
      });
    });

    group('Abastecimentos Tests', () {
      test('Deve inserir abastecimento com sucesso', () async {
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
      });

      test('Deve buscar abastecimentos por combustível', () async {
        await dbService.insertAbastecimento({
          'data_hora': '2024-01-15 14:30:00',
          'km': 50000.0,
          'combustivel': 'Gasolina',
          'valor_por_litro': 5.50,
          'litros_abastecidos': 40.0,
          'total_RS': 220.0,
          'sync': 0,
          'configuracoes_id_usuario': 1,
        });

        await dbService.insertAbastecimento({
          'data_hora': '2024-01-16 14:30:00',
          'km': 50100.0,
          'combustivel': 'Diesel',
          'valor_por_litro': 4.50,
          'litros_abastecidos': 50.0,
          'total_RS': 225.0,
          'sync': 0,
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
          'sync': 0,
          'configuracoes_id_usuario': 1,
        });

        await dbService.insertAbastecimento({
          'data_hora': '2024-02-15 14:30:00',
          'km': 50500.0,
          'combustivel': 'Gasolina',
          'valor_por_litro': 5.60,
          'litros_abastecidos': 35.0,
          'total_RS': 196.0,
          'sync': 0,
          'configuracoes_id_usuario': 1,
        });

        final abastecimentosJaneiro = await dbService.getAbastecimentosByPeriodo(
          '2024-01-01 00:00:00',
          '2024-01-31 23:59:59',
        );
        expect(abastecimentosJaneiro.length, equals(1));
      });

      test('Deve atualizar abastecimento', () async {
        final id = await dbService.insertAbastecimento({
          'data_hora': '2024-01-15 14:30:00',
          'km': 50000.0,
          'combustivel': 'Gasolina',
          'valor_por_litro': 5.50,
          'litros_abastecidos': 40.0,
          'total_RS': 220.0,
          'sync': 0,
          'configuracoes_id_usuario': 1,
        });

        final updated = await dbService.updateAbastecimento(id, {
          'valor_por_litro': 5.60,
          'total_RS': 224.0,
        });

        expect(updated, equals(1));

        final abastecimento = await dbService.getAbastecimentoById(id);
        expect(abastecimento!['valor_por_litro'], equals(5.60));
        expect(abastecimento['total_RS'], equals(224.0));
      });

      test('Deve deletar abastecimento', () async {
        final id = await dbService.insertAbastecimento({
          'data_hora': '2024-01-15 14:30:00',
          'km': 50000.0,
          'combustivel': 'Gasolina',
          'valor_por_litro': 5.50,
          'litros_abastecidos': 40.0,
          'total_RS': 220.0,
          'sync': 0,
          'configuracoes_id_usuario': 1,
        });

        final deleted = await dbService.deleteAbastecimento(id);
        expect(deleted, equals(1));

        final abastecimento = await dbService.getAbastecimentoById(id);
        expect(abastecimento, isNull);
      });
    });

    group('Sincronização Tests', () {
      test('Deve buscar dados não sincronizados', () async {
        await dbService.insertDespesa({
          'valor': 100.0,
          'placa': 'ABC-1234',
          'observacao': 'Não sincronizada',
          'data_hora': '2024-01-15 10:30:00',
          'recorrente': 0,
          'tipo_despesa': 'Geral',
          'configuracoes_id_usuario': 1,
          'sync': 0,
        });

        await dbService.insertDespesa({
          'valor': 200.0,
          'placa': 'ABC-1234',
          'observacao': 'Sincronizada',
          'data_hora': '2024-01-15 11:30:00',
          'recorrente': 0,
          'tipo_despesa': 'Geral',
          'configuracoes_id_usuario': 1,
          'sync': 1,
        });

        final dadosNaoSync = await dbService.getDadosNaoSincronizados('despesa');
        expect(dadosNaoSync.length, greaterThanOrEqualTo(1));
      });

      test('Deve marcar como sincronizado', () async {
        final id = await dbService.insertDespesa({
          'valor': 100.0,
          'placa': 'ABC-1234',
          'observacao': 'Para sincronizar',
          'data_hora': '2024-01-15 10:30:00',
          'recorrente': 0,
          'tipo_despesa': 'Geral',
          'configuracoes_id_usuario': 1,
          'sync': 0,
        });

        final marcado = await dbService.marcarComoSincronizado('despesa', id);
        expect(marcado, equals(1));

        final despesa = await dbService.getDespesaById(id);
        expect(despesa!['sync'], equals(1));
      });
    });

    group('Cenários Extremos', () {
      test('Deve lidar com dados nulos opcionais', () async {
        final despesa = {
          'valor': 100.0,
          'placa': 'ABC-1234',
          'observacao': null,
          'data_hora': '2024-01-15 10:30:00',
          'recorrente': 0,
          'tipo_despesa': 'Geral',
          'configuracoes_id_usuario': 1,
          'sync': 0,
        };

        final id = await dbService.insertDespesa(despesa);
        expect(id, greaterThan(0));
      });

      test('Deve lidar com valores muito grandes', () async {
        final despesa = {
          'valor': 999999999.99,
          'placa': 'ABC-1234',
          'observacao': 'Valor muito grande',
          'data_hora': '2024-01-15 10:30:00',
          'recorrente': 0,
          'tipo_despesa': 'Geral',
          'configuracoes_id_usuario': 1,
          'sync': 0,
        };

        final id = await dbService.insertDespesa(despesa);
        expect(id, greaterThan(0));

        final despesaRecuperada = await dbService.getDespesaById(id);
        expect(despesaRecuperada!['valor'], equals(999999999.99));
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
  });
}

Future<void> _clearDatabase() async {
  final db = await ServiceLocalDatabase.instance.database;
  await db.delete('abastecimento');
  await db.delete('despesa');
  await db.delete('checklist');
  await db.delete('configuracoes');
}
