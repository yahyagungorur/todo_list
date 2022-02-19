class Case {
  int? id;
  String? title;
  String? description;

  caseMap() {
    // ignore: prefer_collection_literals
    var mapping = Map<String, dynamic>();
    mapping['id'] = id;
    mapping['title'] = title;
    mapping['description'] = description;

    return mapping;
  }
}
