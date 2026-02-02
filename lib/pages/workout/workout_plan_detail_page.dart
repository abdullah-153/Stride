import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_tracker_frontend/utils/size_config.dart';
import 'package:fitness_tracker_frontend/services/firestore/workout_plan_service.dart';
import 'package:fitness_tracker_frontend/providers/workout_plans_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutPlanDetailPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> plan;
  final bool isDarkMode;

  const WorkoutPlanDetailPage({
    super.key,
    required this.plan,
    required this.isDarkMode,
  });

  @override
  ConsumerState<WorkoutPlanDetailPage> createState() => _WorkoutPlanDetailPageState();
}

class _WorkoutPlanDetailPageState extends ConsumerState<WorkoutPlanDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Map<String, dynamic> _editablePlan;
  List<dynamic> _weeklyPlan = [];
  bool _isSaving = false;

  late Color _limeAccent;
  late Color _bgColor;
  late Color _textColor;
  late Color _glassColor;
  late Color _borderColor;

  @override
  void initState() {
    super.initState();
    _editablePlan = Map.from(widget.plan);
    _weeklyPlan = List.from(_editablePlan['weeklyPlan'] ?? []);
    
    int length = _weeklyPlan.isNotEmpty ? _weeklyPlan.length : 1;
    _tabController = TabController(length: length, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _setupTheme() {
    _limeAccent = const Color(0xFFCEF24B);
    _bgColor = widget.isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFF5F5F7);
    _textColor = widget.isDarkMode ? Colors.white : Colors.black;
    _glassColor = widget.isDarkMode 
        ? Colors.white.withOpacity(0.03) 
        : Colors.white.withOpacity(0.7);  
    _borderColor = widget.isDarkMode 
        ? Colors.white.withOpacity(0.05) 
        : Colors.black.withOpacity(0.05);
  }

  Future<void> _saveChanges() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      _editablePlan['weeklyPlan'] = _weeklyPlan;

       
      await WorkoutPlanService().updateWorkoutPlan(userId, _editablePlan['id'], _editablePlan);
      
       
      ref.invalidate(workoutPlansProvider);

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context, _editablePlan); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Plan updated successfully!",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            backgroundColor: _limeAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
      print("Save error: $e");
    }
  }

  void _confirmDeletePlan() {
    HapticFeedback.heavyImpact();
    
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text("Delete Plan?", style: TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
          content: Text(
            "Are you sure you want to delete this workout plan? This action cannot be undone.",
            style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Cancel", style: TextStyle(color: widget.isDarkMode ? Colors.white54 : Colors.black54)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _deletePlan();
              },
              child: const Text("Delete", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _deletePlan() async {
    final planId = widget.plan['id'];
    if (planId == null) return;
    
    try {
       
      await ref.read(workoutPlansProvider.notifier).deletePlan(planId);
      
      if (mounted) {
         Navigator.pop(context);  
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: const Text("Plan deleted", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
             backgroundColor: Colors.redAccent,
             behavior: SnackBarBehavior.floating,
           )
         );
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Delete failed: $e")));
    }
  }

  void _removeExercise(int dayIndex, int exIndex) {
    setState(() {
      var day = Map<String, dynamic>.from(_weeklyPlan[dayIndex]);
      var exercises = List<dynamic>.from(day['exercises']);
      exercises.removeAt(exIndex);
      day['exercises'] = exercises;
      _weeklyPlan[dayIndex] = day;
    });
    Navigator.pop(context);
  }
  
  void _editExercise(int dayIndex, int exIndex, Map<String, dynamic> currentEx) {
     Navigator.pop(context);  
     TextEditingController setsCtrl = TextEditingController(text: currentEx['sets'].toString());
     TextEditingController repsCtrl = TextEditingController(text: currentEx['reps'].toString());
     
     showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _buildGlassSheet(
          child: Column(
             mainAxisSize: MainAxisSize.min,
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Center(
                child: Container(
                  width: 40, height: 4, 
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: widget.isDarkMode ? Colors.white24 : Colors.black26, borderRadius: BorderRadius.circular(2)),
                ),
              ),
               Text("Edit ${currentEx['name']}", style: TextStyle(color: _textColor, fontSize: SizeConfig.sp(18), fontWeight: FontWeight.bold)),
               SizedBox(height: SizeConfig.h(24)),
               _buildEditField("Sets", setsCtrl),
               SizedBox(height: SizeConfig.h(12)),
               _buildEditField("Reps", repsCtrl),
               SizedBox(height: SizeConfig.h(24)),
               
               SizedBox(
                 width: double.infinity,
                 child: TextButton(
                  onPressed: () {
                    setState(() {
                       var day = Map<String, dynamic>.from(_weeklyPlan[dayIndex]);
                       var exercises = List<dynamic>.from(day['exercises']);
                       var ex = Map<String, dynamic>.from(exercises[exIndex]);
                       ex['sets'] = int.tryParse(setsCtrl.text) ?? ex['sets'];
                       ex['reps'] = int.tryParse(repsCtrl.text) ?? ex['reps'];
                       exercises[exIndex] = ex;
                       day['exercises'] = exercises;
                       _weeklyPlan[dayIndex] = day;
                    });
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: _limeAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Save Changes", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
               )
             ],
          ),
        ),
      ),
     );
  }
  
  Widget _buildEditField(String label, TextEditingController ctrl) {
     return TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: TextStyle(color: _textColor),
        decoration: InputDecoration(
           labelText: label,
           labelStyle: TextStyle(color: widget.isDarkMode ? Colors.white54 : Colors.black54),
           enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.isDarkMode ? Colors.white24 : Colors.black26)),
           focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _limeAccent)),
        ),
     );
  }

  void _showEditSheet(int dayIndex, int exIndex, Map<String, dynamic> exercise) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildGlassSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4, 
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: widget.isDarkMode ? Colors.white24 : Colors.black26, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(
              exercise['name'] ?? 'Exercise',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: SizeConfig.sp(22),
                fontWeight: FontWeight.w800,
                color: _textColor,
              ),
            ),
            SizedBox(height: SizeConfig.h(24)),
            _buildSheetAction(
              icon: Icons.edit_note_rounded,
              label: 'Edit Details',
              onTap: () => _editExercise(dayIndex, exIndex, exercise),
            ),
            _buildSheetAction(
              icon: Icons.delete_outline_rounded,
              label: 'Remove from Day',
              isDestructive: true,
              onTap: () => _removeExercise(dayIndex, exIndex),
            ),
            SizedBox(height: SizeConfig.h(20)),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassSheet({required Widget child}) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? const Color(0xFF1E1E1E).withOpacity(0.9) : Colors.white.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(top: BorderSide(color: widget.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black12)),
        ),
        child: child,
      ),
    );
  }

  Widget _buildSheetAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDestructive 
              ? (widget.isDarkMode ? const Color(0xFF2C1E1E) : Colors.red.withOpacity(0.1))
              : (widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDestructive ? Colors.redAccent.withOpacity(0.3) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isDestructive ? Colors.redAccent : _textColor),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: SizeConfig.sp(16),
                fontWeight: FontWeight.w600,
                color: isDestructive ? Colors.redAccent : _textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getDayLabel(dynamic dayData) {
      
     if (dayData is Map && dayData.containsKey('dayName')) {
        return dayData['dayName'].toString();
     }
     final dayNum = dayData['day'];
      
      
     return "Day $dayNum";
  }

  @override
  Widget build(BuildContext context) {
    _setupTheme();
    final planName = _editablePlan['name'] ?? 'Custom Plan';
    final goal = _editablePlan['goal'] ?? 'Fitness';

    return Scaffold(
      backgroundColor: _bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: widget.isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        leading: Padding(
           padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
           child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _textColor),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
           ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(SizeConfig.h(60)),
          child: Container(
            margin: EdgeInsets.only(bottom: SizeConfig.h(10)),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: _limeAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              indicatorSize: TabBarIndicatorSize.label,
              indicatorPadding: const EdgeInsets.symmetric(horizontal: -10, vertical: 8),
              labelColor: Colors.black,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.sp(13)),
              unselectedLabelColor: widget.isDarkMode ? Colors.white60 : Colors.black54,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              tabAlignment: TabAlignment.start,
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(16)),
              tabs: _weeklyPlan.map((d) => Tab(text: "  ${_getDayLabel(d)}  ")).toList().isEmpty 
                   ? [const Tab(text: "Overview")] 
                   : _weeklyPlan.map((d) => Tab(text: "  ${_getDayLabel(d)}  ")).toList(),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
           
          Positioned(
            top: -100, right: -50,
            child: _buildBlurBlob(widget.isDarkMode ? _limeAccent.withOpacity(0.15) : Colors.blue.withOpacity(0.1)),
          ),
          Positioned(
             bottom: -50, left: -50,
             child: _buildBlurBlob(widget.isDarkMode ? Colors.blue.withOpacity(0.1) : _limeAccent.withOpacity(0.1)),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(SizeConfig.w(24), SizeConfig.h(10), SizeConfig.w(24), 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                           color: _limeAccent,
                           borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          goal.toString().toUpperCase(),
                          style: TextStyle(
                            fontSize: SizeConfig.sp(11),
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        planName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: SizeConfig.sp(28),
                          fontWeight: FontWeight.w800,
                          color: _textColor,
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: SizeConfig.h(20)),
                Expanded(
                  child: _weeklyPlan.isEmpty 
                      ? Center(child: Text("Empty Plan", style: TextStyle(color: widget.isDarkMode ? Colors.white54 : Colors.black54)))
                      : TabBarView(
                          controller: _tabController,
                          children: _weeklyPlan.map((dayData) {
                            final exercises = dayData['exercises'] as List? ?? [];
                            if (exercises.isEmpty) {
                              return Center(
                                child: Text("Rest Day", style: TextStyle(color: widget.isDarkMode ? Colors.white38 : Colors.black38, fontSize: 16)),
                              );
                            }
                            return ListView.separated(
                              padding: EdgeInsets.fromLTRB(24, 10, 24, 120),
                              physics: const BouncingScrollPhysics(),
                              itemCount: exercises.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (ctx, idx) => _buildGlassExerciseCard(exercises[idx], _weeklyPlan.indexOf(dayData), idx),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          ),
          
           
          Positioned(
            left: 24, right: 24, bottom: 34,
            child: ClipRRect(
               borderRadius: BorderRadius.circular(20),
               child: BackdropFilter(
                 filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                 child: Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(
                     color: widget.isDarkMode ? const Color(0xFF1E1E1E).withOpacity(0.8) : Colors.white.withOpacity(0.85),
                     borderRadius: BorderRadius.circular(20),
                     border: Border.all(color: widget.isDarkMode ? Colors.white10 : Colors.black12),
                     boxShadow: [
                        BoxShadow(
                           color: Colors.black.withOpacity(0.1),
                           blurRadius: 20,
                           offset: const Offset(0, 10),
                        )
                     ]
                   ),
                   child: Row(
                     children: [
                       Expanded(
                         child: TextButton.icon(
                           onPressed: _confirmDeletePlan,
                           icon: Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                           label: Text("Delete", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                         ),
                       ),
                       Container(width: 1, height: 24, color: widget.isDarkMode ? Colors.white12 : Colors.black12),
                       Expanded(
                         child: TextButton.icon(
                           onPressed: _isSaving ? null : _saveChanges,
                           icon: _isSaving 
                               ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: _limeAccent))
                               : Icon(Icons.save_rounded, color: widget.isDarkMode ? _limeAccent : Colors.black, size: 20),
                           label: Text(
                             _isSaving ? "Saving..." : "Save Changes",
                             style: TextStyle(color: widget.isDarkMode ? _limeAccent : Colors.black, fontWeight: FontWeight.bold),
                           ),
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGlassExerciseCard(Map<String, dynamic> ex, int dayIndex, int exIndex) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _showEditSheet(dayIndex, exIndex, ex);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _glassColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: widget.isDarkMode ? _limeAccent.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.fitness_center_rounded, color: widget.isDarkMode ? _limeAccent : Colors.green[700], size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ex['name'] ?? 'Exercise',
                    maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: SizeConfig.sp(15),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "${ex['sets']} sets",
                        style: TextStyle(color: widget.isDarkMode ? Colors.white54 : Colors.black54, fontSize: SizeConfig.sp(12)),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 3, height: 3,
                        decoration: BoxDecoration(color: widget.isDarkMode ? Colors.white24 : Colors.black26, shape: BoxShape.circle),
                      ),
                      Text(
                        "${ex['reps']} reps",
                        style: TextStyle(color: widget.isDarkMode ? Colors.white54 : Colors.black54, fontSize: SizeConfig.sp(12)),
                      ),
                       Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 3, height: 3,
                        decoration: BoxDecoration(color: widget.isDarkMode ? Colors.white24 : Colors.black26, shape: BoxShape.circle),
                      ),
                      Expanded(
                        child: Text(
                        ex['targetMuscle'] ?? 'General',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: widget.isDarkMode ? Colors.white54 : Colors.black54, fontSize: SizeConfig.sp(12)),
                      ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.more_vert_rounded, color: widget.isDarkMode ? Colors.white24 : Colors.black26, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurBlob(Color color) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
      child: Container(
        width: 250, height: 250,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
