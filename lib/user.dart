// import 'package:chatapp/chat_screen.dart';
// import 'package:chatapp/main_drawer.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:intl/intl.dart';
// import 'package:badges/badges.dart';

// class Chats extends StatefulWidget {
//   const Chats({Key? key}) : super(key: key);

//   @override
//   _ChatsState createState() => _ChatsState();
// }

// class _ChatsState extends State<Chats> {
//   // String name = "";
//   // bool isSearching = false;
//   FirebaseAuth _auth = FirebaseAuth.instance;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance
//             .collection('chatrooms')
//             .where('users', arrayContains: _auth.currentUser!.uid)
//             .snapshots(),
//         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (!snapshot.hasData) {
//             return Center(
//               child: Text('No data found'),
//             );
//           } else if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: Text('Loading..'),
//             );
//           } else {
//             return ListView.separated(
//               separatorBuilder: (context, index) {
//                 return Divider(
//                   indent: 80,
//                 );
//               },
//               itemCount: snapshot.data!.docs.length,
//               itemBuilder: (context, index) {
//                 DocumentSnapshot ds = snapshot.data!.docs[index];

//                 return ListTile();
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }
