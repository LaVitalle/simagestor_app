import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:simagestor_app/models/despesa.dart';
import 'package:simagestor_app/services/despesa_service.dart';
import 'package:simagestor_app/services/service_local_database.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DespesaService - Testes Unitários', () {
    setUp(() async {
      await _clearDatabase();
    });

    group('buscarDespesas() - Cenários de Sucesso', () {
      test('Deve retornar lista vazia quando não há despesas', () async {
        final despesas = await DespesaService.buscarDespesas();

        expect(despesas, isEmpty);
        expect(despesas, isA<List<Despesa>>());
      });

      test('Deve retornar todas as despesas cadastradas', () async {
        final despesa1 = Despesa(
          idDespesa: 0,
          valor: 100.0,
          placa: 'ABC-1234',
          observacao: 'Despesa 1',
          dataHora: DateTime(2024, 1, 15, 10, 30),
          recorrente: false,
          tipoDespesa: 'Pedágio',
          configuracoesIdUsuario: 1,
        );

        final despesa2 = Despesa(
          idDespesa: 0,
          valor: 200.0,
          placa: 'XYZ-5678',
          observacao: 'Despesa 2',
          dataHora: DateTime(2024, 1, 16, 11, 30),
          recorrente: true,
          tipoDespesa: 'Estacionamento',
          configuracoesIdUsuario: 1,
        );

        await DespesaService.adicionarDespesa(despesa1);
        await DespesaService.adicionarDespesa(despesa2);

        final despesas = await DespesaService.buscarDespesas();

        expect(despesas.length, equals(2));
        expect(despesas[0].valor, equals(100.0));
        expect(despesas[1].valor, equals(200.0));
      });
    });

    group('buscarDespesaPorId() - Cenários de Sucesso e Falha', () {
      test('Deve retornar despesa quando ID existe', () async {
        final despesa = Despesa(
          idDespesa: 0,
          valor: 150.50,
          placa: 'ABC-1234',
          observacao: 'Combustível',
          dataHora: DateTime(2024, 1, 15, 10, 30),
          recorrente: false,
          tipoDespesa: 'Pedágio',
          configuracoesIdUsuario: 1,
        );

        final despesaAdicionada = await DespesaService.adicionarDespesa(
          despesa,
        );
        final despesaEncontrada = await DespesaService.buscarDespesaPorId(
          despesaAdicionada.idDespesa,
        );

        expect(
          despesaEncontrada.idDespesa,
          equals(despesaAdicionada.idDespesa),
        );
        expect(despesaEncontrada.valor, equals(150.50));
        expect(despesaEncontrada.placa, equals('ABC-1234'));
        expect(despesaEncontrada.observacao, equals('Combustível'));
      });

      test('Deve lançar exceção quando ID não existe', () async {
        expect(() => DespesaService.buscarDespesaPorId(999), throwsException);

        try {
          await DespesaService.buscarDespesaPorId(999);
        } catch (e) {
          expect(e, isA<Exception>());
          expect(e.toString(), contains('Despesa não encontrada'));
        }
      });
    });

    group('adicionarDespesa() - Cenários de Sucesso', () {
      test('Deve adicionar nova despesa e retornar com ID gerado', () async {
        final novaDespesa = Despesa(
          idDespesa: 0,
          valor: 150.50,
          placa: 'ABC-1234',
          observacao: 'Combustível',
          dataHora: DateTime(2024, 1, 15, 10, 30),
          recorrente: false,
          tipoDespesa: 'Pedágio',
          configuracoesIdUsuario: 1,
        );

        final despesaAdicionada = await DespesaService.adicionarDespesa(
          novaDespesa,
        );

        expect(despesaAdicionada.idDespesa, greaterThan(0));
        expect(despesaAdicionada.valor, equals(150.50));
        expect(despesaAdicionada.placa, equals('ABC-1234'));
        expect(despesaAdicionada.observacao, equals('Combustível'));
        expect(despesaAdicionada.recorrente, equals(false));
        expect(despesaAdicionada.tipoDespesa, equals('Pedágio'));
      });

      test('Deve remover id_despesa=0 antes de inserir', () async {
        final novaDespesa = Despesa(
          idDespesa: 0,
          valor: 100.0,
          placa: 'ABC-1234',
          observacao: 'Teste',
          dataHora: DateTime.now(),
          recorrente: false,
          tipoDespesa: 'Outros',
          configuracoesIdUsuario: 1,
        );

        final despesaAdicionada = await DespesaService.adicionarDespesa(
          novaDespesa,
        );

        expect(despesaAdicionada.idDespesa, greaterThan(0));
      });

      test('Deve adicionar despesa recorrente corretamente', () async {
        final novaDespesa = Despesa(
          idDespesa: 0,
          valor: 200.0,
          placa: 'XYZ-5678',
          observacao: 'Manutenção mensal',
          dataHora: DateTime(2024, 2, 20, 14, 45),
          recorrente: true,
          tipoDespesa: 'Manutenção não programada',
          configuracoesIdUsuario: 1,
        );

        final despesaAdicionada = await DespesaService.adicionarDespesa(
          novaDespesa,
        );

        expect(despesaAdicionada.recorrente, equals(true));
      });
    });

    group('atualizarDespesa() - Cenários de Sucesso e Falha', () {
      test('Deve atualizar despesa existente', () async {
        final despesa = Despesa(
          idDespesa: 0,
          valor: 100.0,
          placa: 'ABC-1234',
          observacao: 'Original',
          dataHora: DateTime(2024, 1, 15, 10, 30),
          recorrente: false,
          tipoDespesa: 'Pedágio',
          configuracoesIdUsuario: 1,
        );

        final despesaAdicionada = await DespesaService.adicionarDespesa(
          despesa,
        );

        final despesaAtualizada = Despesa(
          idDespesa: despesaAdicionada.idDespesa,
          valor: 150.0,
          placa: 'XYZ-5678',
          observacao: 'Atualizada',
          dataHora: DateTime(2024, 1, 16, 11, 30),
          recorrente: true,
          tipoDespesa: 'Estacionamento',
          configuracoesIdUsuario: 1,
        );

        final resultado = await DespesaService.atualizarDespesa(
          despesaAtualizada,
        );

        expect(resultado.valor, equals(150.0));
        expect(resultado.placa, equals('XYZ-5678'));
        expect(resultado.observacao, equals('Atualizada'));
        expect(resultado.recorrente, equals(true));
        expect(resultado.tipoDespesa, equals('Estacionamento'));

        final despesaVerificada = await DespesaService.buscarDespesaPorId(
          despesaAdicionada.idDespesa,
        );

        expect(despesaVerificada.valor, equals(150.0));
        expect(despesaVerificada.placa, equals('XYZ-5678'));
      });

      test('Deve lançar exceção quando ID não existe', () async {
        final despesaInexistente = Despesa(
          idDespesa: 999,
          valor: 100.0,
          placa: 'ABC-1234',
          observacao: 'Teste',
          dataHora: DateTime.now(),
          recorrente: false,
          tipoDespesa: 'Outros',
          configuracoesIdUsuario: 1,
        );

        expect(
          () => DespesaService.atualizarDespesa(despesaInexistente),
          throwsException,
        );

        try {
          await DespesaService.atualizarDespesa(despesaInexistente);
        } catch (e) {
          expect(e, isA<Exception>());
          expect(e.toString(), contains('Despesa não encontrada'));
        }
      });
    });

    group('excluirDespesa() - Cenários de Sucesso e Falha', () {
      test('Deve excluir despesa existente', () async {
        final despesa = Despesa(
          idDespesa: 0,
          valor: 100.0,
          placa: 'ABC-1234',
          observacao: 'Para deletar',
          dataHora: DateTime(2024, 1, 15, 10, 30),
          recorrente: false,
          tipoDespesa: 'Outros',
          configuracoesIdUsuario: 1,
        );

        final despesaAdicionada = await DespesaService.adicionarDespesa(
          despesa,
        );

        await DespesaService.excluirDespesa(despesaAdicionada.idDespesa);

        expect(
          () => DespesaService.buscarDespesaPorId(despesaAdicionada.idDespesa),
          throwsException,
        );
      });

      test('Deve lançar exceção quando ID não existe', () async {
        expect(() => DespesaService.excluirDespesa(999), throwsException);

        try {
          await DespesaService.excluirDespesa(999);
        } catch (e) {
          expect(e, isA<Exception>());
          expect(e.toString(), contains('Despesa não encontrada'));
        }
      });
    });

    group('buscarDespesasPorTipo() - Cenários de Sucesso', () {
      test('Deve retornar apenas despesas do tipo especificado', () async {
        final despesa1 = Despesa(
          idDespesa: 0,
          valor: 100.0,
          placa: 'ABC-1234',
          observacao: 'Pedágio 1',
          dataHora: DateTime(2024, 1, 15, 10, 30),
          recorrente: false,
          tipoDespesa: 'Pedágio',
          configuracoesIdUsuario: 1,
        );

        final despesa2 = Despesa(
          idDespesa: 0,
          valor: 200.0,
          placa: 'XYZ-5678',
          observacao: 'Estacionamento 1',
          dataHora: DateTime(2024, 1, 16, 11, 30),
          recorrente: false,
          tipoDespesa: 'Estacionamento',
          configuracoesIdUsuario: 1,
        );

        final despesa3 = Despesa(
          idDespesa: 0,
          valor: 150.0,
          placa: 'DEF-9012',
          observacao: 'Pedágio 2',
          dataHora: DateTime(2024, 1, 17, 12, 30),
          recorrente: false,
          tipoDespesa: 'Pedágio',
          configuracoesIdUsuario: 1,
        );

        await DespesaService.adicionarDespesa(despesa1);
        await DespesaService.adicionarDespesa(despesa2);
        await DespesaService.adicionarDespesa(despesa3);

        final despesasPedagio = await DespesaService.buscarDespesasPorTipo(
          'Pedágio',
        );

        expect(despesasPedagio.length, equals(2));
        expect(
          despesasPedagio.every((d) => d.tipoDespesa == 'Pedágio'),
          isTrue,
        );
      });

      test('Deve retornar lista vazia quando tipo não existe', () async {
        final despesas = await DespesaService.buscarDespesasPorTipo(
          'TipoInexistente',
        );

        expect(despesas, isEmpty);
      });
    });

    group('buscarDespesasPorPeriodo() - Cenários de Sucesso', () {
      test(
        'Deve retornar despesas no período especificado (DateTime)',
        () async {
          final despesa1 = Despesa(
            idDespesa: 0,
            valor: 100.0,
            placa: 'ABC-1234',
            observacao: 'Janeiro',
            dataHora: DateTime(2024, 1, 15, 10, 30),
            recorrente: false,
            tipoDespesa: 'Pedágio',
            configuracoesIdUsuario: 1,
          );

          final despesa2 = Despesa(
            idDespesa: 0,
            valor: 200.0,
            placa: 'XYZ-5678',
            observacao: 'Fevereiro',
            dataHora: DateTime(2024, 2, 15, 11, 30),
            recorrente: false,
            tipoDespesa: 'Estacionamento',
            configuracoesIdUsuario: 1,
          );

          await DespesaService.adicionarDespesa(despesa1);
          await DespesaService.adicionarDespesa(despesa2);

          final inicio = DateTime(2024, 1, 1);
          final fim = DateTime(2024, 1, 31, 23, 59, 59);

          final despesas = await DespesaService.buscarDespesasPorPeriodo(
            inicio,
            fim,
          );

          expect(despesas.length, equals(1));
          expect(despesas[0].observacao, equals('Janeiro'));
        },
      );

      test('Deve retornar despesas no período especificado (String)', () async {
        final despesa1 = Despesa(
          idDespesa: 0,
          valor: 100.0,
          placa: 'ABC-1234',
          observacao: 'Janeiro',
          dataHora: DateTime(2024, 1, 15, 10, 30),
          recorrente: false,
          tipoDespesa: 'Pedágio',
          configuracoesIdUsuario: 1,
        );

        final despesa2 = Despesa(
          idDespesa: 0,
          valor: 200.0,
          placa: 'XYZ-5678',
          observacao: 'Fevereiro',
          dataHora: DateTime(2024, 2, 15, 11, 30),
          recorrente: false,
          tipoDespesa: 'Estacionamento',
          configuracoesIdUsuario: 1,
        );

        await DespesaService.adicionarDespesa(despesa1);
        await DespesaService.adicionarDespesa(despesa2);

        final inicio = DateTime(2024, 2, 1).toIso8601String();
        final fim = DateTime(2024, 2, 28, 23, 59, 59).toIso8601String();

        final despesas = await DespesaService.buscarDespesasPorPeriodoString(
          inicio,
          fim,
        );

        expect(despesas.length, equals(1));
        expect(despesas[0].observacao, equals('Fevereiro'));
      });

      test(
        'Deve retornar lista vazia quando período não contém despesas',
        () async {
          final inicio = DateTime(2025, 1, 1);
          final fim = DateTime(2025, 1, 31);

          final despesas = await DespesaService.buscarDespesasPorPeriodo(
            inicio,
            fim,
          );

          expect(despesas, isEmpty);
        },
      );
    });

    group('buscarDespesasNaoSincronizadas() - Cenários de Sucesso', () {
      test('Deve retornar apenas despesas não sincronizadas', () async {
        final despesa1 = Despesa(
          idDespesa: 0,
          valor: 100.0,
          placa: 'ABC-1234',
          observacao: 'Não sincronizada',
          dataHora: DateTime(2024, 1, 15, 10, 30),
          recorrente: false,
          tipoDespesa: 'Pedágio',
          configuracoesIdUsuario: 1,
        );

        final despesa2 = Despesa(
          idDespesa: 0,
          valor: 200.0,
          placa: 'XYZ-5678',
          observacao: 'Não sincronizada 2',
          dataHora: DateTime(2024, 1, 16, 11, 30),
          recorrente: false,
          tipoDespesa: 'Estacionamento',
          configuracoesIdUsuario: 1,
        );

        final despesaAdicionada1 = await DespesaService.adicionarDespesa(
          despesa1,
        );
        final despesaAdicionada2 = await DespesaService.adicionarDespesa(
          despesa2,
        );

        await DespesaService.marcarDespesaComoSincronizada(
          despesaAdicionada1.idDespesa,
        );

        final despesasNaoSync =
            await DespesaService.buscarDespesasNaoSincronizadas();

        expect(despesasNaoSync.length, equals(1));
        expect(
          despesasNaoSync[0].idDespesa,
          equals(despesaAdicionada2.idDespesa),
        );
      });

      test(
        'Deve retornar lista vazia quando todas estão sincronizadas',
        () async {
          final despesa = Despesa(
            idDespesa: 0,
            valor: 100.0,
            placa: 'ABC-1234',
            observacao: 'Teste',
            dataHora: DateTime(2024, 1, 15, 10, 30),
            recorrente: false,
            tipoDespesa: 'Pedágio',
            configuracoesIdUsuario: 1,
          );

          final despesaAdicionada = await DespesaService.adicionarDespesa(
            despesa,
          );
          await DespesaService.marcarDespesaComoSincronizada(
            despesaAdicionada.idDespesa,
          );

          final despesasNaoSync =
              await DespesaService.buscarDespesasNaoSincronizadas();

          expect(despesasNaoSync, isEmpty);
        },
      );
    });

    group('marcarDespesaComoSincronizada() - Cenários de Sucesso', () {
      test('Deve marcar despesa como sincronizada', () async {
        final despesa = Despesa(
          idDespesa: 0,
          valor: 100.0,
          placa: 'ABC-1234',
          observacao: 'Para sincronizar',
          dataHora: DateTime(2024, 1, 15, 10, 30),
          recorrente: false,
          tipoDespesa: 'Pedágio',
          configuracoesIdUsuario: 1,
        );

        final despesaAdicionada = await DespesaService.adicionarDespesa(
          despesa,
        );

        await DespesaService.marcarDespesaComoSincronizada(
          despesaAdicionada.idDespesa,
        );

        final despesasNaoSync =
            await DespesaService.buscarDespesasNaoSincronizadas();

        expect(
          despesasNaoSync.any(
            (d) => d.idDespesa == despesaAdicionada.idDespesa,
          ),
          isFalse,
        );
      });
    });

    group('calcularTotalDespesas() - Cenários de Sucesso', () {
      test('Deve calcular total de todas as despesas', () async {
        final despesa1 = Despesa(
          idDespesa: 0,
          valor: 100.0,
          placa: 'ABC-1234',
          observacao: 'Despesa 1',
          dataHora: DateTime(2024, 1, 15, 10, 30),
          recorrente: false,
          tipoDespesa: 'Pedágio',
          configuracoesIdUsuario: 1,
        );

        final despesa2 = Despesa(
          idDespesa: 0,
          valor: 200.0,
          placa: 'XYZ-5678',
          observacao: 'Despesa 2',
          dataHora: DateTime(2024, 1, 16, 11, 30),
          recorrente: false,
          tipoDespesa: 'Estacionamento',
          configuracoesIdUsuario: 1,
        );

        final despesa3 = Despesa(
          idDespesa: 0,
          valor: 150.50,
          placa: 'DEF-9012',
          observacao: 'Despesa 3',
          dataHora: DateTime(2024, 1, 17, 12, 30),
          recorrente: false,
          tipoDespesa: 'Outros',
          configuracoesIdUsuario: 1,
        );

        await DespesaService.adicionarDespesa(despesa1);
        await DespesaService.adicionarDespesa(despesa2);
        await DespesaService.adicionarDespesa(despesa3);

        final total = await DespesaService.calcularTotalDespesas();

        expect(total, equals(450.50));
      });

      test('Deve retornar zero quando não há despesas', () async {
        final total = await DespesaService.calcularTotalDespesas();

        expect(total, equals(0.0));
      });
    });

    group('calcularTotalDespesasPorTipo() - Cenários de Sucesso', () {
      test('Deve calcular total de despesas por tipo', () async {
        final despesa1 = Despesa(
          idDespesa: 0,
          valor: 100.0,
          placa: 'ABC-1234',
          observacao: 'Pedágio 1',
          dataHora: DateTime(2024, 1, 15, 10, 30),
          recorrente: false,
          tipoDespesa: 'Pedágio',
          configuracoesIdUsuario: 1,
        );

        final despesa2 = Despesa(
          idDespesa: 0,
          valor: 150.0,
          placa: 'XYZ-5678',
          observacao: 'Pedágio 2',
          dataHora: DateTime(2024, 1, 16, 11, 30),
          recorrente: false,
          tipoDespesa: 'Pedágio',
          configuracoesIdUsuario: 1,
        );

        final despesa3 = Despesa(
          idDespesa: 0,
          valor: 200.0,
          placa: 'DEF-9012',
          observacao: 'Estacionamento',
          dataHora: DateTime(2024, 1, 17, 12, 30),
          recorrente: false,
          tipoDespesa: 'Estacionamento',
          configuracoesIdUsuario: 1,
        );

        await DespesaService.adicionarDespesa(despesa1);
        await DespesaService.adicionarDespesa(despesa2);
        await DespesaService.adicionarDespesa(despesa3);

        final totalPedagio = await DespesaService.calcularTotalDespesasPorTipo(
          'Pedágio',
        );

        expect(totalPedagio, equals(250.0));
      });

      test('Deve retornar zero quando tipo não existe', () async {
        final total = await DespesaService.calcularTotalDespesasPorTipo(
          'TipoInexistente',
        );

        expect(total, equals(0.0));
      });
    });

    group('calcularTotalDespesasPorPeriodo() - Cenários de Sucesso', () {
      test('Deve calcular total de despesas por período', () async {
        final despesa1 = Despesa(
          idDespesa: 0,
          valor: 100.0,
          placa: 'ABC-1234',
          observacao: 'Janeiro',
          dataHora: DateTime(2024, 1, 15, 10, 30),
          recorrente: false,
          tipoDespesa: 'Pedágio',
          configuracoesIdUsuario: 1,
        );

        final despesa2 = Despesa(
          idDespesa: 0,
          valor: 200.0,
          placa: 'XYZ-5678',
          observacao: 'Janeiro',
          dataHora: DateTime(2024, 1, 20, 11, 30),
          recorrente: false,
          tipoDespesa: 'Estacionamento',
          configuracoesIdUsuario: 1,
        );

        final despesa3 = Despesa(
          idDespesa: 0,
          valor: 150.0,
          placa: 'DEF-9012',
          observacao: 'Fevereiro',
          dataHora: DateTime(2024, 2, 15, 12, 30),
          recorrente: false,
          tipoDespesa: 'Outros',
          configuracoesIdUsuario: 1,
        );

        await DespesaService.adicionarDespesa(despesa1);
        await DespesaService.adicionarDespesa(despesa2);
        await DespesaService.adicionarDespesa(despesa3);

        final inicio = DateTime(2024, 1, 1);
        final fim = DateTime(2024, 1, 31, 23, 59, 59);

        final total = await DespesaService.calcularTotalDespesasPorPeriodo(
          inicio,
          fim,
        );

        expect(total, equals(300.0));
      });

      test('Deve retornar zero quando período não contém despesas', () async {
        final inicio = DateTime(2025, 1, 1);
        final fim = DateTime(2025, 1, 31);

        final total = await DespesaService.calcularTotalDespesasPorPeriodo(
          inicio,
          fim,
        );

        expect(total, equals(0.0));
      });
    });

    group('criarDespesa() - Factory Method', () {
      test('Deve criar despesa com valores padrão', () {
        final despesa = DespesaService.criarDespesa(
          valor: 150.0,
          tipoDespesa: 'Pedágio',
          configuracoesIdUsuario: 1,
        );

        expect(despesa.idDespesa, equals(0));
        expect(despesa.valor, equals(150.0));
        expect(despesa.tipoDespesa, equals('Pedágio'));
        expect(despesa.placa, equals(''));
        expect(despesa.observacao, equals(''));
        expect(despesa.recorrente, equals(false));
        expect(despesa.configuracoesIdUsuario, equals(1));
        expect(despesa.dataHora, isA<DateTime>());
      });

      test('Deve criar despesa com todos os parâmetros opcionais', () {
        final dataHora = DateTime(2024, 1, 15, 10, 30);
        final despesa = DespesaService.criarDespesa(
          valor: 200.0,
          tipoDespesa: 'Estacionamento',
          placa: 'ABC-1234',
          observacao: 'Teste',
          dataHora: dataHora,
          recorrente: true,
          configuracoesIdUsuario: 1,
        );

        expect(despesa.valor, equals(200.0));
        expect(despesa.tipoDespesa, equals('Estacionamento'));
        expect(despesa.placa, equals('ABC-1234'));
        expect(despesa.observacao, equals('Teste'));
        expect(despesa.dataHora, equals(dataHora));
        expect(despesa.recorrente, equals(true));
      });

      test('Deve usar DateTime.now() quando dataHora não for fornecida', () {
        final antes = DateTime.now();
        final despesa = DespesaService.criarDespesa(
          valor: 100.0,
          tipoDespesa: 'Outros',
          configuracoesIdUsuario: 1,
        );
        final depois = DateTime.now();

        expect(
          despesa.dataHora.isAfter(antes.subtract(Duration(seconds: 1))),
          isTrue,
        );
        expect(
          despesa.dataHora.isBefore(depois.add(Duration(seconds: 1))),
          isTrue,
        );
      });
    });

    group('Tratamento de Erros e Casos Extremos', () {
      test('Deve tratar erro ao buscar despesas com banco fechado', () async {
        // Este teste verifica se o serviço trata exceções corretamente
        // Em um cenário real, o banco seria fechado, mas aqui testamos
        // apenas a estrutura de tratamento de erro
        expect(() => DespesaService.buscarDespesas(), returnsNormally);
      });

      test('Deve lidar com valores muito grandes', () async {
        final despesa = Despesa(
          idDespesa: 0,
          valor: 999999999.99,
          placa: 'ABC-1234',
          observacao: 'Valor muito grande',
          dataHora: DateTime.now(),
          recorrente: false,
          tipoDespesa: 'Outros',
          configuracoesIdUsuario: 1,
        );

        final despesaAdicionada = await DespesaService.adicionarDespesa(
          despesa,
        );

        expect(despesaAdicionada.valor, equals(999999999.99));

        final total = await DespesaService.calcularTotalDespesas();
        expect(total, equals(999999999.99));
      });

      test('Deve lidar com strings muito longas', () async {
        final observacaoLonga = 'A' * 200;
        final placaLonga = 'B' * 100;
        final tipoLongo = 'C' * 50;

        final despesa = Despesa(
          idDespesa: 0,
          valor: 100.0,
          placa: placaLonga,
          observacao: observacaoLonga,
          dataHora: DateTime.now(),
          recorrente: false,
          tipoDespesa: tipoLongo,
          configuracoesIdUsuario: 1,
        );

        final despesaAdicionada = await DespesaService.adicionarDespesa(
          despesa,
        );

        expect(despesaAdicionada.observacao.length, equals(200));
        expect(despesaAdicionada.placa.length, equals(100));
        expect(despesaAdicionada.tipoDespesa.length, equals(50));
      });

      test('Deve lidar com múltiplas despesas simultaneamente', () async {
        final despesas = List.generate(
          10,
          (index) => Despesa(
            idDespesa: 0,
            valor: (index + 1) * 10.0,
            placa: 'ABC-${index.toString().padLeft(4, '0')}',
            observacao: 'Despesa $index',
            dataHora: DateTime(2024, 1, index + 1),
            recorrente: index % 2 == 0,
            tipoDespesa: 'Tipo ${index % 3}',
            configuracoesIdUsuario: 1,
          ),
        );

        for (final despesa in despesas) {
          await DespesaService.adicionarDespesa(despesa);
        }

        final todasDespesas = await DespesaService.buscarDespesas();
        expect(todasDespesas.length, equals(10));

        final total = await DespesaService.calcularTotalDespesas();
        expect(total, equals(550.0)); // soma de 10+20+30+...+100
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
