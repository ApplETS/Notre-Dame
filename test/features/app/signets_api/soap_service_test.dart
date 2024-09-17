// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/features/app/signets-api/soap_service.dart';

void main() {
  group('SoapService - ', () {
    test('buildBasicSoapBody - contains all basic element', () {
      const String username = "username";
      const String password = "password";

      // ignore: missing_whitespace_between_adjacent_strings
      const expectedResult = '<?xml version="1.0" encoding="utf-8"?>'
          // ignore: missing_whitespace_between_adjacent_strings
          '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'
          '<soap:Body>'
          // ignore: missing_whitespace_between_adjacent_strings
          '<testOperation xmlns="http://etsmtl.ca/">'
          '<codeAccesUniversel>username</codeAccesUniversel>'
          '<motPasse>password</motPasse>'
          '</testOperation>'
          '</soap:Body>'
          '</soap:Envelope>';

      final result =
          SoapService.buildBasicSOAPBody("testOperation", username, password);

      expect(result.buildDocument().toString(), expectedResult);
    });
  });
}
