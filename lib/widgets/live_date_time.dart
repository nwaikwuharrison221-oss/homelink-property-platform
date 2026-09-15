import 'dart:async';
import 'package:flutter/material.dart';

class LiveDateTime extends StatefulWidget {
  const LiveDateTime({super.key, this.textColor});

  final Color? textColor;

  @override
  State<LiveDateTime> createState() => _LiveDateTimeState();
}

class _LiveDateTimeState extends State<LiveDateTime> {
  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final materialLocalizations = MaterialLocalizations.of(context);

    final date = materialLocalizations.formatFullDate(_currentTime);

    final time = materialLocalizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(_currentTime),
      alwaysUse24HourFormat: false,
    );

    final color = widget.textColor ?? Colors.grey.shade700;

    return Column(
      children: [
        Text(
          date,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          time,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
