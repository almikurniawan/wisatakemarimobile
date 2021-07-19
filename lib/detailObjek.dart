import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_html/flutter_html.dart';

class DetailObjek extends StatefulWidget {
  final int id;
  final dynamic data;
  const DetailObjek({Key key, this.id, this.data}) : super(key: key);

  @override
  _DetailObjekState createState() => _DetailObjekState();
}

class _DetailObjekState extends State<DetailObjek> {
  @override
  Widget build(BuildContext context) {
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
                            center: LatLng(-7.812919, 112.014614),
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
                                  point: LatLng(-7.812919, 112.014614),
                                  builder: (ctx) => Container(
                                    child: Icon(Icons.place),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ]))));
  }
}
