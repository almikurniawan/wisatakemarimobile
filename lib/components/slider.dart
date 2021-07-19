import 'package:flutter/material.dart';
class SliderBanner extends StatefulWidget {
  final dynamic item;
  const SliderBanner({ Key key, this.item }) : super(key: key);

  @override
  _SliderBannerState createState() => _SliderBannerState();
}

class _SliderBannerState extends State<SliderBanner> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 620,
      decoration: BoxDecoration(
        color: Colors.black87,
        image: DecorationImage(
          image: NetworkImage(
              'https://wisatakemari.com/public/images/wilayah/kabupaten_magetan.jpeg'),
          colorFilter: new ColorFilter.mode(
              Colors.black.withOpacity(0.6), BlendMode.dstATop),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 15, left: 8, right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 500,
                  width: double.infinity,
                  color: Colors.transparent,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 180, left: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.item['label'],
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      ElevatedButton(
                          child: Text(
                            "Selengkapnya",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(
                                      Colors.red[300]),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(18.0),
                              ))))
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}