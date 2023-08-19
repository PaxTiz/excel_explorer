import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

import '../constants.dart';

List<TreeViewItem> buildTreeView(Directory directory, String? search) {
  List<TreeViewItem> tree = [];

  final children = directory.listSync();
  for (final child in children) {
    if (child is File) {
      final filename = child.uri.pathSegments.last;

      if (search == null || (filename.toLowerCase().contains(search))) {
        final childName = _getSmallChildName(filename);
        tree.add(TreeViewItem(
          selected: true,
          content: Row(
            children: [
              _getIconFromFile(child),
              const SizedBox(width: 8),
              Text(
                childName,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
          value: child.path,
        ));
      }
    }

    if (child is Directory) {
      final directoryName = child.uri.pathSegments.reversed.skip(1).first;
      final childName = _getSmallChildName(directoryName);

      final children = buildTreeView(child, search);

      if (search == null || children.isNotEmpty) {
        tree.add(TreeViewItem(
          content: Row(
            children: [
              _getIconFromFile(child),
              const SizedBox(width: 8),
              Text(
                childName,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
          value: child.path,
          children: children,
        ));
      }
    }
  }

  tree.sort((a, b) => b.children.length - a.children.length);
  return tree;
}

String _getSmallChildName(String name) {
  if (name.length < 50) {
    return name;
  }

  return '${name.substring(0, 50)}...';
}

Icon _getIconFromFile(FileSystemEntity file) {
  const size = 14.0;

  if (file is Directory) {
    return const Icon(
      FluentIcons.folder_open,
      size: size,
    );
  }

  switch (file.uri.pathSegments.last.split('.').last) {
    case 'xlsx':
      return const Icon(
        FluentIcons.excel_document,
        size: size,
        color: kExcelColor,
      );
    case 'doc':
      return const Icon(
        FluentIcons.text_document,
        size: size,
        color: kWordColor,
      );
    case 'docx':
      return const Icon(
        FluentIcons.text_document,
        size: size,
        color: kWordColor,
      );
    case 'ppt':
      return const Icon(
        FluentIcons.power_point_document,
        color: kPowerPointColor,
      );
    case 'pptx':
      return const Icon(
        FluentIcons.power_point_document,
        color: kPowerPointColor,
      );
  }

  return const Icon(
    FluentIcons.file_template,
    size: size,
  );
}
