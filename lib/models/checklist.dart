class Checklist{
    final int idChecklist;
    final int vehicleId;
    final int driverId;
    final bool freios;
    final String? freiosComentario;
    final String? freiosFoto;
    final bool pneus;
    final String? pneusComentario;
    final String? pneusFoto;
    final bool nivelOleo;
    final String? nivelOleoComentario;
    final String? nivelOleoFoto;
    final bool faroisLanternas;
    final String? faroisLanternasComentario;
    final String? faroisLanternasFoto;
    final bool documentosVeiculo;
    final String? documentosVeiculoComentario;
    final String? documentosVeiculoFoto;
    final bool cnhCondutor;
    final String? cnhCondutorComentario;
    final String? cnhCondutorFoto;
    final bool limpadoresParaBrisa;
    final String? limpadoresParaBrisaComentario;
    final String? limpadoresParaBrisaFoto;
    final bool cintoSeguranca;
    final String? cintoSegurancaComentario;
    final String? cintoSegurancaFoto;
    final bool fluidoArrefecimento;
    final String? fluidoArrefecimentoComentario;
    final String? fluidoArrefecimentoFoto;
    final bool suspensao;
    final String? suspensaoComentario;
    final String? suspensaoFoto;
    final String campoAssinatura;  
    final DateTime dataHora;



    Checklist({
        required this.idChecklist,
        required this.vehicleId,
        required this.driverId,
        required this.freios,
        this.freiosComentario,
        this.freiosFoto,
        required this.pneus,
        this.pneusComentario,
        this.pneusFoto,
        required this.nivelOleo,
        this.nivelOleoComentario,
        this.nivelOleoFoto,
        required this.faroisLanternas,
        this.faroisLanternasComentario,
        this.faroisLanternasFoto,
        required this.documentosVeiculo,
        this.documentosVeiculoComentario,
        this.documentosVeiculoFoto,
        required this.cnhCondutor,
        this.cnhCondutorComentario,
        this.cnhCondutorFoto,
        required this.limpadoresParaBrisa,
        this.limpadoresParaBrisaComentario,
        this.limpadoresParaBrisaFoto,
        required this.cintoSeguranca,
        this.cintoSegurancaComentario,
        this.cintoSegurancaFoto,
        required this.fluidoArrefecimento,
        this.fluidoArrefecimentoComentario,
        this.fluidoArrefecimentoFoto,
        required this.suspensao,
        this.suspensaoComentario,
        this.suspensaoFoto,
        required this.campoAssinatura,
        required this.dataHora,

    });


    factory Checklist.fromJson(Map<String, dynamic> json) {
        return Checklist(
            idChecklist: json['id_checklist'] as int,
            vehicleId: json['vehicle_id'] as int,
            driverId: json['driver_id'] as int,
            freios: json['freios'] == 'ok' || json['freios'] == 1,
            freiosComentario: json['freios_comentario'] as String?,
            freiosFoto: json['freios_foto'] as String?,
            pneus: json['pneus'] == 'ok' || json['pneus'] == 1,
            pneusComentario: json['pneus_comentario'] as String?,
            pneusFoto: json['pneus_foto'] as String?,
            nivelOleo: json['nivel_oleo'] == 'ok' || json['nivel_oleo'] == 1,
            nivelOleoComentario: json['nivel_oleo_comentario'] as String?,
            nivelOleoFoto: json['nivel_oleo_foto'] as String?,
            faroisLanternas: json['farois_lanterna'] == 'ok' || json['farois_lanterna'] == 1,
            faroisLanternasComentario: json['farois_lanterna_comentario'] as String?,
            faroisLanternasFoto: json['farois_lanterna_foto'] as String?,
            documentosVeiculo: json['documentacao_veiculo'] == 'ok' || json['documentacao_veiculo'] == 1,
            documentosVeiculoComentario: json['documentacao_veiculo_comentario'] as String?,
            documentosVeiculoFoto: json['documentacao_veiculo_foto'] as String?,
            cnhCondutor: json['CNH_motorista'] == 'ok' || json['CNH_motorista'] == 1,
            cnhCondutorComentario: json['CNH_motorista_comentario'] as String?,
            cnhCondutorFoto: json['CNH_motorista_foto'] as String?,
            limpadoresParaBrisa: json['limpadores_parabrisa'] == 'ok' || json['limpadores_parabrisa'] == 1,
            limpadoresParaBrisaComentario: json['limpadores_parabrisa_comentario'] as String?,
            limpadoresParaBrisaFoto: json['limpadores_parabrisa_foto'] as String?,
            cintoSeguranca: json['cintos_de_seguranca'] == 'ok' || json['cintos_de_seguranca'] == 1,
            cintoSegurancaComentario: json['cintos_de_seguranca_comentario'] as String?,
            cintoSegurancaFoto: json['cintos_de_seguranca_foto'] as String?,
            fluidoArrefecimento: json['fluido_de_arrefecimento'] == 'ok' || json['fluido_de_arrefecimento'] == 1,
            fluidoArrefecimentoComentario: json['fluido_de_arrefecimento_comentario'] as String?,
            fluidoArrefecimentoFoto: json['fluido_de_arrefecimento_foto'] as String?,
            suspensao: json['suspensao'] == 'ok' || json['suspensao'] == 1,
            suspensaoComentario: json['suspensao_comentario'] as String?,
            suspensaoFoto: json['suspensao_foto'] as String?,
            campoAssinatura: json['campo_assinatura'] as String? ?? '',
            dataHora: DateTime.parse(json['data_hora'] ?? DateTime.now().toIso8601String()),
        );
    }    


    Map<String, dynamic> toJson() {
        return {
            'id_checklist': idChecklist,
            'vehicle_id': vehicleId,
            'driver_id': driverId,
            'freios': freios ? 'ok' : 'not_ok',
            'freios_comentario': freiosComentario ?? '',
            'freios_foto': freiosFoto ?? '',
            'pneus': pneus ? 'ok' : 'not_ok',
            'pneus_comentario': pneusComentario ?? '',
            'pneus_foto': pneusFoto ?? '',
            'nivel_oleo': nivelOleo ? 'ok' : 'not_ok',
            'nivel_oleo_comentario': nivelOleoComentario ?? '',
            'nivel_oleo_foto': nivelOleoFoto ?? '',
            'farois_lanterna': faroisLanternas ? 'ok' : 'not_ok',
            'farois_lanterna_comentario': faroisLanternasComentario ?? '',
            'farois_lanterna_foto': faroisLanternasFoto ?? '',
            'documentacao_veiculo': documentosVeiculo ? 'ok' : 'not_ok',
            'documentacao_veiculo_comentario': documentosVeiculoComentario ?? '',
            'documentacao_veiculo_foto': documentosVeiculoFoto ?? '',
            'CNH_motorista': cnhCondutor ? 'ok' : 'not_ok',
            'CNH_motorista_comentario': cnhCondutorComentario ?? '',
            'CNH_motorista_foto': cnhCondutorFoto ?? '',
            'limpadores_parabrisa': limpadoresParaBrisa ? 'ok' : 'not_ok',
            'limpadores_parabrisa_comentario': limpadoresParaBrisaComentario ?? '',
            'limpadores_parabrisa_foto': limpadoresParaBrisaFoto ?? '',
            'cintos_de_seguranca': cintoSeguranca ? 'ok' : 'not_ok',
            'cintos_de_seguranca_comentario': cintoSegurancaComentario ?? '',
            'cintos_de_seguranca_foto': cintoSegurancaFoto ?? '',
            'fluido_de_arrefecimento': fluidoArrefecimento ? 'ok' : 'not_ok',
            'fluido_de_arrefecimento_comentario': fluidoArrefecimentoComentario ?? '',
            'fluido_de_arrefecimento_foto': fluidoArrefecimentoFoto ?? '',
            'suspensao': suspensao ? 'ok' : 'not_ok',
            'suspensao_comentario': suspensaoComentario ?? '',
            'suspensao_foto': suspensaoFoto ?? '',
            'campo_assinatura': campoAssinatura,
            'data_hora': dataHora.toIso8601String(),

        };
    }

    @override
    String toString() {
      return 'Checklist {id_checklist: $idChecklist, vehicle_id: $vehicleId, driver_id: $driverId, freios: $freios, pneus: $pneus, nivelOleo: $nivelOleo, faroisLanternas: $faroisLanternas, documentosVeiculo: $documentosVeiculo, cnhCondutor: $cnhCondutor, limpadoresParaBrisa: $limpadoresParaBrisa, cintoSeguranca: $cintoSeguranca, fluidoArrefecimento: $fluidoArrefecimento, suspensao: $suspensao, campoAssinatura: $campoAssinatura}';
    }
}
