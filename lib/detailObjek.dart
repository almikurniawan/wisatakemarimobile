import 'dart:convert';
import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:wisatakemari/routeNavigation.dart';
import 'config/app.dart';

class DetailObjek extends StatefulWidget {
  final int id;
  final dynamic data;
  const DetailObjek({Key key, this.id, this.data}) : super(key: key);

  @override
  _DetailObjekState createState() => _DetailObjekState();
}

class _DetailObjekState extends State<DetailObjek> {
  dynamic dataObjek;
  dynamic fasilitas;
  List yt;
  List sosialmedia;
  List produk;
  Future<void> _launched;
  bool isLoading;
  List rangeBiaya = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = true;
    this.getData(widget.id);
    this.getDataBiaya(widget.id);
  }

  Future<void> getData(int id) async{
    var urlApi = Uri.https(Config().urlApi, '/public/api/show/'+id.toString());

    http.get(urlApi).then((http.Response response) {
      if (response.statusCode == 401) {
        // logout(context);
      } else {
        Map<String, dynamic> result = json.decode(response.body);
        setState(() {
          dataObjek = result['data'][0][0];
          fasilitas = result['data'][1]['fasilitas'];
          sosialmedia = result['data'][2]['sosialmedia'];
          yt = result['data'][3]['youtube'];
          produk = result['data'][4]['produk'];
          isLoading = false;
        });
      }
    }).onError((error, stackTrace) {
    });
  }

  Future<void> getDataBiaya(int id) async{
    Map<String, dynamic> queryString = new Map<String, dynamic>();
    queryString['id'] = id.toString();
    var urlApi = Uri.https(Config().urlApi, '/public/api/range_biaya', queryString);

    http.get(urlApi).then((http.Response response) {
      if (response.statusCode == 401) {
        // logout(context);
      } else {
        Map<String, dynamic> result = json.decode(response.body);
        setState(() {
          rangeBiaya = result['data'];
        });
      }
    });
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        universalLinksOnly: true,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  List<Widget> rangeComponent(){
    NumberFormat curency = new NumberFormat.currency(locale: "id_ID", symbol: "Rp. ");
    List<Widget> component = [];
    rangeBiaya.forEach((element) {
      component.add(
        Column(
          children: [
            Wrap(
              direction: Axis.horizontal,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                Text(element['nama_kategori'], style: TextStyle(fontWeight: FontWeight.bold),),
                Text(" Mulai Dari Rp. "),
                Text(curency.format(element['min']), style: TextStyle(color: Colors.red[300])),
                Text(" Hingga Rp. "),
                Text(curency.format(element['max']), style: TextStyle(color: Colors.red[300])),
              ],
            ),
            Divider()
          ],
        )
      );
    });
    print(component);
    return component;
  }

  @override
  Widget build(BuildContext context) {
    List<Icon> rating = [];
    if(!isLoading){
      for(int i=1; i <= 5; i++){
        if(dataObjek['rating'].floor()>=i){
          rating.add(Icon(Icons.star, color: Colors.yellow[700], size: 18,));
        }else{
          rating.add(Icon(Icons.star, size: 18));
        }
      }
    }
    NumberFormat curency = new NumberFormat.currency(locale: "id_ID", symbol: "Rp. ");
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Image(
            image: AssetImage("assets/images/logo.png"),
            height: 35,
          ),
          backgroundColor: Colors.transparent,
          elevation: 1,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
            child: Container(
                width: double.infinity,
                child: 
                (isLoading) ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 300),
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ) : 
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  image: DecorationImage(
                    image: (dataObjek['url_gambar'] != null)
                        ? NetworkImage(dataObjek['url_gambar'])
                        : AssetImage("assets/images/bg-1.jpg"),
                    colorFilter: new ColorFilter.mode(
                        Colors.black.withOpacity(0.3), BlendMode.dstATop),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Column(
                    children: [
                      Text(dataObjek['nama'],
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: rating,
                              ),
                              (dataObjek['rating'].floor()>=4) ? Text("Sangat Baik", style: TextStyle(color: Colors.white)) : Text("Baik", style: TextStyle(color: Colors.white))
                            ],
                          ),
                          Container(
                            color: Colors.blue,
                            padding:const EdgeInsets.all(8),
                            child: Text(dataObjek['rating'].toString(), style: TextStyle(color: Colors.white),),
                          )
                        ],
                      ),
                      MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: GridView.builder(
                          padding: EdgeInsets.only(bottom: 10),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 4),
                          itemCount: sosialmedia.length,
                          itemBuilder: (context, index){
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Wrap(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      icon: Icon(Icons.account_circle),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                        primary: Colors.transparent,
                                        onPrimary: Colors.white,
                                        side: BorderSide(color: Colors.red, width: 1),
                                        elevation: 1,
                                        shape: RoundedRectangleBorder( //to set border radius to button
                                            borderRadius: BorderRadius.circular(30)
                                        ),
                                      ),
                                      onPressed: () {
                                        _launched = _launchInBrowser(sosialmedia[index]['url']);
                                      },
                                      label: Text(sosialmedia[index]['nama']),

                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          primary: Colors.transparent,
                          onPrimary: Colors.white,
                          side: BorderSide(color: Colors.red, width: 1),
                          elevation: 1,
                          shape: RoundedRectangleBorder( //to set border radius to button
                              borderRadius: BorderRadius.circular(30)
                          ),
                        ),
                        onPressed: () {
                        },
                        child: Text("Objek Terdekat"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          primary: Colors.transparent,
                          onPrimary: Colors.white,
                          side: BorderSide(color: Colors.red, width: 1),
                          elevation: 1,
                          shape: RoundedRectangleBorder( //to set border radius to button
                              borderRadius: BorderRadius.circular(30)
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return RouteNavigation(latitute: double.parse(dataObjek['latitude']), longitude: double.parse(dataObjek['longitude']),);
                            }));
                        },
                        child: Text("Rute ke Lokasi"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          primary: Colors.transparent,
                          onPrimary: Colors.white,
                          side: BorderSide(color: Colors.red, width: 1),
                          elevation: 1,
                          shape: RoundedRectangleBorder( //to set border radius to button
                              borderRadius: BorderRadius.circular(30)
                          ),
                        ),
                        onPressed: () {
                        },
                        child: Text("Penawaran Kami"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          primary: Colors.transparent,
                          onPrimary: Colors.white,
                          side: BorderSide(color: Colors.red, width: 1),
                          elevation: 1,
                          shape: RoundedRectangleBorder( //to set border radius to button
                              borderRadius: BorderRadius.circular(30)
                          ),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              contentPadding: const EdgeInsets.all(0),
                              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 150),
                              title: Text("Range Biaya di "+dataObjek['nama'], style: TextStyle(fontWeight: FontWeight.bold),),
                              content: Column(
                                children: this.rangeComponent(),
                              )
                            ),
                          );
                        },
                        child: Text("Range Biaya"),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Deskripsi",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Html(data : dataObjek['deskripsi']),
                      Divider(),
                      Text(
                        "Informasi",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text("Alamat : "+dataObjek['alamat']),
                      Text("Nomor Telepon : "+dataObjek['no_telp']),
                      Text("Website  : "+dataObjek['website']),
                      Divider(),
                      Text(
                        "Fasilitas",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Html(data : (fasilitas!=null) ? fasilitas : "-"),
                      Divider(),
                      Row(
                        children: [
                          Icon(Icons.image),
                          Text(
                            "Galeri",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                          itemCount: dataObjek['objek_gambar'].length,
                          itemBuilder: (context, index){
                            return (dataObjek['objek_gambar'][index]['gambar']!=null) ? 
                            GestureDetector(
                              onTap: (){
                                showDialog(context: context, builder: (context){
                                  return AlertDialog(
                                    contentPadding: const EdgeInsets.all(0),
                                    content: 
                                    Image(
                                      image: NetworkImage(
                                        'https://wisatakemari.com/public/images/'+dataObjek['objek_gambar'][index]['gambar']
                                      ),
                                    )
                                  );
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Image(
                                  image: NetworkImage('https://wisatakemari.com/public/images/'+dataObjek['objek_gambar'][index]['gambar']
                                  ),
                                ),
                              ),
                            ) 
                            : 
                            Container();
                          }
                        ),
                      ),
                      Divider(),
                      Row(
                        children: [
                          Icon(Icons.place),
                          Text(
                            "Lokasi",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        height: 250,
                        child: FlutterMap(
                          options: MapOptions(
                            center: LatLng(double.parse(dataObjek['latitude']), double.parse(dataObjek['longitude'])),
                            zoom: 13.0,
                          ),
                          layers: [
                            TileLayerOptions(
                                urlTemplate:
                                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                subdomains: ['a', 'b', 'c']),
                            (dataObjek['latitude']!=null && dataObjek['latitude']!="") ?
                            MarkerLayerOptions(
                              markers: [
                                Marker(
                                  width: 80.0,
                                  height: 80.0,
                                  point: LatLng(double.parse(dataObjek['latitude']), double.parse(dataObjek['longitude'])),
                                  builder: (ctx) => Container(
                                    child: Icon(Icons.place, color : Colors.red, size : 20),
                                  ),
                                ),
                              ],
                            ) :
                            MarkerLayerOptions(),
                          ],
                        ),
                      ),
                      Divider(),
                      Row(
                        children: [
                          Icon(Icons.place),
                          Text(
                            "Produk",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: produk.length,
                          itemBuilder: (context, index){
                            return GestureDetector(
                              onTap: (){
                                showDialog(context: context, builder: (context){
                                  return AlertDialog(
                                    title: Text(produk[index]['nama'], style: TextStyle(fontWeight: FontWeight.bold)),
                                    content: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Html(data: (produk[index]['deskripsi']!=null ? produk[index]['deskripsi'] : "-"), shrinkWrap: true,),
                                          Text(curency.format(produk[index]['harga']), style: TextStyle(color: Colors.red[300], fontWeight: FontWeight.bold,)),
                                          Image(
                                            image: NetworkImage(
                                              produk[index]['url_gambar']
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  );
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Image(
                                      width: MediaQuery.of(context).size.width * 0.3,
                                      image: NetworkImage(
                                        produk[index]['url_gambar']
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text(produk[index]['nama'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold )),
                                          Text(curency.format(produk[index]['harga']))
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }
                        ),
                      ),
                      Divider(),
                      (yt!=null) ? 
                      MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: yt.length,
                          itemBuilder: (context, index){
                            return Html(data: '<iframe width="560" height="315" src="'+yt[index]['url']+'" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>');
                          }
                        ),
                      ) : Container(),
                    ],
                  ),
                ),
              )
            ]))));
  }
}
