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

            // Placa do veículo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  fuelRecord.plate.isNotEmpty ? fuelRecord.plate : 'ID: ${fuelRecord.id}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.title,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Data e hora
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _formatDate(fuelRecord.date),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.text,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Detalhes do abastecimento
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seção: Informações do Veículo
                    _buildSectionTitle('Informações do Veículo'),
                    const SizedBox(height: 16),
                    
                    _buildDetailRow(
                      label: 'Placa:',
                      value: fuelRecord.plate.isNotEmpty ? fuelRecord.plate : 'Não informada',
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildDetailRow(
                      label: 'Quilometragem:',
                      value: '${fuelRecord.km.toStringAsFixed(0)} km',
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Seção: Detalhes do Abastecimento
                    _buildSectionTitle('Detalhes do Abastecimento'),
                    const SizedBox(height: 16),
                    
                    _buildDetailRow(
                      label: 'Combustível:',
                      value: fuelRecord.fuel.isNotEmpty ? fuelRecord.fuel : 'Não informado',
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildDetailRow(
                      label: 'Valor por litro:',
                      value: _formatCurrency(fuelRecord.valuePerLiter),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildDetailRow(
                      label: 'Litros abastecidos:',
                      value: '${fuelRecord.liters.toStringAsFixed(2)} L',
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Seção: Valores
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
                            'Total do Abastecimento:',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatCurrency(fuelRecord.total),
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24), // Espaço extra no final
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

}

