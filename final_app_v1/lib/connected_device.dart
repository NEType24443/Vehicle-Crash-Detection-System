import 'package:scoped_model/scoped_model.dart';

class Device extends Model {
  String device = "";
  bool initialSetup = true;

  update(String value){
    device = value;
    notifyListeners();
  }
  updateSetup(bool value){
    initialSetup = value;
    notifyListeners();
  }
}