import 'package:flutter/material.dart';
import '../../models/checklist.dart';
import '../../services/checklist_service.dart';
import '../../services/service_local_database.dart';
import '../../themes/app_colors.dart';
import 'detalhes_checklist_page.dart';
import 'form_checklist_page.dart';

class ChecklistPage extends StatefulWidget {
    const ChecklistPage({super.key});

    @override
    State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
    List<Checklist> checklists = [];
    Map<int, String> veiculosMap = {};
    Map<int, String> motoristasMap = {};
    bool carregando = true;
    String? erro;

    @override
    void initState() {
        super.initState();
        _carregarDados();
    }

    Future<void> _carregarDados() async {
        try {
            final db = ServiceLocalDatabase.instance;
            
            // Carrega veículos e motoristas
            final veiculos = await db.getAllVeiculos();
            final motoristas = await db.getAllMotoristas();
            
            // Cria mapas de ID para nome/placa
            for (var veiculo in veiculos) {
                veiculosMap[veiculo['id']] = veiculo['placa'];
            }
            for (var motorista in motoristas) {
                motoristasMap[motorista['id']] = motorista['nome'];
            }
            
            // Carrega checklists
            final dados = await ChecklistService.buscarChecklists();
            setState(() {
                checklists = dados;
                carregando = false;
            });
        } catch (e) {
            setState(() {
                erro = e.toString();
                carregando = false;
            });
        }
    }

    Future<void> _carregarChecklists() async {
        await _carregarDados();
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
                actions: [
                    Container(
                        margin: const EdgeInsets.only(right: 16),
                        child: const Text(
                            'Checklists',
                            style: TextStyle(
                                color: AppColors.title,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                            ),
                        ),
                    ),
                ],
            ),
            body: Column(
                children: [
                    // Conteúdo principal
                    Expanded(
                        child: _buildContent(),
                    ),
                    
                    // Botão de nova checklist
                    SafeArea(
                        child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.all(16),
                            child: ElevatedButton(
                                onPressed: _novaChecklist,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                    ),
                                ),
                                child: const Text(
                                    'Nova checklist',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                            ),
                        ),
                    ),
                ],
            ),
        );
    }

    void _novaChecklist() async {
        await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormChecklistPage()),
        );
        _carregarChecklists(); // Atualiza lista ao voltar
    }

    Widget _buildContent() {
        if (carregando) {
            return const Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
            );
        }

        if (erro != null) {
            return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                            'Erro ao carregar checklists',
                            style: TextStyle(
                                color: AppColors.text,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                            ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                            erro!,
                            style: const TextStyle(color: AppColors.text, fontSize: 14),
                            textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                            onPressed: _carregarDados,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                            ),
                            child: const Text('Tentar novamente'),
                        ),
                    ],
                ),
            );
        }

        if (checklists.isEmpty) {
            return const Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Icon(Icons.checklist_outlined, color: AppColors.text, size: 64),
                        SizedBox(height: 16),
                        Text(
                            'Nenhuma checklist encontrada',
                            style: TextStyle(
                                color: AppColors.text,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                            ),
                        ),
                        SizedBox(height: 8),
                        Text(
                            'Adicione sua primeira checklist',
                            style: TextStyle(color: AppColors.text, fontSize: 14),
                        ),
                    ],
                ),
            );
        }

        return ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: checklists.length,
            itemBuilder: (context, index) {
                final c = checklists[index];
                return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                        title: Text(
                            veiculosMap[c.vehicleId] ?? 'Veículo #${c.vehicleId}',
                            style: const TextStyle(color: AppColors.title, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            "Motorista: ${motoristasMap[c.driverId] ?? 'Motorista #${c.driverId}'}\n"
                            "Data: ${c.dataHora.day}/${c.dataHora.month}/${c.dataHora.year}",
                            style: const TextStyle(color: AppColors.text),
                        ),
                        trailing: IconButton(
                            icon: const Icon(Icons.remove_red_eye, color: AppColors.title),
                            onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => DetalhesChecklistPage(idChecklist: c.idChecklist),
                                    ),
                                );
                            },
                        ),
                    ),
                );
            },
        );
    }
}
