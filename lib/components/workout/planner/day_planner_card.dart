import 'package:flutter/material.dart';
import '../../../utils/size_config.dart';
import 'exercise_edit_sheet.dart';

class DayPlannerCard extends StatelessWidget {
  final Map<String, dynamic>? dayData; // Null means Rest Day

  final int dayIndex;
  final ValueChanged<Map<String, dynamic>> onUpdateDay;
  final VoidCallback onClearDay;
  final bool isDark;
  final Color accentColor;

  final VoidCallback onAddExercise;

  const DayPlannerCard({
    super.key,
    required this.dayData,
    required this.dayIndex, // Removed dayLabel
    required this.onUpdateDay,
    required this.onClearDay,
    required this.onAddExercise, // New Callback
    required this.isDark,
    required this.accentColor,
  });

  void _editExercise(
    BuildContext context,
    int index,
    Map<String, dynamic> exercise,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExerciseEditSheet(
        isDark: isDark,
        exercise: exercise,
        onSave: (updatedExercise) {
          final updatedDay = Map<String, dynamic>.from(dayData!);
          final updatedExercises = List<Map<String, dynamic>>.from(
            updatedDay['exercises'],
          );
          updatedExercises[index] = updatedExercise;
          updatedDay['exercises'] = updatedExercises;
          onUpdateDay(updatedDay);
        },
        onDelete: () {
          final updatedDay = Map<String, dynamic>.from(dayData!);
          final updatedExercises = List<Map<String, dynamic>>.from(
            updatedDay['exercises'],
          );
          updatedExercises.removeAt(index);
          updatedDay['exercises'] = updatedExercises;

          if (updatedExercises.isEmpty) {
            onClearDay();
          } else {
            onUpdateDay(updatedDay);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryText = isDark ? Colors.grey[400] : Colors.grey[600];

    final isEmpty = dayData == null;

    return Container(
      width: SizeConfig.w(280),
      margin: EdgeInsets.only(right: SizeConfig.w(16)),
      decoration: BoxDecoration(
        color: isEmpty ? cardColor.withOpacity(0.5) : cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isEmpty)
            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(top: 8, right: 12),
              child: GestureDetector(
                onTap: onClearDay,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.black12,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
              ),
            ),

          Expanded(
            child: isEmpty
                ? GestureDetector(
                    onTap: onAddExercise,
                    behavior: HitTestBehavior.opaque,
                    child: _buildEmptyState(textColor, secondaryText!),
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      SizeConfig.w(16),
                      4,
                      SizeConfig.w(16),
                      SizeConfig.w(16),
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount:
                        (dayData!['exercises'] as List).length +
                        1, // +1 for Add Button
                    itemBuilder: (context, index) {
                      final exercises = dayData!['exercises'] as List;
                      if (index == exercises.length) {
                        return _buildAddButton(isDark, accentColor);
                      }
                      final exercise = exercises[index];
                      return _buildExerciseItem(
                        context,
                        index,
                        exercise,
                        textColor,
                        secondaryText!,
                      );
                    },
                  ),
          ),

        ],
      ),
    );
  }

  Widget _buildAddButton(bool isDark, Color accentColor) {
    return GestureDetector(
      onTap: onAddExercise,
      child: Container(
        margin: EdgeInsets.only(top: SizeConfig.h(8)),
        padding: EdgeInsets.symmetric(vertical: SizeConfig.h(12)),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? Colors.white24 : Colors.black12,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isDark
              ? Colors.white.withOpacity(0.02)
              : Colors.black.withOpacity(0.02),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 16, color: accentColor),
            SizedBox(width: 8),
            Text(
              "Add Workout",
              style: TextStyle(
                fontSize: SizeConfig.sp(12),
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color textColor, Color secondaryText) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.hotel_rounded, // Rest icon
          size: SizeConfig.sp(32),
          color: secondaryText.withOpacity(0.5),
        ),
        SizedBox(height: SizeConfig.h(12)),
        Text(
          "Rest Day",
          style: TextStyle(
            fontSize: SizeConfig.sp(16),
            fontWeight: FontWeight.w600,
            color: secondaryText,
          ),
        ),
        SizedBox(height: SizeConfig.h(8)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "Tap to Add Workout",
            style: TextStyle(
              fontSize: SizeConfig.sp(11),
              color: accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseItem(
    BuildContext context,
    int index,
    Map<String, dynamic> exercise,
    Color textColor,
    Color secondaryText,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeConfig.h(10)),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _editExercise(context, index, exercise),
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.w(12)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "${index + 1}",
                    style: TextStyle(
                      fontSize: SizeConfig.sp(10),
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
                SizedBox(width: SizeConfig.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise['name'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: SizeConfig.sp(13),
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "${exercise['sets']} sets Ãƒâ€” ${exercise['reps']} reps${exercise['estimatedMinutes'] != null && exercise['estimatedMinutes'] > 0 ? ' Ã¢â‚¬Â¢ ${exercise['estimatedMinutes']} min' : ''}",
                        style: TextStyle(
                          fontSize: SizeConfig.sp(11),
                          color: secondaryText,
                        ),
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
