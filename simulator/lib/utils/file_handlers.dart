import 'dart:io';
import 'package:path/path.dart' as path;

late String destinationPath;
late String destinationPathforscenario;
late String destinationPathformanualaiscenario;

Future<void> moveFile(String filePath, String desiredLocation, Function(String)? setStateCallback, Function(String)? showDialogCallback) async {
  try {
    await Directory(desiredLocation).create(recursive: true);
    String fileName = path.basename(filePath);
    String destinationPath = path.join(desiredLocation, fileName);
    await File(filePath).copy(destinationPath);
    if (showDialogCallback != null) {
      showDialogCallback('File moved to: $destinationPath');
    }
    if (setStateCallback != null) {
      setStateCallback(fileName);
    }
  } catch (e) {
    print('Error moving file: $e');
  }
}