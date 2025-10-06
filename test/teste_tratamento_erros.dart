import 'package:flutter_test/flutter_test.dart';
import '../lib/services/service_local_database.dart';

void main() {
  group('Testes de Tratamento de Erros - ServiceLocalDatabase', () {
    late ServiceLocalDatabase dbService;

    setUp(() async {
      dbService = ServiceLocalDatabase.instance;
    });

    tearDown(() async {
      await dbService.close();
    });

    // ==================== TESTES DE ERRO PARA CONFIGURAÇÕES ====================
    group('Testes de Erro - Configurações', () {
      test('Deve capturar e relançar erro ao inserir configuração inválida', () async {
        bool erroCapturado = false;
        String mensagemErro = '';

        try {
          // Tentar inserir configuração com dados inválidos
          await dbService.insertConfiguracao({
            'url_empresa': null, // Dado inválido
            'data_expiracao': 'data_invalida',
          });
        } catch (e) {
          erroCapturado = true;
          mensagemErro = e.toString();
          print('✅ Erro capturado corretamente: $e');
        }

        expect(erroCapturado, isTrue, reason: 'Erro deveria ter sido capturado');
        expect(mensagemErro, isNotEmpty, reason: 'Mensagem de erro deveria existir');
      });

      test('Deve capturar erro ao buscar configuração com ID inválido', () async {
        bool erroCapturado = false;

        try {
          // Tentar buscar com ID negativo (inválido)
          await dbService.getConfiguracaoById(-1);
        } catch (e) {
          erroCapturado = true;
          print('✅ Erro capturado ao buscar ID inválido: $e');
        }

        expect(erroCapturado, isTrue, reason: 'Erro deveria ter sido capturado para ID inválido');
      });

      test('Deve capturar erro ao atualizar configuração inexistente', () async {
        bool erroCapturado = false;

        try {
          await dbService.updateConfiguracao(999, {
            'url_empresa': 'teste.com',
            'data_expiracao': '2024-12-31',
          });
        } catch (e) {
          erroCapturado = true;
          print('✅ Erro capturado ao atualizar configuração inexistente: $e');
        }

        expect(erroCapturado, isTrue, reason: 'Erro deveria ter sido capturado para atualização');
      });
    });

    // ==================== TESTES DE ERRO PARA DESPESAS ====================
    group('Testes de Erro - Despesas', () {
      test('Deve capturar erro ao inserir despesa com dados inválidos', () async {
        bool erroCapturado = false;

        try {
          await dbService.insertDespesa({
            'valor': 'texto_invalido', // Valor deve ser numérico
            'observacao': 'Teste',
            'data_hora': 'formato_invalido',
            'recorrente': 'nao_numerico',
            'tipo_despesa': 'Geral',
            'configuracoes_id_usuario': 1,
            'sync': false,
          });
        } catch (e) {
          erroCapturado = true;
          print('✅ Erro capturado ao inserir despesa inválida: $e');
        }

        expect(erroCapturado, isTrue, reason: 'Erro deveria ter sido capturado para dados inválidos');
      });

      test('Deve capturar erro ao buscar despesas por tipo inexistente', () async {
        bool erroCapturado = false;

        try {
          await dbService.getDespesasByTipo('TipoInexistente');
        } catch (e) {
          erroCapturado = true;
          print('✅ Erro capturado ao buscar por tipo inexistente: $e');
        }

        expect(erroCapturado, isTrue, reason: 'Erro deveria ter sido capturado para busca por tipo');
      });

      test('Deve capturar erro ao buscar despesas por período inválido', () async {
        bool erroCapturado = false;

        try {
          await dbService.getDespesasByPeriodo('data_invalida', 'outra_data_invalida');
        } catch (e) {
          erroCapturado = true;
          print('✅ Erro capturado ao buscar por período inválido: $e');
        }

        expect(erroCapturado, isTrue, reason: 'Erro deveria ter sido capturado para período inválido');
      });
    });

    // ==================== TESTES DE ERRO PARA ABASTECIMENTOS ====================
    group('Testes de Erro - Abastecimentos', () {
      test('Deve capturar erro ao inserir abastecimento com dados inválidos', () async {
        bool erroCapturado = false;

        try {
          await dbService.insertAbastecimento({
            'data_hora': 'formato_invalido',
            'km': 'texto_invalido', // Deve ser numérico
            'combustivel': null, // Pode ser null, mas testando outros campos
            'valor_por_litro': 'nao_numerico',
            'litros_abastecidos': 'texto',
            'total_RS': 'invalido',
            'sync': false,
            'configuracoes_id_usuario': 1,
          });
        } catch (e) {
          erroCapturado = true;
          print('✅ Erro capturado ao inserir abastecimento inválido: $e');
        }

        expect(erroCapturado, isTrue, reason: 'Erro deveria ter sido capturado para abastecimento inválido');
      });

      test('Deve capturar erro ao buscar abastecimentos por combustível inexistente', () async {
        bool erroCapturado = false;

        try {
          await dbService.getAbastecimentosByCombustivel('CombustivelInexistente');
        } catch (e) {
          erroCapturado = true;
          print('✅ Erro capturado ao buscar por combustível inexistente: $e');
        }

        expect(erroCapturado, isTrue, reason: 'Erro deveria ter sido capturado para combustível inexistente');
      });
    });

    // ==================== TESTES DE ERRO PARA CHECKLIST ====================
    group('Testes de Erro - Checklist', () {
      test('Deve capturar erro ao inserir checklist com dados inválidos', () async {
        bool erroCapturado = false;

        try {
          await dbService.insertChecklist({
            'placa_veiculo': null, // Campo obrigatório
            'motorista': 'João Silva',
            'freios': 'texto_invalido', // Deve ser inteiro
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
        } catch (e) {
          erroCapturado = true;
          print('✅ Erro capturado ao inserir checklist inválido: $e');
        }

        expect(erroCapturado, isTrue, reason: 'Erro deveria ter sido capturado para checklist inválido');
      });

      test('Deve capturar erro ao buscar checklist por placa inexistente', () async {
        bool erroCapturado = false;

        try {
          await dbService.getChecklistsByPlaca('PLACA_INEXISTENTE');
        } catch (e) {
          erroCapturado = true;
          print('✅ Erro capturado ao buscar por placa inexistente: $e');
        }

        expect(erroCapturado, isTrue, reason: 'Erro deveria ter sido capturado para placa inexistente');
      });
    });

    // ==================== TESTES DE ERRO PARA SINCRONIZAÇÃO ====================
    group('Testes de Erro - Sincronização', () {
      test('Deve capturar erro ao buscar dados não sincronizados de tabela inexistente', () async {
        bool erroCapturado = false;

        try {
          await dbService.getDadosNaoSincronizados('tabela_inexistente');
        } catch (e) {
          erroCapturado = true;
          print('✅ Erro capturado ao buscar dados de tabela inexistente: $e');
        }

        expect(erroCapturado, isTrue, reason: 'Erro deveria ter sido capturado para tabela inexistente');
      });

      test('Deve capturar erro ao marcar como sincronizado em tabela inexistente', () async {
        bool erroCapturado = false;

        try {
          await dbService.marcarComoSincronizado('tabela_inexistente', 1);
        } catch (e) {
          erroCapturado = true;
          print('✅ Erro capturado ao marcar sincronização em tabela inexistente: $e');
        }

        expect(erroCapturado, isTrue, reason: 'Erro deveria ter sido capturado para sincronização em tabela inexistente');
      });
    });

    // ==================== TESTES DE ERRO PARA OPERAÇÕES EM LOTE ====================
    group('Testes de Erro - Operações em Lote', () {
      test('Deve capturar erro ao inserir múltiplas despesas com dados inválidos', () async {
        int errosCapturados = 0;

        for (int i = 0; i < 5; i++) {
          try {
            await dbService.insertDespesa({
              'valor': 'valor_invalido_$i',
              'observacao': 'Teste $i',
              'data_hora': 'formato_invalido',
              'recorrente': 'nao_numerico',
              'tipo_despesa': 'Geral',
              'configuracoes_id_usuario': 1,
              'sync': false,
            });
          } catch (e) {
            errosCapturados++;
            print('✅ Erro $errosCapturados capturado: $e');
          }
        }

        expect(errosCapturados, equals(5), reason: 'Todos os 5 erros deveriam ter sido capturados');
      });
    });

    // ==================== TESTES DE ERRO PARA VALORES EXTREMOS ====================
    group('Testes de Erro - Valores Extremos', () {
      test('Deve capturar erro ao inserir despesa com valor muito grande', () async {
        bool erroCapturado = false;

        try {
          await dbService.insertDespesa({
            'valor': 999999999999999999999.99, // Valor extremamente grande
            'observacao': 'Teste valor extremo',
            'data_hora': '2024-01-15 10:30:00',
            'recorrente': 0,
            'tipo_despesa': 'Geral',
            'configuracoes_id_usuario': 1,
            'sync': false,
          });
        } catch (e) {
          erroCapturado = true;
          print('✅ Erro capturado para valor extremo: $e');
        }

        expect(erroCapturado, isTrue, reason: 'Erro deveria ter sido capturado para valor extremo');
      });

      test('Deve capturar erro ao inserir string muito longa', () async {
        bool erroCapturado = false;
        String observacaoLonga = 'A' * 10000; // String de 10.000 caracteres

        try {
          await dbService.insertDespesa({
            'valor': 100.0,
            'observacao': observacaoLonga,
            'data_hora': '2024-01-15 10:30:00',
            'recorrente': 0,
            'tipo_despesa': 'Geral',
            'configuracoes_id_usuario': 1,
            'sync': false,
          });
        } catch (e) {
          erroCapturado = true;
          print('✅ Erro capturado para string muito longa: $e');
        }

        expect(erroCapturado, isTrue, reason: 'Erro deveria ter sido capturado para string muito longa');
      });
    });

    // ==================== TESTES DE ERRO PARA FECHAMENTO DO BANCO ====================
    group('Testes de Erro - Fechamento do Banco', () {
      test('Deve capturar erro ao fechar banco já fechado', () async {
        bool erroCapturado = false;

        try {
          await dbService.close();
          await dbService.close(); // Tentar fechar novamente
        } catch (e) {
          erroCapturado = true;
          print('✅ Erro capturado ao fechar banco já fechado: $e');
        }

        expect(erroCapturado, isTrue, reason: 'Erro deveria ter sido capturado ao fechar banco já fechado');
      });
    });
  });
}
