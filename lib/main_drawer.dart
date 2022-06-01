import 'package:chatapp/login.dart';
import 'package:chatapp/profile.dart';
import 'package:chatapp/themes.dart';
import 'package:chatapp/users.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  String? email;
  String? name;
  String? bio;
  String? imageUrl;

  void getInfo() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      email = _prefs.getString('email') ?? '';
      name = _prefs.getString('name') ?? '';
      bio = _prefs.getString('bio') ?? '';
      imageUrl = _prefs.getString('imageUrl') ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            currentAccountPicture: CircleAvatar(),
            accountName: Text(
              '$name',
              style: TextStyle(fontSize: 16),
            ),
            accountEmail: Text('$bio'),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text(
              'Profile',
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Profile()));
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text(
              'Users',
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              // Navigator.of(context).pop();
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Users()));
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text(
              'Messages',
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              // Navigator.of(context).pop();
              // Navigator.push(
              //     context, MaterialPageRoute(builder: (context) => Chats()));
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(
              'Favorite',
              style: TextStyle(fontSize: 16),
            ),
            onTap: null,
          ),
          ListTile(
            leading: Icon(Icons.share),
            title: Text(
              'Share',
              style: TextStyle(fontSize: 16),
            ),
            onTap: null,
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text(
              'Requests',
              style: TextStyle(fontSize: 16),
            ),
            onTap: null,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(
              'Settings',
              style: TextStyle(fontSize: 16),
            ),
            onTap: null,
          ),
          ListTile(
            leading: IconButton(
                onPressed: () {
                  customTheme.toggleTheme();
                },
                icon: Icon(Icons.light_mode)),
            title: Text(
              'Theme',
              style: TextStyle(fontSize: 16),
            ),
            onTap: null,
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text(
              'Policies',
              style: TextStyle(fontSize: 16),
            ),
            onTap: null,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text(
              'Exit',
              style: TextStyle(fontSize: 16),
            ),
            onTap: () async {
              SharedPreferences _prefs = await SharedPreferences.getInstance();
              _prefs.remove('email');
              _prefs.remove('name');
              _prefs.remove('bio');
              _prefs.remove('imageUrl');

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Login(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
