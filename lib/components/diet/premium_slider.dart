import 'package:flutter/material.dart';

class PremiumSlider extends StatefulWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final Function(double) onChanged;
  final String unit;
  final bool isDarkMode;

  const PremiumSlider({
    Key? key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.unit = '',
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  State<PremiumSlider> createState() => _PremiumSliderState();
}

class _PremiumSliderState extends State<PremiumSlider> {
  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.black54;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: TextStyle(
                color: subTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              child: Text(
                "${widget.value.toInt()}${widget.unit}",
                style: const TextStyle(
                  color: Colors.blueAccent, // Premium accent
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.blueAccent,
              inactiveTrackColor: widget.isDarkMode ? Colors.white10 : Colors.grey.shade300,
              thumbColor: Colors.white,
              trackHeight: 4.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0, elevation: 5),
              overlayColor: Colors.blueAccent.withOpacity(0.2),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Slider(
              value: widget.value,
              min: widget.min,
              max: widget.max,
              onChanged: widget.onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
