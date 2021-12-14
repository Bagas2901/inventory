import 'package:dio/dio.dart';
import 'package:inventory/app/api/endpoint.dart';
import 'package:inventory/app/data_class/auth_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authentication {
  Future<AuthType?> checkAuth() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? token = _prefs.getString('token');
    String? role = _prefs.getString('role');
    AuthType? _authtype = AuthType(isLoggedin: token != null, role: role);

    return _authtype;
  }

  Future login(String username, String password) async {
    final dio = Dio();
    Response<dynamic>? data;
    try {
      data = await dio.post(Endpoint.login,
          data: {'username': username, 'password': password});

      bool _isDataExist = data.data["data"].length > 0;
      if (_isDataExist) {
        bool _isTokenExist = data.data["data"]["auth_token"].length > 0;
        if (_isTokenExist) {
          String authtoken = data.data["data"]["auth_token"];
          String role = data.data["data"]["role"];

          SharedPreferences _prefs = await SharedPreferences.getInstance();
          _prefs.setString('token', authtoken);
          _prefs.setString('role', role);
        }
      }

      // print("auth_token = " + data.data["data"]["auth_token"]);
    } catch (e) {
      print(e);
    }

    return data;
  }

  Future logout() async {}
}
