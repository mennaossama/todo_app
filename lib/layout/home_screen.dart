import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

// ignore: must_be_immutable
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => AppCubit()..getTodos(),
        child: BlocConsumer<AppCubit, Appstates>(
          listener: (context, state) {},
          builder: (context, state) {
            AppCubit cubit = AppCubit.get(context);
            return Scaffold(
              appBar: AppBar(
                title: Text(cubit.title[cubit.currentindex]),
              ),
              body: cubit.screens[cubit.currentindex],
              bottomNavigationBar: BottomNavigationBar(
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.menu), label: "New Tasks"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.check_circle_outline),
                      label: "Done Tasks"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.archive_outlined),
                      label: "Archived Tasks"),
                ],
                currentIndex: cubit.currentindex,
                onTap: (index) {
                  cubit.changeIndex(index);
                },
                type: BottomNavigationBarType.fixed,
              ),
            );
          },
        ));
  }
}
