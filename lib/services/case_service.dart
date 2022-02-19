import 'package:todo_list/models/user.dart';
import 'package:todo_list/repositories/repository.dart';

import '../models/case.dart';

class CaseService {
  Repository? _repository;
  CaseService() {
    _repository = Repository();
  }
  saveCase(Case _case) async {
    return await _repository!.insertData('cases', _case.caseMap());
  }

  readCase() async {
    return await _repository!.readData('cases');
  }

  readCaseById(id) async {
    return await _repository!.readDataById('cases', id);
  }

  updateCase(Case _case) async {
    return await _repository!.updateData('cases', _case.caseMap());
  }

  deleteCase(id) async {
    return await _repository!.deleteData('cases', id);
  }

  getCases() async {
    List<Case> _caseList = <Case>[];
    var cases = await readCase();
    cases.forEach((_case) {
      var caseModel = Case();
      caseModel.id = _case['id'];
      caseModel.title = _case['title'];
      caseModel.description = _case['description'];
      _caseList.add(caseModel);
    });
    return _caseList;
  }
}
