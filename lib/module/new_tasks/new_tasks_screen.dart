import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/models/todo_model.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

// ignore: must_be_immutable
class NewTasksScreen extends StatelessWidget {
  var scaffoldkey = GlobalKey<ScaffoldState>();
  var formkey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  NewTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, Appstates>(
      listener: (context, state) {},
      builder: (context, state) {
        AppCubit cubit = AppCubit.get(context);
        return Scaffold(
          key: scaffoldkey,
          body: taskbuilder(
              todolist: cubit.newlist,
              formkey: formkey,
              Scaffoldkey: scaffoldkey),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (cubit.ispressed) {
                if (titleController.text.isEmpty ||
                    dateController.text.isEmpty ||
                    timeController.text.isEmpty) {
                  formkey.currentState!.validate();
                } else {
                  cubit.changePresses(false);

                  cubit.addTodo(TodoModel(
                      title: titleController.text,
                      time: timeController.text,
                      date: dateController.text,
                      status: 'new',
                      id: cubit.mylist.isEmpty
                          ? 0
                          : (cubit.mylist.last.id) + 1));
                  cubit.getTodos();

                  titleController.clear();
                  timeController.clear();
                  dateController.clear();

                  Navigator.pop(context);
                }
              } else {
                cubit.changePresses(true);
                bottomsheet(
                    scaffoldkey: scaffoldkey,
                    formkey: formkey,
                    titleController: titleController,
                    timeController: timeController,
                    dateController: dateController,
                    context: context);
              }
            },
            child: Icon(!cubit.ispressed ? Icons.edit : Icons.add),
          ),
        );
      },
    );
  }
}
