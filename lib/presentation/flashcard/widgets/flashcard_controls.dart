import 'package:flutter/material.dart';
import 'package:baybai/common/components/button.dart';

class FlashcardControls extends StatelessWidget {
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const FlashcardControls({super.key, this.onPrevious, this.onNext});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Button(
            label: "Previous",
            leftIcon: Icons.arrow_back,
            onTap: onPrevious,
            type: ButtonType.secondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Button(
            label: "Next",
            rightIcon: Icons.arrow_forward,
            onTap: onNext,
            type: ButtonType.primary,
          ),
        ),
      ],
    );
  }
}
