import 'package:dio/dio.dart';
import 'package:inventory/app/api/endpoint.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserApi {
  Future updateToken({String? firebaseToken}) async {
    final dio = Dio();
    Response<dynamic>? data;
    try {
      SharedPreferences _pref = await SharedPreferences.getInstance();
      String? token = _pref.getString('token');

      var formData =
          FormData.fromMap({'token': token, 'firebase_token': firebaseToken});

      data = await dio
          .post(Endpoint.updateToken, data: formData)
          .timeout(Duration(seconds: 30));
      // print(data);
    } catch (e) {
      // print(e);
    }
    return data;
  }
}
