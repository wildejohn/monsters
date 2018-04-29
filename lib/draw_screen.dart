import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';


class DrawScreen extends StatelessWidget {
  DrawScreen({
    this.drawingType
  }) : super();

  final int drawingType;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);
    return new Container(
    );
  }

}