import 'package:simagestor_app/services/service_api.dart';

class LoginService {
  final ServiceApi _api = ServiceApi();

  Future<Map<String, dynamic>> authUser(String email, String password, String company) async {
    try {
      _api.init("https://$company.simagestor.com.br/api");
      final data = await _api.postFormData<Map<String, dynamic>>("api_auth.php/login",{"username": email, "password": password},);
      return data;
    } catch (e) {
      throw Exception("Erro ao buscar usuário: $e");
    }
  }
}