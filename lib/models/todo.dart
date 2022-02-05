class Todo {
  int? id;
  String? title;
  String? description;
  String? category;
  String? todoDate;
  int? isDone;

  todoMap() {
    // ignore: prefer_collection_literals
    var mapping = Map<String, dynamic>();
    mapping['id'] = id;
    mapping['title'] = title;
    mapping['description'] = description;
    mapping['category'] = category;
    mapping['todoDate'] = todoDate;
    mapping['isDone'] = isDone;

    return mapping;
  }
}
