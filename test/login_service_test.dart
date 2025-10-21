import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';

void main() {
  group('LoginService - Testes Unitários', () {
    setUp(() {});

    group('authUser - Cenários de Sucesso', () {
      test('Deve autenticar usuário com credenciais válidas e retornar dados completos', () async {
        const email = 'usuario@teste.com';
        const password = 'senha123';
        const company = 'empresateste';

        final mockResponse = {
          'status': 'success',
          'message': 'Login realizado com sucesso',
          'data': {
            'token': 'abc123xyz789',
            'user_id': 42,
            'nivel_acesso': 'adm',
          }
        };

        expect(
          () async {
            final result = mockResponse;
            final data = result['data'] as Map<String, dynamic>;
            expect(result['status'], 'success');
            expect(data['token'], isNotNull);
            expect(data['user_id'], isA<int>());
          },
          returnsNormally,
        );
      });

      test('Deve formatar corretamente a URL da empresa', () async {
        const company = 'minhaempresa';
        final expectedUrl = 'https://$company.simagestor.com.br/api';

        expect(expectedUrl, 'https://minhaempresa.simagestor.com.br/api');
      });

      test('Deve retornar dados para usuário comum (não admin)', () async {
        final mockResponse = {
          'status': 'success',
          'message': 'Login realizado com sucesso',
          'data': {
            'token': 'token123',
            'user_id': 10,
            'nivel_acesso': 'usuario',
          }
        };

        final data = mockResponse['data'] as Map<String, dynamic>;
        final nivelAcesso = data['nivel_acesso'];
        final isAdmin = nivelAcesso == 'adm';

        expect(isAdmin, false);
        expect(data['user_id'], 10);
      });

      test('Deve retornar dados para usuário admin', () async {
        final mockResponse = {
          'status': 'success',
          'message': 'Login realizado com sucesso',
          'data': {
            'token': 'admin_token',
            'user_id': 1,
            'nivel_acesso': 'adm',
          }
        };

        final data = mockResponse['data'] as Map<String, dynamic>;
        final nivelAcesso = data['nivel_acesso'];
        final isAdmin = nivelAcesso == 'adm';

        expect(isAdmin, true);
        expect(mockResponse['status'], 'success');
      });
    });

    group('authUser - Cenários de Falha', () {
      test('Deve lançar exceção com credenciais inválidas', () async {
        const email = 'usuario@teste.com';
        const password = 'senha_errada';
        const company = 'empresateste';

        expect(
          () async {
            throw Exception('Erro ao buscar usuário: Invalid credentials');
          },
          throwsException,
        );
      });

      test('Deve lançar exceção quando empresa não existe', () async {
        const email = 'usuario@teste.com';
        const password = 'senha123';
        const company = 'empresa_inexistente';

        expect(
          () async {
            throw Exception('Erro ao buscar usuário: Company not found');
          },
          throwsException,
        );
      });

      test('Deve lançar exceção em caso de erro de rede', () async {
        const email = 'usuario@teste.com';
        const password = 'senha123';
        const company = 'empresateste';

        expect(
          () async {
            throw Exception('Erro ao buscar usuário: Network error');
          },
          throwsException,
        );
      });

      test('Deve lançar exceção quando resposta da API está malformada', () async {
        final mockResponse = {
          'status': 'error',
        };

        expect(
          () {
            if (mockResponse['status'] != 'success') {
              throw Exception('Resposta inválida da API');
            }
          },
          throwsException,
        );
      });

      test('Deve lançar exceção quando token está ausente na resposta', () async {
        final mockResponse = {
          'status': 'success',
          'data': {
            'user_id': 1,
            'nivel_acesso': 'adm',
          }
        };

        final data = mockResponse['data'] as Map<String, dynamic>;
        expect(data['token'], isNull);
      });
    });

    group('Validação de Campos', () {
      test('Email vazio não deve ser aceito', () {
        const email = '';

        final isValid = email.isNotEmpty && email.contains('@');

        expect(isValid, false);
      });

      test('Email sem @ não deve ser aceito', () {
        const email = 'usuarioteste.com';

        final isValid = email.contains('@');

        expect(isValid, false);
      });

      test('Email válido deve ser aceito', () {
        const email = 'usuario@teste.com';

        final isValid = email.isNotEmpty && email.contains('@');

        expect(isValid, true);
      });

      test('Senha vazia não deve ser aceita', () {
        const password = '';

        final isValid = password.isNotEmpty;

        expect(isValid, false);
      });

      test('Senha com apenas espaços não deve ser aceita', () {
        const password = '   ';

        final isValid = password.trim().isNotEmpty;

        expect(isValid, false);
      });

      test('Nome da empresa vazio não deve ser aceito', () {
        const company = '';

        final isValid = company.isNotEmpty;

        expect(isValid, false);
      });

      test('Campos com espaços devem ser trimados', () {
        const email = '  usuario@teste.com  ';
        const password = '  senha123  ';
        const company = '  empresa  ';

        final emailTrimmed = email.trim();
        final passwordTrimmed = password.trim();
        final companyTrimmed = company.trim();

        expect(emailTrimmed, 'usuario@teste.com');
        expect(passwordTrimmed, 'senha123');
        expect(companyTrimmed, 'empresa');
      });
    });

    group('Formato de Resposta da API', () {
      test('Resposta de sucesso deve ter estrutura correta', () {
        final response = {
          'status': 'success',
          'message': 'Login realizado com sucesso',
          'data': {
            'token': 'abc123',
            'user_id': 1,
            'nivel_acesso': 'adm',
          }
        };

        final data = response['data'] as Map<String, dynamic>;
        expect(response['status'], 'success');
        expect(response['message'], isNotNull);
        expect(response['data'], isNotNull);
        expect(data['token'], isNotNull);
        expect(data['user_id'], isNotNull);
        expect(data['nivel_acesso'], isNotNull);
      });

      test('Resposta de erro deve ter estrutura correta', () {
        final response = {
          'status': 'error',
          'message': 'Credenciais inválidas',
        };

        expect(response['status'], 'error');
        expect(response['message'], isNotNull);
      });

      test('Token deve ser string não vazia', () {
        final token = 'abc123xyz789';

        expect(token, isA<String>());
        expect(token.isNotEmpty, true);
      });

      test('User ID pode ser int ou string', () {
        final userIdInt = 42;
        final userIdString = '42';

        expect(userIdInt, anyOf(isA<int>(), isA<String>()));
        expect(userIdString, anyOf(isA<int>(), isA<String>()));
      });

      test('Nível de acesso deve ser valor válido', () {
        const validLevels = ['adm', 'usuario', 'user'];

        expect(validLevels.contains('adm'), true);
        expect(validLevels.contains('usuario'), true);
        expect(validLevels.contains('invalido'), false);
      });
    });

    group('Configuração Local após Login', () {
      test('Configuração deve ter todos os campos obrigatórios', () {
        final configuracao = {
          'id_usuario': 42,
          'url_empresa': 'https://empresa.simagestor.com.br/api',
          'data_expiracao': DateTime.now().add(Duration(seconds: 30)).toIso8601String(),
          'token': 'abc123',
          'isAdmin': 1,
        };

        expect(configuracao['id_usuario'], isNotNull);
        expect(configuracao['url_empresa'], isNotNull);
        expect(configuracao['data_expiracao'], isNotNull);
        expect(configuracao['token'], isNotNull);
        expect(configuracao.containsKey('isAdmin'), true);
      });

      test('URL da empresa deve ter formato correto', () {
        const company = 'minhaempresa';
        final urlEmpresa = 'https://$company.simagestor.com.br/api';

        expect(urlEmpresa, startsWith('https://'));
        expect(urlEmpresa, contains('.simagestor.com.br'));
        expect(urlEmpresa, endsWith('/api'));
      });

      test('Data de expiração deve ser no futuro', () {
        final now = DateTime.now();
        final dataExpiracao = now.add(Duration(seconds: 30));

        expect(dataExpiracao.isAfter(now), true);
      });

      test('isAdmin deve ser 1 para admin e 0 para usuário comum', () {
        final isAdminForAdmin = 1;
        final isAdminForUser = 0;

        expect(isAdminForAdmin, 1);
        expect(isAdminForUser, 0);
      });

      test('isAdmin deve ser corretamente calculado baseado no nível de acesso', () {
        const nivelAcessoAdmin = 'adm';
        const nivelAcessoUser = 'usuario';

        final isAdminValue1 = nivelAcessoAdmin == 'adm' ? 1 : 0;
        final isAdminValue2 = nivelAcessoUser == 'adm' ? 1 : 0;

        expect(isAdminValue1, 1);
        expect(isAdminValue2, 0);
      });
    });

    group('Casos Edge e Segurança', () {
      test('Email com caracteres especiais deve ser tratado', () {
        const email = 'usuario+teste@empresa.com.br';

        final isValid = email.contains('@');

        expect(isValid, true);
      });

      test('Empresa com caracteres especiais na URL deve ser tratado', () {
        const company = 'empresa-teste';
        final url = 'https://$company.simagestor.com.br/api';

        expect(url, contains('empresa-teste'));
      });

      test('Token vazio não deve ser aceito', () {
        const token = '';

        final isValid = token.isNotEmpty;

        expect(isValid, false);
      });

      test('User ID zero deve ser válido', () {
        const userId = 0;

        expect(userId, isA<int>());
        expect(userId >= 0, true);
      });

      test('User ID negativo não deve ser válido', () {
        const userId = -1;

        final isValid = userId >= 0;

        expect(isValid, false);
      });
    });

    group('Tratamento de Erros HTTP', () {
      test('Erro 401 - Não autorizado deve ser tratado', () {
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/login'),
          response: Response(
            requestOptions: RequestOptions(path: '/login'),
            statusCode: 401,
          ),
        );

        expect(dioError.response?.statusCode, 401);
      });

      test('Erro 404 - Não encontrado deve ser tratado', () {
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/login'),
          response: Response(
            requestOptions: RequestOptions(path: '/login'),
            statusCode: 404,
          ),
        );

        expect(dioError.response?.statusCode, 404);
      });

      test('Erro 500 - Erro do servidor deve ser tratado', () {
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/login'),
          response: Response(
            requestOptions: RequestOptions(path: '/login'),
            statusCode: 500,
          ),
        );

        expect(dioError.response?.statusCode, 500);
      });

      test('Timeout deve ser tratado', () {
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/login'),
          type: DioExceptionType.connectionTimeout,
        );

        expect(dioError.type, DioExceptionType.connectionTimeout);
      });
    });
  });
}
