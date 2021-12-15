import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'endpoint.dart';

class InventoryApi {
  Future add(
      {String? name,
      String? note,
      String? unit,
      String? stock,
      File? image}) async {
    final dio = Dio();
    Response<dynamic>? data;
    try {
      SharedPreferences _pref = await SharedPreferences.getInstance();
      String? token = _pref.getString('token');
      String? path = image != null ? image.path : "";
      var formData = FormData.fromMap({
        'token': token,
        'note': note,
        'name': name,
        'stock': stock,
        'unit': unit,
        'image': await MultipartFile.fromFile(path)
      });
      data = await dio
          .post(Endpoint.add, data: formData)
          .timeout(Duration(seconds: 30));
      print(data);
    } catch (e) {
      print(e);
    }
    return data;
  }

  Future showlist() async {
    final dio = Dio();
    Future<Response>? data;
    try {
      SharedPreferences _pref = await SharedPreferences.getInstance();
      String? token = _pref.getString('token');
      var formData = {
        'token': token,
      };
      data = dio
          .get(Endpoint.showlist, queryParameters: formData)
          .timeout(Duration(seconds: 30));
      print(data);
    } catch (e) {
      print(e);
    }
    return data;
  }

  Future detail(int id) async {
    final dio = Dio();
    Future<Response>? data;
    try {
      SharedPreferences _pref = await SharedPreferences.getInstance();
      String? token = _pref.getString('token');
      var formData = {
        'token': token,
        'id': id,
      };
      data = dio
          .get(Endpoint.detail, queryParameters: formData)
          .timeout(Duration(seconds: 30));
      print(data);
    } catch (e) {
      print(e);
    }
    return data;
  }
}
