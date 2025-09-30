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

  Widget _buildDetalheItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: const Text(
          'Simagestor',
          style: TextStyle(
            color: AppColors.title,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: _buildContent(),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ID da despesa
          Center(
            child: Text(
              _despesa!.idFormatado,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Detalhes da despesa
          _buildDetalheItem('Data da despesa', _despesa!.dataHoraFormatada),

          _buildDetalheItem(
            'Valor da despesa',
            _formatarValor(_despesa!.valor),
          ),

          _buildDetalheItem(
            'Recorrente',
            _formatarRecorrente(_despesa!.recorrente),
          ),

          _buildDetalheItem('Tipo de despesa', _despesa!.tipoDespesa),

          if (_despesa!.placaVeiculo.isNotEmpty)
            _buildDetalheItem('Placa do veículo', _despesa!.placaVeiculo),

          if (_despesa!.observacao.isNotEmpty)
            _buildDetalheItem('Observação', _despesa!.observacao),
        ],
      ),
    );
  }
}
