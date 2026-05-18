import 'dart:io';
import 'dart:ui';

import 'package:baybai/core/configs/theme/colors.dart';
import 'package:baybai/core/configs/theme/text.dart';
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

  List<_DatasetEntry> _entries = <_DatasetEntry>[];
  _DatasetEntry? _selected;

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
      final candidates = await _candidateDatasetDirs();

      debugPrint('[DatasetTab] Candidate dirs:');
      for (final d in candidates) {
        debugPrint('  - ${d.path}');
      }

      List<_DatasetEntry> bestEntries = [];
      Directory? bestDir;

      for (final dir in candidates) {
        final entries = await _scanDatasetDir(dir);

        debugPrint('[DatasetTab] ${dir.path} -> ${entries.length} entry(s)');

        if (entries.isNotEmpty) {
          bestEntries = entries;
          bestDir = dir;
          break;
        }
      }

      if (!mounted) return;

      if (bestEntries.isEmpty) {
        setState(() {
          _entries = <_DatasetEntry>[];
          _selected = null;
          _loading = false;
        });

        debugPrint(
          '[DatasetTab] No usable dataset found in any candidate directory.',
        );
        debugPrint(
          '[DatasetTab] Put files in one of the paths above. '
          'Each item needs an image and a .txt file with the same base name.',
        );
        return;
      }

      debugPrint('[DatasetTab] Using dataset dir: ${bestDir!.path}');

      setState(() {
        _entries = bestEntries;
        _selected = bestEntries.first;
        _loading = false;
      });
    } catch (e, st) {
      debugPrint('[DatasetTab] Load failed: $e');
      debugPrint('$st');

      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<List<Directory>> _candidateDatasetDirs() async {
    final dirs = <Directory>[];

    final docs = await getApplicationDocumentsDirectory();
    dirs.add(Directory('${docs.path}/.datasets'));

    if (Platform.isAndroid) {
      try {
        await Permission.storage.request();
      } catch (_) {}

      try {
        await Permission.manageExternalStorage.request();
      } catch (_) {}

      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        final parts = extDir.path.split('/Android');
        final root = parts.isNotEmpty ? parts.first : extDir.path;
        dirs.add(Directory('$root/.datasets'));
      }

      dirs.add(Directory('/storage/emulated/0/.datasets'));
      dirs.add(Directory('/sdcard/.datasets'));
    }

    return dirs;
  }

  Future<List<_DatasetEntry>> _scanDatasetDir(Directory dir) async {
    if (!await dir.exists()) {
      return <_DatasetEntry>[];
    }

    final imagePaths = <String, String>{};
    final labelPaths = <String, String>{};

    await for (final entity in dir.list(followLinks: false, recursive: false)) {
      if (entity is! File) continue;

      final name = entity.uri.pathSegments.last;
      final lowerName = name.toLowerCase();
      final dotIndex = lowerName.lastIndexOf('.');

      if (dotIndex == -1) continue;

      final ext = lowerName.substring(dotIndex);
      final base = lowerName.substring(0, dotIndex);

      if (_imageExtensions.contains(ext)) {
        imagePaths[base] = entity.path;
      } else if (ext == '.txt') {
        labelPaths[base] = entity.path;
      }
    }

    final keys = <String>{...imagePaths.keys, ...labelPaths.keys}.toList()
      ..sort();

    final entries = <_DatasetEntry>[];

    for (final key in keys) {
      final imagePath = imagePaths[key];
      if (imagePath == null) {
        debugPrint('[DatasetTab] Missing image for: $key');
        continue;
      }

      final labelPath = labelPaths[key] ?? '${dir.path}/$key.txt';

      String title = 'Untitled';
      String? desc;

      final labelFile = File(labelPath);
      if (await labelFile.exists()) {
        final lines = await labelFile.readAsLines();

        final parsedTitle = lines.isNotEmpty ? lines.first.trim() : '';
        final parsedDesc = lines.length > 1
            ? lines.skip(1).join('\n').trim()
            : '';

        if (parsedTitle.isNotEmpty) {
          title = parsedTitle;
        }

        if (parsedDesc.isNotEmpty) {
          desc = parsedDesc;
        }
      } else {
        debugPrint('[DatasetTab] Missing label for: $key');
      }

      entries.add(
        _DatasetEntry(
          id: key,
          imagePath: imagePath,
          labelPath: labelPath,
          titleBaybayin: title,
          descNormal: desc,
        ),
      );
    }

    return entries;
  }

  Future<void> _saveEntry(
    _DatasetEntry entry,
    String title,
    String desc,
  ) async {
    final file = File(entry.labelPath);

    final lines = <String>[title.trim()];
    final normalizedDesc = desc.trim();

    if (normalizedDesc.isNotEmpty) {
      lines.addAll(normalizedDesc.split('\n'));
    }

    await file.parent.create(recursive: true);
    await file.writeAsString('${lines.join('\n')}\n');

    final updated = entry.copyWith(
      titleBaybayin: title.trim().isEmpty ? 'Untitled' : title.trim(),
      descNormal: normalizedDesc.isEmpty ? null : normalizedDesc,
    );

    if (!mounted) return;

    setState(() {
      final index = _entries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _entries[index] = updated;
      }
      if (_selected?.id == entry.id) {
        _selected = updated;
      }
    });
  }

  Future<void> _showEditDialog(_DatasetEntry entry) async {
    final titleCtrl = TextEditingController(text: entry.titleBaybayin);
    final descCtrl = TextEditingController(text: entry.descNormal ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        await _saveEntry(entry, titleCtrl.text, descCtrl.text);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    }

    titleCtrl.dispose();
    descCtrl.dispose();
  }

  void _showMobileEditSheet(BuildContext context, _DatasetEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: _MobileEditSheet(
            entry: entry,
            onSave: (title, desc) async {
              await _saveEntry(entry, title, desc);
            },
          ),
        );
      },
    );
  }

  Future<void> _deleteEntry(_DatasetEntry entry) async {
    try {
      final imageFile = File(entry.imagePath);
      final labelFile = File(entry.labelPath);

      if (await imageFile.exists()) {
        await imageFile.delete();
      }

      if (await labelFile.exists()) {
        await labelFile.delete();
      }

      if (!mounted) return;

      setState(() {
        _entries = _entries.where((e) => e.id != entry.id).toList();
        if (_selected?.id == entry.id) {
          _selected = _entries.isNotEmpty ? _entries.first : null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ColorFiltered(
                colorFilter: isDarkMode
                    ? const ColorFilter.mode(Colors.white70, BlendMode.modulate)
                    : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                child: Opacity(
                  opacity: isDarkMode ? 0.80 : 1,
                  child: Image.asset(
                    "assets/images/illus_sleep.png",
                    height: 200,
                  ),
                ),
              ),
              Text(
                "No datasets",
                style: AppTextStyles.title.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? AppColors.darkTextGrey
                      : AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final showPreviewPane = constraints.maxWidth >= 900;

        if (showPreviewPane) {
          return Row(
            children: [
              Expanded(child: _buildList(context, isDarkMode, isDesktop: true)),
              if (_selected != null) _buildPreview(context, isDarkMode),
            ],
          );
        }

        return _buildList(context, isDarkMode, isDesktop: false);
      },
    );
  }

  Widget _buildList(
    BuildContext context,
    bool isDarkMode, {
    required bool isDesktop,
  }) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 156),
      itemCount: _entries.length,
      cacheExtent: 1000,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final entry = _entries[index];
        final isSelected = _selected?.id == entry.id;

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
                  label: 'DELETE',
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                if (isDesktop) {
                  setState(() {
                    _selected = entry;
                  });
                } else {
                  _showMobileEditSheet(context, entry);
                }
              },
              borderRadius: BorderRadius.circular(10),
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
                              entry.titleBaybayin,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontFamily: 'Baybayin',
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? AppColors.darkText
                                        : AppColors.text,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            if (entry.descNormal != null &&
                                entry.descNormal!.trim().isNotEmpty)
                              Text(
                                entry.descNormal!,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: isDarkMode
                                          ? AppColors.darkTextGrey
                                          : AppColors.textGrey,
                                    ),
                                maxLines: 1,
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
          ),
        );
      },
    );
  }

  Widget _buildPreview(BuildContext context, bool isDarkMode) {
    final entry = _selected;
    if (entry == null) return const SizedBox.shrink();

    return Container(
      width: 360,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBox : AppColors.box,
        border: Border(
          left: BorderSide(color: Colors.black.withOpacity(0.08), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.file(
                File(entry.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 32),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            entry.titleBaybayin,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: 'Baybayin',
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.darkText : AppColors.text,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                entry.descNormal?.isNotEmpty == true
                    ? entry.descNormal!
                    : 'No description',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDarkMode
                      ? AppColors.darkTextGrey
                      : AppColors.textGrey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _showEditDialog(entry),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DatasetEntry {
  final String id;
  final String imagePath;
  final String labelPath;
  final String titleBaybayin;
  final String? descNormal;

  const _DatasetEntry({
    required this.id,
    required this.imagePath,
    required this.labelPath,
    required this.titleBaybayin,
    required this.descNormal,
  });

  _DatasetEntry copyWith({
    String? id,
    String? imagePath,
    String? labelPath,
    String? titleBaybayin,
    String? descNormal,
  }) {
    return _DatasetEntry(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      labelPath: labelPath ?? this.labelPath,
      titleBaybayin: titleBaybayin ?? this.titleBaybayin,
      descNormal: descNormal ?? this.descNormal,
    );
  }
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

class _MobileEditSheet extends StatefulWidget {
  final _DatasetEntry entry;
  final Future<void> Function(String, String) onSave;

  const _MobileEditSheet({required this.entry, required this.onSave});

  @override
  State<_MobileEditSheet> createState() => _MobileEditSheetState();
}

class _MobileEditSheetState extends State<_MobileEditSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.entry.titleBaybayin);
    _descCtrl = TextEditingController(text: widget.entry.descNormal ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      await widget.onSave(_titleCtrl.text, _descCtrl.text);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    }

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final surface = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
    final onSurface = isDarkMode ? Colors.white : const Color(0xFF1C1C1E);
    final subtext = isDarkMode ? Colors.white54 : Colors.black45;

    final canSave = !_isSaving && _titleCtrl.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Dataset',
                          style: TextStyle(
                            color: onSurface,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${widget.entry.id}.jpg",
                          style: TextStyle(color: subtext, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: subtext),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 2.35 / 1,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ImageFiltered(
                                imageFilter: ImageFilter.blur(
                                  sigmaX: 20,
                                  sigmaY: 20,
                                ),
                                child: Image.file(
                                  File(widget.entry.imagePath),
                                  fit: BoxFit.cover,
                                ),
                              ),

                              Container(color: Colors.black.withOpacity(0.1)),

                              Center(
                                child: Image.file(
                                  File(widget.entry.imagePath),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _titleCtrl,
                        style: TextStyle(
                          fontFamily: 'Baybayin',
                          fontSize: 26,
                          color: onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Baybayin Text',
                          labelStyle: TextStyle(fontSize: 13, color: subtext),
                          filled: true,
                          fillColor: onSurface.withValues(alpha: 0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        textAlign: TextAlign.center,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _descCtrl,
                        style: TextStyle(
                          fontSize: 16,
                          color: onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Latin Transcription',
                          labelStyle: TextStyle(fontSize: 13, color: subtext),
                          filled: true,
                          fillColor: onSurface.withValues(alpha: 0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: onSurface,
                                side: BorderSide(
                                  color: onSurface.withValues(alpha: 0.18),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: FilledButton.icon(
                              onPressed: canSave ? _save : null,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                disabledBackgroundColor: AppColors.primary
                                    .withValues(alpha: 0.35),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.save_alt_rounded,
                                      size: 18,
                                    ),
                              label: Text(
                                _isSaving ? 'Saving…' : 'Save Changes',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
