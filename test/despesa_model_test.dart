import 'package:flutter_test/flutter_test.dart';
import 'package:simagestor_app/models/despesa.dart';

void main() {
  group('Despesa Model - Testes Unitários', () {
    group('Serialização - toJson()', () {
      test('Deve serializar todos os campos corretamente', () {
        final despesa = Despesa(
          idDespesa: 1,
          valor: 150.50,
          placa: 'ABC-1234',
          observacao: 'Combustível',
          dataHora: DateTime(2024, 1, 15, 10, 30),
          recorrente: false,
          tipoDespesa: 'Pedágio',
          configuracoesIdUsuario: 1,
        );

        final json = despesa.toJson();

        expect(json['id_despesa'], equals(1));
        expect(json['valor'], equals(150.50));
        expect(json['placa'], equals('ABC-1234'));
        expect(json['observacao'], equals('Combustível'));
        expect(json['data_hora'], isA<String>());
        expect(json['recorrente'], equals(0));
        expect(json['tipo_despesa'], equals('Pedágio'));
        expect(json['configuracoes_id_usuario'], equals(1));
      });

      test('Deve serializar despesa recorrente corretamente', () {
        final despesa = Despesa(
          idDespesa: 2,
          valor: 200.0,
          placa: 'XYZ-5678',
          observacao: 'Manutenção mensal',
          dataHora: DateTime(2024, 2, 20, 14, 45),
          recorrente: true,
          tipoDespesa: 'Manutenção não programada',
          configuracoesIdUsuario: 1,
        );

        final json = despesa.toJson();

        expect(json['recorrente'], equals(1));
      });

      test('Deve serializar data/hora no formato ISO8601', () {
        final dataHora = DateTime(2024, 1, 15, 10, 30, 45);
        final despesa = Despesa(
          idDespesa: 3,
          valor: 100.0,
          placa: 'DEF-9012',
          observacao: 'Teste',
          dataHora: dataHora,
          recorrente: false,
          tipoDespesa: 'Outros',
          configuracoesIdUsuario: 1,
        );

        final json = despesa.toJson();

        expect(json['data_hora'], equals(dataHora.toIso8601String()));
      });
    });

    group('Deserialização - fromJson()', () {
      test('Deve deserializar dados completos corretamente', () {
        final json = {
          'id_despesa': 1,
          'valor': 150.50,
          'placa': 'ABC-1234',
          'observacao': 'Combustível',
          'data_hora': '2024-01-15T10:30:00.000',
          'recorrente': 0,
          'tipo_despesa': 'Pedágio',
          'configuracoes_id_usuario': 1,
        };

        final despesa = Despesa.fromJson(json);

        expect(despesa.idDespesa, equals(1));
        expect(despesa.valor, equals(150.50));
        expect(despesa.placa, equals('ABC-1234'));
        expect(despesa.observacao, equals('Combustível'));
        expect(despesa.dataHora, equals(DateTime(2024, 1, 15, 10, 30)));
        expect(despesa.recorrente, equals(false));
        expect(despesa.tipoDespesa, equals('Pedágio'));
        expect(despesa.configuracoesIdUsuario, equals(1));
      });

      test('Deve deserializar despesa recorrente corretamente', () {
        final json = {
          'id_despesa': 2,
          'valor': 200.0,
          'placa': 'XYZ-5678',
          'observacao': 'Manutenção',
          'data_hora': '2024-02-20T14:45:00.000',
          'recorrente': 1,
          'tipo_despesa': 'Manutenção não programada',
          'configuracoes_id_usuario': 1,
        };

        final despesa = Despesa.fromJson(json);

        expect(despesa.recorrente, equals(true));
      });

      test(
        'Deve deserializar com valores nulos opcionais (placa e observacao)',
        () {
          final json = {
            'id_despesa': 3,
            'valor': 100.0,
            'placa': null,
            'observacao': null,
            'data_hora': '2024-01-15T10:30:00.000',
            'recorrente': 0,
            'tipo_despesa': 'Outros',
            'configuracoes_id_usuario': 1,
          };

          final despesa = Despesa.fromJson(json);

          expect(despesa.placa, equals(''));
          expect(despesa.observacao, equals(''));
        },
      );

      test('Deve deserializar tipo_despesa nulo como string vazia', () {
        final json = {
          'id_despesa': 4,
          'valor': 50.0,
          'placa': 'ABC-1234',
          'observacao': 'Teste',
          'data_hora': '2024-01-15T10:30:00.000',
          'recorrente': 0,
          'tipo_despesa': null,
          'configuracoes_id_usuario': 1,
        };

        final despesa = Despesa.fromJson(json);

        expect(despesa.tipoDespesa, equals(''));
      });

      test('Deve converter valor num para double corretamente', () {
        final json = {
          'id_despesa': 5,
          'valor': 150, // int
          'placa': 'ABC-1234',
          'observacao': 'Teste',
          'data_hora': '2024-01-15T10:30:00.000',
          'recorrente': 0,
          'tipo_despesa': 'Pedágio',
          'configuracoes_id_usuario': 1,
        };

        final despesa = Despesa.fromJson(json);

        expect(despesa.valor, isA<double>());
        expect(despesa.valor, equals(150.0));
      });
    });

    group('Getters', () {
      test('idFormatado deve retornar ID em hexadecimal maiúsculo', () {
        final despesa = Despesa(
          idDespesa: 255,
          valor: 100.0,
          placa: 'ABC-1234',
          observacao: 'Teste',
          dataHora: DateTime.now(),
          recorrente: false,
          tipoDespesa: 'Outros',
          configuracoesIdUsuario: 1,
        );

        expect(despesa.idFormatado, equals('FF'));
      });

      test('idFormatado deve retornar ID correto para diferentes valores', () {
        final despesa1 = Despesa(
          idDespesa: 10,
          valor: 100.0,
          placa: 'ABC-1234',
          observacao: 'Teste',
          dataHora: DateTime.now(),
          recorrente: false,
          tipoDespesa: 'Outros',
          configuracoesIdUsuario: 1,
        );

        final despesa2 = Despesa(
          idDespesa: 16,
          valor: 100.0,
          placa: 'ABC-1234',
          observacao: 'Teste',
          dataHora: DateTime.now(),
          recorrente: false,
          tipoDespesa: 'Outros',
          configuracoesIdUsuario: 1,
        );

        expect(despesa1.idFormatado, equals('A'));
        expect(despesa2.idFormatado, equals('10'));
      });

      test('dataHoraFormatada deve formatar corretamente', () {
        final dataHora = DateTime(2024, 1, 5, 9, 3);
        final despesa = Despesa(
          idDespesa: 1,
          valor: 100.0,
          placa: 'ABC-1234',
          observacao: 'Teste',
          dataHora: dataHora,
          recorrente: false,
          tipoDespesa: 'Outros',
          configuracoesIdUsuario: 1,
        );

        expect(despesa.dataHoraFormatada, equals('05/01/2024 09:03'));
      });

      test('dataHoraFormatada deve adicionar zeros à esquerda', () {
        final dataHora = DateTime(2024, 12, 25, 23, 59);
        final despesa = Despesa(
          idDespesa: 1,
          valor: 100.0,
          placa: 'ABC-1234',
          observacao: 'Teste',
          dataHora: dataHora,
          recorrente: false,
          tipoDespesa: 'Outros',
          configuracoesIdUsuario: 1,
        );

        expect(despesa.dataHoraFormatada, equals('25/12/2024 23:59'));
      });

      test('dataHoraFormatada deve formatar corretamente meia-noite', () {
        final dataHora = DateTime(2024, 1, 1, 0, 0);
        final despesa = Despesa(
          idDespesa: 1,
          valor: 100.0,
          placa: 'ABC-1234',
          observacao: 'Teste',
          dataHora: dataHora,
          recorrente: false,
          tipoDespesa: 'Outros',
          configuracoesIdUsuario: 1,
        );

        expect(despesa.dataHoraFormatada, equals('01/01/2024 00:00'));
      });
    });

    group('toString()', () {
      test('Deve retornar string formatada com todos os campos', () {
        final despesa = Despesa(
          idDespesa: 1,
          valor: 150.50,
          placa: 'ABC-1234',
          observacao: 'Combustível',
          dataHora: DateTime(2024, 1, 15, 10, 30),
          recorrente: false,
          tipoDespesa: 'Pedágio',
          configuracoesIdUsuario: 1,
        );

        final string = despesa.toString();

        expect(string, contains('idDespesa: 1'));
        expect(string, contains('valor: 150.5'));
        expect(string, contains('placa: ABC-1234'));
        expect(string, contains('observacao: Combustível'));
        expect(string, contains('recorrente: false'));
        expect(string, contains('tipoDespesa: Pedágio'));
        expect(string, contains('configuracoesIdUsuario: 1'));
      });
    });

    group('Casos Extremos', () {
      test('Deve lidar com valores muito grandes', () {
        final despesa = Despesa(
          idDespesa: 999999999,
          valor: 999999999.99,
          placa: 'ABC-1234',
          observacao: 'Valor muito grande',
          dataHora: DateTime.now(),
          recorrente: false,
          tipoDespesa: 'Outros',
          configuracoesIdUsuario: 1,
        );

        final json = despesa.toJson();
        expect(json['valor'], equals(999999999.99));

        final despesaDeserializada = Despesa.fromJson(json);
        expect(despesaDeserializada.valor, equals(999999999.99));
      });

      test('Deve lidar com strings muito longas', () {
        final observacaoLonga = 'A' * 200;
        final placaLonga = 'B' * 100;
        final tipoLongo = 'C' * 50;

        final despesa = Despesa(
          idDespesa: 1,
          valor: 100.0,
          placa: placaLonga,
          observacao: observacaoLonga,
          dataHora: DateTime.now(),
          recorrente: false,
          tipoDespesa: tipoLongo,
          configuracoesIdUsuario: 1,
        );

        final json = despesa.toJson();
        expect(json['observacao'].length, equals(200));
        expect(json['placa'].length, equals(100));
        expect(json['tipo_despesa'].length, equals(50));

        final despesaDeserializada = Despesa.fromJson(json);
        expect(despesaDeserializada.observacao.length, equals(200));
        expect(despesaDeserializada.placa.length, equals(100));
        expect(despesaDeserializada.tipoDespesa.length, equals(50));
      });

      test('Deve lidar com data antiga', () {
        final dataAntiga = DateTime(2000, 1, 1, 0, 0);
        final despesa = Despesa(
          idDespesa: 1,
          valor: 100.0,
          placa: 'ABC-1234',
          observacao: 'Teste',
          dataHora: dataAntiga,
          recorrente: false,
          tipoDespesa: 'Outros',
          configuracoesIdUsuario: 1,
        );

        final json = despesa.toJson();
        final despesaDeserializada = Despesa.fromJson(json);

        expect(despesaDeserializada.dataHora.year, equals(2000));
      });

      test('Deve lidar com data futura', () {
        final dataFutura = DateTime(2100, 12, 31, 23, 59);
        final despesa = Despesa(
          idDespesa: 1,
          valor: 100.0,
          placa: 'ABC-1234',
          observacao: 'Teste',
          dataHora: dataFutura,
          recorrente: false,
          tipoDespesa: 'Outros',
          configuracoesIdUsuario: 1,
        );

        final json = despesa.toJson();
        final despesaDeserializada = Despesa.fromJson(json);

        expect(despesaDeserializada.dataHora.year, equals(2100));
      });

      test('Deve lidar com valor zero', () {
        final despesa = Despesa(
          idDespesa: 1,
          valor: 0.0,
          placa: 'ABC-1234',
          observacao: 'Teste',
          dataHora: DateTime.now(),
          recorrente: false,
          tipoDespesa: 'Outros',
          configuracoesIdUsuario: 1,
        );

        final json = despesa.toJson();
        expect(json['valor'], equals(0.0));

        final despesaDeserializada = Despesa.fromJson(json);
        expect(despesaDeserializada.valor, equals(0.0));
      });

      test('Deve lidar com strings vazias', () {
        final despesa = Despesa(
          idDespesa: 1,
          valor: 100.0,
          placa: '',
          observacao: '',
          dataHora: DateTime.now(),
          recorrente: false,
          tipoDespesa: '',
          configuracoesIdUsuario: 1,
        );

        final json = despesa.toJson();
        expect(json['placa'], equals(''));
        expect(json['observacao'], equals(''));
        expect(json['tipo_despesa'], equals(''));

        final despesaDeserializada = Despesa.fromJson(json);
        expect(despesaDeserializada.placa, equals(''));
        expect(despesaDeserializada.observacao, equals(''));
        expect(despesaDeserializada.tipoDespesa, equals(''));
      });

      test('Deve lidar com ID zero', () {
        final despesa = Despesa(
          idDespesa: 0,
          valor: 100.0,
          placa: 'ABC-1234',
          observacao: 'Teste',
          dataHora: DateTime.now(),
          recorrente: false,
          tipoDespesa: 'Outros',
          configuracoesIdUsuario: 1,
        );

        final json = despesa.toJson();
        expect(json['id_despesa'], equals(0));

        final despesaDeserializada = Despesa.fromJson(json);
        expect(despesaDeserializada.idDespesa, equals(0));
        expect(despesaDeserializada.idFormatado, equals('0'));
      });
    });
  });
}
