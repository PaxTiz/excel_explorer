import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

import '../utils/files_tree.dart';
import 'search_results.dart';

class FilesTree extends StatefulWidget {
  final Directory directory;
  final Function onOpenDirectory;

  const FilesTree({
    super.key,
    required this.directory,
    required this.onOpenDirectory,
  });

  @override
  createState() => _FilesTree();
}

class _FilesTree extends State<FilesTree> {
  bool _isLoading = false;
  List<TreeViewItem> _tree = [];
  List<CommandBarItem> _commandBarItems = [];
  final _searchController = TextEditingController();

  void _refreshTreeView() async {
    setState(() => _isLoading = true);
    setState(() => _tree = buildTreeView(widget.directory, null));
    setState(() => _isLoading = false);
  }

  void _openNewDirectory() {
    widget.onOpenDirectory();
  }

  void _watchForFileSystemUpdates() {
    widget.directory.watch().listen((event) {
      _refreshTreeView();
    });
  }

  void _openSearchDialog() async {
    await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Rechercher un fichier'),
        content: TextBox(
          controller: _searchController,
          placeholder: 'Nom du fichier',
        ),
        actions: [
          Button(
            child: const Text('Annuler'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text('Rechercher'),
            onPressed: () {
              final text = _searchController.text;
              _searchController.clear();

              Navigator.pop(context);
              Navigator.push(
                context,
                FluentPageRoute(
                  builder: (_) => SearchResults(
                    search: text.toLowerCase(),
                    directory: widget.directory,
                    onOpenFile: _openFile,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openFile(
    TreeViewItem item,
    TreeViewItemInvokeReason reason,
  ) async {
    if (reason != TreeViewItemInvokeReason.pressed) {
      return;
    }

    if (FileSystemEntity.isDirectorySync(item.value)) {
      return;
    }

    if (Platform.isMacOS) {
      await Process.run('open', [item.value]);
    } else if (Platform.isWindows) {
      await Process.run('start', [item.value]);
    }
  }

  @override
  void initState() {
    super.initState();

    _watchForFileSystemUpdates();
    _refreshTreeView();
    _commandBarItems = [
      CommandBarButton(
        icon: const Icon(FluentIcons.refresh),
        label: const Text('Rafraichir'),
        onPressed: _refreshTreeView,
      ),
      CommandBarButton(
        icon: const Icon(FluentIcons.search),
        label: const Text('Rechercher'),
        onPressed: _openSearchDialog,
      ),
      CommandBarButton(
        icon: const Icon(FluentIcons.open_file),
        label: const Text('Ouvrir un autre dossier'),
        onPressed: _openNewDirectory,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey.withOpacity(.05),
            child: CommandBar(
              overflowBehavior: CommandBarOverflowBehavior.noWrap,
              primaryItems: _commandBarItems,
            ),
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: Center(child: ProgressRing()),
                )
              : TreeView(
                  shrinkWrap: true,
                  items: _tree,
                  onItemInvoked: _openFile,
                ),
        ],
      ),
    );
  }
}
