import 'package:flutter/material.dart';
import '../../models/checklist.dart';
import '../../services/checklist_service.dart';
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
            backgroundColor: Colors.black,
            appBar: AppBar(
                title: const Text("SimageStor"),
                backgroundColor: Colors.teal[900],
            ),
            floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.teal[700],
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
                            color: Colors.teal[900],
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                                title: Text(
                                    c.placaVeiculo,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                    "Motorista: ${c.motorista}\n"
                                    "Data: ${c.dataHora.day}/${c.dataHora.month}/${c.dataHora.year}",
                                    style: const TextStyle(color: Colors.white70),
                                ),
                                trailing: IconButton(
                                    icon: const Icon(Icons.remove_red_eye, color: Colors.white),
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
