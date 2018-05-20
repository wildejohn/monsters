import 'package:flutter/widgets.dart';


class NewGameScreen extends StatelessWidget {
  final String gameKey;
  NewGameScreen({
    this.gameKey
  }) : super();

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 56.0, // in logical pixels
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      // Row is a horizontal, linear layout.
      child: new Row(
        // <Widget> is the type of items in the list.
        children: <Widget>[
          _button(context, 'images/head.jpg', 1),
          _button(context, 'images/torso.jpg', 2),
          _button(context, 'images/legs.png', 3),
        ],
      ),
    );
  }

  void _newDrawing(BuildContext context, String path) {
    Navigator.popAndPushNamed(context, path);
  }

  Widget _button(BuildContext context, String assetPath, int type){
    return new Expanded(child: new GestureDetector(
      onTap: () => _newDrawing(context, '/draw/$type/$gameKey'),
      child: Image.asset(
        assetPath,
        width: 200.0,
      ),
    ));
  }
}