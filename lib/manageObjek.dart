import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wisatakemari/addUsulan.dart';
import 'package:wisatakemari/components/itemObjekManage.dart';
import 'config/app.dart';

class ManageObjek extends StatefulWidget {
  const ManageObjek({ Key key }) : super(key: key);

  @override
  _ManageObjekState createState() => _ManageObjekState();
}

class _ManageObjekState extends State<ManageObjek> {
  
  List<Map<String, dynamic>> wilayahs = [];
  List objeks = [];

  @override
  void initState(){
    this.getObjek();
    super.initState();
  }

  Future<void> getObjek() async{
    var urlApi = Uri.https(Config().urlApi, '/public/api/get_usulan_objek');
    http.get(urlApi).then((http.Response response) {
      if(response.statusCode==401){
        // logout(context);
      }else{
        Map<String, dynamic> result = json.decode(response.body);
        setState(() {
          objeks = result['data'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return AddUsulan();
          }));
        },
      ),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("WISATAKEMARI", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey[300],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  image: DecorationImage(
                    image: AssetImage("assets/images/bg-objek.jpg"),
                    colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("USULAN", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: objeks.length,
                    itemBuilder: (context, index){
                      return ItemObjekManage(
                        data: objeks[index],
                        onEdit: (value){
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            // return EditObjek();
                          }));
                        },
                        onDelete : (value){
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Konfirmasi'),
                              content: Text(
                                  "Yakin ingin menghapus usulan ini?"),
                              actions: [
                                FlatButton(
                                  child: Text("Ya"),
                                  onPressed: () {
                                    // this.terkirim(context, 1);
                                  },
                                )
                              ],
                            )
                          );
                        }
                      );
                    }
                  ),
                ),
              ),
            ]
          ),
        )
      ),
    );
  }
}