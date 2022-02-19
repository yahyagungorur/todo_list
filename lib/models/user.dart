class User {
  int? id;
  String? username;
  String? email;
  String? password;

  userMap() {
    // ignore: prefer_collection_literals
    var mapping = Map<String, dynamic>();
    mapping['id'] = id;
    mapping['username'] = username;
    mapping['email'] = email;
    mapping['password'] = password;

    return mapping;
  }
}
