import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wisatakemari/components/itemObjek.dart';
import 'package:wisatakemari/components/listWilayah.dart';
import 'package:wisatakemari/components/slider.dart';
import 'package:wisatakemari/pencarian.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/autoComplete.dart';
import 'config/app.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'detailObjek.dart';
import 'objekWisata.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
  scopes: <String>[
    'email',
  ],
);

class HomeContent extends StatefulWidget {
  final ValueSetter<double> onOpenDrawer;
  final double open;
  const HomeContent({key, this.onOpenDrawer, this.open}) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>{
  List<dynamic> populers = [
    {
      "id":29,
      "nama":"Grand Surya Hotel Kediri",
      "gambar":null,
      "deskripsi":"<p>Hotel simpel ini berjarak 13 menit berjalan kaki dari Taman Brantas, 5 km dari Kebun Bunga Matahari, dan 3 km dari Taman Wisata Tirtoyoso.</p>\r\n\r\n<p>Memiliki lantai keramik dan perabotan kayu, kamar-kamar simpel dilengkapi dengan Wi-Fi gratis, TV layar datar, serta fasilitas untuk membuat teh dan kopi. Suite memiliki area duduk.</p>\r\n\r\n<p>Sarapan dan minuman selamat datang gratis. Pilihan bersantap terdiri dari restoran, kafe, lounge koktail, dan bar jus. Fasilitas lainnya termasuk toko wine, kolam renang outdoor, dan gym. Ada juga spa, serta ruang pertemuan dan ruang acara.</p>",
    }
  ];
  List kategoris = [];
  List<Map<String, dynamic>> wilayahs = [{
    "label" : "Kota Kediri",
    "logo" : "https://wisatakemari.com/public/images/wilayah/20210719074355_2.jpg"
  }];
  int selectedKategori = 0;
  int selectedWilayah = 0;
  String valueWilayahString = "";
  int openDrawer = 0;
  int selectedSlide = 0;
  bool isLogin = false;
  String nama = "";
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    this.getKategori();
    this.getWilayah();
    this.getPopuler();
    Firebase.initializeApp().whenComplete(() {
      this.checkLogin();
    });
  }

  dispose() {
    super.dispose();
  }

  Future<void> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (await prefs.containsKey('id_user')) {
      setState(() {
        isLogin = true;
        nama = prefs.getString("nama");
      });
    }
  }

  Future<void> _handleLogout() async {
    await _googleSignIn.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (await prefs.containsKey('id_user')) {
      await prefs.clear();
      setState(() {
        isLogin = false;
        nama = "";
      });
    }
  }

  Future<void> _handleSignIn() async {
    try {
      final GoogleSignInAccount userGoogle = await _googleSignIn.signIn();
      if (userGoogle == null) {
        return;
      }

      this.getSessionOnserver(userGoogle);
    } catch (error) {
      print(error);
    }
  }

  Future<void> getSessionOnserver(GoogleSignInAccount userGoogle) async {
    var urlApi = Uri.https(Config().urlApi, '/public/api/login_google');

    http.post(urlApi, body: {
      'email': userGoogle.email,
      'name': userGoogle.displayName,
      'id': userGoogle.id
    }).then((http.Response response) {
      dynamic result = json.decode(response.body);
      this.saveSession(result, userGoogle.displayName);
    }).onError((error, stackTrace) {
      Toast.show(error.toString(), context);
    });
  }

  Future<void> saveSession(dynamic data, String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['data']['token']);
    await prefs.setString('nama', name);
    await prefs.setString('id_user', data['data']['id_user'].toString());
    setState(() {
      isLogin = true;
      nama = "Almi Kurniawan";
    });
  }

  Future<void> getPopuler() async{
    var urlApi = Uri.https(Config().urlApi, '/public/api/wisata_rekomendasi');

    http.get(urlApi).then((http.Response response) {
      if (response.statusCode == 401) {
        // logout(context);
      } else {
        dynamic result = json.decode(response.body);
        setState(() {
          populers = result['data'];
        });
      }
    }).onError((error, stackTrace) {
      Toast.show(error.toString(), context);
    });
  }

  Future<void> getKategori() async {
    var urlApi = Uri.https(Config().urlApi, '/public/api/kategori');

    http.get(urlApi).then((http.Response response) {
      if (response.statusCode == 401) {
        // logout(context);
      } else {
        dynamic result = json.decode(response.body);
        dynamic tempKategori = [];
        int index = 0;
        result['data'].forEach((element) {
          element['child'] = [];
          tempKategori.add(element);
          this.getChildKategori(index, element['id_kategori'], element['nama_kategori']);
          index++;
        });
        this.setState(() {
          kategoris = tempKategori;
        });
      }
    }).onError((error, stackTrace) {
      Toast.show(error.toString(), context);
    });
  }

  Future<void> getChildKategori(int index, int idKategori, String namaKategori) async{
    Map<String, dynamic> queryString = new Map<String, dynamic>();
    queryString['search_by'] = "kategori.nama_kategori";
    queryString['search'] = namaKategori;
    queryString['wilayah-id'] = 5.toString();

    var urlApi = Uri.https(Config().urlApi, '/public/api/wisata/search', queryString);

    http.get(urlApi).then((http.Response response) {
      if(response.statusCode==401){
        // logout(context);
      }else{
        Map<String, dynamic> result = json.decode(response.body);
        kategoris[index]['child'] = result['data']['data'];
        setState(() {});
      }
    });
  }

  Future<void> getWilayah() async {
    var urlApi = Uri.https(Config().urlApi, '/public/api/wilayah');

    http.get(urlApi).then((http.Response response) {
      if (response.statusCode == 401) {
        // logout(context);
      } else {
        Map<String, dynamic> result = json.decode(response.body);
        wilayahs = [];
        result['data'].forEach((value) {
          Map<String, dynamic> item = {
            'id': value['id'],
            'label': value['kabupaten'],
            'logo': value['gambar'],
          };
          return wilayahs.add(item);
        });
        setState(() {});
      }
    }).onError((error, stackTrace) {
      Toast.show(error.toString(), context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.transparent,
        leading: IconButton(
                  icon: (widget.open == 0
                      ? const Icon(Icons.menu)
                      : const Icon(Icons.close)),
                  onPressed: () {
                    widget.onOpenDrawer(widget.open);
                  },
                  color: Colors.white,
                ),
        title: Text("WISATAKEMARI",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
        actions: [
          (!isLogin)
            ? IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  this._handleSignIn();
                },
                color: Colors.white,
              )
            :
            PopupMenuButton(
              icon: Icon(Icons.account_circle),
              onSelected: (dynamic data){
                this._handleLogout();
              },
              itemBuilder: (context){
                return [
                  PopupMenuItem(child: Text("Logout"), height: 3, value: 1),
                ];
              }
            ),
        ],
      ),
        body: SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Container(
        color: const Color(0xffebe8e8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarouselSlider.builder(
              options: CarouselOptions(
                height: 450,
                viewportFraction: 1,
                aspectRatio: 1,
              ),
              itemCount: wilayahs.length,
              itemBuilder: (context, index, realIdx){
                return SliderBanner(
                  item: wilayahs[index],
                  onTap: (dynamic value){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return ObjekWisata(idWilayah: value['id'], namaWilayah: value['label'],);
                    }));
                  },
                );
              }
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                            hintText: 'Apa yang kamu cari?',
                            filled: true,
                            fillColor: Colors.white,
                            border: new OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(10.0),
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            suffixIcon: Icon(Icons.search))),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
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
                            valueWilayahString = value;
                          });
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        hintText: 'Kategori',
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
                      items: kategoris.map((dynamic item) {
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
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          primary: Colors.red[300],
                          onPrimary: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return Pencarian(
                              selectedKategori: selectedKategori,
                              selectedWilayah: selectedWilayah,
                              valueWilayahString: valueWilayahString,
                              search: searchController.text,
                            );
                          }));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search),
                            Text("Cari"),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Text("Terpopuler Kami",
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold)),
                  ),
                  Text(
                      "Jelajahi tempat wisata, akomodasi, kuliner, umkm, dan travel terbaik.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 350,
                child: CarouselSlider.builder(
                  options: CarouselOptions(
                    disableCenter: false,
                    height: 340.0,
                    enlargeCenterPage: true,
                    viewportFraction: 0.8,
                    aspectRatio: 0.7,
                  ),
                  itemCount: populers.length,
                  itemBuilder: (context, index, realIdx){
                    return Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: ItemObjek(
                            data: populers[index],
                            onTap: (dynamic value){
                               Navigator.push(context, MaterialPageRoute(builder: (context){
                                return DetailObjek(id : value['id'], data : value);
                              }));
                            },
                          )
                    );
                  }
                )
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 35),
                child: Text(
                  "Kategori",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DefaultTabController(
              length: kategoris.length,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TabBar(
                    isScrollable: true,
                    unselectedLabelColor: Colors.black.withOpacity(0.6),
                    indicatorColor: Colors.black,
                    labelColor: Colors.black,
                    tabs: this.tabKategori(),
                  ),
                  Container(
                    height: 500,
                    child: TabBarView(
                      children: this.kontenKategori(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  List<Widget> tabKategori() {
    List<Widget> result = [];
    kategoris.forEach((element) {
      result.add(
        Tab(
          text: element['nama_kategori'],
        ),
      );
    });
    return result;
  }

  List<Widget> kontenKategori() {
    List<Widget> result = [];
    kategoris.forEach((element) {
      result.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: element['child'].length,
                    itemBuilder: (context, index) {
                      return ListWilayah(
                        item: element['child'][index],
                        onTap: (value){
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return DetailObjek(id : value['id'], data : value);
                          }));
                        },
                      );
                    }),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(
                  "Tampilkan Semua",
                  style: TextStyle(
                      color: Colors.red[300], fontWeight: FontWeight.w600),
                ),
              )
            ],
          ),
        ),
      );
    });
    return result;
  }
}
