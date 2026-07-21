import "package:flutter/material.dart";
import "package:solar_icons/solar_icons.dart";

class SolarIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;

  const SolarIcon(this.icon, {super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: size, color: color);
  }
}

class AppSolarIcons {
  static const academicCap = SolarIconsOutline.squareAcademicCap;
  static const alarm = SolarIconsOutline.alarm;
  static const alarmOff = SolarIconsOutline.alarmTurnOff;
  static const altArrowLeft = SolarIconsOutline.altArrowLeft;
  static const altArrowRight = SolarIconsOutline.altArrowRight;
  static const arrowLeft = SolarIconsOutline.arrowLeft;
  static const arrowRight = SolarIconsOutline.arrowRight;
  static const arrowRightUp = SolarIconsOutline.arrowRightUp;
  static const bolt = SolarIconsOutline.bolt;
  static const character = SolarIconsOutline.userId;
  static const check = SolarIconsOutline.checklist;
  static const close = SolarIconsOutline.closeCircle;
  static const confetti = SolarIconsOutline.stars;
  static const copy = SolarIconsOutline.copy;
  static const cup = SolarIconsOutline.cup;
  static const cupStar = SolarIconsOutline.cupStar;
  static const delete = SolarIconsOutline.trashBinTrash;
  static const fire = SolarIconsOutline.fire;
  static const flashcard = SolarIconsOutline.card;
  static const game = SolarIconsOutline.gameboy;
  static const gameWhite = SolarIconsBold.gameboy;
  static const lightbulb = SolarIconsOutline.lightbulb;
  static const lesson = SolarIconsOutline.book;
  static const lessonWhite = SolarIconsBold.book;
  static const magnifier = SolarIconsOutline.magnifier;
  static const medalStar = SolarIconsOutline.medalStar;
  static const practice = SolarIconsOutline.penNewSquare;
  static const questionSquare = SolarIconsOutline.questionSquare;
  static const settings = SolarIconsOutline.settings;
  static const share = SolarIconsOutline.share;
  static const switchHorizontal = SolarIconsOutline.transferHorizontal;
  static const undo = SolarIconsOutline.undoLeft;
  static const userCircle = SolarIconsOutline.userCircle;
  static const text = SolarIconsOutline.textSquare;
  static const textWhite = SolarIconsBold.textSquare;
  static const pen = SolarIconsOutline.pen;
  static const penWhite = SolarIconsBold.pen;
  static const lock = SolarIconsOutline.lock;
  static const flag = SolarIconsOutline.flag;
  static const volume = SolarIconsOutline.volumeLoud;

  const AppSolarIcons._();
}
