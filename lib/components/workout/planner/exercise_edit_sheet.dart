import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/size_config.dart';

class ExerciseEditSheet extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback onDelete;
  final bool isDark;

  const ExerciseEditSheet({
    super.key,
    required this.exercise,
    required this.onSave,
    required this.onDelete,
    required this.isDark,
  });

  @override
  State<ExerciseEditSheet> createState() => _ExerciseEditSheetState();
}

class _ExerciseEditSheetState extends State<ExerciseEditSheet> {
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _restController;

  @override
  void initState() {
    super.initState();
    _setsController = TextEditingController(
      text: widget.exercise['sets'].toString(),
    );
    _repsController = TextEditingController(
      text: widget.exercise['reps'].toString(),
    );
    _restController = TextEditingController(
      text: widget.exercise['restSeconds'].toString(),
    );
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _restController.dispose();
    super.dispose();
  }

  void _save() {
    final updatedExercise = Map<String, dynamic>.from(widget.exercise);
    updatedExercise['sets'] =
        int.tryParse(_setsController.text) ?? widget.exercise['sets'];
    updatedExercise['reps'] =
        int.tryParse(_repsController.text) ?? widget.exercise['reps'];
    updatedExercise['restSeconds'] =
        int.tryParse(_restController.text) ?? widget.exercise['restSeconds'];

    widget.onSave(updatedExercise);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final accentColor = const Color(0xFFCEF24B);

    return Container(
      padding: EdgeInsets.only(
        top: SizeConfig.h(20),
        left: SizeConfig.w(24),
        right: SizeConfig.w(24),
        bottom: MediaQuery.of(context).viewInsets.bottom + SizeConfig.h(24),
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: SizeConfig.h(24)),

          Text(
            widget.exercise['name'],
            style: TextStyle(
              fontSize: SizeConfig.sp(24),
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            widget.exercise['targetMuscle'].toString().toUpperCase(),
            style: TextStyle(
              fontSize: SizeConfig.sp(14),
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : Colors.black54,
              letterSpacing: 1.0,
            ),
          ),

          SizedBox(height: SizeConfig.h(30)),

          Row(
            children: [
              Expanded(
                child: _buildNumberInput(
                  'Sets',
                  _setsController,
                  isDark,
                  accentColor,
                ),
              ),
              SizedBox(width: SizeConfig.w(16)),
              Expanded(
                child: _buildNumberInput(
                  'Reps',
                  _repsController,
                  isDark,
                  accentColor,
                ),
              ),
              SizedBox(width: SizeConfig.w(16)),
              Expanded(
                child: _buildNumberInput(
                  'Rest (s)',
                  _restController,
                  isDark,
                  accentColor,
                ),
              ),
            ],
          ),

          SizedBox(height: SizeConfig.h(40)),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    widget.onDelete();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text("Remove"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    padding: EdgeInsets.symmetric(vertical: SizeConfig.h(16)),
                    side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              SizedBox(width: SizeConfig.w(16)),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: SizeConfig.h(16)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInput(
    String label,
    TextEditingController controller,
    bool isDark,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: SizeConfig.sp(12),
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white38 : Colors.black38,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: SizeConfig.h(8)),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: SizeConfig.sp(20),
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
      ],
    );
  }
}
