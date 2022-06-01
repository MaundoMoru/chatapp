import 'package:chatapp/home.dart';
import 'package:chatapp/register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Sign in',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Form(
            key: _form,
            child: ListView(
              children: [
                SizedBox(
                  height: 50,
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                      controller: _email,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: 'eg. chatapp@gmail.com',
                        prefixIcon: Icon(
                          Icons.email,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter username';
                        }
                      }),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    controller: _password,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintText: '******',
                      prefixIcon: Icon(
                        Icons.lock,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      if (value.length < 6) {
                        return 'Password is too short';
                      }
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  height: 70,
                  child: RaisedButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: () async {
                      if (_form.currentState!.validate()) {
                        try {
                          UserCredential userCredential =
                              await _auth.signInWithEmailAndPassword(
                                  email: _email.text, password: _password.text);

                          // get user info from firestore and save to device disk
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(_auth.currentUser!.uid)
                              .get()
                              .then(
                            (DocumentSnapshot documentSnapshot) async {
                              if (documentSnapshot.exists) {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setString(
                                    "name", documentSnapshot['name']);
                                prefs.setString("bio", documentSnapshot['bio']);
                                prefs.setString(
                                    "email", documentSnapshot['email']);
                                prefs.setString(
                                    "imageUrl", documentSnapshot['imageUrl']);
                                prefs.setString("uid", documentSnapshot['uid']);
                              }
                            },
                          );

                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) => Home()));
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'invalid-email') {
                            Fluttertoast.showToast(msg: 'invalid email');
                          } else if (e.code == 'user-not-found') {
                            Fluttertoast.showToast(
                                msg: 'User not found for that email');
                          }
                        }
                      }
                    },
                    child: Text(
                      'Sign in',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Text('Do not have account?'),
                      FlatButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Register(),
                              ),
                            );
                          },
                          child: Text(
                            'Sign up',
                            style: TextStyle(color: Colors.blue, fontSize: 20),
                          ))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
