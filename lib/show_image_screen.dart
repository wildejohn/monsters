import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ShowImageScreen extends StatelessWidget {
  final String url;

  ShowImageScreen({
    Key key,
    @required this.url
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("show image $url");
    return new Scaffold(
      body: new Image.network(
        url,
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
      ),
    );
  }
}
