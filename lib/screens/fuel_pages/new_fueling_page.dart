import 'package:flutter/material.dart';
import 'package:simagestor_app/themes/app_colors.dart';
import 'package:simagestor_app/models/fuel.dart';
import 'package:simagestor_app/services/service_local_database.dart';
import 'package:simagestor_app/services/service_sync.dart';
import 'package:simagestor_app/services/service_connection.dart';

class NewFuelingPage extends StatefulWidget {
  const NewFuelingPage({super.key});

  @override
  State<NewFuelingPage> createState() => _NewFuelingPageState();
}

class _NewFuelingPageState extends State<NewFuelingPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores dos campos
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _fuelTypeController = TextEditingController();
  final TextEditingController _valuePerLiterController = TextEditingController();
  final TextEditingController _litersController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();

  // Lista de tipos de combustível
  final List<String> _fuelTypes = ['Gasolina', 'Etanol', 'Diesel', 'GNV'];
  String? _selectedFuelType;

  final ServiceSync _serviceSync = ServiceSync();

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(DateTime.now());
    _totalController.text = '0,00';
    
    // Listeners para cálculo automático
    _valuePerLiterController.addListener(_calculateTotal);
    _litersController.addListener(_calculateTotal);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _calculateTotal() {
    final valuePerLiter = double.tryParse(_valuePerLiterController.text.replaceAll(',', '.'));
    final liters = double.tryParse(_litersController.text.replaceAll(',', '.'));
    
    if (valuePerLiter != null && liters != null) {
      final total = valuePerLiter * liters;
      setState(() {
        _totalController.text = total.toStringAsFixed(2).replaceAll('.', ',');
      });
    }
  }

  void _navigateBack() {
    Navigator.pop(context);
  }

  void _showFuelTypePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Selecionar tipo de combustível',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.title,
              ),
            ),
            const SizedBox(height: 16),
            for (final fuelType in _fuelTypes) ListTile(
              title: Text(
                fuelType,
                style: const TextStyle(color: AppColors.textInput),
              ),
              onTap: () {
                setState(() {
                  _selectedFuelType = fuelType;
                  _fuelTypeController.text = fuelType;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.inputBackground,
              onSurface: AppColors.textInput,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _dateController.text = _formatDate(picked);
      });
    }
  }

  void _saveFueling() async {
    if (_formKey.currentState!.validate()) {
      final abastecimento = {
        'placa': _plateController.text,
        'data_hora': _parseDate(_dateController.text),
        'km': (_kmController.text.isNotEmpty ? _kmController.text : '0'),
        'combustivel': _selectedFuelType ?? '',
        'valor_por_litro': _valuePerLiterController.text.replaceAll(',', '.'),
        'litros_abastecidos': _litersController.text.replaceAll(',', '.'),
        'total_RS': _totalController.text.replaceAll(',', '.'),
        'sync': 0,
      };

      try {
        final hasConnection = await ServiceConnection.hasInternetConnection();
        if (hasConnection) {
          await ServiceLocalDatabase.instance.insertAbastecimento(abastecimento);
          await _serviceSync.syncAllModel();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Abastecimento salvo e sincronizado!'),
              backgroundColor: AppColors.primary,
            ),
          );
        } else {
          abastecimento['sync'] = 0;
          await ServiceLocalDatabase.instance.insertAbastecimento(abastecimento);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Abastecimento salvo localmente (offline)!'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar abastecimento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _parseDate(String dateStr) {
    // Espera formato dd/MM/yyyy
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final now = DateTime.now();
        // Usar a data selecionada mas com o horário atual para evitar duplicatas
        final dt = DateTime(year, month, day, now.hour, now.minute, now.second, now.millisecond);
        return dt.toIso8601String();
      }
    } catch (_) {}
    return DateTime.now().toIso8601String();
  }

  String _generateId() {
    // Gerar ID único baseado no timestamp
    final now = DateTime.now();
      final id = now.millisecondsSinceEpoch.toString().substring(8);
    return id.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
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

              // Título da página
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Novo abastecimento',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.title,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Formulário
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      // Placa do veículo
                      _buildTextField(
                        controller: _plateController,
                        label: 'Placa do veículo',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite a placa do veículo';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Data do abastecimento
                      _buildTextField(
                        controller: _dateController,
                        label: 'Data do abastecimento',
                        readOnly: true,
                        onTap: _showDatePicker,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Selecione a data';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Quilometragem
                      _buildTextField(
                        controller: _kmController,
                        label: 'Quilometragem (KM)',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite a quilometragem';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Digite um número válido';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Tipo de combustível
                      _buildTextField(
                        controller: _fuelTypeController,
                        label: 'Tipo de combustível',
                        readOnly: true,
                        onTap: _showFuelTypePicker,
                        suffixIcon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.textInput,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Selecione o tipo de combustível';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Valor por litro
                      _buildTextField(
                        controller: _valuePerLiterController,
                        label: 'Valor por litro (R\$)',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite o valor por litro';
                          }
                          if (double.tryParse(value.replaceAll(',', '.')) == null) {
                            return 'Digite um valor válido';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Litros abastecidos
                      _buildTextField(
                        controller: _litersController,
                        label: 'Litros abastecidos',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite a quantidade de litros';
                          }
                          if (double.tryParse(value.replaceAll(',', '.')) == null) {
                            return 'Digite um valor válido';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Total
                      _buildTextField(
                        controller: _totalController,
                        label: 'Total (R\$)',
                        readOnly: true,
                      ),

                      const SizedBox(height: 32),

                      // Botão Salvar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveFueling,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00796B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Salvar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF324B4B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        onTap: onTap,
        validator: validator,
        style: const TextStyle(color: AppColors.textInput),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textInput),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _plateController.dispose();
    _dateController.dispose();
    _kmController.dispose();
    _fuelTypeController.dispose();
    _valuePerLiterController.dispose();
    _litersController.dispose();
    _totalController.dispose();
    super.dispose();
  }
}
