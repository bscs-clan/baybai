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
  static const game = SolarIconsOutline.gamepad;
  static const lightbulb = SolarIconsOutline.lightbulb;
  static const lesson = SolarIconsOutline.book;
  static const magnifier = SolarIconsOutline.magnifier;
  static const medalStar = SolarIconsOutline.medalStar;
  static const practice = SolarIconsOutline.penNewSquare;
  static const questionSquare = SolarIconsOutline.questionSquare;
  static const settings = SolarIconsOutline.settings;
  static const share = SolarIconsOutline.share;
  static const switchHorizontal = SolarIconsOutline.transferHorizontal;
  static const undo = SolarIconsOutline.undoLeft;
  static const userCircle = SolarIconsOutline.userCircle;

  const AppSolarIcons._();
}
