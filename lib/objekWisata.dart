import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'components/autoComplete.dart';
import 'components/itemObjek.dart';
import 'config/app.dart';
import 'detailObjek.dart';
import 'objekWisataMap.dart';
class ObjekWisata extends StatefulWidget {
  final int idWilayah;
  final String namaWilayah;
  final List<int> selectedKategori;
  const ObjekWisata({Key key, this.idWilayah, this.namaWilayah, this.selectedKategori}) : super(key: key);

  @override
  _ObjekWisataState createState() => _ObjekWisataState();
}

class _ObjekWisataState extends State<ObjekWisata> {
  List kategoris = [];
  List<Map<String, dynamic>> wilayahs = [];
  List objeks = [];
  int selectedWilayah;
  String selectedWilayahString;
  bool collapseFilter = false;
  int currentPage = 1;
  int totalPage = 1;

  @override
  void initState(){
    super.initState();
    this.getWilayah();
    this.getKategori(widget.selectedKategori).then((value) {
      selectedWilayah = widget.idWilayah;
      selectedWilayahString = widget.namaWilayah;
      this.getObjek();
    });
  }

  Future getKategori(List<int> selectedKategori) async{
    var urlApi = Uri.https(Config().urlApi, '/public/api/kategori');

    return http.get(urlApi).then((http.Response response) {
      if(response.statusCode==401){
        // logout(context);
      }else{
        Map<String, dynamic> result = json.decode(response.body);
        result['data'].forEach((value) {
          bool checked = (selectedKategori.contains(value['id_kategori']) ? true : false);
          Map<String, dynamic> item = {
            'id': value['id_kategori'],
            'label': value['nama_kategori'],
            'checked' : checked
          };
          return kategoris.add(item);
        });
        setState(() {});
      }
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
    });
  }

  Future<void> getObjek() async{
    Map<String, dynamic> queryString = new Map<String, dynamic>();
    queryString['page'] = currentPage.toString();
    bool search = false;

    if(selectedWilayah>0){
      search = true;
      queryString['wilayah-id'] = selectedWilayah.toString();
    }

    List queryKategori = [];
    kategoris.forEach((element) {
      if(element['checked']){
        queryKategori.add(element['id'].toString());
      }
    });
    if(queryKategori.length>0){
      search = true;
      queryString['kategori-id_kategori[]'] = queryKategori;    
    }

    var urlApi;
    if(search){
      queryString['search_by'] = "";
      queryString['search'] = "";
      urlApi = Uri.https(Config().urlApi, '/public/api/wisata/search', queryString);
    }else{
      urlApi = Uri.https(Config().urlApi, '/public/api/wisata');
    }

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

  void _reset(){
    List<Map<String, dynamic>> kategoriNew = [];
    kategoris.forEach((element) {
      element['checked'] = false;
      kategoriNew.add(element);
    });

    setState(() {
      kategoris = kategoriNew;
      objeks = [];
      selectedWilayah = 0;
      currentPage = 1;
    });
    this.getObjek();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("WISATAKEMARI", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 1,
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
                                Text("Kabupaten / Kota", style: TextStyle(fontWeight: FontWeight.w600)),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: AutoCompleteComponent(
                                    label: "Kemana?",
                                    icon: Icon(Icons.place),
                                    options: wilayahs,
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
                                MediaQuery.removePadding(
                                  context: context,
                                  removeTop: true,
                                  child: ListView.builder(
                                    itemCount: kategoris.length,
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index){
                                      return Row(
                                        children: [
                                          Checkbox(
                                            checkColor: Colors.white,
                                            activeColor : Colors.red,
                                            // fillColor: MaterialStateProperty.resolveWith(getColor),
                                            value: kategoris[index]['checked'],
                                            onChanged: (bool value) {
                                              setState(() {
                                                kategoris[index]['checked'] = !kategoris[index]['checked'];
                                              });
                                            },
                                          ),
                                          Text(kategoris[index]['label'])
                                        ],
                                      );
                                    }
                                  ),
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
                      this.getObjek();
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
