import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import 'package:http/http.dart' as http;
import 'components/autoComplete.dart';
import 'components/itemObjek.dart';
import 'config/app.dart';
import 'detailObjek.dart';
import 'objekWisataMap.dart';

class Pencarian extends StatefulWidget {
  final int selectedWilayah;
  final int selectedKategori;
  final String valueWilayahString;
  final String search;
  const Pencarian({ Key key , this.selectedWilayah, this.selectedKategori, this.valueWilayahString, this.search}) : super(key: key);

  @override
  _PencarianState createState() => _PencarianState();
}

class _PencarianState extends State<Pencarian> {

  List kategoris = [];
  List<Map<String, dynamic>> wilayahs = [];
  List objeks = [];
  int selectedWilayah;
  int selectedKategori;
  String valueWilayahString;
  bool collapseFilter = true;
  int currentPage = 1;
  int totalPage = 1;
  TextEditingController searchController = TextEditingController();

  @override
  void initState(){
    selectedKategori = widget.selectedKategori;
    selectedWilayah = widget.selectedWilayah;
    valueWilayahString = widget.valueWilayahString;
    searchController.text = widget.search;
    this.getKategori();
    this.getWilayah();
    this.getObjek();
    super.initState();
  }

  Future<void> getKategori() async{
    var urlApi = Uri.https(Config().urlApi, '/public/api/kategori');

    http.get(urlApi).then((http.Response response) {
      if(response.statusCode==401){
        // logout(context);
      }else{
        dynamic result = json.decode(response.body);
        result['data'].insert(0, {'id_kategori': 0, 'nama_kategori': 'Semua Kategori'});
        this.setState(() {
          kategoris = result['data'];
        });
      }
    }).onError((error, stackTrace) {
      Toast.show(error.toString(), context);
    });
  }

  Future<void> getWilayah() async{
    var urlApi = Uri.https(Config().urlApi, '/public/api/wilayah');

    http.get(urlApi).then((http.Response response) {
      if(response.statusCode==401){
        // logout(context);
      }else{
        Map<String, dynamic> result = json.decode(response.body);
        result['data'].forEach((value) {
          Map<String, dynamic> item = {
            'id': value['id'],
            'label': value['kabupaten'],
            'logo': value['logo'],
          };
          return wilayahs.add(item);
        });
        setState(() {});
      }
    }).onError((error, stackTrace) {
      Toast.show(error.toString(), context);
    });
  }

  void _reset(){
    setState(() {
      objeks = [];
      selectedWilayah = 0;
      selectedKategori = 0;
      searchController.text = "";
      currentPage = 1;
    });
    this.getObjek();
  }

  Future<void> getObjek() async{
    Map<String, dynamic> queryString = new Map<String, dynamic>();
    queryString['page'] = currentPage.toString();
    queryString['wilayah-id'] = 5.toString();
    queryString['search_by'] = "searching";
    String search = searchController.text+"."+valueWilayahString+"."+selectedKategori.toString();
    queryString['search'] = search;

    var urlApi = Uri.https(Config().urlApi, '/public/api/wisata/search', queryString);

    http.get(urlApi).then((http.Response response) {
      if(response.statusCode==401){
        // logout(context);
      }else{
        Map<String, dynamic> result = json.decode(response.body);
        result['data']['data'].forEach((element){
          objeks.add(element);
        });
        setState(() {
          currentPage = result['data']['current_page']+1;
          totalPage = result['data']['last_page'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    child: Text("LIST OBJEK", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[300]
                    )
                  )
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          onPrimary: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                            return ObjekWisataMap();
                          }));
                        },
                        child: Row(
                          children: [
                            Icon(Icons.place, color: Colors.grey,),
                            Text("View on mini map", style: TextStyle(color: Colors.grey),),
                          ],
                        ),
                      ),
                      SizedBox(width: 10,),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          onPrimary: Colors.white,
                        ),
                        onPressed: () {

                        },
                        child: Row(
                          children: [
                            Icon(Icons.place, color: Colors.grey,),
                            Text("View on full map", style: TextStyle(color: Colors.grey),),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Filters", style: TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(icon: Icon(Icons.filter_alt_outlined), onPressed: (){
                                setState(() {
                                  collapseFilter = !collapseFilter;
                                });
                              }),
                            ],
                          ),
                          Divider(
                            color: Colors.grey[300],
                          ),
                          (collapseFilter) ? 

                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Cari", style: TextStyle(fontWeight: FontWeight.w600)),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: TextField(
                                    controller: searchController,                                   
                                    decoration: InputDecoration(
                                      hintText : 'Apa yang kamu cari?',
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: new OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: const BorderRadius.all(
                                          const Radius.circular(10.0),
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                      suffixIcon: Icon(Icons.search)
                                    )
                                  ),
                                ),
                                Text("Kabupaten / Kota", style: TextStyle(fontWeight: FontWeight.w600)),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: AutoCompleteComponent(
                                    label: "Kemana?",
                                    icon: Icon(Icons.place),
                                    options: wilayahs,
                                    value: valueWilayahString,
                                    onSelect: (selection) {
                                      setState(() {
                                        selectedWilayah = selection['id'];
                                      });
                                    },
                                    onChange: (value) {
                                      setState(() {
                                        selectedWilayah = 0;
                                      });
                                    }),
                                ),
                                Divider(
                                  color: Colors.grey[300],
                                ),

                                Text("Kategori", style: TextStyle(fontWeight: FontWeight.w600)),
                                DropdownButtonFormField(
                                  decoration : InputDecoration(
                                    hintText : 'Kategori',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: new OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: const BorderRadius.all(
                                        const Radius.circular(10.0),
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  ),
                                  value: selectedKategori,
                                  items: kategoris.map((dynamic item){
                                    return DropdownMenuItem(
                                      value: item['id_kategori'],
                                      child: Text(item['nama_kategori']),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedKategori = value;
                                    });
                                  },
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.refresh),
                                        Text("Reset", style: TextStyle(color: Colors.white),),
                                      ],
                                    ),
                                    onPressed: () {
                                      this._reset();
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red[300]),
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                        )
                                      )
                                    )
                                  ),
                                ),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.filter_alt_outlined),
                                        Text("Filter", style: TextStyle(color: Colors.white),),
                                      ],
                                    ),
                                    onPressed: () async{
                                      setState(() {
                                        currentPage = 1;
                                        objeks = [];
                                      });
                                      this.getObjek();
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                        )
                                      )
                                    )
                                  ),
                                ),
                              ],
                            ),
                          )

                          : Container(),

                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 0),
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: objeks.length,
                    itemBuilder: (context, index){
                      return ItemObjek(data : objeks[index], onTap: (value){
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return DetailObjek(id : value['id'], data : value);
                        }));
                      },);
                    }
                  ),
                ),
              ),

              (currentPage>totalPage) ? Container() :
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: Text("Load More", style: TextStyle(color: Colors.white),),
                    onPressed: () {
                      this..getObjek();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red[300]),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        )
                      )
                    )
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