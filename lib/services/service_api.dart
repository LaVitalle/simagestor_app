import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:simagestor_app/services/service_local_database.dart';

class ServiceApi {
  static final ServiceApi _instance = ServiceApi._internal();

  String token = "";
  final Dio _dio = Dio();
  late String url;


  ServiceApi._internal();

  factory ServiceApi() {
    return _instance;
  }

  void init(String url) {
    this.url = url;
  }

  /// Configura o token de autenticação
  void setToken(String token) {
    this.token = token;
  }

  Future<void> loadConfigFromDatabase() async {
    try {
      final db = ServiceLocalDatabase.instance;
      final configs = await db.getAllConfiguracoes();
      
      if (configs.isNotEmpty) {
        final config = configs.first;
        url = config['url_empresa'];
        token = config['token'];
      }
    } catch (e) {
      debugPrint("Erro ao carregar configurações: $e");
    }
  }

  String _buildPath(String path) {
    return '$url/$path';
  }

  Future<T> get<T>(String path, {Map<String, dynamic>? params}) async {
    final response = await _dio.get<T>(
      _buildPath(path),
      queryParameters: params,
    );
    return response.data as T;
  }

  Future<T> getWithAuth<T>(String path, {Map<String, dynamic>? params}) async {
    final response = await _dio.get<T>(
      _buildPath(path),
      queryParameters: params,
      options: Options(
        headers: {"Authorization": "Bearer $token"},
      ),  
    );
    return response.data as T;
  }

  Future<T> post<T>(String path, Map<String, dynamic> body) async {
    final response = await _dio.post<T>(
      _buildPath(path),
      data: body,
      options: Options(
        headers: {
        },
      ),
    );
    return response.data as T;
  }

  Future<T> postWithAuth<T>(String path, Map<String, dynamic> body) async {
    final response = await _dio.post<T>(
      _buildPath(path),
      data: body,
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );
    return response.data as T;
  }

  Future<T> postFormData<T>(String path, Map<String, dynamic> fields) async {
    final formData = FormData.fromMap(fields);

    final response = await _dio.post<T>(
      _buildPath(path),
      data: formData,
      options: Options(
        headers: {
        },
      ),
    );
    return response.data as T;
  }

  Future<T> postFormDataWithAuth<T>(String path, Map<String, dynamic> fields) async {
    final formData = FormData.fromMap(fields);
    final urlCompleta = _buildPath(path);
    
    debugPrint("POST FormData para: $urlCompleta");
    debugPrint("Campos: $fields");

    final response = await _dio.post<T>(
      urlCompleta,
      data: formData,
      options: Options(
        headers: {"Authorization": "Bearer $token"},
      ),
    );
    return response.data as T;
  }

  Future<T> postJsonWithAuth<T>(String path, Map<String, dynamic> body) async {
    final url = _buildPath(path);
    
    try {
      final response = await _dio.post<T>(
        url,
        data: body,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );
      
      return response.data as T;
    } catch (e) {
      if (e is DioException) {
        debugPrint("Erro na API: ${e.response?.statusCode} - ${e.response?.data}");
      }
      rethrow;
    }
  }

  /// Envia dados como JSON sem autenticação
  Future<T> postJson<T>(String path, Map<String, dynamic> body) async {
    final response = await _dio.post<T>(
      _buildPath(path),
      data: body,
      options: Options(
        headers: {
          "Content-Type": "application/json",
        },
      ),
    );
    return response.data as T;
  }

  /// Busca vehicle_id pela placa do veículo
  Future<String?> buscarVehicleIdPorPlaca(String placa) async {
    try {
      // Tenta vários endpoints possíveis
      List<String> endpointsPossiveis = [
        'api_veiculos.php',
        'api_vehicles.php',
        'api_veiculo.php',
      ];
      
      for (String endpoint in endpointsPossiveis) {
        try {
          final response = await getWithAuth<Map<String, dynamic>>(
            endpoint,
            params: {'placa': placa.toUpperCase()},
          );
          
          if (response.containsKey('data') && response['data'] != null) {
            dynamic data = response['data'];
            if (data is Map && data.containsKey('id')) {
              return data['id'].toString();
            } else if (data is List && data.isNotEmpty && data[0] is Map) {
              return data[0]['id']?.toString();
            }
          } else if (response.containsKey('id')) {
            return response['id'].toString();
          }
        } catch (e) {
          // Continua tentando outros endpoints
          continue;
        }
      }
      
      debugPrint("Não foi possível encontrar vehicle_id para a placa: $placa");
      return null;
    } catch (e) {
      debugPrint("Erro ao buscar vehicle_id: $e");
      return null;
    }
  }

  /// Busca driver_id pelo nome do motorista
  Future<String?> buscarDriverIdPorNome(String nome) async {
    try {
      // Tenta vários endpoints possíveis
      List<String> endpointsPossiveis = [
        'api_motoristas.php',
        'api_drivers.php',
        'api_motorista.php',
      ];
      
      for (String endpoint in endpointsPossiveis) {
        try {
          final response = await getWithAuth<Map<String, dynamic>>(
            endpoint,
            params: {'nome': nome},
          );
          
          if (response.containsKey('data') && response['data'] != null) {
            dynamic data = response['data'];
            if (data is Map && data.containsKey('id')) {
              return data['id'].toString();
            } else if (data is List && data.isNotEmpty && data[0] is Map) {
              return data[0]['id']?.toString();
            }
          } else if (response.containsKey('id')) {
            return response['id'].toString();
          }
        } catch (e) {
          // Continua tentando outros endpoints
          continue;
        }
      }
      
      debugPrint("Não foi possível encontrar driver_id para o motorista: $nome");
      return null;
    } catch (e) {
      debugPrint("Erro ao buscar driver_id: $e");
      return null;
    }
  }
}