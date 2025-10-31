import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import '../../models/checklist.dart';
import '../../services/checklist_service.dart';

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
            color: Colors.grey[900],
            child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(label, style: const TextStyle(fontSize: 16, color: Colors.white)),
                        const SizedBox(height: 8),
                        Row(
                            children: [
                                Expanded(
                                    child: RadioListTile<bool>(
                                        value: true,
                                        groupValue: selecionado,
                                        onChanged: (v) => setState(() => campos[key] = v),
                                        title: const Text("Ok", style: TextStyle(color: Colors.white)),
                                    ),
                                ),
                                Expanded(
                                    child: RadioListTile<bool>(
                                        value: false,
                                        groupValue: selecionado,
                                        onChanged: (v) => setState(() => campos[key] = v),
                                        title: const Text("Não Ok", style: TextStyle(color: Colors.white)),
                                    ),
                                ),
                            ],
                        ),
                        if (selecionado == false)
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        imagemAdicionada ? Colors.teal[300] : Colors.teal[700],
                            ),
                            onPressed: () => _pickImage(key),
                            child: Text(imagemAdicionada ? "Foto adicionada" : "Adicionar foto"),
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
            backgroundColor: Colors.black,
            appBar: AppBar(
                backgroundColor: Colors.teal[900],
                title: const Text("SimageStor"),
            ),
            body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                    children: [
                        TextField(
                            controller: placaController,
                            decoration: const InputDecoration(
                                labelText: "Placa do veículo",
                                filled: true,
                                fillColor: Colors.grey,
                            ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                            controller: motoristaController,
                            decoration: const InputDecoration(
                                labelText: "Motorista",
                                filled: true,
                                fillColor: Colors.grey,
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
                        const Text("Assinatura", style: TextStyle(color: Colors.white)),
                        Container(
                            height: 150,
                            color: Colors.grey[300],
                            child: Signature(controller: _signatureController, backgroundColor: Colors.grey[300]!),
                        ),
                        const SizedBox(height: 10),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                ElevatedButton(
                                    onPressed: _signatureController.clear,
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                                    child: const Text("Limpar assinatura"),
                                ),
                            ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                            onPressed: _salvarChecklist,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal[700],
                                minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text("Salvar", style: TextStyle(fontSize: 18)),
                        ),
                    ],
                ),
            ),
        );
    }
}
