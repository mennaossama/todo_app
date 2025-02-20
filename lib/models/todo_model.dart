import 'package:hive/hive.dart';
part 'todo_model.g.dart';

@HiveType(typeId: 0)
class TodoModel extends HiveObject {
  @HiveField(0)
  String title;
  @HiveField(1)
  String time;
  @HiveField(2)
  String date;
  @HiveField(3)
  String status;
  @HiveField(4)
  final int id;
  TodoModel(
      {required this.title,
      required this.time,
      required this.date,
      required this.status,
      required this.id});
}
