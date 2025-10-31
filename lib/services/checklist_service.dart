import 'package:simagestor_app/services/service_local_database.dart';
import '../../models/checklist.dart';

class ChecklistService {
    static final ServiceLocalDatabase _db = ServiceLocalDatabase.instance;

  static Future<List<Checklist>> buscarChecklists() async {
    try {
      final List<Map<String, dynamic>> results = await _db.getAllChecklists();
      return results.map((json) => Checklist.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar Checklists: $e');
    }
  }

  static Future<Checklist> buscarChecklistPorId(int id) async {
    try {
      final Map<String, dynamic>? result = await _db.getChecklistById(id);
      if (result == null) {
        throw Exception('Checklist não encontrada');
      }
      return Checklist.fromJson(result);
    } catch (e) {
      throw Exception('Erro ao buscar Checklist por ID $id: $e');
    }
  }

  static Future<Checklist> adicionarChecklist(Checklist novaChecklist) async {
    try {
      final data = novaChecklist.toJson();
      // Remove o id_checklist se for 0 (novo registro)
      if (data['id_checklist'] == 0) {
        data.remove('id_checklist');
      }

      final int id = await _db.insertChecklist(data);

      // Retorna a Checklist com o ID gerado pelo banco
      return Checklist(
        idChecklist: id,
        campoAssinatura: novaChecklist.campoAssinatura,
        cintoSeguranca: novaChecklist.cintoSeguranca,
        cnhCondutor: novaChecklist.cnhCondutor,
        dataHora: novaChecklist.dataHora,
        documentosVeiculo: novaChecklist.documentosVeiculo,
        faroisLanternas: novaChecklist.faroisLanternas,
        fluidoArrefecimento: novaChecklist.fluidoArrefecimento,
        freios: novaChecklist.freios,
        limpadoresParaBrisa: novaChecklist.limpadoresParaBrisa,
        motorista: novaChecklist.motorista,
        nivelOleo: novaChecklist.nivelOleo,
        placaVeiculo: novaChecklist.placaVeiculo,
        pneus: novaChecklist.pneus,
        suspensao: novaChecklist.suspensao,
      );
    } catch (e) {
      throw Exception('Erro ao adicionar Checklist: $e');
    }
  }

  static Future<Checklist> atualizarChecklist(Checklist checklistAtualizada) async {
    try {
      final data = checklistAtualizada.toJson();
      // Remove o id_checklist do update
      data.remove('id_checklist');

      final int rowsAffected = await _db.updateChecklist(
        checklistAtualizada.idChecklist,
        data,
      );

      if (rowsAffected == 0) {
        throw Exception('Checklist não encontrada');
      }

      return checklistAtualizada;
    } catch (e) {
      throw Exception('Erro ao atualizar Checklist: $e');
    }
  }

  static Future<void> excluirChecklist(int id) async {
    try {
      final int rowsAffected = await _db.deleteChecklist(id);

      if (rowsAffected == 0) {
        throw Exception('Checklist não encontrada');
      }
    } catch (e) {
      throw Exception('Erro ao excluir Checklist: $e');
    }
  }
}
