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
      "gambar": "202107140318150.97212400%201626232695_101.jpg",
      "nama": "LOTUS GARDEN Hotel Kediri",
      "deskripsi":
          "Lotus Garden Hotel adalah tempat bermalam yang tepat bagi Anda yang berlibur bersama keluarga. Nikmati segala fasilitas hiburan untuk Anda dan keluarga. Lotus Garden Hotel memiliki segala fasilitas penunjang bisnis untuk Anda dan kolega. Jika Anda berniat menginap dalam jangka waktu yang lama, Lotus Garden Hotel adalah pilihan tepat."
    },
    {
      "gambar": "202107131448240.44410600%201626187704_90.jpg",
      "nama": "Parai beach",
      "deskripsi":
          "Lotus Garden Hotel adalah tempat bermalam yang tepat bagi Anda yang berlibur bersama keluarga. Nikmati segala fasilitas hiburan untuk Anda dan keluarga. Lotus Garden Hotel memiliki segala fasilitas penunjang bisnis untuk Anda dan kolega. Jika Anda berniat menginap dalam jangka waktu yang lama, Lotus Garden Hotel adalah pilihan tepat."
    },
    {
      "gambar": "202107140222410.69786800%201626229361_96.jpeg",
      "nama": "Kartika Hotel",
      "deskripsi":
          "Lotus Garden Hotel adalah tempat bermalam yang tepat bagi Anda yang berlibur bersama keluarga. Nikmati segala fasilitas hiburan untuk Anda dan keluarga. Lotus Garden Hotel memiliki segala fasilitas penunjang bisnis untuk Anda dan kolega. Jika Anda berniat menginap dalam jangka waktu yang lama, Lotus Garden Hotel adalah pilihan tepat."
    }
  ];
  List kategoris = [];
  List<Map<String, dynamic>> wilayahs = [{
    "label" : "Kota Kediri",
    "logo" : "kabupaten_magetang.jpg"
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

  Future<void> getKategori() async {
    var urlApi = Uri.https(Config().urlApi, '/public/api/kategori');

    http.get(urlApi).then((http.Response response) {
      if (response.statusCode == 401) {
        // logout(context);
      } else {
        dynamic result = json.decode(response.body);
        dynamic tempKategori = [];
        result['data'].forEach((element) {
          element['child'] = [];
          tempKategori.add(element);
        });
        this.setState(() {
          kategoris = tempKategori;
        });
      }
    }).onError((error, stackTrace) {
      Toast.show(error.toString(), context);
    });
  }

  Future<void> getWilayah() async {
    var urlApi = Uri.https(Config().urlApi, '/public/api/wilayah');

    http.get(urlApi).then((http.Response response) {
      if (response.statusCode == 401) {
        // logout(context);
      } else {
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

  @override
  Widget build(BuildContext context) {

    // print(wilayahs);
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
                height: 620,
                viewportFraction: 1,
                aspectRatio: 1,
              ),
              itemCount: wilayahs.length,
              itemBuilder: (context, index, realIdx){
                return SliderBanner(item: wilayahs[index],);
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
                          padding: EdgeInsets.all(20),
                          primary: Colors.red[300],
                          onPrimary: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return Pencarian(
                              selectedKategori: selectedKategori,
                              selectedWilayah: selectedWilayah,
                              valueWilayahString: "",
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
                      // physics: const NeverScrollableScrollPhysics(),
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
                    // physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: wilayahs.length,
                    itemBuilder: (context, index) {
                      return ListWilayah(item: wilayahs[index]);
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