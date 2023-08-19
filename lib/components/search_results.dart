import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

import '../utils/files_tree.dart';

class SearchResults extends StatefulWidget {
  final Directory directory;
  final String search;
  final Future<void> Function(TreeViewItem, TreeViewItemInvokeReason)
      onOpenFile;

  const SearchResults({
    super.key,
    required this.directory,
    required this.search,
    required this.onOpenFile,
  });

  @override
  createState() => _SearchResults();
}

class _SearchResults extends State<SearchResults> {
  bool _isLoading = false;
  List<TreeViewItem> _tree = [];

  void _searchFiles() {
    setState(() => _isLoading = true);
    setState(() => _tree = buildTreeView(widget.directory, widget.search));
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _searchFiles();
  }

  @override
  Widget build(BuildContext context) {
    final noResults = Center(
      child: Text('Aucun résultat pour la recherche "${widget.search}"'),
    );

    const loadingIndicator = SizedBox(
      width: double.infinity,
      height: 300,
      child: Center(child: ProgressRing()),
    );

    return NavigationView(
      appBar: NavigationAppBar(
        leading: null,
        title: Text('Résultats de la recherche "${widget.search}"'),
      ),
      content: _isLoading
          ? loadingIndicator
          : _tree.isEmpty
              ? noResults
              : TreeView(
                  shrinkWrap: true,
                  items: _tree,
                  onItemInvoked: widget.onOpenFile,
                ),
    );
  }
}
