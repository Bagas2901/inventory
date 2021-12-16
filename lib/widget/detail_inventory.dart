import 'package:flutter/material.dart';
import 'package:inventory/app/api/inventory_api.dart';
import 'package:inventory/widget/edit_inventory.dart';

class DetailInventory extends StatefulWidget {
  final String namaBarang;
  final int id;

  DetailInventory({Key? key, required this.namaBarang, required this.id})
      : super(key: key);

  @override
  _DetailInventoryState createState() => _DetailInventoryState();
}

class _DetailInventoryState extends State<DetailInventory> {
  Future? _detail;
  @override
  void initState() {
    // TODO: implement initState
    _detail = InventoryApi().detail(widget.id);
    super.initState();
  }

  Widget _detailInventoryBody(dynamic data) {
    return SingleChildScrollView(
        child: Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('nama barang')),
              Expanded(child: Text('${data.data["data"]["name"]}')),
            ],
          ),
          Divider(),
          Row(
            children: [
              Expanded(child: Text('stock')),
              Expanded(
                  child: Text(
                      '${data.data["data"]["stock"]} ${data.data["data"]["unit"]}')),
            ],
          ),
          Divider(),
          Text('Keterangan'),
          SizedBox(height: 10),
          Text('${data.data["data"]["note"]}'),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.namaBarang}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EditInventory(id: widget.id.toString()))),
              child: Text(
                'Edit',
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      body: FutureBuilder(
          future: _detail,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                // request berhasil
                return _detailInventoryBody(snapshot.data);
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
    );
  }
}
