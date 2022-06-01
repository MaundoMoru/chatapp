import 'package:chatapp/chats.dart';
import 'package:chatapp/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Users extends StatefulWidget {
  const Users({Key? key}) : super(key: key);

  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> {
  bool isSearching = false;
  String name = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: !isSearching ? MainDrawer() : null,
        appBar: AppBar(
          elevation: 0,
          title: !isSearching
              ? Text('Users')
              : TextField(
                  cursorColor: Colors.white,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    border: InputBorder.none,
                    hintText: 'Search by name...',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                ),
          actions: [
            isSearching
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        this.isSearching = false;
                        name = "";
                      });
                    },
                    icon: Icon(Icons.cancel),
                  )
                : IconButton(
                    onPressed: () {
                      setState(() {
                        this.isSearching = true;
                      });
                    },
                    icon: Icon(Icons.search),
                  )
          ],
        ),
        body: StreamBuilder(
          stream: (name != "" && name != null)
              ? FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('name')
                  .startAt([(name)]).endAt([name + '\uf8ff']).snapshots()
              : FirebaseFirestore.instance.collection('users').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Text('Loading...'),
              );
            } else {
              return ListView.separated(
                separatorBuilder: (context, index) {
                  return Divider(
                    indent: 80,
                    endIndent: 10,
                  );
                },
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                )
                              ]),
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            radius: 24,
                            backgroundImage: NetworkImage(
                              snapshot.data!.docs[index]['imageUrl'],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            height: 15,
                            width: 15,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                              border: Border.all(
                                width: 2,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    title: Text(
                      snapshot.data!.docs[index]['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(snapshot.data!.docs[index]['bio']),
                    trailing: Text('12:32'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Chats(),
                        ),
                      );
                    },
                  );
                },
              );
            }
          },
        ));
  }
}
