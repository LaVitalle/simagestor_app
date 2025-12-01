import 'package:flutter/material.dart';
import 'package:simagestor_app/models/despesa.dart';
import 'package:simagestor_app/services/despesa_service.dart';
import 'package:simagestor_app/themes/app_colors.dart';

class DetalhesDespesaPage extends StatefulWidget {
  final int idDespesa;

  const DetalhesDespesaPage({super.key, required this.idDespesa});

  @override
  State<DetalhesDespesaPage> createState() => _DetalhesDespesaPageState();
}

class _DetalhesDespesaPageState extends State<DetalhesDespesaPage> {
  Despesa? _despesa;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarDespesa();
  }

  Future<void> _carregarDespesa() async {
    try {
      final despesa = await DespesaService.buscarDespesaPorId(widget.idDespesa);
      setState(() {
        _despesa = despesa;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatarValor(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatarRecorrente(bool recorrente) {
    return recorrente ? 'Sim' : 'Não';
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        color: AppColors.title,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.text,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.title,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Erro ao carregar despesa',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.text, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarDespesa,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_despesa == null) {
      return const Center(
        child: Text(
          'Despesa não encontrada',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    final despesa = _despesa!;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Botão Voltar
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const Spacer(),
              // Título Simagestor
              const Text(
                'Simagestor',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.title,
                ),
              ),
              const Spacer(),
              // Espaço para balancear o layout
              const SizedBox(width: 80),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Placa ou ID
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              despesa.placa.isNotEmpty ? despesa.placa : 'ID: ${despesa.idFormatado}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.title,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Data
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              despesa.dataHoraFormatada,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.text,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Detalhes da despesa
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Informações da Despesa'),
                const SizedBox(height: 16),

                _buildDetailRow(
                  label: 'Tipo de despesa:',
                  value: despesa.tipoDespesa,
                ),

                const SizedBox(height: 12),

                _buildDetailRow(
                  label: 'Recorrente:',
                  value: _formatarRecorrente(despesa.recorrente),
                ),

                if (despesa.placa.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    label: 'Placa do veículo:',
                    value: despesa.placa,
                  ),
                ],

                if (despesa.observacao.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    label: 'Observação:',
                    value: despesa.observacao,
                  ),
                ],

                const SizedBox(height: 24),

                _buildSectionTitle('Valores'),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C4747),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Valor da despesa:',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatarValor(despesa.valor),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
