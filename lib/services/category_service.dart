// ignore_for_file: avoid_print

import 'package:todo_list/models/category.dart';
import 'package:todo_list/repositories/repository.dart';

class CategoryService {
  Repository? _repository;
  CategoryService() {
    _repository = Repository();
  }
  saveCategory(Category category) async {
    return await _repository!.insertData('categories', category.categoryMap());
  }

  readCategories() async {
    return await _repository!.readData('categories');
  }

  readCategoryById(id) async {
    return await _repository!.readDataById('categories', id);
  }

  updateCategory(Category category) async {
    return await _repository!.updateData('categories', category.categoryMap());
  }

  deleteCategory(id) async {
    return await _repository!.deleteData('categories', id);
  }

  getAllCategories() async {
    List<Category> _categoryList = <Category>[];
    var categories = await readCategories();
    categories.forEach((category) {
      var categoryModel = Category();
      categoryModel.id = category['id'];
      categoryModel.name = category['name'];
      categoryModel.description = category['description'];
      _categoryList.add(categoryModel);
    });
    return _categoryList;
  }
}
