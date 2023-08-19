import 'package:fluent_ui/fluent_ui.dart';

class Home extends StatelessWidget {
  final void Function() onAskForDirectory;

  const Home({
    super.key,
    required this.onAskForDirectory,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: FilledButton(
          onPressed: onAskForDirectory,
          child: const Text('Ouvrir un dossier'),
        ),
      ),
    );
  }
}
