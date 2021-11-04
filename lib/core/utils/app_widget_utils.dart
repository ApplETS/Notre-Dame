// FLUTTER / DART / THIRD-PARTIES
import 'package:workmanager/workmanager.dart';

mixin AppWidgetUtils {
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) {
      print("Native called background task: $task"); //simpleTask will be emitted here.
      return Future.value(true);
    });
  }
  static void initWorkManager() {
    Workmanager().initialize(
        callbackDispatcher, // The top level function, aka callbackDispatcher
        isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
    );
  }
}
