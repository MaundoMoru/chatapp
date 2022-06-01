import 'package:flutter/material.dart';

class ShowImage extends StatelessWidget {
  const ShowImage({@required this.imageUrl, Key? key}) : super(key: key);

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.black,
        child: Image.network('$imageUrl'),
      ),
    );
  }
}
