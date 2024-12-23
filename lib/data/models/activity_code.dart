/// A class containing all the ActivityCode for a schedule activity
///
/// Actual known definition of the code id of a schedule activity:
/// A -> Atelier [workshop]
/// B -> ???
/// C -> Activité de cours [lectureCourse]
/// D -> ???
/// E -> Travaux pratiques [practicalWork]
/// F -> Travaux pratiques aux 2 semaines [practicalWorkEvery2Weeks]
/// G -> ???
/// H -> ???
/// I -> ???
/// J -> ??? (Could be "Travaux pratiques (Groupe A)")
/// K -> ??? (Could be "Travaux pratiques (Groupe B)")
/// L -> Laboratoire [lab]
/// M -> Laboratoire aux 2 semaines [labEvery2Weeks]
/// N -> ???
/// O -> ???
/// P -> ???
/// Q -> Laboratoire (Groupe A) [labGroupA]
/// R -> Laboratoire (Groupe B) [labGroupB]
class ActivityCode {
  static const String practicalWork = "E";
  static const String practicalWorkEvery2Weeks = "F";
  static const String workshop = "A";
  static const String lectureCourse = "C";
  static const String lab = "L";
  static const String labEvery2Weeks = "M";
  static const String labGroupA = "Q";
  static const String labGroupB = "R";
}

class ActivityDescriptionName {
  static const String labA = "Laboratoire (Groupe A)";
  static const String labB = "Laboratoire (Groupe B)";
}
