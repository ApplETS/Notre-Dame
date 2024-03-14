// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rive/rive.dart';

// Project imports:
import 'package:notredame/core/services/rive_animation_service.dart';
import 'package:notredame/core/utils/animation_exception.dart';

import 'rive_animation_service_mock.mocks.dart';

/// Mock for the [RiveAnimationService]
@GenerateNiceMocks([MockSpec<RiveAnimationService>()])
class RiveAnimationServiceMock extends MockRiveAnimationService {
  static const startException = AnimationException(
      prefix: "addControllerToAnimation",
      message:
          "The animation controller was not able to attach to the artboard.");

  static const loadException =
      AnimationException(prefix: "loadRiveFile", message: "");

  /// Stub the load rive file when the method is called with any string argument
  /// to return [artboardToReturn]
  static void stubLoadRiveFile(RiveAnimationServiceMock mock,
      String riveFileName, Artboard artboardToReturn) {
    when(mock.loadRiveFile(riveFileName: anyNamed("riveFileName")))
        .thenAnswer((_) async => artboardToReturn);
  }

  /// Throw [exceptionToThrow] when [loadRiveFile] used.
  static void stubLoadRiveFileException(RiveAnimationServiceMock mock,
      {AnimationException exceptionToThrow = loadException}) {
    when(mock.loadRiveFile(riveFileName: anyNamed("riveFileName")))
        .thenThrow(exceptionToThrow);
  }

  /// Throw [exceptionToThrow] when [addControllerToAnimation] used.
  static void stubAddControllerToAnimationException(
      RiveAnimationServiceMock mock, Artboard artboard,
      {AnimationException exceptionToThrow = startException}) {
    when(mock.addControllerToAnimation(artboard: artboard))
        .thenThrow(exceptionToThrow);
  }
}
