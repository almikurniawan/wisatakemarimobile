import 'package:flutter/material.dart';
import 'dart:core';

import 'package:flutter_html/flutter_html.dart';

class ItemObjekManage extends StatefulWidget {
  final dynamic data;
  final ValueSetter<dynamic> onEdit;
  final ValueSetter<dynamic> onDelete;
  const ItemObjekManage({Key key, this.data, this.onEdit, this.onDelete}) : super(key: key);

  @override
  _ItemObjekManageState createState() => _ItemObjekManageState();
}

class _ItemObjekManageState extends State<ItemObjekManage> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (widget.data['gambar']!=null) ? 
          Image(
              image: NetworkImage(
                  'https://wisatakemari.com/public/images/'+widget.data['gambar'])) : Container(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.data['objek'],
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
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(icon: Icon(Icons.edit, color: Colors.amber,), onPressed: (){
                widget.onEdit(widget.data);
              }),
              IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: (){
                widget.onDelete(widget.data);
              })
            ],
          )
        ],
      ),
    );
  }
}
