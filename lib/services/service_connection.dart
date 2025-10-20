import 'dart:io';
import 'package:http/http.dart' as http;

class ServiceConnection {
  static Future<bool> hasInternetConnection() async {
  try {
    final result = await http.get(Uri.parse('https://google.com'))
          .timeout(const Duration(seconds: 5));
      return result.statusCode == 200;
    } on SocketException catch (_) {
      return false;
    } on Exception catch (_) {
      return false;
    }
  }
}