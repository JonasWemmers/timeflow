import 'package:flutter/material.dart';
import 'package:timeflow/constants/app_colors.dart';
import 'package:table_calendar/table_calendar.dart';

class HolidayView extends StatefulWidget {
  const HolidayView({super.key});

  @override
  State<HolidayView> createState() => _HolidayViewState();
}

class _HolidayViewState extends State<HolidayView> {
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => Navigator.of(context).pop(), // Klick außerhalb schließt Dialog
      child: Center(
        child: GestureDetector(
          onTap: () {}, // Klick innerhalb blockiert Schließen
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 8,
            child: Container(
              width: 340,
              padding: const EdgeInsets.all(18),
              child: _buildCardContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Urlaubsantrag',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 12),
        TableCalendar(
          focusedDay: _focusedDay,
          firstDay: DateTime.now(),
          lastDay: DateTime(DateTime.now().year + 2),
          rangeStartDay: _rangeStart,
          rangeEndDay: _rangeEnd,
          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: const {
            CalendarFormat.month: 'Monat',
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
              if (_rangeStart == null || (_rangeStart != null && _rangeEnd != null)) {
                _rangeStart = selectedDay;
                _rangeEnd = null;
              } else if (_rangeStart != null && _rangeEnd == null) {
                if (selectedDay.isBefore(_rangeStart!)) {
                  _rangeStart = selectedDay;
                } else {
                  _rangeEnd = selectedDay;
                }
              }
            });
          },
          onRangeSelected: (start, end, focusedDay) {
            setState(() {
              _rangeStart = start;
              _rangeEnd = end;
              _focusedDay = focusedDay;
            });
          },
          rangeSelectionMode: RangeSelectionMode.toggledOn,
          selectedDayPredicate: (day) =>
              (_rangeStart != null && _rangeEnd != null)
                  ? (day.isAtSameMomentAs(_rangeStart!) ||
                      day.isAtSameMomentAs(_rangeEnd!) ||
                      (day.isAfter(_rangeStart!) && day.isBefore(_rangeEnd!)))
                  : (_rangeStart != null && day.isAtSameMomentAs(_rangeStart!)),
          calendarStyle: CalendarStyle(
            rangeHighlightColor: AppColors.primary.withAlpha(60),
            rangeStartDecoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            rangeEndDecoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_rangeStart != null && _rangeEnd != null)
          Column(
            children: [
              Text(
                'Beginn: ${_rangeStart!.day}.${_rangeStart!.month}.${_rangeStart!.year}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Ende: ${_rangeEnd!.day}.${_rangeEnd!.month}.${_rangeEnd!.year}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: (_rangeStart != null && _rangeEnd != null)
              ? () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Urlaub beantragt!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              : null,
          child: const Text(
            'Urlaub beantragen',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
