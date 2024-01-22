import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uas_mobile_programing_randika/pages/add_data.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;
  List data = [];

  @override
  void initState() {
    super.initState();
    getAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.yellow[700],
          title: const Text(
            'CRUD Data Siswa',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold),
          )),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
            onRefresh: getAllData,
            child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final dataList = data[index] as Map;
                  final id = dataList['id'].toString();
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(dataList['name']),
                    subtitle: Text(dataList['age'].toString()),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'edit') {
                          //edit page
                          navigateToEditPage(dataList);
                        } else if (value == 'delete') {
                          //delete
                          deleteData(id);
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(child: Text('Edit'), value: 'edit'),
                          PopupMenuItem(child: Text('Delete'), value: 'delete'),
                        ];
                      },
                    ),
                  );
                })),
        child: const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateToAddData, label: const Text('Add Data')),
    );
  }

  Future<void> navigateToAddData() async {
    final route = MaterialPageRoute(builder: (context) => const AddDataPage());
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    getAllData();
  }

  Future<void> navigateToEditPage(Map dataList) async {
    final route =
        MaterialPageRoute(builder: (context) => AddDataPage(data: dataList));
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    getAllData();
  }

  Future<void> getAllData() async {
    setState(() {
      isLoading = true;
    });
    const url = 'http://10.0.2.2:4200/api/school';
    final uri = Uri.parse(url);

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['data'] as List;
      setState(() {
        data = result;
      });
    }
    setState(() {
      isLoading = false;
    });
    print(response.body);
  }

  Future<void> deleteData(String id) async {
    final url = 'http://10.0.2.2:4200/api/school/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      final filterData = data.where((element) => element['id'] != id).toList();
      setState(() {
        data = filterData;
      });
      messageHandler('success Delete data');
      await getAllData();
    }
  }

  void messageHandler(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.yellow[600],
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
