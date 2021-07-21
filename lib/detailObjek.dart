import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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
  Future<void> _launched;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dataObjek = widget.data;
    this.getData(); 
  }

  Future<void> getData() async{
    var urlApi = Uri.https(Config().urlApi, '/public/api/show/'+dataObjek['id'].toString());

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
        });
      }
    }).onError((error, stackTrace) {
      Toast.show(error.toString(), context);
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

  @override
  Widget build(BuildContext context) {
    print(fasilitas);
    print(yt);
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text("WISATAKEMARI",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 1,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
            child: Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
              Container(
                height: 500,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  image: DecorationImage(
                    image: (widget.data['gambar'] != null)
                        ? NetworkImage(
                            'http://wisatakemari.com/public/images/' +
                                widget.data['gambar'])
                        : AssetImage("assets/images/bg-1.jpg"),
                    colorFilter: new ColorFilter.mode(
                        Colors.black.withOpacity(0.3), BlendMode.dstATop),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Align(
                      alignment: Alignment.center,
                      child: Text(widget.data['nama'],
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold))),
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
                      Html(data : widget.data['deskripsi']),
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
                          itemCount: widget.data['objek_gambar'].length,
                          itemBuilder: (context, index){
                            return (widget.data['objek_gambar'][index]['gambar']!=null) ? Image(image: NetworkImage('http://wisatakemari.com/public/images/'+widget.data['objek_gambar'][index]['gambar'])) : Container();
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
                            MarkerLayerOptions(
                              markers: [
                                Marker(
                                  width: 80.0,
                                  height: 80.0,
                                  point: LatLng(double.parse(dataObjek['latitude']), double.parse(dataObjek['longitude'])),
                                  builder: (ctx) => Container(
                                    child: Icon(Icons.place),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                            itemCount: sosialmedia.length,
                            itemBuilder: (context, index){
                              return Wrap(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      icon: Icon(Icons.account_circle),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                        primary: Colors.red[300],
                                        onPrimary: Colors.white,
                                      ),
                                      onPressed: () {
                                        _launched = _launchInBrowser(sosialmedia[index]['url']);
                                      },
                                      label: Text(sosialmedia[index]['nama']),

                                    ),
                                  ),
                                ],
                              );
                            }
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ]))));
  }
}
