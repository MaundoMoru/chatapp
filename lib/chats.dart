import 'package:chatapp/chat_screen.dart';
import 'package:chatapp/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:badges/badges.dart';

class Chats extends StatefulWidget {
  const Chats({Key? key}) : super(key: key);

  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  String name = "";
  bool isSearching = false;
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: !isSearching ? MainDrawer() : null,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: !isSearching
            ? Text('Chats')
            : Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        this.isSearching = !this.isSearching;
                        name = "";
                      });
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search..',
                        hintStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          name = value;
                        });
                      },
                    ),
                  )
                ],
              ),
        actions: [
          !isSearching
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      this.isSearching = !this.isSearching;
                    });
                  },
                  icon: Icon(Icons.search),
                )
              : IconButton(
                  onPressed: () {
                    setState(
                      () {
                        this.isSearching = !this.isSearching;
                        name = "";
                      },
                    );
                  },
                  icon: Icon(Icons.cancel),
                ),
        ],
      ),
      body: (name != "")
          ? StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('name')
                  .startAt([name]).endAt([name + '\uf8ff']).snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: Text('Loading..'),
                  );
                } else {
                  return ListView.separated(
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot ds = snapshot.data!.docs[index];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(
                            ds['imageUrl'],
                          ),
                        ),
                        title: Text(ds['name']),
                        subtitle: Text(ds['bio']),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                imageUrl: ds['imageUrl'],
                                name: ds['name'],
                                uid: ds['uid'],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chatrooms')
                  .where('users', arrayContains: _auth.currentUser!.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: Text('Loading..'),
                  );
                } else {
                  return ListView.separated(
                    separatorBuilder: (context, index) {
                      return Divider(
                        indent: 80,
                      );
                    },
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot ds = snapshot.data!.docs[index];

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
                                    ),
                                  ]),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundImage:
                                    ds['sentBy'] == _auth.currentUser!.uid
                                        ? NetworkImage(ds['receiver_image'])
                                        : NetworkImage(ds['sender_image']),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 15,
                                height: 15,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        title: ds['sentBy'] == _auth.currentUser!.uid
                            ? Text(ds['receiver_name'],
                                style: TextStyle(fontWeight: FontWeight.w500))
                            : Text(ds['sender_name'],
                                style: TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: ds['receiver_typing']
                            ? Row(
                                children: [
                                  SpinKitThreeBounce(
                                    color: Colors.blue,
                                    size: 20.0,
                                  )
                                ],
                              )
                            : Row(
                                children: [
                                  ds['type'] == "text"
                                      ? Expanded(
                                          child: Text(
                                            ds['last_message'],
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(),
                                          ),
                                        )
                                      : Icon(
                                          Icons.image,
                                          color: Colors.grey[600],
                                        ),
                                ],
                              ),
                        trailing: Column(
                          children: [
                            ds['time'] == null
                                ? Text(DateTime.now().toString())
                                : Text(
                                    DateFormat('hh:mm a').format(
                                      ds['time'].toDate(),
                                    ),
                                  ),
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                              child: ds['sentBy'] == _auth.currentUser!.uid
                                  ? ds['unread_message_count'] == 0
                                      ? Icon(Icons.done_all, size: 17)
                                      : Icon(Icons.done, size: 17)
                                  : ds['unread_message_count'] > 0
                                      ? Badge(
                                          toAnimate: false,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          badgeContent: Text(
                                            ds['unread_message_count']
                                                .toString(),
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        )
                                      : Text(''),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                imageUrl: ds['sentBy'] == _auth.currentUser!.uid
                                    ? ds['receiver_image']
                                    : ds['sender_image'],
                                name: ds['sentBy'] == _auth.currentUser!.uid
                                    ? ds['receiver_name']
                                    : ds['sender_name'],
                                uid: ds['sentBy'] == _auth.currentUser!.uid
                                    ? ds['receivedBy']
                                    : ds['sentBy'],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
