// Project imports:
import 'package:notredame/l10n/app_localizations.dart';

String localizedSessionName(AppIntl intl, String shortName) {
  switch (shortName[0]) {
    case 'H':
      return "${intl.session_winter} ${shortName.substring(1)}";
    case 'A':
      return "${intl.session_fall} ${shortName.substring(1)}";
    case 'É':
    case 'E':
      return "${intl.session_summer} ${shortName.substring(1)}";
    default:
      return shortName;
  }
}
