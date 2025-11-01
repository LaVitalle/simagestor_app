import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import '../../models/checklist.dart';
import '../../services/checklist_service.dart';
import '../../themes/app_colors.dart';

class FormChecklistPage extends StatefulWidget {
    const FormChecklistPage({super.key});

    @override
    State<FormChecklistPage> createState() => _FormChecklistPageState();
}

class _FormChecklistPageState extends State<FormChecklistPage> {
    final TextEditingController placaController = TextEditingController();
    final TextEditingController motoristaController = TextEditingController();

    final Map<String, bool?> campos = {
        'freios': null,
        'pneus': null,
        'nivelOleo': null,
        'faroisLanternas': null,
        'documentosVeiculo': null,
        'cnhCondutor': null,
        'limpadoresParaBrisa': null,
        'cintoSeguranca': null,
        'fluidoArrefecimento': null,
        'suspensao': null,
    };

    final Map<String, File?> imagens = {};

    final SignatureController _signatureController = SignatureController(
        penStrokeWidth: 3,
        penColor: Colors.black,
    );

    final picker = ImagePicker();

    Future<void> _pickImage(String campo) async {
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
            setState(() {
                imagens[campo] = File(pickedFile.path);
            });
        }
    }

    Widget _buildCampo(String label, String key) {
        final selecionado = campos[key];
        final imagemAdicionada = imagens[key] != null;

        return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: AppColors.inputBackground,
            child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(label, style: const TextStyle(fontSize: 16, color: AppColors.title)),
                        const SizedBox(height: 8),
                        Row(
                            children: [
                                Expanded(
                                    child: RadioListTile<bool>(
                                        value: true,
                                        groupValue: selecionado,
                                        onChanged: (v) => setState(() => campos[key] = v),
                                        title: const Text("Ok", style: TextStyle(color: AppColors.title)),
                                    ),
                                ),
                                Expanded(
                                    child: RadioListTile<bool>(
                                        value: false,
                                        groupValue: selecionado,
                                        onChanged: (v) => setState(() => campos[key] = v),
                                        title: const Text("Não Ok", style: TextStyle(color: AppColors.title)),
                                    ),
                                ),
                            ],
                        ),
                        if (selecionado == false)
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        imagemAdicionada ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary,
                                ),
                                onPressed: () => _pickImage(key),
                                child: Text(
                                    imagemAdicionada ? "Foto adicionada" : "Adicionar foto",
                                    style: const TextStyle(color: Colors.white),
                                ),
                            ),
                    ],
                ),
            ),
        );
    }

    void _salvarChecklist() async {
        try {
            final checklist = Checklist(
                idChecklist: 0,
                placaVeiculo: placaController.text,
                motorista: motoristaController.text,
                freios: campos['freios'] ?? false,
                pneus: campos['pneus'] ?? false,
                nivelOleo: campos['nivelOleo'] ?? false,
                faroisLanternas: campos['faroisLanternas'] ?? false,
                documentosVeiculo: campos['documentosVeiculo'] ?? false,
                cnhCondutor: campos['cnhCondutor'] ?? false,
                limpadoresParaBrisa: campos['limpadoresParaBrisa'] ?? false,
                cintoSeguranca: campos['cintoSeguranca'] ?? false,
                fluidoArrefecimento: campos['fluidoArrefecimento'] ?? false,
                suspensao: campos['suspensao'] ?? false,
                campoAssinatura: "assinatura_base64_mockada",
                dataHora: DateTime.now(),
            );

            await ChecklistService.adicionarChecklist(checklist);

            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Checklist salvo com sucesso!")),
            );
        } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Erro ao salvar: $e")),
            );
        }
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
            body: Column(
                children: [
                    // Título
                    Container(
                        margin: const EdgeInsets.all(16),
                        child: const Text(
                            'Novo checklist',
                            style: TextStyle(
                                color: AppColors.title,
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                            ),
                        ),
                    ),
                    // Conteúdo com scroll
                    Expanded(
                        child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            child: Column(
                                children: [
                                    TextField(
                                        controller: placaController,
                                        decoration: InputDecoration(
                                            labelText: "Placa do veículo",
                                            labelStyle: const TextStyle(color: AppColors.textInput),
                                            filled: true,
                                            fillColor: AppColors.inputBackground,
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide.none,
                                            ),
                                        ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                        controller: motoristaController,
                                        decoration: InputDecoration(
                                            labelText: "Motorista",
                                            labelStyle: const TextStyle(color: AppColors.textInput),
                                            filled: true,
                                            fillColor: AppColors.inputBackground,
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide.none,
                                            ),
                                        ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Campos dinâmicos
                                    _buildCampo("Freios", "freios"),
                                    _buildCampo("Pneus", "pneus"),
                                    _buildCampo("Nível de óleo", "nivelOleo"),
                                    _buildCampo("Faróis e lanternas", "faroisLanternas"),
                                    _buildCampo("Documentos do veículo", "documentosVeiculo"),
                                    _buildCampo("CNH do condutor", "cnhCondutor"),
                                    _buildCampo("Limpadores de para-brisa", "limpadoresParaBrisa"),
                                    _buildCampo("Cinto de segurança", "cintoSeguranca"),
                                    _buildCampo("Fluido de arrefecimento", "fluidoArrefecimento"),
                                    _buildCampo("Suspensão", "suspensao"),

                                    const SizedBox(height: 20),
                                    const Text("Assinatura", style: TextStyle(color: AppColors.title, fontSize: 16)),
                                    const SizedBox(height: 10),
                                    Container(
                                        height: 150,
                                        decoration: BoxDecoration(
                                            color: AppColors.inputBackground,
                                            borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Signature(controller: _signatureController, backgroundColor: AppColors.inputBackground),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                            ElevatedButton(
                                                onPressed: _signatureController.clear,
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[600]),
                                                child: const Text("Limpar assinatura", style: TextStyle(color: Colors.white)),
                                            ),
                                        ],
                                    ),
                                    const SizedBox(height: 32),

                                    // Botão Salvar
                                    SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                            onPressed: _salvarChecklist,
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primary,
                                                minimumSize: const Size(double.infinity, 50),
                                            ),
                                            child: const Text("Salvar", style: TextStyle(fontSize: 18)),
                                        ),
                                    ),

                                    const SizedBox(height: 32),
                                ],
                            ),
                        ),
                    ),
                ],
            ),
        );
    }
}
