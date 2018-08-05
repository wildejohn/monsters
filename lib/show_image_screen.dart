import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:monsters/zoomable_image.dart';

class ShowImageScreen extends StatelessWidget {
  final String url;

  ShowImageScreen({Key key, @required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return new Scaffold(
        backgroundColor: Colors.black,
        body: new ZoomableImage(
            new NetworkImage(
              url,
            ),
            placeholder: Center(
              child: CircularProgressIndicator(),
            )));
  }
}
