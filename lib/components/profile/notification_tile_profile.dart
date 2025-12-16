import 'package:flutter/material.dart';
import '../../utils/size_config.dart';

class NotificationTile extends StatefulWidget {
  final String title;
  final bool initialValue;
  final ValueChanged<bool>? onChanged;
  final GestureTapCallback? onTap;

  const NotificationTile({
    super.key,
    required this.title,
    this.initialValue = false,
    this.onChanged,
    this.onTap,
  });

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: SizeConfig.w(16),
          vertical: SizeConfig.h(8),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.w(18),
          vertical: SizeConfig.h(8),
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.35),
          borderRadius: BorderRadius.circular(SizeConfig.w(18)),
          border: Border.all(
            color: Colors.black.withOpacity(0.05),
            width: SizeConfig.w(1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: SizeConfig.w(8),
              offset: Offset(0, SizeConfig.h(4)),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: SizeConfig.w(42),
              height: SizeConfig.w(42),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_rounded,
                color: Colors.orange,
                size: SizeConfig.w(22),
              ),
            ),
            SizedBox(width: SizeConfig.w(14)),
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: SizeConfig.h(16),
                  fontWeight: FontWeight.w300,
                  color: Colors.black87,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            Switch.adaptive(
              value: _isEnabled,
              onChanged: (val) {
                setState(() => _isEnabled = val);
                widget.onChanged?.call(val);
              },
              activeColor: Colors.orange,
              inactiveTrackColor: Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}
