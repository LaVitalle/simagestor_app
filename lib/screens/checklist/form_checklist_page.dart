import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import '../../models/checklist.dart';
import '../../services/checklist_service.dart';
import '../../services/service_local_database.dart';
import '../../themes/app_colors.dart';

class FormChecklistPage extends StatefulWidget {
    const FormChecklistPage({super.key});

    @override
    State<FormChecklistPage> createState() => _FormChecklistPageState();
}

class _FormChecklistPageState extends State<FormChecklistPage> {
    int? selectedVehicleId;
    int? selectedDriverId;
    
    List<Map<String, dynamic>> veiculos = [];
    List<Map<String, dynamic>> motoristas = [];
    bool isLoadingData = true;

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

    final Map<String, TextEditingController> comentarios = {
        'freios': TextEditingController(),
        'pneus': TextEditingController(),
        'nivelOleo': TextEditingController(),
        'faroisLanternas': TextEditingController(),
        'documentosVeiculo': TextEditingController(),
        'cnhCondutor': TextEditingController(),
        'limpadoresParaBrisa': TextEditingController(),
        'cintoSeguranca': TextEditingController(),
        'fluidoArrefecimento': TextEditingController(),
        'suspensao': TextEditingController(),
    };

    final Map<String, File?> imagens = {};

    final SignatureController _signatureController = SignatureController(
        penStrokeWidth: 3,
        penColor: Colors.black,
    );

    final picker = ImagePicker();

    @override
    void initState() {
        super.initState();
        _loadData();
    }

    @override
    void dispose() {
        // Limpa os controllers
        for (var controller in comentarios.values) {
            controller.dispose();
        }
        _signatureController.dispose();
        super.dispose();
    }

    Future<void> _loadData() async {
        try {
            final db = ServiceLocalDatabase.instance;
            final veiculosList = await db.getAllVeiculos();
            final motoristasList = await db.getAllMotoristas();
            
            setState(() {
                veiculos = veiculosList;
                motoristas = motoristasList;
                isLoadingData = false;
            });
        } catch (e) {
            debugPrint('Erro ao carregar dados: $e');
            setState(() {
                isLoadingData = false;
            });
        }
    }

    Future<void> _pickImage(String key) async {
        try {
            final XFile? pickedFile = await picker.pickImage(
                source: ImageSource.camera,
                maxWidth: 1920,
                maxHeight: 1080,
                imageQuality: 85,
            );
            
            if (pickedFile != null) {
                setState(() {
                    imagens[key] = File(pickedFile.path);
                });
            }
        } catch (e) {
            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao capturar foto: $e')),
                );
            }
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
                        Text(label, style: const TextStyle(fontSize: 16, color: AppColors.title, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Row(
                            children: [
                                Expanded(
                                    child: RadioListTile<bool>(
                                        value: true,
                                        groupValue: selecionado,
                                        onChanged: (v) => setState(() => campos[key] = v),
                                        title: const Text("OK", style: TextStyle(color: AppColors.title)),
                                    ),
                                ),
                                Expanded(
                                    child: RadioListTile<bool>(
                                        value: false,
                                        groupValue: selecionado,
                                        onChanged: (v) => setState(() => campos[key] = v),
                                        title: const Text("Não OK", style: TextStyle(color: AppColors.title)),
                                    ),
                                ),
                            ],
                        ),
                        if (selecionado == false) ...[
                            const SizedBox(height: 8),
                            TextField(
                                controller: comentarios[key],
                                style: const TextStyle(color: AppColors.textInput),
                                decoration: InputDecoration(
                                    hintText: "Comentários opcionais",
                                    hintStyle: const TextStyle(color: AppColors.textInput),
                                    filled: true,
                                    fillColor: AppColors.background,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                    ),
                                ),
                                maxLines: 2,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        imagemAdicionada ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary,
                                ),
                                onPressed: () => _pickImage(key),
                                icon: Icon(
                                    imagemAdicionada ? Icons.check_circle : Icons.camera_alt,
                                    color: Colors.white,
                                ),
                                label: Text(
                                    imagemAdicionada ? "Foto adicionada" : "Tirar foto",
                                    style: const TextStyle(color: Colors.white),
                                ),
                            ),
                        ],
                    ],
                ),
            ),
        );
    }

    void _salvarChecklist() async {
        if (selectedVehicleId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Selecione um veículo")),
            );
            return;
        }

        if (selectedDriverId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Selecione um motorista")),
            );
            return;
        }

        try {
            final checklist = Checklist(
                idChecklist: 0,
                vehicleId: selectedVehicleId!,
                driverId: selectedDriverId!,
                freios: campos['freios'] ?? false,
                freiosComentario: comentarios['freios']?.text,
                freiosFoto: imagens['freios']?.path,
                pneus: campos['pneus'] ?? false,
                pneusComentario: comentarios['pneus']?.text,
                pneusFoto: imagens['pneus']?.path,
                nivelOleo: campos['nivelOleo'] ?? false,
                nivelOleoComentario: comentarios['nivelOleo']?.text,
                nivelOleoFoto: imagens['nivelOleo']?.path,
                faroisLanternas: campos['faroisLanternas'] ?? false,
                faroisLanternasComentario: comentarios['faroisLanternas']?.text,
                faroisLanternasFoto: imagens['faroisLanternas']?.path,
                documentosVeiculo: campos['documentosVeiculo'] ?? false,
                documentosVeiculoComentario: comentarios['documentosVeiculo']?.text,
                documentosVeiculoFoto: imagens['documentosVeiculo']?.path,
                cnhCondutor: campos['cnhCondutor'] ?? false,
                cnhCondutorComentario: comentarios['cnhCondutor']?.text,
                cnhCondutorFoto: imagens['cnhCondutor']?.path,
                limpadoresParaBrisa: campos['limpadoresParaBrisa'] ?? false,
                limpadoresParaBrisaComentario: comentarios['limpadoresParaBrisa']?.text,
                limpadoresParaBrisaFoto: imagens['limpadoresParaBrisa']?.path,
                cintoSeguranca: campos['cintoSeguranca'] ?? false,
                cintoSegurancaComentario: comentarios['cintoSeguranca']?.text,
                cintoSegurancaFoto: imagens['cintoSeguranca']?.path,
                fluidoArrefecimento: campos['fluidoArrefecimento'] ?? false,
                fluidoArrefecimentoComentario: comentarios['fluidoArrefecimento']?.text,
                fluidoArrefecimentoFoto: imagens['fluidoArrefecimento']?.path,
                suspensao: campos['suspensao'] ?? false,
                suspensaoComentario: comentarios['suspensao']?.text,
                suspensaoFoto: imagens['suspensao']?.path,
                campoAssinatura: "assinatura_base64_mockada",
                dataHora: DateTime.now(),
            );

            debugPrint('FormChecklist: Chamando ChecklistService.adicionarChecklist');
            await ChecklistService.adicionarChecklist(checklist);
            debugPrint('FormChecklist: Checklist adicionado com sucesso');

            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Checklist salvo com sucesso!"),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                    ),
                );
                Navigator.of(context).pop();
            }
        } catch (e) {
            debugPrint('FormChecklist: Erro ao salvar checklist: $e');
            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Erro ao salvar: $e"),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                    ),
                );
            }
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
            body: isLoadingData
                ? const Center(child: CircularProgressIndicator())
                : Column(
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
                                    // Dropdown Veículo
                                    DropdownButtonFormField<int>(
                                        value: selectedVehicleId,
                                        decoration: InputDecoration(
                                            labelText: "Veículo",
                                            labelStyle: const TextStyle(color: AppColors.textInput),
                                            filled: true,
                                            fillColor: AppColors.inputBackground,
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide.none,
                                            ),
                                        ),
                                        dropdownColor: AppColors.inputBackground,
                                        style: const TextStyle(color: AppColors.title),
                                        items: veiculos.map((veiculo) {
                                            return DropdownMenuItem<int>(
                                                value: veiculo['id'] as int,
                                                child: Text(
                                                    "${veiculo['placa']} - ${veiculo['tipo']}",
                                                    style: const TextStyle(color: AppColors.title),
                                                ),
                                            );
                                        }).toList(),
                                        onChanged: (value) {
                                            setState(() {
                                                selectedVehicleId = value;
                                            });
                                        },
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Dropdown Motorista
                                    DropdownButtonFormField<int>(
                                        value: selectedDriverId,
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
                                        dropdownColor: AppColors.inputBackground,
                                        style: const TextStyle(color: AppColors.title),
                                        items: motoristas.map((motorista) {
                                            return DropdownMenuItem<int>(
                                                value: motorista['id'] as int,
                                                child: Text(
                                                    motorista['nome'] as String,
                                                    style: const TextStyle(color: AppColors.title),
                                                ),
                                            );
                                        }).toList(),
                                        onChanged: (value) {
                                            setState(() {
                                                selectedDriverId = value;
                                            });
                                        },
                                    ),
                                    const SizedBox(height: 20),

                                    // Campos dinâmicos
                                    _buildCampo("Verificar freios", "freios"),
                                    _buildCampo("Checar pneus (pressão e desgaste)", "pneus"),
                                    _buildCampo("Verificar nível de óleo", "nivelOleo"),
                                    _buildCampo("Testar faróis e lanternas", "faroisLanternas"),
                                    _buildCampo("Verificar documentação do veículo", "documentosVeiculo"),
                                    _buildCampo("Minha CNH está OK", "cnhCondutor"),
                                    _buildCampo("Checar limpadores de para-brisa", "limpadoresParaBrisa"),
                                    _buildCampo("Verificar cintos de segurança", "cintoSeguranca"),
                                    _buildCampo("Verificar fluido de arrefecimento", "fluidoArrefecimento"),
                                    _buildCampo("Avaliar suspensão (leves)", "suspensao"),

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
                                            child: const Text("Salvar", style: TextStyle(fontSize: 18, color: Colors.white)),
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
