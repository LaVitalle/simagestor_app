import 'package:flutter/material.dart';
import 'package:simagestor_app/components/despesa_item.dart';
import 'package:simagestor_app/models/despesa.dart';
import 'package:simagestor_app/services/despesa_service.dart';
import 'package:simagestor_app/themes/app_colors.dart';

class DespesasPage extends StatefulWidget {
  const DespesasPage({super.key});

  @override
  State<DespesasPage> createState() => _DespesasPageState();
}

class _DespesasPageState extends State<DespesasPage> {
  List<Despesa> despesas = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _carregarDespesas();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _carregarDespesas() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final despesasCarregadas = await DespesaService.buscarDespesas();
      setState(() {
        despesas = despesasCarregadas;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _visualizarDespesa(Despesa despesa) {
    Navigator.pushNamed(
      context,
      '/detalhes-despesa',
      arguments: {'idDespesa': despesa.idDespesa},
    );
  }

  void _novaDespesa() {
    Navigator.pushNamed(context, '/form-despesas').then((_) {
      // Recarregar a lista quando retornar da tela de formulário
      _carregarDespesas();
    });
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
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: const Text(
              'Despesas',
              style: TextStyle(
                color: AppColors.title,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Conteúdo principal
          Expanded(child: _buildContent()),

          // Botão de nova despesa
          SafeArea(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _novaDespesa,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Nova despesa',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar despesas',
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: const TextStyle(color: AppColors.text, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarDespesas,
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

    if (despesas.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, color: AppColors.text, size: 64),
            SizedBox(height: 16),
            Text(
              'Nenhuma despesa encontrada',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Adicione sua primeira despesa',
              style: TextStyle(color: AppColors.text, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarDespesas,
      color: AppColors.primary,
      backgroundColor: AppColors.background,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: despesas.length,
        itemBuilder: (context, index) {
          final despesa = despesas[index];
          return DespesaItem(
            despesa: despesa,
            onVisualizar: () => _visualizarDespesa(despesa),
          );
        },
      ),
    );
  }
}
