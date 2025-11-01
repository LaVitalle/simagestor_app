import 'package:flutter/material.dart';
import '../../models/checklist.dart';
import '../../services/checklist_service.dart';
import '../../services/service_local_database.dart';

class DetalhesChecklistPage extends StatefulWidget {
  final int idChecklist;

  const DetalhesChecklistPage({super.key, required this.idChecklist});

  @override
  State<DetalhesChecklistPage> createState() => _DetalhesChecklistPageState();
}

class _DetalhesChecklistPageState extends State<DetalhesChecklistPage> {
  Checklist? checklist;
  String? placaVeiculo;
  String? nomeMotorista;
  bool carregando = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    _carregarChecklist();
  }

  Future<void> _carregarChecklist() async {
    try {
      final db = ServiceLocalDatabase.instance;
      final dados = await ChecklistService.buscarChecklistPorId(widget.idChecklist);
      
      // Busca informações do veículo e motorista
      final veiculo = await db.getAllVeiculos();
      final motorista = await db.getAllMotoristas();
      
      final veiculoData = veiculo.where((v) => v['id'] == dados.vehicleId).firstOrNull;
      final motoristaData = motorista.where((m) => m['id'] == dados.driverId).firstOrNull;
      
      setState(() {
        checklist = dados;
        placaVeiculo = veiculoData?['placa'] ?? 'Veículo #${dados.vehicleId}';
        nomeMotorista = motoristaData?['nome'] ?? 'Motorista #${dados.driverId}';
        carregando = false;
      });
    } catch (e) {
      setState(() {
        erro = e.toString();
        carregando = false;
      });
    }
  }

  Widget _buildCampo(String titulo, bool valor, String? comentario) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          if (!valor && comentario != null && comentario.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                "Comentário: $comentario",
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
          ],
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
                          placaVeiculo ?? '',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Motorista: $nomeMotorista",
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
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

                        _buildCampo("Freios", checklist!.freios, checklist!.freiosComentario),
                        _buildCampo("Pneus", checklist!.pneus, checklist!.pneusComentario),
                        _buildCampo("Nível de óleo", checklist!.nivelOleo, checklist!.nivelOleoComentario),
                        _buildCampo("Faróis e lanternas", checklist!.faroisLanternas, checklist!.faroisLanternasComentario),
                        _buildCampo("Documentos do veículo", checklist!.documentosVeiculo, checklist!.documentosVeiculoComentario),
                        _buildCampo("CNH do condutor", checklist!.cnhCondutor, checklist!.cnhCondutorComentario),
                        _buildCampo("Limpadores de para-brisa", checklist!.limpadoresParaBrisa, checklist!.limpadoresParaBrisaComentario),
                        _buildCampo("Cinto de segurança", checklist!.cintoSeguranca, checklist!.cintoSegurancaComentario),
                        _buildCampo("Fluido de arrefecimento", checklist!.fluidoArrefecimento, checklist!.fluidoArrefecimentoComentario),
                        _buildCampo("Suspensão", checklist!.suspensao, checklist!.suspensaoComentario),

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
