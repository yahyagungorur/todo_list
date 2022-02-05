class Category {
  int? id;
  String? name;
  String? description;

  categoryMap() {
    // ignore: prefer_collection_literals
    var mapping = Map<String, dynamic>();
    mapping['id'] = id;
    mapping['name'] = name;
    mapping['description'] = description;

    return mapping;
  }
}
