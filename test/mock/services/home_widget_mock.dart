// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:home_widget/home_widget.dart';
import 'package:mockito/annotations.dart';

// Project imports:
import 'package:notredame/core/services/app_widget_service.dart';
import 'home_widget_mock.mocks.dart';

import 'home_widget_mock.mocks.dart';

/// Pseudo-mock for the static [HomeWidget] class (mocks the channel instead)
@GenerateNiceMocks([MockSpec<HomeWidget>()])
class HomeWidgetMock extends MockHomeWidget {
  late MethodChannel _channel;
  late TestDefaultBinaryMessenger _messenger;

  HomeWidgetMock() {
    _channel = const MethodChannel('home_widget');

    _messenger =
        TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger;
  }

  /// Overrides [HomeWidget]'s channel messenger behavior on [HomeWidget.setAppGroupId]
  /// to enable [AppWidgetService.init] testing
  void stubInit() {
    _messenger.setMockMethodCallHandler(_channel,
        (MethodCall methodCall) async {
      if (methodCall.method == 'setAppGroupId' &&
          methodCall.arguments.toString() ==
              {'groupId': 'group.ca.etsmtl.applets.ETSMobile'}.toString()) {
        return true;
      }
      return false;
    });
  }

  /// Overrides [HomeWidget]'s channel messenger behavior on [HomeWidget.saveWidgetData]
  /// to enable [AppWidgetService] send...Data testing
  void stubSaveWidgetDataMock(
      List<String> expectedIds, List<dynamic> expectedDatas) {
    _messenger.setMockMethodCallHandler(_channel,
        (MethodCall methodCall) async {
      for (int i = 0; i < expectedIds.length; i++) {
        if (methodCall.method == 'saveWidgetData' &&
            methodCall.arguments.toString() ==
                {
                  'id': expectedIds[i],
                  'data': expectedDatas[i],
                }.toString()) {
          return true;
        }
      }

      throw PlatformException(code: "ERR1", message: "Test failed, wrong data");
    });
  }

  /// Overrides [HomeWidget]'s channel messenger behavior on [HomeWidget.saveWidgetData]
  /// to enable [AppWidgetService] send...Data testing
  void stubUpdateWidgetMock(String name, String androidName, String iOSName) {
    _messenger.setMockMethodCallHandler(_channel,
        (MethodCall methodCall) async {
      if (methodCall.method == 'updateWidget' &&
          methodCall.arguments.toString() ==
              {
                'name': name,
                'android': androidName,
                'ios': iOSName,
                'qualifiedAndroidName': null
              }.toString()) {
        return true;
      }
      return false;
    });
  }
}
