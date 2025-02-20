import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/models/todo_model.dart';
import 'package:todo_app/module/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_app/module/done_tasks/done_tasks_screen.dart';
import 'package:todo_app/module/new_tasks/new_tasks_screen.dart';
import 'package:todo_app/shared/cubit/states.dart';

class AppCubit extends Cubit<Appstates> {
  AppCubit() : super(Initialstate());

  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen()
  ];

  List<String> title = ["New Tasks", "Done Tasks", "Archived Tasks"];
  int currentindex = 0;

  var ispressed = false;
  List<TodoModel> mylist = [];
  List<TodoModel> newlist = [];
  List<TodoModel> donelist = [];
  List<TodoModel> archivelist = [];

  final mybox = Hive.box<TodoModel>("TodoBox");

  var scaffoldkey = GlobalKey<ScaffoldState>();
  var formkey = GlobalKey<FormState>();

  static AppCubit get(context) {
    return BlocProvider.of(context);
  }

  void changeIndex(index) {
    currentindex = index;
    emit(BottomNavState());
  }

  void changePresses(bool press) {
    ispressed = press;
    emit(AppBottomSheet());
  }

  List<TodoModel> getTodos() {
    // Clear previous lists to prevent duplication
    newlist = [];
    donelist = [];
    archivelist = [];

    // Retrieve all todos from Hive
    mylist = mybox.values.toList();

    // Categorize todos based on status
    for (var todo in mylist) {
      if (todo.status == "new") {
        newlist.add(todo);
      } else if (todo.status == "done") {
        donelist.add(todo);
      } else if (todo.status == "archived") {
        archivelist.add(todo);
      }
    }

    emit(AppGetToDos());

    return mylist;
  }

  void addTodo(TodoModel todomodel) {
    mybox.add(todomodel);
    emit(AppInsertToDos());
  }

  void updatetodostatus(int id, String status) async {
    // Retrieve the task from Hive using the ID
    var todo = mybox.get(id);

    // Check if the task exists
    if (todo != null) {
      todo.status = status; // Update the status
      mybox.putAt(
          mylist.indexWhere(
            (element) => element.id == id,
          ),
          todo);

      getTodos(); // Refresh the list
      emit(AppUpdateToDoStatus()); // Emit state change
    }
  }

  void updateTodo(TodoModel todo, int id) {
    var todo = mybox.get(id);
    // Check if the task exists
    if (todo != null) {
      // Update the status
      mybox.putAt(
          mylist.indexWhere(
            (element) => element.id == id,
          ),
          todo); // Save back to Hive
      getTodos(); // Refresh the list
      emit(AppUpdateToDo()); // Emit state change
    }
  }

  void deletetodo(TodoModel todo) {
    mybox.delete(todo.key);
    mylist = getTodos(); // Refresh the list
    emit(AppDeleteToDos()); // Notify the UI
  }
}
