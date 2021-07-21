import 'package:flutter/material.dart';
import 'dart:core';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';

class ItemObjek extends StatefulWidget {
  final dynamic data;
  final ValueSetter<dynamic> onTap;
  const ItemObjek({Key key, this.data, this.onTap}) : super(key: key);

  @override
  _ItemObjekState createState() => _ItemObjekState();
}

class _ItemObjekState extends State<ItemObjek> {

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        widget.onTap(widget.data);
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (widget.data['gambar']!=null) ? 
            CachedNetworkImage(
                imageUrl: widget.data['gambar'],
                progressIndicatorBuilder: (context, url, downloadProgress){
                  return Container();
                },
                errorWidget: (context, url, error){
                  return Container();
                },
            )
            : Container(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.data['nama'],
                softWrap: true,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: (widget.data['deskripsi'].length>=100) ? Html(data : widget.data['deskripsi'].substring(0, 100)) : Html(data : widget.data["deskripsi"]),
            )
          ],
        ),
      ),
    );
  }
}
