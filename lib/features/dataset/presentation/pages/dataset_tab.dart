import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:loading_animation_widget/loading_animation_widget.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/dataset/domain/entities/dataset_entry.dart";
import "package:baybai/features/dataset/presentation/bloc/dataset_bloc.dart";
import "package:baybai/features/dataset/presentation/bloc/dataset_event.dart";
import "package:baybai/features/dataset/presentation/bloc/dataset_state.dart";
import "package:baybai/features/dataset/presentation/widgets/dataset_edit_dialog.dart";
import "package:baybai/features/dataset/presentation/widgets/dataset_edit_sheet.dart";
import "package:baybai/features/dataset/presentation/widgets/dataset_empty_state.dart";
import "package:baybai/features/dataset/presentation/widgets/dataset_entry_tile.dart";
import "package:baybai/features/dataset/presentation/widgets/dataset_preview_pane.dart";
import "package:baybai/features/dataset/presentation/widgets/dataset_character_bar_graph.dart";
import "package:baybai/shared/components/toast/toast.dart";

class DatasetScreen extends StatelessWidget {
  const DatasetScreen({super.key});

  Color _iconColor(BuildContext context, bool isDark) =>
      isDark ? AppColors.darkIcon : AppColors.icon;

  Color _textColor(BuildContext context, bool isDark) =>
      isDark ? AppColors.darkText : AppColors.text;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _iconColor(context, isDarkMode)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Datasets",
          style: TextStyle(
            color: _textColor(context, isDarkMode),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: const DatasetTab(bottomPadding: 32),
    );
  }
}

class DatasetTab extends StatefulWidget {
  final double bottomPadding;

  const DatasetTab({super.key, this.bottomPadding = 156});

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
    if (mounted) context.read<DatasetBloc>().add(const DatasetLoadRequested());
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
      onSave: (title, description) =>
          _saveEntry(context, entry, title, description),
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
        onSave: (title, description) =>
            _saveEntry(context, entry, title, description),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DatasetBloc, DatasetState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        AppToast.show(
          context,
          message: state.errorMessage!,
          variant: AppToastVariant.error,
        );
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 320,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                      child: DatasetCharacterBarGraph(
                        entries: state.entries,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                  ),

                  Expanded(
                    child: _DatasetEntryList(
                      entries: state.entries,
                      selectedEntry: state.selectedEntry,
                      isDesktop: true,
                      isDarkMode: isDarkMode,
                      onSelected: (entry) => context.read<DatasetBloc>().add(
                        DatasetEntrySelected(entry),
                      ),
                      onDelete: (entry) => _deleteEntry(context, entry),
                      onMobileEdit: (entry) =>
                          _showMobileEditSheet(context, entry),
                      bottomPadding: widget.bottomPadding,
                    ),
                  ),

                  // Preview Pane
                  if (state.selectedEntry != null)
                    SizedBox(
                      width: 360,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 12, 12, 12),
                        child: DatasetPreviewPane(
                          entry: state.selectedEntry!,
                          isDarkMode: isDarkMode,
                          onEdit: (entry) => _showEditDialog(context, entry),
                        ),
                      ),
                    ),
                ],
              );
            }

            // Mobile Layout
            return _DatasetEntryList(
              entries: state.entries,
              selectedEntry: state.selectedEntry,
              isDesktop: false,
              isDarkMode: isDarkMode,
              onSelected: (entry) =>
                  context.read<DatasetBloc>().add(DatasetEntrySelected(entry)),
              onDelete: (entry) => _deleteEntry(context, entry),
              onMobileEdit: (entry) => _showMobileEditSheet(context, entry),
              bottomPadding: widget.bottomPadding,
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
  final double bottomPadding;

  const _DatasetEntryList({
    required this.entries,
    required this.selectedEntry,
    required this.isDesktop,
    required this.isDarkMode,
    required this.onSelected,
    required this.onDelete,
    required this.onMobileEdit,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    final reversedEntries = entries.reversed.toList();

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBox : AppColors.box,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          if (!isDesktop)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: DatasetCharacterBarGraph(
                  entries: entries,
                  isDarkMode: isDarkMode,
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              height: 4,
              color: isDarkMode
                  ? AppColors.darkBackground
                  : AppColors.background,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Datasets',
                    style: AppTextStyles.bigbody.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? AppColors.darkText : AppColors.text,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${entries.length} ${entries.length == 1 ? "item" : "items"}',
                    style: TextStyle(
                      color: isDarkMode
                          ? AppColors.darkTextGrey
                          : AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index.isOdd) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: isDarkMode
                          ? AppColors.darkListSeparator
                          : AppColors.listSeparator,
                    ),
                  );
                }
                final itemIndex = index ~/ 2;
                final entry = reversedEntries[itemIndex];
                return DatasetEntryTile(
                  entry: entry,
                  isDarkMode: isDarkMode,
                  onTap: () =>
                      isDesktop ? onSelected(entry) : onMobileEdit(entry),
                  onDelete: () => onDelete(entry),
                );
              },
              childCount: reversedEntries.isEmpty
                  ? 0
                  : reversedEntries.length * 2 - 1,
            ),
          ),
          SliverPadding(padding: EdgeInsets.only(bottom: bottomPadding)),
        ],
      ),
    );
  }
}
