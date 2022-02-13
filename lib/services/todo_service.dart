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
    var todo = await _repository!.readDataById('todos', id);
    return mapToModel(todo[0]);
  }

  updateTodo(Todo todo) async {
    return await _repository!.updateData('todos', todo.todoMap());
  }

  deleteTodo(id) async {
    return await _repository!.deleteData('todos', id);
  }

  getAllTodos() async {
    List<Todo> _todoList = <Todo>[];
    var todos = await readTodos();
    todos.forEach((todo) {
      _todoList.add(mapToModel(todo));
    });
    if (_todoList.isNotEmpty) {
      _todoList.sort((a, b) => (a.todoDate ?? DateTime.now().toString())
          .compareTo(b.todoDate ?? DateTime.now().toString()));
    }
    return _todoList;
  }

  mapToModel(todo) {
    var todoModel = Todo();
    todoModel.id = todo["id"];
    todoModel.title = todo["title"];
    todoModel.description = todo["description"];
    todoModel.category = todo["category"];
    todoModel.todoDate = todo["todoDate"];
    todoModel.isDone = todo["isDone"];
    return todoModel;
  }
}
