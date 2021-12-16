import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
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

  Future update(
      {String? name,
      String? note,
      String? unit,
      String? stock,
      File? image,
      String? id}) async {
    final dio = Dio();
    Response<dynamic>? data;
    try {
      SharedPreferences _pref = await SharedPreferences.getInstance();
      String? token = _pref.getString('token');
      String? path = image != null ? image.path : "";

      var formData;
      if (image != null) {
        formData = FormData.fromMap({
          'token': token,
          'note': note,
          'name': name,
          'stock': stock,
          'unit': unit,
          'image': await MultipartFile.fromFile(path),
          'id': id
        });
      } else {
        formData = FormData.fromMap({
          'token': token,
          'note': note,
          'name': name,
          'stock': stock,
          'unit': unit,
          'id': id
        });
      }

      data = await dio
          .post(Endpoint.update, data: formData)
          .timeout(Duration(seconds: 30));
      print(data);
    } catch (e) {
      print(e);
    }
    return data;
  }

  Future delete({
    String? id,
  }) async {
    final dio = Dio();
    Response<dynamic>? data;
    try {
      SharedPreferences _pref = await SharedPreferences.getInstance();
      String? token = _pref.getString('token');

      var formData = FormData.fromMap({
        'token': token,
        'id': id,
      });
      data = await dio
          .post(Endpoint.delete, data: formData)
          .timeout(Duration(seconds: 30));
      print(data);
    } catch (e) {
      print(e);
    }
    return data;
  }

  Future downloadPDF() async {
    final dio = Dio();

    try {
      if (await Permission.storage.isGranted) {
        //ijin didapatkan
        Directory? path = await getExternalStorageDirectory();
        String filePath = path!.path + "Inventory.pdf";
        final response = await dio.download(Endpoint.export_pdf, filePath);
      }
    } catch (e) {}
  }
}
