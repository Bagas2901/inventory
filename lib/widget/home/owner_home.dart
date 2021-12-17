import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inventory/app/api/inventory_api.dart';
import 'package:inventory/app/api/inventory_api_offline.dart';
import 'package:inventory/widget/add_invnetory.dart';
import 'package:inventory/widget/detail_inventory.dart';
import 'package:inventory/widget/pdf_viewer.dart';

class OwnerHome extends StatefulWidget {
  OwnerHome({Key? key}) : super(key: key);

  @override
  _OwnerHomeState createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHome> {
  Future? _inventoryList;

  @override
  void initState() {
    // TODO: implement initState
    _inventoryList = InventoryApi().showlist();
    super.initState();
  }

  _showMsg(String msg, List<Widget> actions) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Pesan'),
              content: Text('$msg'),
              actions: actions,
            ));
  }

  _deleteInventory(String id) async {
    Navigator.pop(context);
    _showMsg('Memproses...', []);
    final _delete = await InventoryApi().delete(id: id);

    Navigator.pop(context);

    if (_delete != null) {
      if (_delete.data['code'] == 200) {
        //success
        setState(() {
          _inventoryList = InventoryApi().showlist();
        });
        _showMsg('Berhasil dihapus', [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))
        ]);
      } else {
        //error
        _showMsg('Sepertinya ada yang salah', [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))
        ]);
      }
      print(_delete);
    } else {
      //error koneksi
      _showMsg('Periksa koneksi anda', [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))
      ]);
    }
  }

  _confirmDelete(String id) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                'Konfirmasi',
              ),
              content: Text('Yakin ingin menghapus?'),
              actions: [
                TextButton(
                    onPressed: () => _deleteInventory(id),
                    child: Text('Hapus')),
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Batal'))
              ],
            ));
  }

  void _downloadFile() async {
    _showMsg('Memproses', []);
    String filePath = await InventoryApi().downloadPDF();
    print(filePath);

    Navigator.pop(context);
    _showMsg('File berhasil tersimpan di $filePath', [
      TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
      TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PdfViewer(
                          pdfFile: File(filePath),
                        )));
          },
          child: Text('Buka'))
    ]);
  }

  Widget _inventoryListBody(dynamic data) {
    return ListView.builder(
      itemCount: data.data['data'].length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            index == 0 ? _offlinewarning() : Container(),
            ListTile(
              trailing: IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () =>
                    _confirmDelete(data.data['data'][index]['id'].toString()),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetailInventory(
                            id: data.data["data"][index]["id"],
                            namaBarang: data.data["data"][index]["name"])));
              },
              title: Text('${data.data["data"][index]["name"]}'),
              subtitle: Row(
                children: [
                  Expanded(
                      child: Text(
                          'Stock : ${data.data["data"][index]["stock"]} ${data.data["data"][index]["unit"]}')),
                  Expanded(
                      child: Text(
                          'Keterangan : ${data.data["data"][index]["note"]}'))
                ],
              ),
            ),
            Divider(
              height: 2,
            )
          ],
        );
      },
    );
  }

  _sinkronisasi() async {
    _showMsg('Memproses', []);

    int _success = 0;
    int _failed = 0;
    List<Map> _offlineData = await InventoryApiOffline().offlineData();
    for (var i = 0; i < _offlineData.length; i++) {
      final _inventory = _offlineData[i];
      var _sync;
      String _inventoryImage = _inventory['image']?.replaceAll(' ', '');
      if (_inventory['image'] != null && _inventoryImage.isNotEmpty) {
        _sync = await InventoryApi().add(
            image: File(_inventory['image']),
            name: _inventory['name'],
            unit: _inventory['unit'],
            note: _inventory['note'],
            stock: _inventory['stock'].toString());
      } else {
        _sync = await InventoryApi().add(
            name: _inventory['name'],
            unit: _inventory['unit'],
            note: _inventory['note'],
            stock: _inventory['stock'].toString());
      }
      print("sync : $_sync");
      if (_sync != null && _sync.data['code'] == 200) {
        _success += 1;
        await InventoryApiOffline().setToOnline(_inventory['id']);
      } else {
        _failed += 1;
      }
    }

    setState(() {
      _inventoryList = InventoryApi().showlist();
    });
    Navigator.pop(context);
    _showMsg(
        '$_success data dari ${_offlineData.length} berhasil di sinkronasi', [
      TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))
    ]);
  }

  Widget _offlinewarning() {
    return FutureBuilder<List<Map>>(
        future: InventoryApiOffline().offlineData(),
        builder: (context, snapshot) {
          int? _jumlahDataOffline = 0;
          if (snapshot.hasData && snapshot!.data!.length > 0) {
            _jumlahDataOffline = snapshot.data?.length;
            return Container(
                padding: EdgeInsets.all(20),
                color: Colors.orange[100],
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            'Mohon Sinkronisasi data anda ($_jumlahDataOffline data)'),
                        TextButton(
                            onPressed: () => _sinkronisasi(),
                            child: Text('Sinkronisasi data'))
                      ],
                    )
                  ],
                ));
          } else {
            return Container();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddInventory())),
          child: Icon(Icons.add),
        ),
        body: FutureBuilder(
            future: _inventoryList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  // request berhasil
                  return _inventoryListBody(snapshot.data);
                } else {
                  //request gagal
                  return Center(
                    child: Text('Oops, sepertinya ada yang salah!'),
                  );
                }
              } else {
                //unfinished connection
                return Center(child: CircularProgressIndicator());
              }
            }),
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () => _downloadFile(),
              icon: Icon(Icons.download),
              color: Colors.white,
            )
          ],
          title: Text('Inventory App'),
          elevation: 0, //ketinggian
        ));
  }
}
