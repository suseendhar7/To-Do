import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTask extends StatefulWidget {
  String ptitle, ptasks, isDone;
  bool edit;

  AddTask(this.ptitle, this.ptasks, this.isDone, this.edit);
  @override
  State<AddTask> createState() => _AddTaskState();
}

create(String etitle, String etasks, String eDones, String title, String tasks,
    bool edit) async {
  List<String> task = tasks.split("\n");
  print(task);
  List<bool> isDone = [];

  if (edit) {
    var etask_list = etasks.split("\n");
    var eDone_list = eDones.split(" ");
    print(etask_list);
    print(eDone_list);

    for (int i = 0; i < task.length; i++) {
      int idx = etask_list.indexOf(task[i]);
      print(idx);
      isDone.add(idx < 0
          ? false
          : eDone_list[idx] == "true"
              ? true
              : false);
    }
  } else
    for (int i = 0; i < task.length; i++) isDone.add(false);

  Map<String, List> todoList = {
    "title": [title],
    "tasks": task,
    "isDone": isDone
  };

  print(todoList);

  var collection = FirebaseFirestore.instance.collection("todo");

  if (edit) {
    await collection
        .doc(etitle)
        .delete()
        .then((_) => print("Started to update"))
        .catchError((error) => print("Delete failed: $error"));
  }

  await collection
      .doc(title)
      .set(todoList)
      .whenComplete(() => print("Created successfully"));
}

class _AddTaskState extends State<AddTask> {
  late String title, tasks;

  @override
  Widget build(BuildContext context) {
    final titleController = new TextEditingController(
        text: (widget.edit)
            ? (widget.ptitle != "Untitled")
                ? widget.ptitle
                : ""
            : "");
    final taskController =
        new TextEditingController(text: (widget.edit) ? widget.ptasks : "");
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 23),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  margin: EdgeInsets.only(left: 8, right: 8),
                  child: TextField(
                      controller: titleController,
                      textAlign: TextAlign.center,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (value) {
                        print("Title: $value");
                      },
                      style:
                          TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: "Untitled"))),
              Expanded(
                  child: Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: TextField(
                          controller: taskController,
                          style: TextStyle(fontSize: 18),
                          textInputAction: TextInputAction.newline,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                              hintText: "Add a Task...",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none))))
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.done),
        label: Text((widget.edit) ? "Save Changes" : "Create Task"),
        onPressed: () => {
          title = (titleController.text.toString().isNotEmpty)
              ? titleController.text.toString().trim()
              : "Untitled",
          tasks = taskController.text.toString().trim(),
          print("Title: $title"),
          print("Tasks: $tasks"),
          if (!(title == "Untitled" && tasks.isEmpty))
            {
              create(widget.ptitle, widget.ptasks, widget.isDone, title, tasks,
                  widget.edit),
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: (widget.edit)
                      ? Text("Changes saved")
                      : Text("Task added sucessfully")))
            },
          Navigator.pop(context)
        },
        foregroundColor: Colors.black,
        backgroundColor: Colors.blue,
        elevation: 10,
      ),
    );
  }
}
