import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ListWilayah extends StatefulWidget {
  final dynamic item;
  final ValueSetter<dynamic> onTap;
  const ListWilayah({ Key key, this.item, this.onTap }) : super(key: key);

  @override
  _ListWilayahState createState() => _ListWilayahState();
}

class _ListWilayahState extends State<ListWilayah> {

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        widget.onTap(widget.item);
      },
      child: Stack(
        textDirection: TextDirection.rtl,
        fit: StackFit.loose,
        clipBehavior: Clip.hardEdge,
        children: [
          Container(
            // width: double.infinity,
            height: 250,
            child: 
            (widget.item['gambar']!=null) ? 
            CachedNetworkImage(
              imageUrl: 'https://wisatakemari.com/public/images/'+widget.item['gambar'],
              progressIndicatorBuilder: (context, url, downloadProgress){
                return Container();
              },
              errorWidget: (context, url, error){
                return Container();
              },
            )
            : Container(),
          ),
          Container(
            height: 220,
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.grey.withOpacity(0.0),
                  Colors.black,
                ],
                stops: [
                  0.0,
                  0.9
                ],
              ),
            ),
          ),
          Container(
            height: 220,
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.item['nama'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18 ),)),
          ),
          Container(
            height: 200,
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.white, size: 12),
                  Icon(Icons.star, color: Colors.white, size: 12),
                  Icon(Icons.star, color: Colors.white, size: 12),
                  Icon(Icons.star, color: Colors.white, size: 12),
                ],
              )
            )
          )
        ]
      ),
    );
  }
}