import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/shared/components/base/component_tokens.dart";

class BaybyainSymbol {
  final String unicode;
  final String romanization;

  const BaybyainSymbol({required this.unicode, required this.romanization});
}

class BaybyainSymbolCard extends StatelessWidget {
  final List<BaybyainSymbol> symbols;

  const BaybyainSymbolCard({
    super.key,
    required this.symbols,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: symbols.length,
      itemBuilder: (context, index) {
        final symbol = symbols[index];
        return _SymbolTile(
          unicode: symbol.unicode,
          romanization: symbol.romanization,
        );
      },
    );
  }
}

class _SymbolTile extends StatefulWidget {
  final String unicode;
  final String romanization;

  const _SymbolTile({
    required this.unicode,
    required this.romanization,
  });

  @override
  State<_SymbolTile> createState() => _SymbolTileState();
}

class _SymbolTileState extends State<_SymbolTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ComponentRadius.md),
            color: isDarkMode ? AppColors.darkCompBg : AppColors.white,
          ),
          child: Center(
            child: Text(
              widget.unicode,
              style: TextStyle(
                fontFamily: 'Baybayin',
                fontSize: 64,
                color: isDarkMode ? Colors.white : Colors.black,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
