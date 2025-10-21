import 'package:flutter_test/flutter_test.dart';
import 'package:simagestor_app/services/service_local_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('Login Integration Tests - Banco de Dados', () {
    late ServiceLocalDatabase database;

    setUpAll(() async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      database = ServiceLocalDatabase.instance;
      final db = await database.database;
      await db.delete('configuracoes');
    });

    tearDown(() async {
      final db = await database.database;
      await db.delete('configuracoes');
    });

    group('Armazenamento de Configurações após Login', () {
      test('Deve inserir nova configuração após primeiro login', () async {
        final configuracao = {
          'id_usuario': 1,
          'url_empresa': 'https://empresa.simagestor.com.br/api',
          'data_expiracao': DateTime.now().add(Duration(days: 1)).toIso8601String(),
          'token': 'token_teste_123',
          'isAdmin': 1,
        };

        final id = await database.insertConfiguracao(configuracao);

        expect(id, greaterThan(0));
        
        final result = await database.getConfiguracaoById(1);
        expect(result, isNotNull);
        expect(result!['token'], 'token_teste_123');
        expect(result['isAdmin'], 1);
      });

      test('Deve atualizar configuração existente no login subsequente', () async {
        final configuracaoInicial = {
          'id_usuario': 1,
          'url_empresa': 'https://empresa.simagestor.com.br/api',
          'data_expiracao': DateTime.now().add(Duration(days: 1)).toIso8601String(),
          'token': 'token_antigo',
          'isAdmin': 0,
        };

        await database.insertConfiguracao(configuracaoInicial);

        final configuracaoAtualizada = {
          'id_usuario': 1,
          'url_empresa': 'https://empresa.simagestor.com.br/api',
          'data_expiracao': DateTime.now().add(Duration(days: 1)).toIso8601String(),
          'token': 'token_novo',
          'isAdmin': 1,
        };

        final rowsAffected = await database.updateConfiguracao(1, configuracaoAtualizada);

        expect(rowsAffected, 1);
        
        final result = await database.getConfiguracaoById(1);
        expect(result!['token'], 'token_novo');
        expect(result['isAdmin'], 1);
      });

      test('Deve verificar se configuração existe antes de inserir ou atualizar', () async {
        const userId = 1;

        final configAntes = await database.getConfiguracaoById(userId);

        expect(configAntes, isNull);

        final configuracao = {
          'id_usuario': userId,
          'url_empresa': 'https://empresa.simagestor.com.br/api',
          'data_expiracao': DateTime.now().add(Duration(days: 1)).toIso8601String(),
          'token': 'token123',
          'isAdmin': 0,
        };
        await database.insertConfiguracao(configuracao);

        final configDepois = await database.getConfiguracaoById(userId);

        expect(configDepois, isNotNull);
        expect(configDepois!['id_usuario'], userId);
      });

      test('Deve salvar corretamente o flag isAdmin para usuário admin', () async {
        final configuracao = {
          'id_usuario': 1,
          'url_empresa': 'https://empresa.simagestor.com.br/api',
          'data_expiracao': DateTime.now().add(Duration(days: 1)).toIso8601String(),
          'token': 'admin_token',
          'isAdmin': 1,
        };

        await database.insertConfiguracao(configuracao);
        final result = await database.getConfiguracaoById(1);

        expect(result!['isAdmin'], 1);
      });

      test('Deve salvar corretamente o flag isAdmin para usuário comum', () async {
        final configuracao = {
          'id_usuario': 2,
          'url_empresa': 'https://empresa.simagestor.com.br/api',
          'data_expiracao': DateTime.now().add(Duration(days: 1)).toIso8601String(),
          'token': 'user_token',
          'isAdmin': 0,
        };

        await database.insertConfiguracao(configuracao);
        final result = await database.getConfiguracaoById(2);

        expect(result!['isAdmin'], 0);
      });

      test('Deve salvar URL da empresa com formato correto', () async {
        const company = 'minhaempresa';
        final configuracao = {
          'id_usuario': 1,
          'url_empresa': 'https://$company.simagestor.com.br/api',
          'data_expiracao': DateTime.now().add(Duration(days: 1)).toIso8601String(),
          'token': 'token123',
          'isAdmin': 0,
        };

        await database.insertConfiguracao(configuracao);
        final result = await database.getConfiguracaoById(1);

        expect(result!['url_empresa'], 'https://minhaempresa.simagestor.com.br/api');
        expect(result['url_empresa'], startsWith('https://'));
        expect(result['url_empresa'], endsWith('/api'));
      });

      test('Deve salvar data de expiração em formato ISO 8601', () async {
        final dataExpiracao = DateTime.now().add(Duration(seconds: 30));
        final configuracao = {
          'id_usuario': 1,
          'url_empresa': 'https://empresa.simagestor.com.br/api',
          'data_expiracao': dataExpiracao.toIso8601String(),
          'token': 'token123',
          'isAdmin': 0,
        };

        await database.insertConfiguracao(configuracao);
        final result = await database.getConfiguracaoById(1);

        expect(result!['data_expiracao'], isNotNull);
        final dataSalva = DateTime.parse(result['data_expiracao']);
        expect(dataSalva, isA<DateTime>());
        expect(dataSalva.isAfter(DateTime.now()), true);
      });

      test('Deve suportar múltiplos usuários logados (configurações diferentes)', () async {
        final config1 = {
          'id_usuario': 1,
          'url_empresa': 'https://empresa1.simagestor.com.br/api',
          'data_expiracao': DateTime.now().add(Duration(days: 1)).toIso8601String(),
          'token': 'token_user_1',
          'isAdmin': 1,
        };

        final config2 = {
          'id_usuario': 2,
          'url_empresa': 'https://empresa2.simagestor.com.br/api',
          'data_expiracao': DateTime.now().add(Duration(days: 1)).toIso8601String(),
          'token': 'token_user_2',
          'isAdmin': 0,
        };

        await database.insertConfiguracao(config1);
        await database.insertConfiguracao(config2);

        final result1 = await database.getConfiguracaoById(1);
        final result2 = await database.getConfiguracaoById(2);

        expect(result1!['id_usuario'], 1);
        expect(result1['token'], 'token_user_1');
        expect(result1['isAdmin'], 1);

        expect(result2!['id_usuario'], 2);
        expect(result2['token'], 'token_user_2');
        expect(result2['isAdmin'], 0);
      });
    });

    group('Fluxo Completo de Login', () {
      test('Simula fluxo completo: validação -> API -> salvamento', () async {
        const email = 'usuario@teste.com';
        const password = 'senha123';
        const company = 'empresateste';

        final emailValido = email.isNotEmpty && email.contains('@');
        final senhaValida = password.isNotEmpty;
        final empresaValida = company.isNotEmpty;

        expect(emailValido, true);
        expect(senhaValida, true);
        expect(empresaValida, true);

        final apiResponse = {
          'status': 'success',
          'data': {
            'token': 'abc123xyz',
            'user_id': 10,
            'nivel_acesso': 'adm',
          }
        };

        final data = apiResponse['data'] as Map<String, dynamic>;
        final token = data['token'];
        final userId = data['user_id'];
        final isAdmin = data['nivel_acesso'] == 'adm';

        final configuracao = {
          'id_usuario': userId,
          'url_empresa': 'https://$company.simagestor.com.br/api',
          'data_expiracao': DateTime.now().add(Duration(seconds: 30)).toIso8601String(),
          'token': token,
          'isAdmin': isAdmin ? 1 : 0,
        };

        final infos = await database.getConfiguracaoById(userId);
        
        if (infos == null) {
          await database.insertConfiguracao(configuracao);
        } else {
          await database.updateConfiguracao(userId, configuracao);
        }

        final resultado = await database.getConfiguracaoById(userId);
        expect(resultado, isNotNull);
        expect(resultado!['token'], 'abc123xyz');
        expect(resultado['isAdmin'], 1);
        expect(resultado['url_empresa'], 'https://empresateste.simagestor.com.br/api');
      });

      test('Simula erro de validação - email inválido', () {
        const email = 'emailinvalido';

        final emailValido = email.contains('@');

        expect(emailValido, false);
      });

      test('Simula erro de validação - campos vazios', () {
        const email = '';
        const password = '';
        const company = '';

        final formValido = email.isNotEmpty && 
                          password.isNotEmpty && 
                          company.isNotEmpty;

        expect(formValido, false);
      });
    });

    group('Limpeza e Manutenção', () {
      test('Deve deletar configuração de usuário', () async {
        final configuracao = {
          'id_usuario': 1,
          'url_empresa': 'https://empresa.simagestor.com.br/api',
          'data_expiracao': DateTime.now().add(Duration(days: 1)).toIso8601String(),
          'token': 'token123',
          'isAdmin': 0,
        };
        await database.insertConfiguracao(configuracao);

        final rowsDeleted = await database.deleteConfiguracao(1);

        expect(rowsDeleted, 1);
        final result = await database.getConfiguracaoById(1);
        expect(result, isNull);
      });

      test('Deve retornar todas as configurações', () async {
        final config1 = {
          'id_usuario': 1,
          'url_empresa': 'https://empresa1.simagestor.com.br/api',
          'data_expiracao': DateTime.now().add(Duration(days: 1)).toIso8601String(),
          'token': 'token1',
          'isAdmin': 0,
        };

        final config2 = {
          'id_usuario': 2,
          'url_empresa': 'https://empresa2.simagestor.com.br/api',
          'data_expiracao': DateTime.now().add(Duration(days: 1)).toIso8601String(),
          'token': 'token2',
          'isAdmin': 1,
        };

        await database.insertConfiguracao(config1);
        await database.insertConfiguracao(config2);

        final configs = await database.getAllConfiguracoes();

        expect(configs.length, 2);
        expect(configs[0]['id_usuario'], anyOf(1, 2));
        expect(configs[1]['id_usuario'], anyOf(1, 2));
      });
    });

    group('Tratamento de Erros', () {
      test('Deve lançar erro ao inserir configuração com campos faltando', () async {
        final configuracaoIncompleta = {
          'id_usuario': 1,
        };

        expect(
          () async => await database.insertConfiguracao(configuracaoIncompleta),
          throwsA(anything),
        );
      });

      test('Deve tratar erro ao buscar configuração inexistente', () async {
        final result = await database.getConfiguracaoById(999);

        expect(result, isNull);
      });

      test('Deve tratar erro ao atualizar configuração inexistente', () async {
        final configuracao = {
          'id_usuario': 999,
          'url_empresa': 'https://empresa.simagestor.com.br/api',
          'data_expiracao': DateTime.now().add(Duration(days: 1)).toIso8601String(),
          'token': 'token123',
          'isAdmin': 0,
        };

        final rowsAffected = await database.updateConfiguracao(999, configuracao);

        expect(rowsAffected, 0);
      });

      test('Deve tratar erro ao deletar configuração inexistente', () async {
        final rowsDeleted = await database.deleteConfiguracao(999);

        expect(rowsDeleted, 0);
      });
    });
  });
}
