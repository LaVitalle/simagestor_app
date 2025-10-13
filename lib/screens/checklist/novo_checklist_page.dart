import 'package:flutter/material.dart';
import 'package:simagestor_app/themes/app_colors.dart';
// TODO: importar seu model e seu service
// import 'package:simagestor_app/models/checklist.dart';
// import 'package:simagestor_app/services/checklist_service.dart';

class NovoChecklistPage extends StatefulWidget {
  const NovoChecklistPage({super.key});

  @override
  State<NovoChecklistPage> createState() => _NovoChecklistPageState();
}

class _NovoChecklistPageState extends State<NovoChecklistPage> {
  final TextEditingController placaController = TextEditingController();
  String freios = 'Ok';
  String pneus = 'Ok';
  String oleo = 'Ok';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.inputBackground,
                    ),
                    child: const Text('Voltar', style: TextStyle(color: AppColors.textInput)),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Simgestor',
                    style: TextStyle(color: AppColors.title, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Novo checklist',
                style: TextStyle(color: AppColors.title, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: placaController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  hintText: 'Placa do veículo',
                  hintStyle: const TextStyle(color: AppColors.textInput),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildRadioGroup('Freios', freios, (val) => setState(() => freios = val)),
              _buildRadioGroup('Pneus', pneus, (val) => setState(() => pneus = val)),
              ElevatedButton(
                onPressed: () {
                  // TODO: abrir picker de imagem
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Adicionar foto', style: TextStyle(color: Colors.white)),
              ),
              _buildRadioGroup('Nível de óleo', oleo, (val) => setState(() => oleo = val)),
              ElevatedButton(
                onPressed: () {
                  // TODO: abrir assinatura
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.inputBackground,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Assinatura', style: TextStyle(color: AppColors.textInput)),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  // TODO: salvar checklist via service
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Salvar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioGroup(String title, String groupValue, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(color: AppColors.text)),
        Row(
          children: [
            Radio<String>(
              value: 'Ok',
              groupValue: groupValue,
              onChanged: (val) => onChanged(val!),
              activeColor: AppColors.textButton,
            ),
            const Text('Ok', style: TextStyle(color: AppColors.text)),
            Radio<String>(
              value: 'Não Ok',
              groupValue: groupValue,
              onChanged: (val) => onChanged(val!),
              activeColor: AppColors.textButton,
            ),
            const Text('Não Ok', style: TextStyle(color: AppColors.text)),
          ],
        ),
      ],
    );
  }
}
