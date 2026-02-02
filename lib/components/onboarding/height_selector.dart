import 'package:flutter/material.dart';
import '../../utils/size_config.dart';

class HeightSelector extends StatefulWidget {
  final double initialHeight;
  final Function(double) onHeightChanged;
  final bool isCm;

  const HeightSelector({
    super.key,
    required this.initialHeight,
    required this.onHeightChanged,
    this.isCm = true,
  });

  @override
  State<HeightSelector> createState() => _HeightSelectorState();
}

class _HeightSelectorState extends State<HeightSelector> {
  final double _minCm = 100;
  final double _maxCm = 250;
  late int _itemCount;
  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _itemCount = (_maxCm - _minCm + 1).toInt();

    double heightCm = widget.isCm
        ? widget.initialHeight
        : widget.initialHeight * 2.54;
    _selectedIndex = (heightCm - _minCm).round().clamp(0, _itemCount - 1);

    _pageController = PageController(
      initialPage: _selectedIndex,
      viewportFraction: 0.12,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cmValue = (_minCm + _selectedIndex).round();
    final feetValue = (cmValue / 30.48).floor();
    final inchValue = ((cmValue / 2.54) - feetValue * 12).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: widget.isCm
              ? [
                  Text(
                    "$cmValue",
                    style: TextStyle(
                      fontSize: SizeConfig.sp(48),
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(width: SizeConfig.w(8)),
                  Padding(
                    padding: EdgeInsets.only(bottom: SizeConfig.h(10)),
                    child: Text(
                      "cm",
                      style: TextStyle(
                        fontSize: SizeConfig.sp(20),
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ]
              : [
                  Text(
                    "$feetValue",
                    style: TextStyle(
                      fontSize: SizeConfig.sp(48),
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: SizeConfig.h(10)),
                    child: Text(
                      "ft",
                      style: TextStyle(
                        fontSize: SizeConfig.sp(20),
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  SizedBox(width: SizeConfig.w(12)),
                  Text(
                    "$inchValue",
                    style: TextStyle(
                      fontSize: SizeConfig.sp(48),
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: SizeConfig.h(10)),
                    child: Text(
                      "in",
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
            widget.isCm ? "Metric (cm)" : "Imperial (ft/in)",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),

        SizedBox(height: SizeConfig.h(40)),

        SizedBox(
          height: SizeConfig.h(150),
          child: RotatedBox(
            quarterTurns: -1,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _itemCount,
              onPageChanged: (index) {
                setState(() => _selectedIndex = index);
                double heightCm = _minCm + index;
                widget.onHeightChanged(
                  widget.isCm ? heightCm : heightCm / 2.54,
                );
                widget.onHeightChanged(_minCm + index);
              },
              itemBuilder: (context, index) {
                final value = _minCm.toInt() + index;
                final isSelected = index == _selectedIndex;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (value % 10 == 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: RotatedBox(
                          quarterTurns: 1,
                          child: Text(
                            "$value",
                            style: TextStyle(
                              fontSize: isSelected ? 14 : 10,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.green
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isSelected ? 14 : 6,
                      height: value % 10 == 0
                          ? (isSelected ? 100 : 80)
                          : (isSelected ? 60 : 40),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green : Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
