import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simagestor_app/models/despesa.dart';
import 'package:simagestor_app/services/despesa_service.dart';
import 'package:simagestor_app/themes/app_colors.dart';

class FormDespesasPage extends StatefulWidget {
  const FormDespesasPage({super.key});

  @override
  State<FormDespesasPage> createState() => _FormDespesasPageState();
}

class _FormDespesasPageState extends State<FormDespesasPage> {
  final _formKey = GlobalKey<FormState>();
  final _placaController = TextEditingController();
  final _dataController = TextEditingController();
  final _valorController = TextEditingController();
  final _observacaoController = TextEditingController();

  String? _tipoDespesaSelecionado;
  String? _recorrenteSelecionado;
  bool _isLoading = false;

  final List<String> _tiposDespesa = [
    'Pedágio',
    'Estacionamento',
    'Conserto de pneu',
    'Manutenção não programada',
    'Despesas de viagem',
    'Rastreamento',
    'Aluguel de veículo',
    'Salário',
    'Financiamento',
    'Outros',
  ];

  final List<String> _opcoesRecorrente = ['Sim', 'Não'];

  @override
  void initState() {
    super.initState();
    _dataController.text = _formatarData(DateTime.now());
  }

  @override
  void dispose() {
    _placaController.dispose();
    _dataController.dispose();
    _valorController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  String? _validarPlaca(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Placa do veículo é obrigatória';
    }
    if (value.trim().length < 7) {
      return 'Placa deve ter pelo menos 7 caracteres';
    }
    return null;
  }

  String? _validarData(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Data da despesa é obrigatória';
    }
    return null;
  }

  String? _validarValor(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Valor da despesa é obrigatório';
    }
    final valor = double.tryParse(value.replaceAll(',', '.'));
    if (valor == null) {
      return 'Valor deve ser um número válido';
    }
    if (valor <= 0) {
      return 'Valor deve ser maior que zero';
    }
    return null;
  }

  String? _validarTipoDespesa(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tipo de despesa é obrigatório';
    }
    return null;
  }

  String? _validarRecorrente(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo recorrente é obrigatório';
    }
    return null;
  }

  String? _validarObservacao(String? value) {
    if (value != null && value.trim().length > 45) {
      return 'Observação deve ter no máximo 45 caracteres';
    }
    return null;
  }

  Future<void> _selecionarData() async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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

    if (dataSelecionada != null) {
      _dataController.text = _formatarData(dataSelecionada);
    }
  }

  Future<void> _salvarDespesa() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final novaDespesa = Despesa(
        idDespesa: 0, // Será gerado pelo serviço
        valor: double.parse(_valorController.text.replaceAll(',', '.')),
        placa: _placaController.text.trim(),
        observacao: _observacaoController.text.trim(),
        dataHora: DateTime.now(), // Usar data atual por enquanto
        recorrente: _recorrenteSelecionado == 'Sim',
        tipoDespesa: _tipoDespesaSelecionado!,
        configuracoesIdUsuario: 1, // ID do usuário atual (mockado)
      );

      await DespesaService.adicionarDespesa(novaDespesa);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Despesa salva com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar despesa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildDropdown<T>({
    required String? value,
    required List<T> items,
    required String Function(T) itemBuilder,
    required String? Function(String?) validator,
    required void Function(String?) onChanged,
    required String hintText,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: itemBuilder(item),
          child: Text(
            itemBuilder(item),
            style: const TextStyle(color: AppColors.textInput),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textInput),
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      dropdownColor: AppColors.inputBackground,
      icon: const Icon(Icons.arrow_drop_down, color: AppColors.textInput),
      style: const TextStyle(color: AppColors.textInput),
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
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Título
            Container(
              margin: const EdgeInsets.all(16),
              child: const Text(
                'Nova despesa',
                style: TextStyle(
                  color: AppColors.title,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Campos do formulário
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Placa do veículo
                    TextFormField(
                      controller: _placaController,
                      validator: _validarPlaca,
                      style: const TextStyle(color: AppColors.textInput),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[A-Za-z0-9\-]'),
                        ),
                        LengthLimitingTextInputFormatter(8),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Placa do veículo',
                        hintStyle: const TextStyle(color: AppColors.textInput),
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Data da despesa
                    TextFormField(
                      controller: _dataController,
                      validator: _validarData,
                      readOnly: true,
                      onTap: _selecionarData,
                      style: const TextStyle(color: AppColors.textInput),
                      decoration: InputDecoration(
                        hintText: 'Data da despesa',
                        hintStyle: const TextStyle(color: AppColors.textInput),
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          color: AppColors.textInput,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Valor da despesa
                    TextFormField(
                      controller: _valorController,
                      validator: _validarValor,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(color: AppColors.textInput),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Valor da despesa (R\$)',
                        hintStyle: const TextStyle(color: AppColors.textInput),
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Recorrente
                    _buildDropdown<String>(
                      value: _recorrenteSelecionado,
                      items: _opcoesRecorrente,
                      itemBuilder: (item) => item,
                      validator: _validarRecorrente,
                      onChanged: (value) {
                        setState(() {
                          _recorrenteSelecionado = value;
                        });
                      },
                      hintText: 'Recorrente',
                    ),

                    const SizedBox(height: 16),

                    // Tipo de despesa
                    _buildDropdown<String>(
                      value: _tipoDespesaSelecionado,
                      items: _tiposDespesa,
                      itemBuilder: (item) => item,
                      validator: _validarTipoDespesa,
                      onChanged: (value) {
                        setState(() {
                          _tipoDespesaSelecionado = value;
                        });
                      },
                      hintText: 'Tipo de despesa',
                    ),

                    const SizedBox(height: 16),

                    // Observação
                    TextFormField(
                      controller: _observacaoController,
                      validator: _validarObservacao,
                      maxLines: 3,
                      style: const TextStyle(color: AppColors.textInput),
                      decoration: InputDecoration(
                        hintText: 'Observação',
                        hintStyle: const TextStyle(color: AppColors.textInput),
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Botão Salvar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _salvarDespesa,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Salvar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
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
    );
  }
}
