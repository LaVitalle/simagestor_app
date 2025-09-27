import 'package:dio/dio.dart';

class ServiceApi {
  static final ServiceApi _instance = ServiceApi._internal();

  String token = "";
  Dio _dio = Dio();
  late String url;


  ServiceApi._internal();

  factory ServiceApi() {
    return _instance;
  }

  void init(String url) {
    this.url = url;
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
    final pathR = _buildPath(path);
    print(pathR);

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
}