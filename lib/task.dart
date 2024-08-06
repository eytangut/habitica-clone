enum IsPositive {
  positive,
  negative,
  both
}
enum IsCompleted {
  yes,
  no,
}
enum TaskType{
  task,
  habit,
  daily
}

class Task {
  String title;
  String description;
  TaskType type;
  IsCompleted completion = IsCompleted.no;
  IsPositive positive;
  Task({
    required this.title,
    required this.description,
    required this.type
  });
}