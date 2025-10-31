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
            freios: json['freios'] == 1,
            pneus: json['pneus'] == 1,
            nivelOleo: json['nivel_oleo'] == 1,
            faroisLanternas:json['farois_lanternas'] == 1,
            documentosVeiculo: json['documentos_veiculo'] == 1,
            cnhCondutor: json['cnh_condutor'] == 1,
            limpadoresParaBrisa: json['limpadores_para_brisa'] == 1,
            cintoSeguranca: json['cinto_seguranca'] == 1,
            fluidoArrefecimento: json['fluido_arrefecimento'] == 1,
            suspensao: json['suspensao'] == 1,
            campoAssinatura:json['campo_assinatura'] as String? ?? '',
            dataHora: DateTime.parse(json['data_hora'] ?? DateTime.now().toIso8601String()),
        );
    }    


    Map<String, dynamic> toJson() {
        return {
            'id_checklist': idChecklist,
            'placa_veiculo': placaVeiculo,
            'motorista': motorista,
            'freios': freios ? 1 : 0,
            'pneus': pneus ? 1 : 0,
            'nivel_oleo': nivelOleo ? 1 : 0,
            'farois_lanternas': faroisLanternas ? 1 : 0,
            'documentos_veiculo': documentosVeiculo ? 1 : 0,
            'cnh_condutor': cnhCondutor ? 1 : 0,
            'limpadores_para_brisa': limpadoresParaBrisa ? 1 : 0,
            'cinto_seguranca': cintoSeguranca ? 1 : 0,
            'fluido_arrefecimento': fluidoArrefecimento ? 1 : 0,
            'suspensao': suspensao ? 1 : 0,
            'campo_assinatura': campoAssinatura,
            'data_hora': dataHora.toIso8601String(),

        };
    }

    @override
    String toString() {
      return 'Checklist {id_checklist: $idChecklist, placaVeiculo: $placaVeiculo, motorista: $motorista, freios: $freios, pneus: $pneus, nivelOleo: $nivelOleo, faroisLanternas: $faroisLanternas, documentosVeiculo: $documentosVeiculo, cnhCondutor: $cnhCondutor, limpadoresParaBrisa: $limpadoresParaBrisa, cintoSeguranca: $cintoSeguranca, fluidoArrefecimento: $fluidoArrefecimento, suspensao: $suspensao, campoAssinatura: $campoAssinatura}';
    }
}