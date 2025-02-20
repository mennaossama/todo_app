import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/models/todo_model.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget defaultFormField({
  required IconData prefix,
  required String label,
  required TextEditingController controller,
  VoidCallback? ontap,
  String? Function(String?)? validate,
}) =>
    TextFormField(
      decoration: InputDecoration(
          prefixIcon: Icon(prefix),
          labelText: label,
          border: OutlineInputBorder()),
      controller: controller,
      onTap: ontap,
      validator: validate,
    );

Widget taskItem({
  required TodoModel todo,
  required int index,
  required BuildContext context1,
}) =>
    Dismissible(
      key: Key(todo.id.toString()),
      direction: DismissDirection.horizontal, // Allow both swipe directions
      background: Container(
        color: Colors.green, // Left to Right Swipe (startToEnd)
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.edit, color: Colors.white), // Example icon
      ),
      secondaryBackground: Container(
        color: Colors.red, // Right to Left Swipe (endToStart)
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          bool shouldDelete = await showDialog(
            context: context1,
            builder: (context) => AlertDialog(
              title: Text("Are you sure you want to delete this To Do?"),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, false); // Cancel delete
                        },
                        child: Text("Cancel"),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          AppCubit.get(context1).deletetodo(todo);
                          Navigator.pop(context, true); // Confirm delete
                        },
                        child: Text("Delete"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
          return shouldDelete;
        } else {
          var cubit = AppCubit.get(context1);

          // Initialize controllers with todo values
          TextEditingController titleController =
              TextEditingController(text: todo.title);
          TextEditingController timeController =
              TextEditingController(text: todo.time);
          TextEditingController dateController =
              TextEditingController(text: todo.date);

          // Open ModalBottomSheet properly
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showModalBottomSheet(
              context: context1,
              builder: (context) => Container(
                color: Colors.white,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: cubit.formkey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        defaultFormField(
                          prefix: Icons.title,
                          validate: (value) {
                            if (value == null || value.isEmpty) {
                              return "Title can't be null";
                            }
                            return null;
                          },
                          label: "Title",
                          controller: titleController,
                        ),
                        SizedBox(height: 20),
                        defaultFormField(
                          prefix: Icons.timer_sharp,
                          label: "Task time",
                          controller: timeController,
                          validate: (value) {
                            if (value == null || value.isEmpty) {
                              return "Time can't be null";
                            }
                            return null;
                          },
                          ontap: () {
                            showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            ).then((value) {
                              if (value != null) {
                                timeController.text = value.format(context);
                              }
                            });
                          },
                        ),
                        SizedBox(height: 20),
                        defaultFormField(
                          prefix: Icons.date_range,
                          label: "Task date",
                          controller: dateController,
                          validate: (value) {
                            if (value == null || value.isEmpty) {
                              return "Date can't be null";
                            }
                            return null;
                          },
                          ontap: () {
                            showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2026, 1, 1),
                            ).then((value) {
                              if (value != null) {
                                dateController.text =
                                    DateFormat.yMMMd().format(value);
                              }
                            });
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Save the data here
                            if (cubit.formkey.currentState!.validate()) {
                              // Update the todo with new values
                              todo.title = titleController.text;
                              todo.time = timeController.text;
                              todo.date = dateController.text;

                              // Save the updated todo
                              cubit.updateTodo(todo, todo.id);

                              // Close the bottom sheet
                              Navigator.pop(context);
                            }
                          },
                          child: Text("Save"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });

          return false; // Do not dismiss the item
        }
      },

      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              child: Text('${todo.time}'),
              radius: 40,
              backgroundColor: Colors.blue,
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${todo.title}",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                  Text("${todo.date}",
                      style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            todo.status != 'done'
                ? IconButton(
                    onPressed: () {
                      AppCubit.get(context1).updatetodostatus(todo.id, 'done');
                    },
                    icon: Icon(
                      Icons.check_box,
                      color: Colors.green,
                    ),
                  )
                : SizedBox(), // Hides the button when archived

            todo.status != 'archived'
                ? IconButton(
                    onPressed: () {
                      AppCubit.get(context1)
                          .updatetodostatus(todo.id, 'archived');
                    },
                    icon: Icon(
                      Icons.archive,
                      color: Colors.black38,
                    ),
                  )
                : SizedBox(), // Hides the button when archived
          ],
        ),
      ),
    );
Widget taskbuilder(
    {required List<TodoModel> todolist,
    required formkey,
    required Scaffoldkey}) {
  return ListView.separated(
      itemBuilder: (context, index) => taskItem(
            todo: todolist[index],
            index: index,
            context1: context,
          ),
      separatorBuilder: (context, index) => Padding(
            padding: EdgeInsetsDirectional.only(start: 15),
            child: Container(
              height: 1,
              color: Colors.grey,
            ),
          ),
      itemCount: todolist.length);
}

Widget bottomsheet({
  required scaffoldkey,
  required formkey,
  required titleController,
  required timeController,
  required dateController,
  required context,
}) {
  return scaffoldkey.currentState!
      .showBottomSheet((context) => Container(
            color: Colors.white,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: formkey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    defaultFormField(
                        prefix: Icons.title,
                        validate: (value) {
                          if (value == null || value.isEmpty) {
                            return "title can't be null";
                          }
                          return null;
                        },
                        label: "title",
                        controller: titleController),
                    SizedBox(
                      height: 20,
                    ),
                    defaultFormField(
                        prefix: Icons.timer_sharp,
                        label: "Task time",
                        controller: timeController,
                        validate: (value) {
                          if (value == null || value.isEmpty) {
                            return "time can't be null";
                          }
                          return null;
                        },
                        ontap: () {
                          showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now())
                              .then((value) {
                            timeController.text =
                                value!.format(context).toString();
                          });
                        }),
                    SizedBox(
                      height: 20,
                    ),
                    defaultFormField(
                        prefix: Icons.date_range,
                        label: "Task date",
                        controller: dateController,
                        validate: (value) {
                          if (value == null || value.isEmpty) {
                            return "date can't be null";
                          }
                          return null;
                        },
                        ontap: () {
                          showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2026, 1, 1))
                              .then((value) {
                            dateController.text =
                                DateFormat.yMMMd().format(value!);
                          });
                        }),
                  ],
                ),
              ),
            ),
          ))
      .closed
      .then((value) {
    AppCubit.get(context).changePresses(false);
  });
}
