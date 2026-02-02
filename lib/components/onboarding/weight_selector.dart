import 'package:flutter/material.dart';
import '../../utils/size_config.dart';

class WeightSelector extends StatefulWidget {
  final double initialWeight;
  final Function(double) onWeightChanged;
  final bool isKg;

  const WeightSelector({
    super.key,
    required this.initialWeight,
    required this.onWeightChanged,
    this.isKg = true,
  });

  @override
  State<WeightSelector> createState() => _WeightSelectorState();
}

class _WeightSelectorState extends State<WeightSelector> {
  final double _minWeightKg = 30;
  final double _maxWeightKg = 200;
  late int _itemCount;
  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _itemCount = (_maxWeightKg - _minWeightKg + 1).toInt();

    double weightInKg = widget.isKg
        ? widget.initialWeight
        : widget.initialWeight / 2.20462;
    _selectedIndex = (weightInKg - _minWeightKg).round().clamp(
      0,
      _itemCount - 1,
    );

    _pageController = PageController(
      initialPage: _selectedIndex,
      viewportFraction: 0.15,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  double _calculateHeight(int value, bool isSelected) {
    if (value % 10 == 0) {
      return isSelected ? SizeConfig.h(120) : SizeConfig.h(80);
    }
    return isSelected ? SizeConfig.h(120) : SizeConfig.h(50);
  }

  double _calculateWidth(int value, bool isSelected) {
    if (value % 10 == 0) {
      return isSelected ? SizeConfig.w(4) : SizeConfig.w(2);
    }
    return isSelected ? SizeConfig.w(3) : SizeConfig.w(1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              widget.isKg
                  ? (_minWeightKg + _selectedIndex).toInt().toString()
                  : ((_minWeightKg + _selectedIndex) * 2.20462)
                        .round()
                        .toString(),
              style: TextStyle(
                fontSize: SizeConfig.sp(48),
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(width: SizeConfig.w(8)),
            Padding(
              padding: EdgeInsets.only(bottom: SizeConfig.h(10)),
              child: Text(
                widget.isKg ? "kg" : "lbs",
                style: TextStyle(
                  fontSize: SizeConfig.sp(20),
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: SizeConfig.h(20)),

        Container(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.w(16),
            vertical: SizeConfig.h(8),
          ),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(SizeConfig.w(20)),
          ),
          child: Text(
            widget.isKg ? "Metric (kg)" : "Imperial (lbs)",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),

        SizedBox(height: SizeConfig.h(40)),

        SizedBox(
          height: SizeConfig.h(150),
          child: PageView.builder(
            controller: _pageController,
            itemCount: _itemCount,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index) {
              setState(() => _selectedIndex = index);
              double weightKg = _minWeightKg + index;
              widget.onWeightChanged(
                widget.isKg ? weightKg : weightKg * 2.20462,
              );
            },
            itemBuilder: (context, index) {
              final rawValue = (_minWeightKg + index).toInt();
              final isSelected = index == _selectedIndex;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (rawValue % 10 == 0)
                    Padding(
                      padding: EdgeInsets.only(bottom: SizeConfig.h(8)),
                      child: Text(
                        widget.isKg
                            ? "$rawValue"
                            : "${(rawValue * 2.20462).round()}",
                        style: TextStyle(
                          fontSize: SizeConfig.sp(12),
                          color: isSelected ? Colors.orange : Colors.grey[400],
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _calculateWidth(rawValue, isSelected),
                    height: _calculateHeight(rawValue, isSelected),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.orange : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
