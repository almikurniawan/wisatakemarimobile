import 'package:flutter/material.dart';

class IconKategori extends StatefulWidget {
  final Map<String, dynamic> item;
  const IconKategori({ Key key, this.item }) : super(key: key);

  @override
  _IconKategoriState createState() => _IconKategoriState();
}

class _IconKategoriState extends State<IconKategori> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      child: Column(
        children: [
          MaterialButton(
            shape: CircleBorder(),
            child: Icon(Icons.home, color: Colors.white,),
            onPressed: () {
            },
            color: Colors.red[300],
            height: 60,
          ),
          Text(widget.item['nama_kategori'], style: TextStyle(color: Colors.white, fontSize: 20, ),)
        ],
      ),
    );
  }
}