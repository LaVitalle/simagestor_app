import 'package:flutter/material.dart';
import '../models/checklist.dart';
import '../services/checklist_service.dart';

class DetalhesChecklistPage extends StatefulWidget {
  final int idChecklist;

  const DetalhesChecklistPage({super.key, required this.idChecklist});

  @override
  State<DetalhesChecklistPage> createState() => _DetalhesChecklistPageState();
}

class _DetalhesChecklistPageState extends State<DetalhesChecklistPage> {
  Checklist? checklist;
  bool carregando = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    _carregarChecklist();
  }

  Future<void> _carregarChecklist() async {
    try {
      final dados = await ChecklistService.buscarChecklistPorId(widget.idChecklist);
      setState(() {
        checklist = dados;
        carregando = false;
      });
    } catch (e) {
      setState(() {
        erro = e.toString();
        carregando = false;
      });
    }
  }

  Widget _buildCampo(String titulo, bool valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$titulo:",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            valor ? "Ok" : "Não Ok",
            style: TextStyle(
              color: valor ? Colors.tealAccent : Colors.redAccent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("SimageStor"),
        backgroundColor: Colors.teal[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          checklist!.placaVeiculo,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Data do checklist: ${checklist!.dataHora.day.toString().padLeft(2, '0')}/"
                          "${checklist!.dataHora.month.toString().padLeft(2, '0')}/"
                          "${checklist!.dataHora.year} "
                          "${checklist!.dataHora.hour.toString().padLeft(2, '0')}:"
                          "${checklist!.dataHora.minute.toString().padLeft(2, '0')}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),

                        _buildCampo("Freios", checklist!.freios),
                        _buildCampo("Pneus", checklist!.pneus),
                        _buildCampo("Nível de óleo", checklist!.nivelOleo),
                        _buildCampo("Faróis e lanternas", checklist!.faroisLanternas),
                        _buildCampo("Documentos do veículo", checklist!.documentosVeiculo),
                        _buildCampo("CNH do condutor", checklist!.cnhCondutor),
                        _buildCampo("Limpadores de para-brisa", checklist!.limpadoresParaBrisa),
                        _buildCampo("Cinto de segurança", checklist!.cintoSeguranca),
                        _buildCampo("Fluido de arrefecimento", checklist!.fluidoArrefecimento),
                        _buildCampo("Suspensão", checklist!.suspensao),

                        const SizedBox(height: 16),
                        const Text(
                          "Assinatura:",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 120,
                          width: double.infinity,
                          color: Colors.grey[300],
                          alignment: Alignment.center,
                          child: Text(
                            checklist!.campoAssinatura.isEmpty
                                ? "(sem assinatura)"
                                : "Assinatura registrada",
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
