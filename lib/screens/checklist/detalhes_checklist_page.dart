import 'package:flutter/material.dart';
import '../../models/checklist.dart';
import '../../services/checklist_service.dart';
import '../../services/service_local_database.dart';
import '../../themes/app_colors.dart';

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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        color: AppColors.title,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCampo(String titulo, bool valor, String? comentario) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "$titulo:",
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                valor ? "OK" : "Não OK",
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
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: carregando
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : erro != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'Erro ao carregar checklist',
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
                      ],
                    ),
                  )
                : checklist == null
                    ? const Center(
                        child: Text(
                          'Checklist não encontrado',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  'Simagestor',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.title,
                                  ),
                                ),
                                const Spacer(),
                                const SizedBox(width: 80),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Placa do veículo
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                placaVeiculo ?? '',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.title,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Motorista
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Motorista: $nomeMotorista',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.text,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Data
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Data do checklist: ${checklist!.dataHora.day.toString().padLeft(2, '0')}/"
                                "${checklist!.dataHora.month.toString().padLeft(2, '0')}/"
                                "${checklist!.dataHora.year} "
                                "${checklist!.dataHora.hour.toString().padLeft(2, '0')}:"
                                "${checklist!.dataHora.minute.toString().padLeft(2, '0')}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.text,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Conteúdo
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle('Itens verificados'),
                                  const SizedBox(height: 16),

                                  _buildCampo("Freios", checklist!.freios, checklist!.freiosComentario),
                                  _buildCampo("Pneus", checklist!.pneus, checklist!.pneusComentario),
                                  _buildCampo(
                                      "Nível de óleo", checklist!.nivelOleo, checklist!.nivelOleoComentario),
                                  _buildCampo("Faróis e lanternas", checklist!.faroisLanternas,
                                      checklist!.faroisLanternasComentario),
                                  _buildCampo("Documentos do veículo", checklist!.documentosVeiculo,
                                      checklist!.documentosVeiculoComentario),
                                  _buildCampo("CNH do condutor", checklist!.cnhCondutor,
                                      checklist!.cnhCondutorComentario),
                                  _buildCampo("Limpadores de para-brisa", checklist!.limpadoresParaBrisa,
                                      checklist!.limpadoresParaBrisaComentario),
                                  _buildCampo("Cinto de segurança", checklist!.cintoSeguranca,
                                      checklist!.cintoSegurancaComentario),
                                  _buildCampo("Fluido de arrefecimento", checklist!.fluidoArrefecimento,
                                      checklist!.fluidoArrefecimentoComentario),
                                  _buildCampo(
                                      "Suspensão", checklist!.suspensao, checklist!.suspensaoComentario),

                                  const SizedBox(height: 24),

                                  _buildSectionTitle('Assinatura'),
                                  const SizedBox(height: 16),

                                  Container(
                                    height: 120,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      checklist!.campoAssinatura.isEmpty
                                          ? "(sem assinatura)"
                                          : "Assinatura registrada",
                                      style: const TextStyle(color: Colors.black54),
                                    ),
                                  ),

                                  const SizedBox(height: 24),
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
