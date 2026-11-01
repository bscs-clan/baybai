import "package:baybai/shared/components/inputs/input.dart";
import "package:flutter/material.dart";

class LessonTextAnswerInput extends StatefulWidget {
  final String? answer;
  final bool enabled;
  final ValueChanged<String?>? onChanged;

  const LessonTextAnswerInput({
    super.key,
    this.answer,
    this.enabled = true,
    this.onChanged,
  });

  @override
  State<LessonTextAnswerInput> createState() => _LessonTextAnswerInputState();
}

class _LessonTextAnswerInputState extends State<LessonTextAnswerInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.answer);
  }

  @override
  void didUpdateWidget(LessonTextAnswerInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.answer != _controller.text) {
      final answer = widget.answer ?? "";
      _controller.value = TextEditingValue(
        text: answer,
        selection: TextSelection.collapsed(offset: answer.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Input(
        hintText: "Type your answer",
        controller: _controller,
        enabled: widget.enabled,
        textInputAction: TextInputAction.done,
        onChanged: widget.onChanged,
      ),
    );
  }
}
