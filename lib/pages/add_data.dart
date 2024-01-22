import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddDataPage extends StatefulWidget {
  final Map? data;
  const AddDataPage({super.key, this.data});

  @override
  State<AddDataPage> createState() => _AddDataPageState();
}

class _AddDataPageState extends State<AddDataPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  bool isEditing = false;
  @override
  void initState() {
    super.initState();
    final datas = widget.data;
    if (datas != null) {
      isEditing = true;
      final name = datas['name'];
      final age = datas['age'].toString();

      nameController.text = name;
      ageController.text = age;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.yellow[700],
          title: Text(
            isEditing ? 'Edit Data' : 'Add Data ',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold),
          )),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Nama',
              hintText: 'Masukkan Nama Anda',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: ageController,
            decoration: InputDecoration(
              labelText: 'Usia',
              hintText: 'Masukkan Usia Anda',
              prefixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: isEditing ? doUpdate : doSubmit,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple[900]),
            child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Text(isEditing ? 'Perbarui' : 'Kirim')),
          )
        ],
      ),
    );
  }

  Future<void> doSubmit() async {
    final name = nameController.text;
    final age = ageController.text;
    final body = {"name": name, "age": int.parse(age)};
    // emulator localhost 10.0.2.2
    const url = 'http://10.0.2.2:4200/api/school';
    final uri = Uri.parse(url);
    try {
      if (name == '' || age == '') {
        failedMessageHandler('form tidak boleh kosong');
      } else {
        final response = await http.post(uri,
            body: jsonEncode(body),
            headers: {'Content-Type': 'application/json'});

        if (response.statusCode == 201) {
          nameController.text = '';
          ageController.text = '';
          print('Berhasil menambah Data');
          succesMessageHandler('Berhasil menambah Data');
          print(response.body);
        }
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> doUpdate() async {
    final datas = widget.data;
    if (datas == null) {
      print('Tidak ditemukan data siswa');
      return;
    }
    final name = nameController.text;
    final age = ageController.text;
    final id = datas['id'];

    final body = {"name": name, "age": int.parse(age)};
    final url = 'http://10.0.2.2:4200/api/school/$id';
    final uri = Uri.parse(url);
    try {
      if (name == '' || age == '') {
        failedMessageHandler('form tidak boleh kosong');
      } else {
        final response = await http.patch(uri,
            body: jsonEncode(body),
            headers: {'Content-Type': 'application/json'});
        if (response.statusCode == 200) {
          print('Berhasil memperbarui Data');
          succesMessageHandler('Berhasil memperbarui Data');
          print(response.body);
        }
      }
    } catch (error) {
      print('Error: $error');
      failedMessageHandler('Gagal memperbarui data');
    }
  }

  void succesMessageHandler(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.yellow[600],
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void failedMessageHandler(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red[600],
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
