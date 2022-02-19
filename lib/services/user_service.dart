import 'package:todo_list/models/user.dart';
import 'package:todo_list/repositories/repository.dart';

class UserService {
  Repository? _repository;
  UserService() {
    _repository = Repository();
  }
  saveUser(User user) async {
    return await _repository!.insertData('users', user.userMap());
  }

  readUser() async {
    return await _repository!.readData('users');
  }

  readUserById(id) async {
    return await _repository!.readDataById('users', id);
  }

  updateUser(User user) async {
    return await _repository!.updateData('users', user.userMap());
  }

  deleteUser(id) async {
    return await _repository!.deleteData('users', id);
  }

  getUser() async {
    List<User> _userList = <User>[];
    var users = await readUser();
    users.forEach((user) {
      var userModel = User();
      userModel.id = user['id'];
      userModel.username = user['username'];
      userModel.email = user['email'];
      userModel.password = user['password'];
      _userList.add(userModel);
    });
    return _userList;
  }
}
