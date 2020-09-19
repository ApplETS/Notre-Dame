class Cours {
  String _code;
  String _finalGrade;
  String _coursName;

  Cours(this._code, this._coursName);

  String get coursName => _coursName;

  String get finalGrade => _finalGrade;

  String get code => _code;

  set finalGrade(String value) {
    _finalGrade = value;
  }
}
