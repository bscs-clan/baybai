import "package:flutter/material.dart";
import "package:baybai/core/configs/theme/colors.dart";

class TabScan extends StatefulWidget {
  const TabScan({super.key});

  @override
  State<TabScan> createState() => _TabScanState();
}

class _TabScanState extends State<TabScan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.background);
  }
}
