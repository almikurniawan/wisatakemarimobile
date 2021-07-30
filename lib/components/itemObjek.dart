import 'package:flutter/material.dart';
import 'dart:core';
import 'package:html/parser.dart';

class ItemObjek extends StatefulWidget {
  final dynamic data;
  final ValueSetter<dynamic> onTap;
  const ItemObjek({Key key, this.data, this.onTap}) : super(key: key);

  @override
  _ItemObjekState createState() => _ItemObjekState();
}

class _ItemObjekState extends State<ItemObjek> {
  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString = parse(document.body.text).documentElement.text;

    return parsedString;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onTap(widget.data);
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (widget.data['url_gambar']!=null) ?
            Image.network(widget.data['url_gambar'])
            : Container(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.data['nama'],
                  softWrap: true,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: (_parseHtmlString(widget.data['deskripsi']).length >= 100)
                  ? Text(_parseHtmlString(widget.data['deskripsi'])
                      .substring(0, 100))
                  : Text(_parseHtmlString(widget.data['deskripsi'])),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.place, color: Colors.grey,),
                  Text(widget.data['wilayah']['kabupaten']),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.category, color: Colors.grey,),
                  Text(widget.data['kategori']['nama_kategori']),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
            )
          ],
        ),
      ),
    );
  }
}
