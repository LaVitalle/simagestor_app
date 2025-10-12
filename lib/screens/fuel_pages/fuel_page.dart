import 'package:flutter/material.dart';
import 'package:simagestor_app/themes/app_colors.dart';
import 'package:simagestor_app/models/fuel.dart';
import 'package:simagestor_app/services/service_local_database.dart';
import 'package:simagestor_app/screens/fuel_pages/new_fueling_page.dart';
import 'package:simagestor_app/screens/fuel_pages/fuel_detail_page.dart';

class FuelPage extends StatefulWidget {
  const FuelPage({super.key});

  @override
  State<FuelPage> createState() => _FuelPageState();
}

class _FuelPageState extends State<FuelPage> {
  final TextEditingController _searchController = TextEditingController();
  List<FuelModel> _fuelRecords = [];
  List<FuelModel> _filteredRecords = [];

  @override
  void initState() {
    super.initState();
    _loadFuelRecords();
  }

  Future<void> _loadFuelRecords() async {
    final abastecimentos = await ServiceLocalDatabase.instance.getAllAbastecimentos();
    _fuelRecords = abastecimentos.map((item) {
      return FuelModel(
        id: item['id_abastecimento'].toString(),
        plate: item['placa_veiculo'] ?? '',
        date: DateTime.tryParse(item['data_hora'] ?? '') ?? DateTime.now(),
        km: (item['km'] is int) ? item['km'] : int.tryParse(item['km']?.toString() ?? '') ?? 0,
        fuel: item['combustivel'] ?? '',
        valuePerLiter: (item['valor_por_litro'] is double) ? item['valor_por_litro'] : double.tryParse(item['valor_por_litro']?.toString() ?? '') ?? 0.0,
        liters: (item['litros_abastecidos'] is double) ? item['litros_abastecidos'] : double.tryParse(item['litros_abastecidos']?.toString() ?? '') ?? 0.0,
        total: (item['total_RS'] is double) ? item['total_RS'] : double.tryParse(item['total_RS']?.toString() ?? '') ?? 0.0,
      );
    }).toList();
    setState(() {
      _filteredRecords = List.from(_fuelRecords);
    });
  }

  void _filterRecords(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRecords = List.from(_fuelRecords);
      } else {
        _filteredRecords = _fuelRecords.where((record) {
          return record.id.toLowerCase().contains(query.toLowerCase()) ||
                 record.plate.toLowerCase().contains(query.toLowerCase()) ||
                 record.fuel.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _navigateBack() {
    Navigator.pop(context);
  }

  void _viewRecord(FuelModel record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FuelDetailPage(fuelRecord: record),
      ),
    );
  }

  void _newFueling() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewFuelingPage()),
    ).then((_) {
      // Recarregar a lista quando voltar da página de novo abastecimento
      _loadFuelRecords();
    });
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
                      onPressed: _navigateBack,
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
            
            // Título da seção
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Histórico de abastecimento',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.title,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Barra de pesquisa
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterRecords,
                  style: const TextStyle(color: AppColors.textInput),
                  decoration: const InputDecoration(
                    hintText: 'Pesquisar',
                    hintStyle: TextStyle(color: Color(0xFFA0A0A0)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Lista de registros
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _filteredRecords.length,
                itemBuilder: (context, index) {
                  final record = _filteredRecords[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border.all(
                        color: const Color(0xFF404040),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                record.id,
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${record.date.day.toString().padLeft(2, '0')}/${record.date.month.toString().padLeft(2, '0')}/${record.date.year} ${record.date.hour.toString().padLeft(2, '0')}:${record.date.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _viewRecord(record),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00796B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: const Text(
                                'Visualizar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Botão Novo Abastecimento
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _newFueling,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Novo abastecimento',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
