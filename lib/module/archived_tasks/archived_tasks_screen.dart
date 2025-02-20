import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class ArchivedTasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, Appstates>(
      listener: (context, state) {},
      builder: (context, state) {
        return taskbuilder(
            todolist: AppCubit.get(context).archivelist,
            Scaffoldkey: AppCubit.get(context).scaffoldkey,
            formkey: AppCubit.get(context).scaffoldkey);
      },
    );
  }
}
