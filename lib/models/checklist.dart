class Checklist{
    final int idChecklist;
    final String placaVeiculo;
    final String motorista;
    final bool freios;
    final bool pneus;
    final bool nivelOleo;
    final bool faroisLanternas;
    final bool documentosVeiculo;
    final bool cnhCondutor;
    final bool limpadoresParaBrisa;
    final bool cintoSeguranca;
    final bool fluidoArrefecimento;
    final bool suspensao;
    final String campoAssinatura;  
    final DateTime dataHora;



    Checklist({
        required this.idChecklist,
        required this.placaVeiculo,
        required this.motorista,
        required this.freios,
        required this.pneus,
        required this.nivelOleo,
        required this.faroisLanternas,
        required this.documentosVeiculo,
        required this.cnhCondutor,
        required this.limpadoresParaBrisa,
        required this.cintoSeguranca,
        required this.fluidoArrefecimento,
        required this.suspensao,
        required this.campoAssinatura,
        required this.dataHora,

    });


    factory Checklist.fromJson(Map<String, dynamic> json) {
        return Checklist(
            idChecklist: json['id_checklist'] as int,
            placaVeiculo:json['placa_veiculo'] as String? ?? '',
            motorista:json['motorista'] as String? ?? '',
            freios: json['freios'] == 'ok' || json['freios'] == 1,
            pneus: json['pneus'] == 'ok' || json['pneus'] == 1,
            nivelOleo: json['nivel_oleo'] == 'ok' || json['nivel_oleo'] == 1,
            faroisLanternas: json['farois_lanterna'] == 'ok' || json['farois_lanterna'] == 1,
            documentosVeiculo: json['documentacao_veiculo'] == 'ok' || json['documentacao_veiculo'] == 1,
            cnhCondutor: json['CNH_motorista'] == 'ok' || json['CNH_motorista'] == 1,
            limpadoresParaBrisa: json['limpadores_parabrisa'] == 'ok' || json['limpadores_parabrisa'] == 1,
            cintoSeguranca: json['cintos_de_seguranca'] == 'ok' || json['cintos_de_seguranca'] == 1,
            fluidoArrefecimento: json['fluido_de_arrefecimento'] == 'ok' || json['fluido_de_arrefecimento'] == 1,
            suspensao: json['suspensao'] == 'ok' || json['suspensao'] == 1,
            campoAssinatura:json['campo_assinatura'] as String? ?? '',
            dataHora: DateTime.parse(json['data_hora'] ?? DateTime.now().toIso8601String()),
        );
    }    


    Map<String, dynamic> toJson() {
        return {
            'id_checklist': idChecklist,
            'placa_veiculo': placaVeiculo,
            'motorista': motorista,
            'freios': freios ? 'ok' : 'not_ok',
            'pneus': pneus ? 'ok' : 'not_ok',
            'nivel_oleo': nivelOleo ? 'ok' : 'not_ok',
            'farois_lanterna': faroisLanternas ? 'ok' : 'not_ok',
            'documentacao_veiculo': documentosVeiculo ? 'ok' : 'not_ok',
            'CNH_motorista': cnhCondutor ? 'ok' : 'not_ok',
            'limpadores_parabrisa': limpadoresParaBrisa ? 'ok' : 'not_ok',
            'cintos_de_seguranca': cintoSeguranca ? 'ok' : 'not_ok',
            'fluido_de_arrefecimento': fluidoArrefecimento ? 'ok' : 'not_ok',
            'suspensao': suspensao ? 'ok' : 'not_ok',
            'campo_assinatura': campoAssinatura,
            'data_hora': dataHora.toIso8601String(),

        };
    }

    @override
    String toString() {
      return 'Checklist {id_checklist: $idChecklist, placaVeiculo: $placaVeiculo, motorista: $motorista, freios: $freios, pneus: $pneus, nivelOleo: $nivelOleo, faroisLanternas: $faroisLanternas, documentosVeiculo: $documentosVeiculo, cnhCondutor: $cnhCondutor, limpadoresParaBrisa: $limpadoresParaBrisa, cintoSeguranca: $cintoSeguranca, fluidoArrefecimento: $fluidoArrefecimento, suspensao: $suspensao, campoAssinatura: $campoAssinatura}';
    }
}