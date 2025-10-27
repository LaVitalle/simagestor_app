class ChecklistService {
    static final List<Checklist> _checklistsMockados = [
        Checklist(
        idChecklist: 1,
        placaVeiculo: 'BAA7E82',
        motorista: 'João Silva',
        freios: true,
        pneus: false,
        nivelOleo: false,
        faroisLanternas: true,
        documentosVeiculo: true,
        cnhCondutor: true,
        limpadoresParaBrisa: true,
        cintoSeguranca: true,
        fluidoArrefecimento: false,
        suspensao: true,
        campoAssinatura: 'assinatura_base64_aqui',
        dataHora: DateTime(2025, 8, 29, 19, 30),
        ),
    ];

    // Buscar todos os checklists
    static Future<List<Checklist>> buscarChecklists() async {
        await Future.delayed(const Duration(milliseconds: 800));
        return List.from(_checklistsMockados);
    }

    // Buscar checklist por ID
    static Future<Checklist> buscarChecklistPorId(int id) async {
        await Future.delayed(const Duration(milliseconds: 400));
        final checklist = _checklistsMockados.firstWhere(
            (c) => c.idChecklist == id,
            orElse: () => throw Exception('Checklist não encontrado'),
        );
        return checklist;
    }

    // Adicionar novo checklist
    static Future<Checklist> adicionarChecklist(Checklist novo) async {
        await Future.delayed(const Duration(milliseconds: 800));

        final ultimoId = _checklistsMockados.isNotEmpty
            ? _checklistsMockados.map((c) => c.idChecklist).reduce((a, b) => a > b ? a : b)
            : 0;

        final checklistComId = novo.copyWith(idChecklist: ultimoId + 1);

        _checklistsMockados.insert(0, checklistComId);
        return checklistComId;
    }

    // Atualizar checklist existente
    static Future<Checklist> atualizarChecklist(Checklist atualizado) async {
        await Future.delayed(const Duration(milliseconds: 600));

        final index = _checklistsMockados.indexWhere(
            (c) => c.idChecklist == atualizado.idChecklist,
        );
        if (index == -1) throw Exception('Checklist não encontrado');

        _checklistsMockados[index] = atualizado;
        return atualizado;
    }

    // Excluir checklist
    static Future<void> excluirChecklist(int id) async {
        await Future.delayed(const Duration(milliseconds: 400));
        final index = _checklistsMockados.indexWhere((c) => c.idChecklist == id);
        if (index == -1) throw Exception('Checklist não encontrado');
        _checklistsMockados.removeAt(index);
    }
}
