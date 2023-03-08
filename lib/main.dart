import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await runPB();
  runApp(const MainApp());
}

Future<void> runPB() async {
  try {
    final pb = await initPB();
    if (pb != null) {
      final result = await Process.run(pb.path, ['--version']);
      debugPrint('Execution Result: ${result.stdout}');
    }
  } catch (e) {
    debugPrint('PB Execution Error: $e');
  }
}

Future<File?> initPB() async {
  try {
    final dir = join((await getApplicationDocumentsDirectory()).path, 'pocketbase');
    final pbFile = File(join(dir, 'pocketbase'));
    // if (pbFile.existsSync()) return pbFile;
    if (pbFile.existsSync()) await pbFile.delete(); // for testing
    final pbAsset = await rootBundle.load('assets/pocketbase');
    await pbFile.create(recursive: true);
    await pbFile.writeAsBytes(pbAsset.buffer.asUint8List());
    pbFile.setExecutable(true);
    return pbFile;
  } catch (e) {
    debugPrint('Error: $e');
  }
  return null;
}

extension on File {
  Future<void> setExecutable(bool executable) async {
    late final ProcessResult result;
    if (Platform.isWindows) {
      await Process.run('icacls', [path, '/inheritance:r']);
      result = await Process.run('icacls', [path, '/grant:r', 'Users:F']);
    } else {
      result = await Process.run('chmod', [executable ? '+x' : '-x', path]);
    }
    debugPrint('Set Executable Result: ${result.stderr}');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: const Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
