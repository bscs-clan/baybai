import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/features/dataset/domain/entities/dataset_entry.dart";
import "package:baybai/features/dataset/presentation/widgets/dataset_thumbnail.dart";

class DatasetEntryTile extends StatelessWidget {
  final DatasetEntry entry;
  final bool isDarkMode;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const DatasetEntryTile({
    super.key,
    required this.entry,
    required this.isDarkMode,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(entry.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.45,
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: isDarkMode
                ? AppColors.darkBackground
                : AppColors.background,
            foregroundColor: Colors.red,
            label: 'DELETE',
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkBox : AppColors.box,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DatasetThumbnail(imagePath: entry.imagePath),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.titleBaybayin.replaceAll(
                          RegExp(r'\s+'),
                          '\u2003\u2003\u2003',
                        ),
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
                      Text(
                        entry.descNormal?.trim().isNotEmpty == true
                            ? entry.descNormal!
                            : '-',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: entry.descNormal?.trim().isNotEmpty == true
                              ? (isDarkMode
                                    ? AppColors.darkTextGrey
                                    : AppColors.textGrey)
                              : Theme.of(context).disabledColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
  }
}
