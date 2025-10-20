import 'package:dio/dio.dart';
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
        this.url = config['url_empresa'];
        this.token = config['token'];
      }
    } catch (e) {
      print("Erro ao carregar configurações: $e");
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

    final response = await _dio.post<T>(
      _buildPath(path),
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
        print("Erro na API: ${e.response?.statusCode} - ${e.response?.data}");
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
}