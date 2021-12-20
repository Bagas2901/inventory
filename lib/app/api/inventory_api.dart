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

      FormData formData;
      if (image != null) {
        formData = FormData.fromMap({
          'token': token,
          'note': note,
          'name': name,
          'stock': stock,
          'unit': unit,
          'image': await MultipartFile.fromFile(path)
        });
      } else {
        formData = FormData.fromMap({
          'token': token,
          'note': note,
          'name': name,
          'stock': stock,
          'unit': unit,
        });
      }
      data = await dio
          .post(Endpoint.add, data: formData)
          .timeout(Duration(seconds: 30));
      // print(data);
    } catch (e) {
      // print(e);
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
      // print(data);
    } catch (e) {
      // print(e);
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
      // print(data);
    } catch (e) {
      // print(e);
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

      FormData formData;
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
      // print(data);
    } catch (e) {
      // print(e);
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
      // print(data);
    } catch (e) {
      // print(e);
    }
    return data;
  }

  Future downloadPDF() async {
    final dio = Dio();
    String? finalPath;

    try {
      if (await Permission.storage.request().isGranted) {
        //ijin didapatkan
        SharedPreferences _prefs = await SharedPreferences.getInstance();
        String? token = _prefs.getString('token');

        Directory? path = await getExternalStorageDirectory();
        String filePath = path!.path + "Inventory.PDF";
        var formData = {'token': token};
        final response = await dio
            .download(Endpoint.exportPdf, filePath, queryParameters: formData)
            .timeout(Duration(seconds: 60));
        if (response.data != null) {
          finalPath = filePath;
        }
      }
    } catch (e) {
      // print(e);
    }
    return finalPath;
  }
}
