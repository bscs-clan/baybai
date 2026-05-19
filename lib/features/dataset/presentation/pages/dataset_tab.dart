import "dart:io";
import "package:flutter/material.dart";
import "package:path_provider/path_provider.dart";
import "package:permission_handler/permission_handler.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:loading_animation_widget/loading_animation_widget.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/features/dataset/domain/entities/dataset_entry.dart";
import "package:baybai/features/dataset/presentation/bloc/dataset_bloc.dart";
import "package:baybai/features/dataset/presentation/bloc/dataset_event.dart";
import "package:baybai/features/dataset/presentation/bloc/dataset_state.dart";
import "package:baybai/features/dataset/presentation/widgets/dataset_edit_dialog.dart";
import "package:baybai/features/dataset/presentation/widgets/dataset_edit_sheet.dart";
import "package:baybai/features/dataset/presentation/widgets/dataset_empty_state.dart";
import "package:baybai/features/dataset/presentation/widgets/dataset_entry_tile.dart";
import "package:baybai/features/dataset/presentation/widgets/dataset_preview_pane.dart";

class DatasetTab extends StatefulWidget {
  const DatasetTab({super.key});

  @override
  State<DatasetTab> createState() => _DatasetTabState();
}

class _DatasetTabState extends State<DatasetTab> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        context.read<DatasetBloc>().add(const DatasetRefreshRequested());
      }
    }
  }

  Future<void> _initializeFolder() async {
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Permission Required'),
        content: const Text(
          'We need storage permission to create and access the ".datasets" folder in your device storage. Do you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Proceed'),
          ),
        ],
      ),
    );

    if (shouldProceed != true) return;

    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isRestricted ||
          await Permission.manageExternalStorage.isDenied) {
        await Permission.manageExternalStorage.request();
      }
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }

      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        final parts = extDir.path.split('/Android');
        final root = parts.isNotEmpty ? parts.first : extDir.path;
        final dir = Directory('$root/.datasets');
        if (!dir.existsSync()) {
          try {
            dir.createSync(recursive: true);
          } catch (_) {}
        }
      }
    }

    if (mounted) {
      context.read<DatasetBloc>().add(const DatasetLoadRequested());
    }
  }

  Future<void> _saveEntry(
    BuildContext context,
    DatasetEntry entry,
    String title,
    String description,
  ) async {
    context.read<DatasetBloc>().add(
      DatasetEntrySaveRequested(
        entry: entry,
        title: title,
        description: description,
      ),
    );
  }

  void _deleteEntry(BuildContext context, DatasetEntry entry) {
    context.read<DatasetBloc>().add(DatasetEntryDeleteRequested(entry));
  }

  Future<void> _showEditDialog(BuildContext context, DatasetEntry entry) async {
    await showDatasetEditDialog(
      context: context,
      entry: entry,
      onSave: (title, description) {
        return _saveEntry(context, entry, title, description);
      },
    );
  }

  void _showMobileEditSheet(BuildContext context, DatasetEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DatasetEditSheet(
        entry: entry,
        onSave: (title, description) {
          return _saveEntry(context, entry, title, description);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DatasetBloc, DatasetState>(
      listenWhen: (previous, current) {
        return previous.errorMessage != current.errorMessage &&
            current.errorMessage != null;
      },
      listener: (context, state) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      builder: (context, state) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        if (state.isLoading) {
          return Center(
            child: LoadingAnimationWidget.threeArchedCircle(
              color: AppColors.primary,
              size: 40,
            ),
          );
        }

        if (state.status == DatasetStatus.failure && !state.hasEntries) {
          return Center(
            child: Text(
              'Failed to load dataset:\n${state.errorMessage}',
              textAlign: TextAlign.center,
            ),
          );
        }

        if (state.entries.isEmpty) {
          return DatasetEmptyState(onInitialize: _initializeFolder);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final showPreviewPane = constraints.maxWidth >= 900;

            if (showPreviewPane) {
              return Row(
                children: [
                  Expanded(
                    child: _DatasetEntryList(
                      entries: state.entries,
                      selectedEntry: state.selectedEntry,
                      isDesktop: true,
                      isDarkMode: isDarkMode,
                      onSelected: (entry) {
                        context.read<DatasetBloc>().add(
                          DatasetEntrySelected(entry),
                        );
                      },
                      onDelete: (entry) => _deleteEntry(context, entry),
                      onMobileEdit: (entry) {
                        _showMobileEditSheet(context, entry);
                      },
                    ),
                  ),
                  if (state.selectedEntry != null)
                    DatasetPreviewPane(
                      entry: state.selectedEntry!,
                      isDarkMode: isDarkMode,
                      onEdit: (entry) => _showEditDialog(context, entry),
                    ),
                ],
              );
            }

            return _DatasetEntryList(
              entries: state.entries,
              selectedEntry: state.selectedEntry,
              isDesktop: false,
              isDarkMode: isDarkMode,
              onSelected: (entry) {
                context.read<DatasetBloc>().add(DatasetEntrySelected(entry));
              },
              onDelete: (entry) => _deleteEntry(context, entry),
              onMobileEdit: (entry) => _showMobileEditSheet(context, entry),
            );
          },
        );
      },
    );
  }
}

class _DatasetEntryList extends StatelessWidget {
  final List<DatasetEntry> entries;
  final DatasetEntry? selectedEntry;
  final bool isDesktop;
  final bool isDarkMode;
  final ValueChanged<DatasetEntry> onSelected;
  final ValueChanged<DatasetEntry> onDelete;
  final ValueChanged<DatasetEntry> onMobileEdit;

  const _DatasetEntryList({
    required this.entries,
    required this.selectedEntry,
    required this.isDesktop,
    required this.isDarkMode,
    required this.onSelected,
    required this.onDelete,
    required this.onMobileEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDarkMode ? AppColors.darkBox : AppColors.box,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 156),
        itemCount: entries.length,
        cacheExtent: 1000,
        physics: const BouncingScrollPhysics(),

        itemBuilder: (context, index) {
          final entry = entries[index];

          return DatasetEntryTile(
            entry: entry,
            isDarkMode: isDarkMode,
            onTap: () => isDesktop ? onSelected(entry) : onMobileEdit(entry),
            onDelete: () => onDelete(entry),
          );
        },

        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Divider(
            height: 1,
            thickness: 1,
            color: isDarkMode
                ? AppColors.darkListSeparator
                : AppColors.listSeparator,
          ),
        ),
      ),
    );
  }
}
