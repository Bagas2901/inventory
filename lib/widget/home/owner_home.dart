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

  Widget _inventoryListBody(dynamic data) {
    return ListView.builder(
      itemCount: data.data['data'].length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            ListTile(
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
              icon: Icon(Icons.more_vert),
              color: Colors.white,
            )
          ],
          title: Text('Inventory App'),
          elevation: 0, //ketinggian
        ));
  }
}
