import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeflow/appBar/custom_app_bar.dart';
import 'package:timeflow/BottomNavBar/bottom_nav_bar.dart';
import 'package:timeflow/constants/app_colors.dart';
import 'package:timeflow/routes/app_routes.dart';
import 'package:timeflow/statistics/statistics_view_model.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 1; // Statistik ist der zweite Tab

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatisticsViewModel>().loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Navigation zu anderen Seiten
    if (index == 0) {
      Navigator.pushNamed(context, AppRoutes.dashboard);
    } else if (index == 2) {
      Navigator.pushNamed(context, AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: const CustomAppBar(title: 'Statistik'),
          body: Column(
            children: [
              // Tab Bar
              Container(
                color: AppColors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'Arbeitszeiten'),
                    Tab(text: 'Pausen'),
                    Tab(text: 'Urlaube'),
                  ],
                ),
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildWorkTimesTab(vm),
                    _buildBreaksTab(vm),
                    _buildHolidaysTab(vm),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTap: _onNavTap,
          ),
        );
      },
    );
  }

  Widget _buildWorkTimesTab(StatisticsViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.workTimes.isEmpty) {
      return const Center(
        child: Text(
          'Keine Arbeitszeiten vorhanden',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vm.workTimes.length,
      itemBuilder: (context, index) {
        final workTime = vm.workTimes[index];
        final duration =
            workTime.endTime != null
                ? workTime.endTime!.difference(workTime.startTime)
                : Duration.zero;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.work_outline, color: AppColors.primary),
            title: Text(
              '${workTime.startTime.day}.${workTime.startTime.month}.${workTime.startTime.year}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${workTime.startTime.hour.toString().padLeft(2, '0')}:${workTime.startTime.minute.toString().padLeft(2, '0')} - ${workTime.endTime != null ? '${workTime.endTime!.hour.toString().padLeft(2, '0')}:${workTime.endTime!.minute.toString().padLeft(2, '0')}' : 'läuft...'}',
            ),
            trailing: Text(
              '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBreaksTab(StatisticsViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.breaks.isEmpty) {
      return const Center(
        child: Text(
          'Keine Pausen vorhanden',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vm.breaks.length,
      itemBuilder: (context, index) {
        final breakItem = vm.breaks[index];
        final duration =
            breakItem.endTime != null
                ? breakItem.endTime!.difference(breakItem.startTime)
                : Duration.zero;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(
              Icons.coffee_outlined,
              color: AppColors.warning,
            ),
            title: Text(
              '${breakItem.startTime.day}.${breakItem.startTime.month}.${breakItem.startTime.year}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${breakItem.startTime.hour.toString().padLeft(2, '0')}:${breakItem.startTime.minute.toString().padLeft(2, '0')} - ${breakItem.endTime != null ? '${breakItem.endTime!.hour.toString().padLeft(2, '0')}:${breakItem.endTime!.minute.toString().padLeft(2, '0')}' : 'läuft...'}',
            ),
            trailing: Text(
              '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.warning,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHolidaysTab(StatisticsViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Übersicht Card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'Urlaubsübersicht',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildHolidayStat(
                    'Verfügbar',
                    '${vm.getAvailableHolidayDays()} Tage',
                    AppColors.success,
                  ),
                  _buildHolidayStat(
                    'Genommen',
                    '${vm.getUsedHolidayDays()} Tage',
                    AppColors.warning,
                  ),
                  _buildHolidayStat('Gesamt', '30 Tage', AppColors.primary),
                ],
              ),
            ],
          ),
        ),

        // Urlaubsliste
        Expanded(
          child:
              vm.holidays.isEmpty
                  ? const Center(
                    child: Text(
                      'Keine Urlaube vorhanden',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vm.holidays.length,
                    itemBuilder: (context, index) {
                      final holiday = vm.holidays[index];
                      final duration =
                          holiday.endDate.difference(holiday.startDate).inDays +
                          1;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(
                            Icons.beach_access_outlined,
                            color: AppColors.success,
                          ),
                          title: Text(
                            holiday.description ?? 'Urlaub',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${holiday.startDate.day}.${holiday.startDate.month}.${holiday.startDate.year} - ${holiday.endDate.day}.${holiday.endDate.month}.${holiday.endDate.year}',
                          ),
                          trailing: Text(
                            '$duration Tage',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildHolidayStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// Wrapper widget to provide StatisticsViewModel
class StatisticsViewWrapper extends StatelessWidget {
  const StatisticsViewWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StatisticsViewModel(),
      child: const StatisticsView(),
    );
  }
}
