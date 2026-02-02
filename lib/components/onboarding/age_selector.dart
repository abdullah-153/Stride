import 'package:flutter/material.dart';
import '../../utils/size_config.dart';

class AgeSelector extends StatefulWidget {
  final int initialAge;
  final Function(int) onAgeChanged;

  const AgeSelector({
    super.key,
    required this.initialAge,
    required this.onAgeChanged,
  });

  @override
  State<AgeSelector> createState() => _AgeSelectorState();
}

class _AgeSelectorState extends State<AgeSelector> {
  final List<int> ageList = List.generate(88, (i) => i + 13);
  late int selectedAgeIndex;
  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    selectedAgeIndex = ageList.indexOf(widget.initialAge);
    if (selectedAgeIndex == -1) {
      dAgeIndex = 12;

   
    } _controller = FixedExtentScrollController(initialItem: selectedAgeIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "${ageList[selectedAgeIndex]}",
          style: TextStyle(
            fontSize: SizeConfig.sp(48),
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFF7700),
          ),
        ),
        Text(
          "years old",
          style: TextStyle(
            fontSize: SizeConfig.sp(16),
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),

        SizedBox(height: SizeConfig.h(40)),

        SizedBox(
          height: SizeConfig.h(200),
          child: ListWheelScrollView.useDelegate(
            controller: _controller,
            itemExtent: SizeConfig.h(60),
            diameterRatio: 1.5,
            onSelectedItemChanged: (index) {
              setState(() => selectedAgeIndex = index);
              widget.onAgeChanged(ageList[index]);
            },
            physics: const FixedExtentScrollPhysics(),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: ageList.length,
              builder: (context, index) {
                return Center(
                  child: Text(
                    ageList[index].toString(),
                    style: TextStyle(
                      fontSize: SizeConfig.sp(24),
                      fontWeight: index == selectedAgeIndex
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: index == selectedAgeIndex
                          ? const Color(0xFFFF7700)
                          : Colors.grey[400],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
