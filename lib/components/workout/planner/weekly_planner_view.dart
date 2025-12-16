import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../utils/size_config.dart';
import 'day_planner_card.dart';

class WeeklyPlannerView extends StatefulWidget {
  final Map<String, dynamic> generatedPlan;
  final ValueChanged<Map<String, dynamic>> onPlanUpdated;
  final bool isDark; // Add explicit theme control

  const WeeklyPlannerView({
    super.key,
    required this.generatedPlan,
    required this.onPlanUpdated,
    required this.isDark,
  });

  @override
  State<WeeklyPlannerView> createState() => _WeeklyPlannerViewState();
}

class _WeeklyPlannerViewState extends State<WeeklyPlannerView> {
  final List<Map<String, dynamic>?> _weeklySchedule = List.filled(7, null);
  final List<String> _dayLabels = [
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];

  final List<List<Map<String, dynamic>?>> _history = [];

  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _initializeSchedule();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  void _initializeSchedule() {
    final originalWeeklyPlan = widget.generatedPlan['weeklyPlan'] as List;

    for (int i = 0; i < originalWeeklyPlan.length; i++) {
      int targetIndex = i;
      if (originalWeeklyPlan.length == 3) {
        if (i == 1) targetIndex = 2;
        if (i == 2) targetIndex = 4;
      } else if (originalWeeklyPlan.length == 4) {
        if (i >= 2) targetIndex = i + 1;
      } else if (originalWeeklyPlan.length == 5) {
        targetIndex = i;
      }

      if (targetIndex < 7) {
        _weeklySchedule[targetIndex] = Map<String, dynamic>.from(
          originalWeeklyPlan[i],
        );
        _weeklySchedule[targetIndex]!['originalDayIndex'] = targetIndex + 1;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _notifyUpdate();
      }
    });
  }

  void _saveToHistory() {
    final copy = _weeklySchedule
        .map((day) => day == null ? null : Map<String, dynamic>.from(day))
        .toList();
    _history.add(copy);
    if (_history.length > 20) _history.removeAt(0);
  }

  void _undo() {
    if (_history.isEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() {
      final previousState = _history.removeLast();
      for (int i = 0; i < 7; i++) {
        _weeklySchedule[i] = previousState[i];
      }
    });
    _notifyUpdate();
  }

  void _notifyUpdate() {
    final activeDays = _weeklySchedule
        .where((day) => day != null)
        .map((day) => day!)
        .toList();

    final updatedPlan = Map<String, dynamic>.from(widget.generatedPlan);
    updatedPlan['weeklyPlan'] = activeDays;

    widget.onPlanUpdated(updatedPlan);
  }

  void _onDayUpdated(int index, Map<String, dynamic> updatedDay) {
    _saveToHistory();
    setState(() {
      _weeklySchedule[index] = updatedDay;
    });
    _notifyUpdate();
  }

  void _onClearDay(int index) {
    _saveToHistory();
    setState(() {
      _weeklySchedule[index] = null;
    });
    HapticFeedback.mediumImpact();
    _notifyUpdate();
  }

  void _onAddNewDay(int index) {
    _saveToHistory();
    setState(() {
      _weeklySchedule[index] = {
        'name': 'Custom Workout',
        'exercises': [],
        'estimatedMinutes': 0,
        'originalDayIndex': index + 1,
      };
    });
    _notifyUpdate();
  }

  void _checkAutoScroll(Offset position) {
    const double edgeThreshold = 80.0; // Increased threshold
    final double screenWidth = MediaQuery.of(context).size.width;


    if (position.dx < edgeThreshold) {
      _startAutoScroll(-8.0); // Slightly faster scroll
    } else if (position.dx > screenWidth - edgeThreshold) {
      _startAutoScroll(8.0); // Slightly faster scroll
    } else {
      _stopAutoScroll();
    }
  }

  void _startAutoScroll(double delta) {
    if (_autoScrollTimer != null) return;
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 16), (
      timer,
    ) {
      if (_scrollController.hasClients) {
        final newOffset = _scrollController.offset + delta;
        if (newOffset >= _scrollController.position.minScrollExtent &&
            newOffset <= _scrollController.position.maxScrollExtent) {
          _scrollController.jumpTo(newOffset);
        }
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void _handleDrop(int sourceIndex, int targetIndex) {
    _stopAutoScroll();
    _saveToHistory();

    setState(() {

      final sourceItem = _weeklySchedule[sourceIndex];
      final targetItem = _weeklySchedule[targetIndex];

      _weeklySchedule[targetIndex] = sourceItem;
      _weeklySchedule[sourceIndex] =
          targetItem; // Swap allows simple shifting without losing data
    });

    HapticFeedback.mediumImpact();
    _notifyUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark; // Use widget parameter
    final textColor = isDark ? Colors.white : Colors.black;
    final accentColor = const Color(0xFFCEF24B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Weekly Schedule",
                style: TextStyle(
                  fontSize: SizeConfig.sp(18),
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              if (_history.isNotEmpty)
                TextButton.icon(
                  onPressed: _undo,
                  icon: Icon(Icons.undo_rounded, size: 16, color: accentColor),
                  label: Text(
                    "Undo",
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: SizeConfig.h(8)),
        Container(
          margin: EdgeInsets.symmetric(horizontal: SizeConfig.w(8)),
          padding: EdgeInsets.all(SizeConfig.w(12)),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.touch_app_rounded,
                size: 20,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Long Press & Drag to rearrange. Tap '+' to add workout.",
                  style: TextStyle(
                    fontSize: SizeConfig.sp(12),
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: SizeConfig.h(24)),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(7, (index) {
                  return Container(
                    width: SizeConfig.w(280),
                    margin: EdgeInsets.only(right: SizeConfig.w(16)),
                    padding: EdgeInsets.only(
                      left: SizeConfig.w(8),
                      bottom: SizeConfig.h(8),
                    ),
                    child: Text(
                      _dayLabels[index],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                        letterSpacing: 1.2,
                        fontSize: SizeConfig.sp(12),
                      ),
                    ),
                  );
                }),
              ),

              Row(
                children: List.generate(7, (index) {
                  return _buildDragTargetSlot(index);
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onAddExercise(int index) {
    if (_weeklySchedule[index] == null) {
      _onAddNewDay(index); // If empty, first create the day structure
      return;
    }
    _showAddExerciseDialog(index);
  }

  void _showAddExerciseDialog(int dayIndex) {
    String name = '';
    int sets = 3;
    int reps = 12;
    int minutes = 10; // Default estimate

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add Exercise",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: "Exercise Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) => name = val,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildCompactInput(
                    "Sets",
                    "3",
                    (val) => sets = int.tryParse(val) ?? 3,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildCompactInput(
                    "Reps",
                    "12",
                    (val) => reps = int.tryParse(val) ?? 12,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildCompactInput(
                    "Time (min)",
                    "10",
                    (val) => minutes = int.tryParse(val) ?? 10,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (name.isEmpty) return;
                  Navigator.pop(context);
                  _saveToHistory();
                  setState(() {
                    final day = Map<String, dynamic>.from(
                      _weeklySchedule[dayIndex]!,
                    );
                    final exercises = List<Map<String, dynamic>>.from(
                      day['exercises'],
                    );
                    exercises.add({
                      'name': name,
                      'sets': sets,
                      'reps': reps,
                      'restSeconds': 60, // Default
                      'estimatedMinutes': minutes,
                      'targetMuscle': 'custom',
                    });
                    day['exercises'] = exercises;
                    _weeklySchedule[dayIndex] = day;
                  });
                  _notifyUpdate();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCEF24B),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Add to Workout",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactInput(
    String label,
    String initial,
    Function(String) onChanged,
  ) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: TextInputType.number,
      controller: TextEditingController(text: initial),
      onChanged: onChanged,
    );
  }


  Widget _buildDragTargetSlot(int index) {
    final double cardWidth = MediaQuery.of(context).size.width * 0.75;

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != index,
      onMove: (details) {
        _checkAutoScroll(details.offset);
      },
      onLeave: (_) => _stopAutoScroll(),
      onAcceptWithDetails: (details) => _handleDrop(details.data, index),
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: cardWidth, // Updated width
          margin: EdgeInsets.only(right: SizeConfig.w(12)), // Reduced Margin
          transform: isHovered
              ? Matrix4.identity().scaled(1.02)
              : Matrix4.identity(),
          decoration: isHovered
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFCEF24B), width: 2),
                  color: const Color(0xFFCEF24B).withOpacity(0.1),
                )
              : null,
          child: _buildDraggableCard(index, isHovered, cardWidth),
        );
      },
    );
  }

  Widget _buildDraggableCard(int index, bool isHovered, double cardWidth) {
    final dayData = _weeklySchedule[index];
    final isDark = widget.isDark; // Use widget parameter

    Widget content;
    if (dayData == null) {
      content = DayPlannerCard(
        dayData: null,
        dayIndex: index,
        onUpdateDay: (d) => _onDayUpdated(index, d),
        onClearDay: () => _onClearDay(index),
        onAddExercise: () => _onAddExercise(index),
        isDark: isDark,
        accentColor: const Color(0xFFCEF24B),
      );
    } else {
      content = DayPlannerCard(
        dayData: dayData,
        dayIndex: index,
        onUpdateDay: (d) => _onDayUpdated(index, d),
        onClearDay: () => _onClearDay(index),
        onAddExercise: () => _onAddExercise(index),
        isDark: isDark,
        accentColor: const Color(0xFFCEF24B),
      );
    }

    if (dayData == null) {
      return SizedBox(height: SizeConfig.h(400), child: content);
    }

    return LongPressDraggable<int>(
      data: index,
      delay: const Duration(milliseconds: 400),
      onDragUpdate: (details) {
        _checkAutoScroll(details.globalPosition);
      },
      onDragEnd: (_) => _stopAutoScroll(),
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: cardWidth, // Feedback matches new width
          height: SizeConfig.h(400),
          child: Opacity(
            opacity: 0.9,
            child: Theme(
              data: Theme.of(context),
              child: DayPlannerCard(
                dayData: dayData,
                dayIndex: index,
                onUpdateDay: (d) {},
                onClearDay: () {},
                onAddExercise: () {},
                isDark: isDark,
                accentColor: const Color(0xFFCEF24B),
              ),
            ),
          ),
        ),
      ),
      childWhenDragging: SizedBox(
        height: SizeConfig.h(400),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.02)
                : Colors.black.withOpacity(0.02),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black12,
              style: BorderStyle.solid,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.arrow_forward_rounded,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ),
        ),
      ),
      onDragStarted: () => HapticFeedback.selectionClick(),
      child: SizedBox(height: SizeConfig.h(400), child: content),
    );
  }
}
