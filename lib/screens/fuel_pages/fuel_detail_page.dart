import 'package:flutter/material.dart';
import 'package:simagestor_app/themes/app_colors.dart';
import 'package:simagestor_app/models/fuel.dart';

class FuelDetailPage extends StatelessWidget {
  final FuelModel fuelRecord;

  const FuelDetailPage({
    super.key,
    required this.fuelRecord,
  });

  void _navigateBack(BuildContext context) {
    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Botão Voltar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C4747),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      onPressed: () => _navigateBack(context),
                      child: const Text(
                        'Voltar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

            // ID do registro
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  fuelRecord.id,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.title,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Detalhes do abastecimento
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      label: 'Data do abastecimento:',
                      value: _formatDate(fuelRecord.date),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildDetailRow(
                      label: 'Quilometragem:',
                      value: '${fuelRecord.km} KM',
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildDetailRow(
                      label: 'Tipo de combustível:',
                      value: fuelRecord.fuel,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildDetailRow(
                      label: 'Valor por litro:',
                      value: _formatCurrency(fuelRecord.valuePerLiter),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildDetailRow(
                      label: 'Litros abastecidos:',
                      value: '${fuelRecord.liters.toStringAsFixed(0)}L',
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildDetailRow(
                      label: 'Total:',
                      value: _formatCurrency(fuelRecord.total),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
}

