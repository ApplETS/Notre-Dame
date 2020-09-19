import 'cours.dart';

class Trimester {
  List<Cours> _coursParSession;
  String _trimesterTitle;

  Trimester(this._trimesterTitle) {
    _coursParSession = <Cours>[];
  }

  void addingCours(Cours newCours) {
    _coursParSession.add(newCours);
  }

  String get trimesterTitle => _trimesterTitle;

  set coursParSession(List<Cours> value) {
    _coursParSession = value;
  }

  List<Cours> get coursParSession => _coursParSession;
}
