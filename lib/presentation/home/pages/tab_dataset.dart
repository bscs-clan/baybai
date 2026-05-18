import 'dart:io';

import 'package:baybai/core/configs/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:solar_icons/solar_icons.dart';

class TabDataset extends StatefulWidget {
  const TabDataset({super.key});

  @override
  State<TabDataset> createState() => _TabDatasetState();
}

class _TabDatasetState extends State<TabDataset> {
  bool _loading = true;
  String? _error;
  List<_DatasetEntry> _entries = const [];

  static const Set<String> _imageExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dir = await _datasetDir();

      debugPrint('[DatasetTab] datasetDir resolved: ${dir?.path}');

      if (dir == null) {
        throw Exception('Could not access dataset directory');
      }

      if (!await dir.exists()) {
        debugPrint('[DatasetTab] datasetDir does not exist: ${dir.path}');

        if (!mounted) return;

        setState(() {
          _entries = const [];
          _loading = false;
        });

        return;
      }

      final imagePaths = <String, String>{};
      final labelPaths = <String, String>{};

      int totalFiles = 0;
      int imageFilesCount = 0;
      int labelFilesCount = 0;

      await for (final entity in dir.list(
        followLinks: false,
        recursive: false,
      )) {
        if (entity is! File) continue;

        final name = entity.uri.pathSegments.last.toLowerCase();

        final dotIndex = name.lastIndexOf('.');
        if (dotIndex == -1) continue;

        final ext = name.substring(dotIndex);
        final base = name.substring(0, dotIndex);

        totalFiles++;

        if (_imageExtensions.contains(ext)) {
          imageFilesCount++;
          imagePaths[base] = entity.path;
        } else if (ext == '.txt') {
          labelFilesCount++;
          labelPaths[base] = entity.path;
        }
      }

      debugPrint(
        '[DatasetTab] totalFiles=$totalFiles images=$imageFilesCount labels=$labelFilesCount',
      );

      if (imagePaths.isEmpty || labelPaths.isEmpty) {
        debugPrint(
          '[DatasetTab] sample image bases: ${imagePaths.keys.take(5).toList()}',
        );
        debugPrint(
          '[DatasetTab] sample label bases: ${labelPaths.keys.take(5).toList()}',
        );
      }

      final basenames =
          imagePaths.keys.toSet().intersection(labelPaths.keys.toSet()).toList()
            ..sort();

      final entries = await Future.wait(
        basenames.map((base) async {
          final labelFile = File(labelPaths[base]!);

          final lines = await labelFile.readAsLines();

          final title = lines.isNotEmpty ? lines.first.trim() : '';

          final desc = lines.length > 1 ? lines.skip(1).join('\n').trim() : '';

          return _DatasetEntry(
            id: base,
            imagePath: imagePaths[base]!,
            titleBaybayin: title,
            descNormal: desc.isEmpty ? null : desc,
          );
        }),
      );

      if (!mounted) return;

      setState(() {
        _entries = entries;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<Directory?> _datasetDir() async {
    if (Platform.isAndroid) {
      try {
        await Permission.manageExternalStorage.request();
      } catch (_) {}

      try {
        await Permission.storage.request();
      } catch (_) {}
    }

    final candidates = <Future<Directory?>>[];

    if (Platform.isAndroid) {
      candidates.add(() async {
        final extDir = await getExternalStorageDirectory();

        if (extDir == null) return null;

        final parts = extDir.path.split('/Android');

        final basePath = parts.isNotEmpty ? parts.first : extDir.path;

        final dir = Directory('$basePath/.datasets');

        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }

        return dir;
      }());
    }

    candidates.add(() async {
      final docs = await getApplicationDocumentsDirectory();

      final dir = Directory('${docs.path}/.datasets');

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      return dir;
    }());

    for (final future in candidates) {
      try {
        final dir = await future;

        if (dir != null) {
          return dir;
        }
      } catch (_) {}
    }

    return null;
  }

  void _editEntry(_DatasetEntry entry) {
    debugPrint('Edit: ${entry.id}');
  }

  void _deleteEntry(_DatasetEntry entry) {
    setState(() {
      _entries = _entries.where((e) => e.id != entry.id).toList();
    });

    debugPrint('Deleted: ${entry.id}');
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return Center(
        child: LoadingAnimationWidget.threeArchedCircle(
          color: AppColors.primary,
          size: 40,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(
          'Failed to load dataset:\n$_error',
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_entries.isEmpty) {
      return const Center(
        child: Text(
          'No dataset found in .datasets.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 156),
      itemCount: _entries.length,
      cacheExtent: 1000,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final entry = _entries[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Slidable(
            key: ValueKey(entry.id),

            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.45,
              children: [
                SlidableAction(
                  onPressed: (_) => _deleteEntry(entry),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.red,
                  label: "Delete",
                  icon: SolarIconsBold.trashBin2,
                ),
              ],
            ),

            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkBox : AppColors.box,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DatasetThumbnail(imagePath: entry.imagePath),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.titleBaybayin.isEmpty
                                ? 'Untitled'
                                : entry.titleBaybayin,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontFamily: 'Baybayin',
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? AppColors.darkText
                                      : AppColors.text,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 6),

                          if (entry.descNormal != null)
                            Text(
                              entry.descNormal!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: isDarkMode
                                        ? AppColors.darkTextGrey
                                        : AppColors.textGrey,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          else
                            Text(
                              '—',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context).disabledColor,
                                  ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DatasetEntry {
  final String id;
  final String imagePath;
  final String titleBaybayin;
  final String? descNormal;

  const _DatasetEntry({
    required this.id,
    required this.imagePath,
    required this.titleBaybayin,
    required this.descNormal,
  });
}

class _DatasetThumbnail extends StatelessWidget {
  final String imagePath;

  const _DatasetThumbnail({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    const double width = 80;
    const double height = 48;

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          File(imagePath),
          width: width,
          height: height,
          fit: BoxFit.cover,

          // Performance optimization
          cacheWidth: width.toInt() * 2,
          cacheHeight: height.toInt() * 2,

          filterQuality: FilterQuality.low,
          gaplessPlayback: true,

          errorBuilder: (_, __, ___) {
            return Container(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: const Icon(Icons.image_not_supported, size: 20),
            );
          },
        ),
      ),
    );
  }
}
