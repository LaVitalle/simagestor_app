class checklist{
    final int id;
    final String placaVeiculo;
    // final StatusItem freios;
    final bool freiosOK;
    // final StatusItem pneus;
    final bool pneusOK;
    // final StatusItem nivelOleo;
    final bool nivelOleoOK;
    final DateTime dataHora;

    checklist({
        required this.id,
        required this.placaVeiculo,
        required this.freiosOK,
        required this.pneusOK,
        required this.novelOleoOK,
        required this.dataHora,
    });
}