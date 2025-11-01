import 'package:flutter/material.dart';
import '../../models/checklist.dart';
import '../../services/checklist_service.dart';
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
    bool carregando = true;
    String? erro;

    @override
    void initState() {
        super.initState();
        _carregarChecklists();
    }

    Future<void> _carregarChecklists() async {
    try {
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
            floatingActionButton: FloatingActionButton(
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add),
                onPressed: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FormChecklistPage()),
                    );
                    _carregarChecklists(); // Atualiza lista ao voltar
                },
            ),
            body: carregando
            ? const Center(child: CircularProgressIndicator())
            : erro != null
                ? Center(
                    child: Text(
                        "Erro ao carregar: $erro",
                        style: const TextStyle(color: Colors.redAccent),
                    ),
                )
                : ListView.builder(
                    itemCount: checklists.length,
                    itemBuilder: (context, index) {
                        final c = checklists[index];
                        return Card(
                            color: AppColors.inputBackground,
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                                title: Text(
                                    c.placaVeiculo,
                                    style: const TextStyle(color: AppColors.title, fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                    "Motorista: ${c.motorista}\n"
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
                ),
        );
    }
}
