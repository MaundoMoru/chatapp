import 'package:chatapp/main_drawer.dart';
import 'package:flutter/material.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: MainDrawer(),
        appBar: AppBar(
          title: Text('Notifications'),
        ),
        body: Center(
          child: Text(
            'No notifications',
            style: TextStyle(fontSize: 16, color: Colors.blue),
          ),
        ));
  }
}
