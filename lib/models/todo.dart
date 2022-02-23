class Todo {
  int? id;
  String? title;
  String? description;
  String? category;
  String? todoDate;
  int? isDone;
  int? notify;

  todoMap() {
    // ignore: prefer_collection_literals
    var mapping = Map<String, dynamic>();
    mapping['id'] = id;
    mapping['title'] = title;
    mapping['description'] = description;
    mapping['category'] = category;
    mapping['todoDate'] = todoDate;
    mapping['isDone'] = isDone;
    mapping['notify'] = notify;

    return mapping;
  }
}
