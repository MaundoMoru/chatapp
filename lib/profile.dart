import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController _name = TextEditingController();
  TextEditingController _bio = TextEditingController();
  CollectionReference _ref = FirebaseFirestore.instance.collection('users');

  XFile? image;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.blue),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          color: Colors.blue,
          onPressed: () {
            Navigator.of(context).pop();
            // Navigator.push(
            //     context, MaterialPageRoute(builder: (context) => Home()));
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(auth.currentUser!.uid)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text('Loading...'),
            );
          } else {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;

            return ListView(
              children: [
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundImage: NetworkImage('${data['imageUrl']}'),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                            border: Border.all(
                                width: 2,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor),
                          ),
                          child: IconButton(
                            onPressed: () async {
                              final XFile? img = await _picker.pickImage(
                                  source: ImageSource.gallery);

                              setState(
                                () {
                                  image = img;
                                },
                              );

                              File file = File(image!.path);
                              try {
                                firebase_storage.UploadTask task =
                                    firebase_storage.FirebaseStorage.instance
                                        .ref(auth.currentUser!.uid)
                                        .putFile(file);

                                final String? downloadUrl =
                                    await (await task).ref.getDownloadURL();

                                _ref
                                    .doc(auth.currentUser!.uid)
                                    .update({"imageUrl": downloadUrl});
                              } catch (e) {}
                            },
                            icon: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('${data['name']}'),
                  subtitle: Text('This name will be visible by others'),
                  trailing: IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 20, top: 16, right: 20),
                                child: TextFormField(
                                  controller: _name,
                                  decoration: InputDecoration(
                                    labelText: 'Full name',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    hintText: '${data['name']}',
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 20, top: 16, right: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    OutlineButton(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      onPressed: () {},
                                      child: Text('CNCEL'),
                                    ),
                                    RaisedButton(
                                      color: Colors.blue,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      onPressed: () async {
                                        await _ref
                                            .doc(auth.currentUser!.uid)
                                            .update({'name': _name.text});
                                        Fluttertoast.showToast(
                                            msg:
                                                'Profile updated successfully!');
                                        SharedPreferences _prefs =
                                            await SharedPreferences
                                                .getInstance();

                                        _prefs.setString("name", _name.text);
                                      },
                                      child: Text(
                                        'SAVE',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: Icon(Icons.edit),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.work),
                  title: Text('${data['bio']}'),
                  subtitle: Text('Briefly describe yourself'),
                  trailing: IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 20, top: 16, right: 20),
                                child: TextFormField(
                                  controller: _bio,
                                  decoration: InputDecoration(
                                    labelText: 'Bio',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    hintText: '${data['bio']}',
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 20, top: 16, right: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    OutlineButton(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      onPressed: () {},
                                      child: Text('CNCEL'),
                                    ),
                                    RaisedButton(
                                      color: Colors.blue,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      onPressed: () async {
                                        await _ref
                                            .doc(auth.currentUser!.uid)
                                            .update({'bio': _bio.text});
                                        Fluttertoast.showToast(
                                            msg:
                                                'Profile updated successfully!');
                                        SharedPreferences _prefs =
                                            await SharedPreferences
                                                .getInstance();

                                        _prefs.setString("bio", _bio.text);
                                      },
                                      child: Text(
                                        'SAVE',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: Icon(Icons.edit),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
