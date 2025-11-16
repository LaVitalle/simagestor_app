import 'package:flutter/material.dart';
import 'package:simagestor_app/models/despesa.dart';
import 'package:simagestor_app/themes/app_colors.dart';

class DespesaItem extends StatelessWidget {
  final Despesa despesa;
  final VoidCallback onVisualizar;

  const DespesaItem({
    super.key,
    required this.despesa,
    required this.onVisualizar,
  });

  @override
  Widget build(BuildContext context) {
    String _formatCurrency(double value) {
      return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF404040),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  despesa.placa.isNotEmpty ? 'Placa: ${despesa.placa}' : 'ID: ${despesa.idFormatado}',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Valor: ${_formatCurrency(despesa.valor)}',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              despesa.dataHoraFormatada,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onVisualizar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Visualizar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
