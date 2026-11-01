class FilipinoOutputToken {
  final int index;
  final String text;
  final int start;
  final int end;
  final List<String> suggestions;

  const FilipinoOutputToken({
    required this.index,
    required this.text,
    required this.start,
    required this.end,
    required this.suggestions,
  });
}
