import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory/app/api/inventory_api.dart';
import 'package:inventory/widget/splashscreen.dart';

class EditInventory extends StatefulWidget {
  final String id;
  EditInventory({Key? key, required this.id}) : super(key: key);

  @override
  _EditInventoryState createState() => _EditInventoryState();
}

class _EditInventoryState extends State<EditInventory> {
  GlobalKey<FormState> _addinventoryForm = GlobalKey<FormState>();
  TextEditingController _namaBarang = TextEditingController();
  TextEditingController _stock = TextEditingController();
  TextEditingController _satuan = TextEditingController();
  TextEditingController _keterangan = TextEditingController();

  File? _gambar;

  bool _apiCall = false;

  Future? _detail;
  @override
  void initState() {
    // TODO: implement initState
    _detail =
        InventoryApi().detail(int.parse(widget.id)).then((inventoryDetail) {
      _namaBarang.text = inventoryDetail.data['data']['name'];
      _satuan.text = inventoryDetail.data['data']['unit'];
      _stock.text = inventoryDetail.data['data']['stock'].toString();
      _keterangan.text = inventoryDetail.data['data']['note'];
      return inventoryDetail;
    });
    super.initState();
  }

  showMessage(String msg, List<Widget> actions) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Pesan'),
              content: Text('$msg'),
              actions: actions,
            ));
  }

  void _saveInventory() async {
    if (_addinventoryForm.currentState!.validate()) {
      setState(() {
        _apiCall = true;
      });

      var _addInventory;
      if (_gambar != null) {
        _addInventory = await InventoryApi().update(
            id: widget.id,
            name: _namaBarang.text,
            note: _keterangan.text,
            stock: _stock.text,
            unit: _satuan.text,
            image: _gambar);
      } else {
        _addInventory = await InventoryApi().update(
            id: widget.id,
            name: _namaBarang.text,
            note: _keterangan.text,
            stock: _stock.text,
            unit: _satuan.text);
      }

      if (_addInventory == null) {
        //offline
        showMessage("Maaf anda offline, mohon coba lagi!", [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))
        ]);
      } else if (_addInventory != null && _addInventory.data["code"] == 200) {
        //success
        showMessage("Inventory Disimpan", [
          TextButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Splashscreen())),
              child: Text('OK'))
        ]);
      } else {
        //error
        showMessage("Opss, Sepertinya ada yang salah, mohon coba lagi!", [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))
        ]);
      }
      setState(() {
        _apiCall = false;
      });
    }
  }

  void _takePicture() async {
    final ImagePicker _picker = ImagePicker();

    XFile? _takeImage =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 10);
    setState(() {
      _gambar = File(_takeImage!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Edit Inventory'),
      ),
      body: FutureBuilder(
          future: _detail,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                // request berhasil
                return _editinventoryForm(snapshot.data);
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

  SingleChildScrollView _editinventoryForm(dynamic data) {
    return SingleChildScrollView(
      //agar tidak error saat scroll
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _addinventoryForm,
          child: Column(
            children: [
              Column(
                children: [
                  Container(
                      child: _gambar != null
                          ? Image.file(_gambar!)
                          : data.data['data']['image'] == null
                              ? Text('Ambil gambar')
                              : Image.network(data.data['data']['image'])),
                  TextButton(
                      onPressed: () => _takePicture(),
                      child: Text('Ambil Gambar'))
                ],
              ),
              TextFormField(
                controller: _namaBarang,
                decoration: InputDecoration(labelText: 'Nama Barang'),
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'Harus diisi!';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _stock,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Stock Barang'),
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'Harus diisi!';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _satuan,
                decoration: InputDecoration(labelText: 'Satuan'),
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'Harus diisi!';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _keterangan,
                decoration: InputDecoration(labelText: 'Keterangan'),
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'Harus diisi!';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () => _apiCall ? null : _saveInventory(),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text(_apiCall ? 'Menyimpan ...' : 'Simpan')],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
