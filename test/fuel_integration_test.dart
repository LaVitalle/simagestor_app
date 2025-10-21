import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:simagestor_app/services/service_local_database.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Fuel Integration Tests - Banco de Dados', () {
    late ServiceLocalDatabase database;

    setUp(() async {
      database = ServiceLocalDatabase.instance;
      await _clearDatabase();
    });

    group('CRUD de Abastecimento', () {
      test('Deve inserir novo abastecimento', () async {
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

        final id = await database.insertAbastecimento(abastecimento);

        expect(id, greaterThan(0));

        final result = await database.getAbastecimentoById(id);
        expect(result, isNotNull);
        expect(result!['combustivel'], 'Gasolina');
        expect(result['valor_por_litro'], 5.50);
      });

      test('Deve buscar abastecimento por ID', () async {
        final abastecimento = {
          'data_hora': '2024-01-15 14:30:00',
          'km': 50000.0,
          'combustivel': 'Diesel',
          'valor_por_litro': 4.50,
          'litros_abastecidos': 50.0,
          'total_RS': 225.0,
          'sync': 0,
          'configuracoes_id_usuario': 1,
        };

        final id = await database.insertAbastecimento(abastecimento);
        final result = await database.getAbastecimentoById(id);

        expect(result, isNotNull);
        expect(result!['id_abastecimento'], id);
        expect(result['combustivel'], 'Diesel');
      });

      test('Deve retornar null para ID inexistente', () async {
        final result = await database.getAbastecimentoById(999);

        expect(result, isNull);
      });

      test('Deve atualizar abastecimento existente', () async {
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

        final id = await database.insertAbastecimento(abastecimento);

        final updated = await database.updateAbastecimento(id, {
          'valor_por_litro': 5.75,
          'total_RS': 230.0,
        });

        expect(updated, 1);

        final result = await database.getAbastecimentoById(id);
        expect(result!['valor_por_litro'], 5.75);
        expect(result['total_RS'], 230.0);
      });

      test('Deve deletar abastecimento', () async {
        final abastecimento = {
          'data_hora': '2024-01-15 14:30:00',
          'km': 50000.0,
          'combustivel': 'Etanol',
          'valor_por_litro': 3.80,
          'litros_abastecidos': 35.0,
          'total_RS': 133.0,
          'sync': 0,
          'configuracoes_id_usuario': 1,
        };

        final id = await database.insertAbastecimento(abastecimento);
        final deleted = await database.deleteAbastecimento(id);

        expect(deleted, 1);

        final result = await database.getAbastecimentoById(id);
        expect(result, isNull);
      });
    });

    group('Busca de Abastecimentos', () {
      test('Deve buscar últimos 5 abastecimentos', () async {
        for (int i = 0; i < 7; i++) {
          await database.insertAbastecimento({
            'data_hora': DateTime.now().subtract(Duration(days: i)).toIso8601String(),
            'km': 50000.0 + (i * 100),
            'combustivel': 'Gasolina',
            'valor_por_litro': 5.50,
            'litros_abastecidos': 40.0,
            'total_RS': 220.0,
            'sync': 0,
            'configuracoes_id_usuario': 1,
          });
        }

        final results = await database.getLast5Abastecimentos();

        expect(results.length, 5);
      });

      test('Deve buscar abastecimentos por tipo de combustível', () async {
        await database.insertAbastecimento({
          'data_hora': '2024-01-15 14:30:00',
          'km': 50000.0,
          'combustivel': 'Gasolina',
          'valor_por_litro': 5.50,
          'litros_abastecidos': 40.0,
          'total_RS': 220.0,
          'sync': 0,
          'configuracoes_id_usuario': 1,
        });

        await database.insertAbastecimento({
          'data_hora': '2024-01-16 14:30:00',
          'km': 50100.0,
          'combustivel': 'Diesel',
          'valor_por_litro': 4.50,
          'litros_abastecidos': 50.0,
          'total_RS': 225.0,
          'sync': 0,
          'configuracoes_id_usuario': 1,
        });

        await database.insertAbastecimento({
          'data_hora': '2024-01-17 14:30:00',
          'km': 50200.0,
          'combustivel': 'Gasolina',
          'valor_por_litro': 5.60,
          'litros_abastecidos': 35.0,
          'total_RS': 196.0,
          'sync': 0,
          'configuracoes_id_usuario': 1,
        });

        final gasolina = await database.getAbastecimentosByCombustivel('Gasolina');
        final diesel = await database.getAbastecimentosByCombustivel('Diesel');

        expect(gasolina.length, 2);
        expect(diesel.length, 1);
      });

      test('Deve buscar abastecimentos por período', () async {
        await database.insertAbastecimento({
          'data_hora': '2024-01-15 14:30:00',
          'km': 50000.0,
          'combustivel': 'Gasolina',
          'valor_por_litro': 5.50,
          'litros_abastecidos': 40.0,
          'total_RS': 220.0,
          'sync': 0,
          'configuracoes_id_usuario': 1,
        });

        await database.insertAbastecimento({
          'data_hora': '2024-02-15 14:30:00',
          'km': 50500.0,
          'combustivel': 'Gasolina',
          'valor_por_litro': 5.60,
          'litros_abastecidos': 35.0,
          'total_RS': 196.0,
          'sync': 0,
          'configuracoes_id_usuario': 1,
        });

        final janeiro = await database.getAbastecimentosByPeriodo(
          '2024-01-01 00:00:00',
          '2024-01-31 23:59:59',
        );

        expect(janeiro.length, 1);
        expect(janeiro.first['data_hora'], contains('2024-01'));
      });

      test('Deve retornar vazio quando não há abastecimentos no período', () async {
        await database.insertAbastecimento({
          'data_hora': '2024-01-15 14:30:00',
          'km': 50000.0,
          'combustivel': 'Gasolina',
          'valor_por_litro': 5.50,
          'litros_abastecidos': 40.0,
          'total_RS': 220.0,
          'sync': 0,
          'configuracoes_id_usuario': 1,
        });

        final marco = await database.getAbastecimentosByPeriodo(
          '2024-03-01 00:00:00',
          '2024-03-31 23:59:59',
        );

        expect(marco.length, 0);
      });
    });

    group('Fluxo Completo de Cadastro', () {
      test('Simula cadastro completo de abastecimento', () async {
        const placa = 'ABC-1234';
        const data = '15/01/2024';
        const km = '50000';
        const combustivel = 'Gasolina';
        const valorPorLitro = '5,50';
        const litros = '40,0';

        final placaValida = placa.isNotEmpty;
        final dataValida = data.isNotEmpty;
        final kmValido = int.tryParse(km) != null;
        final combustivelValido = combustivel.isNotEmpty;
        final valorValido = double.tryParse(valorPorLitro.replaceAll(',', '.')) != null;
        final litrosValido = double.tryParse(litros.replaceAll(',', '.')) != null;

        expect(placaValida, true);
        expect(dataValida, true);
        expect(kmValido, true);
        expect(combustivelValido, true);
        expect(valorValido, true);
        expect(litrosValido, true);

        final valorNum = double.parse(valorPorLitro.replaceAll(',', '.'));
        final litrosNum = double.parse(litros.replaceAll(',', '.'));
        final total = valorNum * litrosNum;

        final abastecimento = {
          'data_hora': '2024-01-15 14:30:00',
          'km': double.parse(km),
          'combustivel': combustivel,
          'valor_por_litro': valorNum,
          'litros_abastecidos': litrosNum,
          'total_RS': total,
          'sync': 0,
          'configuracoes_id_usuario': 1,
        };

        final id = await database.insertAbastecimento(abastecimento);
        expect(id, greaterThan(0));

        final result = await database.getAbastecimentoById(id);
        expect(result, isNotNull);
        expect(result!['total_RS'], 220.0);
      });

      test('Simula erro de validação - campos vazios', () {
        const placa = '';
        const data = '';
        const km = '';

        final formValido = placa.isNotEmpty && 
                          data.isNotEmpty && 
                          km.isNotEmpty;

        expect(formValido, false);
      });

      test('Simula erro de validação - valores inválidos', () {
        const km = 'abc';
        const valor = 'xyz';

        final kmValido = int.tryParse(km) != null;
        final valorValido = double.tryParse(valor.replaceAll(',', '.')) != null;

        expect(kmValido, false);
        expect(valorValido, false);
      });
    });

    group('Conversão de Tipos', () {
      test('Deve converter km de string para número', () async {
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

        final id = await database.insertAbastecimento(abastecimento);
        final result = await database.getAbastecimentoById(id);

        expect(result, isNotNull);
        final km = result!['km'];
        expect(km is num, true);
      });

      test('Deve converter valores monetários corretamente', () async {
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

        final id = await database.insertAbastecimento(abastecimento);
        final result = await database.getAbastecimentoById(id);

        expect(result!['valor_por_litro'], isA<num>());
        expect(result['litros_abastecidos'], isA<num>());
        expect(result['total_RS'], isA<num>());
      });
    });

    group('Sincronização de Abastecimentos', () {
      test('Deve inserir abastecimento não sincronizado', () async {
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

        final id = await database.insertAbastecimento(abastecimento);
        final result = await database.getAbastecimentoById(id);

        expect(result!['sync'], 0);
      });

      test('Deve buscar abastecimentos não sincronizados', () async {
        await database.insertAbastecimento({
          'data_hora': '2024-01-15 14:30:00',
          'km': 50000.0,
          'combustivel': 'Gasolina',
          'valor_por_litro': 5.50,
          'litros_abastecidos': 40.0,
          'total_RS': 220.0,
          'sync': 0,
          'configuracoes_id_usuario': 1,
        });

        await database.insertAbastecimento({
          'data_hora': '2024-01-16 14:30:00',
          'km': 50100.0,
          'combustivel': 'Diesel',
          'valor_por_litro': 4.50,
          'litros_abastecidos': 50.0,
          'total_RS': 225.0,
          'sync': 1,
          'configuracoes_id_usuario': 1,
        });

        final naoSincronizados = await database.getDadosNaoSincronizados('abastecimento');

        expect(naoSincronizados.length, greaterThanOrEqualTo(1));
      });

      test('Deve marcar abastecimento como sincronizado', () async {
        final id = await database.insertAbastecimento({
          'data_hora': '2024-01-15 14:30:00',
          'km': 50000.0,
          'combustivel': 'Gasolina',
          'valor_por_litro': 5.50,
          'litros_abastecidos': 40.0,
          'total_RS': 220.0,
          'sync': 0,
          'configuracoes_id_usuario': 1,
        });

        final marcado = await database.marcarComoSincronizado('abastecimento', id);
        expect(marcado, 1);

        final result = await database.getAbastecimentoById(id);
        expect(result!['sync'], 1);
      });
    });

    group('Casos Edge e Limites', () {
      test('Deve lidar com valores decimais precisos', () async {
        final abastecimento = {
          'data_hora': '2024-01-15 14:30:00',
          'km': 50000.123,
          'combustivel': 'Gasolina',
          'valor_por_litro': 5.789,
          'litros_abastecidos': 40.456,
          'total_RS': 234.199,
          'sync': 0,
          'configuracoes_id_usuario': 1,
        };

        final id = await database.insertAbastecimento(abastecimento);
        final result = await database.getAbastecimentoById(id);

        expect(result, isNotNull);
        expect(result!['valor_por_litro'], closeTo(5.789, 0.001));
      });

      test('Deve lidar com quilometragem alta', () async {
        final abastecimento = {
          'data_hora': '2024-01-15 14:30:00',
          'km': 999999.0,
          'combustivel': 'Diesel',
          'valor_por_litro': 4.50,
          'litros_abastecidos': 100.0,
          'total_RS': 450.0,
          'sync': 0,
          'configuracoes_id_usuario': 1,
        };

        final id = await database.insertAbastecimento(abastecimento);
        final result = await database.getAbastecimentoById(id);

        expect(result, isNotNull);
        expect(result!['km'], 999999.0);
      });

      test('Deve adicionar data/hora automaticamente se não fornecida', () async {
        final abastecimento = {
          'km': 50000.0,
          'combustivel': 'Gasolina',
          'valor_por_litro': 5.50,
          'litros_abastecidos': 40.0,
          'total_RS': 220.0,
          'sync': 0,
          'configuracoes_id_usuario': 1,
        };

        final id = await database.insertAbastecimento(abastecimento);
        final result = await database.getAbastecimentoById(id);

        expect(result, isNotNull);
        expect(result!['data_hora'], isNotNull);
        expect(result['data_hora'], isNotEmpty);
      });

      test('Deve lidar com combustíveis diferentes', () async {
        final combustiveis = ['Gasolina', 'Etanol', 'Diesel', 'GNV'];

        for (final combustivel in combustiveis) {
          await database.insertAbastecimento({
            'data_hora': DateTime.now().toIso8601String(),
            'km': 50000.0,
            'combustivel': combustivel,
            'valor_por_litro': 5.0,
            'litros_abastecidos': 40.0,
            'total_RS': 200.0,
            'sync': 0,
            'configuracoes_id_usuario': 1,
          });
        }

        for (final combustivel in combustiveis) {
          final results = await database.getAbastecimentosByCombustivel(combustivel);
          expect(results.length, greaterThanOrEqualTo(1));
        }
      });
    });

    group('Tratamento de Erros', () {
      test('Deve retornar 0 ao atualizar abastecimento inexistente', () async {
        final updated = await database.updateAbastecimento(999, {
          'valor_por_litro': 6.00,
        });

        expect(updated, 0);
      });

      test('Deve retornar 0 ao deletar abastecimento inexistente', () async {
        final deleted = await database.deleteAbastecimento(999);

        expect(deleted, 0);
      });

      test('Deve retornar lista vazia para combustível não encontrado', () async {
        await database.insertAbastecimento({
          'data_hora': '2024-01-15 14:30:00',
          'km': 50000.0,
          'combustivel': 'Gasolina',
          'valor_por_litro': 5.50,
          'litros_abastecidos': 40.0,
          'total_RS': 220.0,
          'sync': 0,
          'configuracoes_id_usuario': 1,
        });

        final results = await database.getAbastecimentosByCombustivel('Hidrogênio');

        expect(results.length, 0);
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

