import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeflow/constants/app_colors.dart';
import 'package:timeflow/holiday/holiday_view_model.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HolidayViewModel>().loadHolidays();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HolidayViewModel>(
      builder: (context, vm, _) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap:
              () =>
                  Navigator.of(
                    context,
                  ).pop(), // Klick außerhalb schließt Dialog
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Klick innerhalb blockiert Schließen
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 8,
                child: Container(
                  width: 340,
                  padding: const EdgeInsets.all(18),
                  child: _buildCardContent(vm),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardContent(HolidayViewModel vm) {
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
        const SizedBox(height: 8),

        // Verfügbare Urlaubstage
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(30),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Verfügbare Tage:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                '${vm.availableHolidayDays} / ${HolidayViewModel.totalHolidayDays}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        TableCalendar(
          focusedDay: _focusedDay,
          firstDay: DateTime.now(),
          lastDay: DateTime(DateTime.now().year + 2),
          rangeStartDay: _rangeStart,
          rangeEndDay: _rangeEnd,
          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: const {CalendarFormat.month: 'Monat'},
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
              if (_rangeStart == null ||
                  (_rangeStart != null && _rangeEnd != null)) {
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
          selectedDayPredicate:
              (day) =>
                  (_rangeStart != null && _rangeEnd != null)
                      ? (day.isAtSameMomentAs(_rangeStart!) ||
                          day.isAtSameMomentAs(_rangeEnd!) ||
                          (day.isAfter(_rangeStart!) &&
                              day.isBefore(_rangeEnd!)))
                      : (_rangeStart != null &&
                          day.isAtSameMomentAs(_rangeStart!)),
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
              Text(
                'Dauer: ${vm.calculateDaysForRange(_rangeStart!, _rangeEnd!)} Tage',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),

        // Fehlermeldung
        if (vm.errorMessage != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Text(
              vm.errorMessage!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
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
          onPressed:
              (_rangeStart != null && _rangeEnd != null && !vm.isLoading)
                  ? () async {
                    final success = await vm.createHoliday(
                      startDate: _rangeStart!,
                      endDate: _rangeEnd!,
                      description: null,
                    );

                    if (success) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Urlaub erfolgreich beantragt!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  }
                  : null,
          child:
              vm.isLoading
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Text(
                    'Urlaub beantragen',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
        ),
      ],
    );
  }
}

// Wrapper widget to provide HolidayViewModel
class HolidayViewWrapper extends StatelessWidget {
  const HolidayViewWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HolidayViewModel(),
      child: const HolidayView(),
    );
  }
}
