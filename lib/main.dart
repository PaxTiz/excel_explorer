import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'components/files_tree.dart';
import 'components/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Flutter Demo',
      locale: const Locale('fr'),
      theme: FluentThemeData(
        accentColor: Colors.blue,
        visualDensity: VisualDensity.standard,
        focusTheme: FocusThemeData(
          glowFactor: is10footScreen(context) ? 2.0 : 0.0,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Directory? _directory;

  void onAskForDirectory(bool reset) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      if (reset) {
        setState(() => _directory = null);
      }
    } else {
      setState(() => _directory = Directory(selectedDirectory));
    }
  }

  @override
  Widget build(BuildContext context) {
    final widget = _directory == null
        ? Home(onAskForDirectory: () => onAskForDirectory(true))
        : FilesTree(
            key: ValueKey(_directory!.path),
            directory: _directory!,
            onOpenDirectory: () => onAskForDirectory(false),
          );

    return NavigationView(
      content: widget,
      appBar: const NavigationAppBar(
        leading: null,
        title: Text('Explorateur de fichiers'),
      ),
    );
  }
}
