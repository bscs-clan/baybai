import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/lessons/domain/entities/lesson_content.dart";
import "package:baybai/features/lessons/data/datasources/lesson_data_source.dart";
import "package:baybai/shared/components/cards/app_card.dart";
import "package:baybai/shared/components/icons/solar_icon.dart";

class LessonCompleteWidget extends StatelessWidget {
  final int lessonId;
  final LessonContent completionSlide;
  final int correctCount;
  final int incorrectCount;
  final int totalQuestions;
  final String formattedTime;
  final List<WrongAnswerInfo> wrongAnswers;
  final bool isNextLessonUnlocked;

  const LessonCompleteWidget({
    super.key,
    required this.lessonId,
    required this.completionSlide,
    required this.correctCount,
    required this.incorrectCount,
    required this.totalQuestions,
    required this.formattedTime,
    required this.wrongAnswers,
    required this.isNextLessonUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final accuracy = totalQuestions > 0
        ? (correctCount / totalQuestions) * 100
        : 0.0;

    // Find the next lesson metadata
    final nextLessonId = lessonId + 1;
    final nextLesson = LessonData.lessonList.firstWhere(
      (l) => l.id == nextLessonId,
      orElse: () => const LessonMetadata(id: -1, number: "", title: ""),
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Congratulations Section
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SolarIcon(
                AppSolarIcons.confetti,
                size: 20,
                color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                completionSlide.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.heading.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppColors.white : AppColors.dark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Combined Stats Card
          AppCard(
            padding: const EdgeInsets.all(0),
            backgroundColor: isDarkMode ? AppColors.darkBox : AppColors.box,
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Text(
                    "Accuracy",
                    style: AppTextStyles.body.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode
                          ? AppColors.darkTextGrey
                          : AppColors.textGrey,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 110,
                        height: 110,
                        child: CircularProgressIndicator(
                          value: accuracy / 100,
                          strokeWidth: 10,
                          backgroundColor: isDarkMode
                              ? AppColors.darkCompBg
                              : AppColors.compBg,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDarkMode
                                ? AppColors.darkPrimary
                                : AppColors.primary,
                          ),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text(
                        "${accuracy.toStringAsFixed(0)}%",
                        style: AppTextStyles.bigbody.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: isDarkMode ? AppColors.white : AppColors.dark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: isDarkMode ? AppColors.darkCompBg : AppColors.compBg,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Score",
                            style: AppTextStyles.body.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? AppColors.darkTextGrey
                                  : AppColors.textGrey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "$correctCount / $totalQuestions",
                            style: AppTextStyles.bigbody.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? AppColors.white
                                  : AppColors.dark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Mistakes Review Section
          Text(
            "Review Mistakes",
            style: AppTextStyles.bigbody.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.white : AppColors.dark,
            ),
          ),
          const SizedBox(height: 12),
          if (wrongAnswers.isEmpty)
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              backgroundColor: isDarkMode
                  ? Colors.green.withValues(alpha: 0.05)
                  : Colors.green.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.stars_rounded,
                    color: Colors.green,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Perfect Score! No mistakes to review. Keep it up!",
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDarkMode
                            ? Colors.green.shade300
                            : Colors.green.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: wrongAnswers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final wrong = wrongAnswers[index];
                return _buildMistakeCard(context, wrong);
              },
            ),
          const SizedBox(height: 32),

          // Up Next Section
          if (nextLesson.id != -1) ...[
            Text(
              "Up Next",
              style: AppTextStyles.bigbody.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.white : AppColors.dark,
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(20),
              backgroundColor: isDarkMode ? AppColors.darkBox : AppColors.box,
              borderRadius: BorderRadius.circular(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isNextLessonUnlocked
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : (isDarkMode
                                ? AppColors.darkCompBg
                                : AppColors.compBg),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isNextLessonUnlocked
                          ? Icons.lock_open_rounded
                          : Icons.lock_rounded,
                      color: isNextLessonUnlocked
                          ? (isDarkMode
                                ? AppColors.darkPrimary
                                : AppColors.primary)
                          : (isDarkMode
                                ? AppColors.darkTextGrey
                                : AppColors.textGrey),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nextLesson.number,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode
                                ? AppColors.darkTextGrey
                                : AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          nextLesson.title,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? AppColors.white
                                : AppColors.dark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMistakeCard(BuildContext context, WrongAnswerInfo wrong) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final question = wrong.question;

    // Determine the stimulus widget (Baybayin Text, Image, or plain description)
    Widget stimulusWidget;
    if (question.baybayinText.isNotEmpty) {
      stimulusWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkCompBg : AppColors.compBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          question.baybayinText,
          style:
              (question.baybayinFontFamily != null &&
                  question.baybayinFontFamily != 'Baybayin')
              ? GoogleFonts.getFont(
                  question.baybayinFontFamily!,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppColors.white : AppColors.dark,
                )
              : TextStyle(
                  fontFamily: 'Baybayin',
                  fontSize: 28,
                  color: isDarkMode ? AppColors.white : AppColors.dark,
                  height: 1.0,
                ),
        ),
      );
    } else if (question.image != null) {
      stimulusWidget = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          question.image!,
          height: 48,
          width: 48,
          fit: BoxFit.contain,
        ),
      );
    } else {
      stimulusWidget = const Icon(
        Icons.quiz_outlined,
        size: 28,
        color: AppColors.primary,
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: isDarkMode ? AppColors.darkBox : AppColors.box,
      borderRadius: BorderRadius.circular(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          stimulusWidget,
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.title,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppColors.white : AppColors.dark,
                  ),
                ),

              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    wrong.selectedOption,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.cancel_outlined,
                    color: Colors.red,
                    size: 14,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    wrong.correctOption,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.green,
                    size: 14,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
