import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inventory/app/api/inventory_api.dart';
import 'package:inventory/widget/add_invnetory.dart';
import 'package:inventory/widget/detail_inventory.dart';

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

  Widget _inventoryListBody(dynamic data) {
    return ListView.builder(
      itemCount: data.data['data'].length,
      itemBuilder: (context, index) {
        return Column(
          children: [
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
              onPressed: null,
              icon: Icon(Icons.download),
              color: Colors.white,
            )
          ],
          title: Text('Inventory App'),
          elevation: 0, //ketinggian
        ));
  }
}
