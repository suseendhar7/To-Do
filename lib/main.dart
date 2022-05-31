import 'package:flutter/material.dart';
import 'addTask.dart';
import 'card.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: 16.0, bottom: 0, left: 16, right: 16),
          child: Column(children: [
            Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.all(20.0),
              child: Text("To-Do",
                  style:
                      TextStyle(fontSize: 35.0, fontWeight: FontWeight.bold)),
              /*Icon(
                    Icons.account_circle_outlined,
                    size: 40.0,
                  )*/
            ),
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("todo")
                        .snapshots(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Center(child: CircularProgressIndicator());
                        default:
                          if (snapshot.hasError) {
                            return Text(
                                "Something went wrong. Try again Later");
                          } else if (snapshot.data?.docs.length == 0) {
                            return Center(
                                child: Text("No Tasks Pending",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 22, color: Colors.grey)));
                          } else if (snapshot.hasData ||
                              snapshot.data != null) {
                            return ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data?.docs.length,
                                itemBuilder: (BuildContext context, int index) {
                                  QueryDocumentSnapshot<Object?>?
                                      documentSnapshot =
                                      snapshot.data?.docs[index];
                                  return (documentSnapshot != null)
                                      ? CardWidget(
                                          documentSnapshot["title"][0],
                                          documentSnapshot["tasks"],
                                          documentSnapshot["isDone"])
                                      : SizedBox.shrink();
                                });
                          }

                          return Text("");
                      }
                    }))
          ]),
        )),
        floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.add),
          foregroundColor: Colors.black,
          backgroundColor: Colors.blue,
          elevation: 10.0,
          label: Text("Add Task"),
          onPressed: () => {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddTask("xyz", "xyz", "sss", false)))
          },
        ));
  }
}
