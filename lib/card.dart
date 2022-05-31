import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'addTask.dart';
import 'task.dart';

var dt;
String pt = "";

class CardWidget extends StatefulWidget {
  String titleName;
  List tasks;
  List isDone;

  CardWidget(this.titleName, this.tasks, this.isDone);

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

delete(String title) async {
  print("Title: $title");
  pt = title;
  var docRef = FirebaseFirestore.instance.collection("todo").doc(title);
  await docRef.get().then((DocumentSnapshot doc) {
    dt = doc.data();
  });

  var collection = FirebaseFirestore.instance.collection("todo");
  await collection
      .doc(title)
      .delete()
      .then((_) => print("Deleted"))
      .catchError((error) => print("Deletion failed: $error"));
}

restore() async {
  print("Title: $pt");
  var collection = FirebaseFirestore.instance.collection("todo");
  (dt != null)
      ? await collection
          .doc(pt)
          .set(dt)
          .whenComplete(() => print("Data restored Successfully"))
      : print("Data: $dt\nUnable to restore");
}

class _CardWidgetState extends State<CardWidget> {
  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(motion: ScrollMotion(), children: [
        SlidableAction(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            onPressed: (context) => {
                  delete(widget.titleName),
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Task deleted"),
                      action: SnackBarAction(
                          label: "Undo", onPressed: () => {restore()})))
                },
            backgroundColor: Color(0xFFFE4A49),
            foregroundColor: Colors.black,
            icon: Icons.delete,
            label: 'Delete')
      ]),
      child: GestureDetector(
        onTap: () => {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddTask(widget.titleName,
                      widget.tasks.join("\n"), widget.isDone.join(" "), true)))
        },
        child: Material(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          child: Container(
              margin: EdgeInsets.symmetric(vertical: 6),
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              decoration: BoxDecoration(
                  //color: Color.fromARGB(255, 117, 234, 121),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.black, width: 2)),
              child: Wrap(
                spacing: 20,
                runSpacing: 6,
                children: [
                  Text(
                      (widget.titleName.isNotEmpty)
                          ? widget.titleName
                          : "Untitled",
                      style: TextStyle(
                          fontSize: 20.5, fontWeight: FontWeight.bold)),
                  for (int i = 0; i < widget.tasks.length; i++)
                    TaskWidget(
                        widget.titleName, widget.tasks[i], widget.isDone[i])
                ],
              )),
        ),
      ),
    );
  }
}
