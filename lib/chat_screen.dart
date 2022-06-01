import 'dart:async';

import 'package:chatapp/show_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as Path;
import 'dart:io';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    Key? key,
    @required this.imageUrl,
    @required this.name,
    @required this.uid,
  }) : super(key: key);

  final String? imageUrl;
  final String? name;
  final String? uid;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _message = TextEditingController();
  ScrollController _scrollController = ScrollController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  String? chatRoomId;

  XFile? _image;
  String? uploadedFileUrl;
  final ImagePicker _picker = ImagePicker();

  // current user details
  String? myEmail;
  String? myName;
  String? myBio;
  String? myImageUrl;
  String? myUid;

  @override
  void initState() {
    super.initState();
    currentUserDetails();
    createChatRoom();
    seeMsg();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage('${widget.imageUrl}'),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.name}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Active 3min',
                    style: TextStyle(fontSize: 12),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        child: Stack(
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chatrooms')
                  .doc(chatRoomId)
                  .collection('chats')
                  .orderBy('time', descending: false)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Text('No data found'),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 10, bottom: 50),
                    controller: _scrollController,
                    itemBuilder: (context, index) {
                      DocumentSnapshot ds = snapshot.data!.docs[index];
                      return ds['type'] == "text"
                          ? Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: Column(
                                children: [
                                  Container(
                                    alignment:
                                        ds['sentBy'] == _auth.currentUser!.uid
                                            ? Alignment.topRight
                                            : Alignment.topLeft,
                                    child: Container(
                                      constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8),
                                      padding: EdgeInsets.all(10),
                                      margin: EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                          color: ds['sentBy'] ==
                                                  _auth.currentUser!.uid
                                              ? Colors.blue
                                              : Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(8.0)),
                                      child: Text(
                                        ds['message'],
                                        style: TextStyle(
                                            color: ds['sentBy'] ==
                                                    _auth.currentUser!.uid
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        ds['sentBy'] == _auth.currentUser!.uid
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                    children: [
                                      ds['sentBy'] == _auth.currentUser!.uid
                                          ? ds['is_read'] == true
                                              ? Icon(
                                                  Icons.done_all,
                                                  size: 15,
                                                )
                                              : Icon(
                                                  Icons.done,
                                                  size: 15,
                                                )
                                          : Text(''),
                                      SizedBox(width: 4),
                                      ds['time'] == null
                                          ? Text('')
                                          : Text(
                                              DateFormat("hh:mm a").format(
                                                ds['time'].toDate(),
                                              ),
                                            ),
                                    ],
                                  )
                                ],
                              ),
                            )

                          // dispaly image
                          : Container(
                              padding: EdgeInsets.only(
                                  left: 14, right: 14, top: 10, bottom: 10),
                              child: Align(
                                alignment:
                                    ds['sentBy'] == _auth.currentUser!.uid
                                        ? Alignment.topRight
                                        : Alignment.topLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                        ],
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => ShowImage(
                                                  imageUrl: ds['message']),
                                            ),
                                          );
                                        },
                                        child: Image.network(
                                            ds['message'].toString()),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                    },
                  );
                }
              },
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                height: 60,
                width: double.infinity,
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          // Button send image
                          Material(
                            child: new Container(
                              margin: new EdgeInsets.symmetric(horizontal: 1.0),
                              child: new IconButton(
                                icon: new Icon(Icons.image),
                                onPressed: () async {
                                  await chooseFile();
                                },
                                color: Colors.blueGrey,
                              ),
                            ),
                            color: Colors.white,
                          ),
                          Material(
                            child: new Container(
                              margin: new EdgeInsets.symmetric(horizontal: 1.0),
                              child: new IconButton(
                                icon: new Icon(Icons.face),
                                onPressed: () {},
                                color: Colors.blueGrey,
                              ),
                            ),
                            color: Colors.white,
                          ),

                          // Edit text
                          Flexible(
                            child: Container(
                              child: TextField(
                                controller: _message,
                                style: TextStyle(
                                    color: Colors.blueGrey, fontSize: 15.0),
                                decoration: InputDecoration.collapsed(
                                  hintText: 'Type your message...',
                                  hintStyle: TextStyle(color: Colors.blueGrey),
                                ),
                                onTap: () {
                                  Timer(
                                    Duration(milliseconds: 500),
                                    () => _scrollController.jumpTo(
                                        _scrollController
                                            .position.maxScrollExtent),
                                  );
                                },
                              ),
                            ),
                          ),

                          // Button send message
                          Material(
                            child: new Container(
                              margin: new EdgeInsets.symmetric(horizontal: 8.0),
                              child: new IconButton(
                                icon: new Icon(Icons.send),
                                onPressed: () {
                                  sendMessage();
                                },
                                color: Colors.blueGrey,
                              ),
                            ),
                            color: Colors.white,
                          ),
                        ],
                      ),
                      Text('data')
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // current user details
  void currentUserDetails() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      myEmail = _prefs.getString('email') ?? '';
      myName = _prefs.getString('name') ?? '';
      myBio = _prefs.getString('bio') ?? '';
      myImageUrl = _prefs.getString('imageUrl') ?? '';
      myUid = _prefs.getString('uid') ?? '';
    });
  }

  // create chatroom
  createChatRoom() {
    var user1 = _auth.currentUser!.uid;
    var user2 = '${widget.uid}';
    var chatroom = 'chat_' +
        (user1.substring(0).codeUnitAt(0) <= user2.substring(0).codeUnitAt(0)
            ? user1 + '_' + user2
            : user2 + '_' + user1);
    setState(() {
      chatRoomId = chatroom;
    });
  }

  // select image to upload
  Future chooseFile() async {
    final XFile? _img = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = _img;
    });
    uploadFile();
  }

  // Upload image
  Future uploadFile() async {
    firebase_storage.Reference _reference = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('chats')
        .child('${Path.basename(_image!.path)}');

    firebase_storage.UploadTask _uploadTask =
        _reference.putFile(File(_image!.path));

    await _uploadTask;

    await _reference.getDownloadURL().then((value) {
      setState(() {
        uploadedFileUrl = value;
      });
    });

    CollectionReference ref1 =
        FirebaseFirestore.instance.collection('chatrooms');
    await ref1.doc(chatRoomId).set({
      "chatid": chatRoomId,
      "users": FieldValue.arrayUnion([widget.uid, _auth.currentUser!.uid]),
      "time": FieldValue.serverTimestamp(),
      "sentBy": _auth.currentUser!.uid,
      "receivedBy": widget.uid,
      "last_message": uploadedFileUrl,
      "type": "image",
      // receiver
      "receiver_image": widget.imageUrl,
      "receiver_name": widget.name,
      "receiver_typing": false,
      "unread_message_count": FieldValue.increment(1),

      // sender
      "sender_image": myImageUrl,
      "sender_name": myName,
      "sender_typing": false,
    }, SetOptions(merge: true));

    await ref1.doc(chatRoomId).collection('chats').add(
      {
        "users": FieldValue.arrayUnion([widget.uid, _auth.currentUser!.uid]),
        "time": FieldValue.serverTimestamp(),
        "sentBy": _auth.currentUser!.uid,
        "message": uploadedFileUrl,
        "type": "image",
        "is_read": false
      },
    );
  }

  // send message
  sendMessage() async {
    CollectionReference ref1 =
        FirebaseFirestore.instance.collection('chatrooms');

    await ref1.doc(chatRoomId).set({
      "chatid": chatRoomId,
      "users": FieldValue.arrayUnion([widget.uid, _auth.currentUser!.uid]),
      "time": FieldValue.serverTimestamp(),
      "sentBy": _auth.currentUser!.uid,
      "receivedBy": widget.uid,
      "last_message": _message.text,
      "type": "text",
      // receiver
      "receiver_image": widget.imageUrl,
      "receiver_name": widget.name,
      "receiver_typing": false,
      "unread_message_count": FieldValue.increment(1),

      // sender
      "sender_image": myImageUrl,
      "sender_name": myName,
      "sender_typing": false,
    }, SetOptions(merge: true));

    await ref1.doc(chatRoomId).collection('chats').add(
      {
        "users": FieldValue.arrayUnion([widget.uid, _auth.currentUser!.uid]),
        "time": FieldValue.serverTimestamp(),
        "sentBy": _auth.currentUser!.uid,
        "message": _message.text,
        "type": "text",
        "is_read": false
      },
    );
    _message.text = "";
  }

// mark message as read
  Future<void> seeMsg() async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    DocumentReference reference =
        FirebaseFirestore.instance.collection('chatrooms').doc(chatRoomId);

    //update message read count
    reference.get().then((documentSnapshot) {
      if (documentSnapshot.exists) {
        if (documentSnapshot['sentBy'] != _auth.currentUser!.uid) {
          reference.update({"unread_message_count": 0});
        }
      }
    });

    //update message read to true
    reference
        .collection('chats')
        .where('sentBy', isEqualTo: widget.uid)
        .where('is_read', isEqualTo: false)
        .get()
        .then(
      (querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          batch.update(doc.reference, {"is_read": true});
        });
        return batch.commit();
      },
    );
  }
}
