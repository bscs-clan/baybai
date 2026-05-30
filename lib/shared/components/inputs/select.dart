import "package:baybai/shared/components/base/component_tokens.dart";
import "package:flutter/material.dart";
import "package:shadcn_flutter/shadcn_flutter.dart" as shadcn;

class Select<T> extends StatefulWidget {
  final List<T> items;
  final T? value;
  final String Function(T) label;
  final ValueChanged<T> onChanged;
  final IconData leftIcon;
  final String placeholder;
  final Widget Function(BuildContext context, T? value)? displayBuilder;
  final Widget Function(BuildContext context, T item, bool selected)?
  itemBuilder;

  const Select({
    super.key,
    required this.items,
    required this.label,
    required this.onChanged,
    required this.leftIcon,
    required this.placeholder,
    this.value,
    this.displayBuilder,
    this.itemBuilder,
  });

  @override
  State<Select<T>> createState() => _SelectState<T>();
}

class _SelectState<T> extends State<Select<T>> {
  OverlayEntry? _overlay;
  final LayerLink _link = LayerLink();

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  void _open() {
    if (_overlay != null) return;
    _overlay = _createOverlay();
    Overlay.of(context).insert(_overlay!);
  }

  void _close() {
    _overlay?.remove();
    _overlay = null;
  }

  OverlayEntry _createOverlay() {
    return OverlayEntry(
      builder: (context) {
        final theme = Theme.of(context);

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _close,
                behavior: HitTestBehavior.translucent,
              ),
            ),
            CompositedTransformFollower(
              link: _link,
              offset: const Offset(0, 56),
              showWhenUnlinked: false,
              child: shadcn.SurfaceCard(
                padding: const EdgeInsets.all(ComponentSpacing.sm),
                borderRadius: BorderRadius.circular(ComponentRadius.md),
                boxShadow: ComponentShadow.elevated(context),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 260,
                    maxWidth: 320,
                    minWidth: 320,
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: widget.items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: ComponentSpacing.xs),
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      final selected = widget.value == item;

                      return shadcn.Button(
                        style: shadcn.ButtonStyle.ghost()
                            .withPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            )
                            .withBorderRadius(
                              borderRadius: BorderRadius.circular(
                                ComponentRadius.sm,
                              ),
                            )
                            .withBackgroundColor(
                              color: selected
                                  ? theme.colorScheme.primary.withValues(
                                      alpha: 0.10,
                                    )
                                  : Colors.transparent,
                            ),
                        onPressed: () {
                          widget.onChanged(item);
                          _close();
                        },
                        child:
                            widget.itemBuilder?.call(context, item, selected) ??
                            _defaultItem(context, item, selected, theme),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _defaultItem(
    BuildContext context,
    T item,
    bool selected,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.label(item),
            style: TextStyle(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        AnimatedOpacity(
          duration: ComponentMotion.fast,
          opacity: selected ? 1 : 0,
          child: Icon(Icons.check, size: 18, color: theme.colorScheme.primary),
        ),
      ],
    );
  }

  Widget _buildDisplay(BuildContext context) {
    final theme = Theme.of(context);
    final content =
        widget.displayBuilder?.call(context, widget.value) ??
        Row(
          children: [
            Expanded(
              child: Text(
                widget.value != null
                    ? widget.label(widget.value as T)
                    : widget.placeholder,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: widget.value == null
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        );

    return Row(
      children: [
        Icon(
          widget.leftIcon,
          size: 18,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 10),
        Expanded(child: content),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CompositedTransformTarget(
      link: _link,
      child: shadcn.Button(
        style: shadcn.ButtonStyle.outline()
            .withPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            )
            .withBorderRadius(
              borderRadius: BorderRadius.circular(ComponentRadius.sm),
            )
            .withBackgroundColor(color: theme.colorScheme.surface)
            .withBorder(
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
              ),
            ),
        onPressed: _open,
        child: _buildDisplay(context),
      ),
    );
  }
}
