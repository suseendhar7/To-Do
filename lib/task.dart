import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskWidget extends StatefulWidget {
  String title;
  String taskName;
  bool done;

  TaskWidget(this.title, this.taskName, this.done);
  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

update(String title, String task, bool done) async {
  var docRef = FirebaseFirestore.instance.collection("todo").doc(title);
  await docRef.get().then(
    (DocumentSnapshot doc) async {
      final data = doc.data() as Map<String, dynamic>;
      var tasks = data["tasks"];
      var isDone;
      for (int i = 0; i < tasks.length; i++) {
        if (tasks[i] == task) {
          isDone = doc["isDone"];
          isDone[i] = (isDone[i]) ? false : true;
          i = tasks.length;
        }
      }

      var collection = FirebaseFirestore.instance.collection("todo");
      await collection
          .doc(title)
          .update({"isDone": isDone})
          .then((_) => print('Updated'))
          .catchError((error) => print('Update failed: $error'));
    },
    onError: (e) => print("Error getting document: $e"),
  );
}

class _TaskWidgetState extends State<TaskWidget> {
  @override
  Widget build(BuildContext context) {
    return (widget.taskName.isNotEmpty)
        ? Container(
            child: Row(children: [
            Text(widget.taskName,
                style: TextStyle(
                    fontSize: 18.0,
                    color: (widget).done ? Colors.grey : null,
                    decoration:
                        (widget.done) ? TextDecoration.lineThrough : null)),
            Spacer(),
            Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black, width: 1.5)),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.done = !widget.done;
                      update(widget.title, widget.taskName, widget.done);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: (widget.done)
                              ? Text("Marked as done")
                              : Text("Marked as undone")));
                    });
                  },
                  child: Icon(Icons.check_circle_rounded,
                      color: (widget.done) ? Colors.black : Colors.white,
                      size: 18),
                ))
          ]))
        : SizedBox.shrink();
  }
}
