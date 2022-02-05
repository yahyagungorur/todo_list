import 'package:todo_list/models/todo.dart';
import 'package:todo_list/repositories/repository.dart';

class TodoService {
  Repository? _repository;
  TodoService() {
    _repository = Repository();
  }

  saveTodo(Todo todo) async {
    return await _repository!.insertData('todos', todo.todoMap());
  }

  readTodos() async {
    return await _repository!.readData('todos');
  }

  readTodoById(id) async {
    return await _repository!.readDataById('todos', id);
  }

  updateTodo(Todo todo) async {
    return await _repository!.updateData('todos', todo.todoMap());
  }

  deleteTodo(id) async {
    return await _repository!.deleteData('todos', id);
  }
}
