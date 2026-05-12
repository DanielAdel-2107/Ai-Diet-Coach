import 'package:ai_diet_coach/core/utils/colors/app_colors.dart';
import 'package:ai_diet_coach/core/utils/sizes/sized_config.dart';
import 'package:ai_diet_coach/core/utils/styles/app_text_styles.dart';
import 'package:ai_diet_coach/features/patient/sugar_tracking/models/sugar_level_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SugarChartSection extends StatefulWidget {
  final List<SugarLevelModel> levels;
  const SugarChartSection({super.key, required this.levels});

  @override
  State<SugarChartSection> createState() => _SugarChartSectionState();
}

class _SugarChartSectionState extends State<SugarChartSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0; // 0=All, 1=Before, 2=After

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedTab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<SugarLevelModel> get _filteredLevels {
    switch (_selectedTab) {
      case 1:
        return widget.levels.where((l) => l.mealTag == 'before_meal').toList();
      case 2:
        return widget.levels.where((l) => l.mealTag == 'after_meal').toList();
      default:
        return widget.levels;
    }
  }

  Color get _chartColor {
    switch (_selectedTab) {
      case 1:
        return const Color(0xFFF57C00);
      case 2:
        return AppColors.primary;
      default:
        return AppColors.chartBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.width * 0.05,
        vertical: SizeConfig.height * 0.015,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Row
            Padding(
              padding: EdgeInsets.fromLTRB(
                SizeConfig.width * 0.05,
                SizeConfig.height * 0.022,
                SizeConfig.width * 0.05,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Trend',
                        style: AppTextStyles.title18BlackBold,
                      ),
                      Text(
                        'Last ${_filteredLevels.length} readings',
                        style: AppTextStyles.title12Grey,
                      ),
                    ],
                  ),
                  // Average pill
                  if (_filteredLevels.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _chartColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Avg: ${(_filteredLevels.map((l) => l.level).reduce((a, b) => a + b) / _filteredLevels.length).toStringAsFixed(0)} mg/dL',
                        style: AppTextStyles.title12PrimaryColorW500.copyWith(
                          color: _chartColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: SizeConfig.height * 0.018),
            // Tab Filter
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.04),
              child: Container(
                height: 40,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: AppTextStyles.title12PrimaryColorW500.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  unselectedLabelStyle: AppTextStyles.title12Grey,
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.textPrimary,
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Before'),
                    Tab(text: 'After'),
                  ],
                ),
              ),
            ),
            SizedBox(height: SizeConfig.height * 0.022),
            // Chart
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: child,
              ),
              child: _filteredLevels.isEmpty
                  ? _buildEmptyChart()
                  : _buildChart(_filteredLevels, _chartColor),
            ),
            SizedBox(height: SizeConfig.height * 0.01),
            // Legend
            if (_filteredLevels.isNotEmpty) _buildLegend(),
            SizedBox(height: SizeConfig.height * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart() {
    return SizedBox(
      key: const ValueKey('empty'),
      height: SizeConfig.height * 0.2,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart_rounded,
              size: 36,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 8),
            Text('No data for this filter', style: AppTextStyles.title14Grey),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<SugarLevelModel> data, Color color) {
    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.level))
        .toList();

    final maxY = (data.map((l) => l.level).reduce((a, b) => a > b ? a : b) +
            40)
        .ceilToDouble();
    final minY = (data.map((l) => l.level).reduce((a, b) => a < b ? a : b) -
            20)
        .floorToDouble()
        .clamp(0.0, double.infinity);

    return SizedBox(
      key: ValueKey('chart_$_selectedTab'),
      height: SizeConfig.height * 0.26,
      child: Padding(
        padding: const EdgeInsets.only(right: 20, left: 10, bottom: 6),
        child: LineChart(
          LineChartData(
            minY: minY,
            maxY: maxY,
            // Normal range reference line at y=99
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: 99,
                  color: AppColors.success.withOpacity(0.4),
                  strokeWidth: 1.5,
                  dashArray: [6, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    labelResolver: (_) => 'Normal',
                  ),
                ),
                HorizontalLine(
                  y: 140,
                  color: AppColors.error.withOpacity(0.3),
                  strokeWidth: 1.5,
                  dashArray: [6, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    labelResolver: (_) => 'High',
                  ),
                ),
              ],
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: (maxY - minY) / 4,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.1),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: (maxY - minY) / 4,
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: AppTextStyles.title12Grey.copyWith(fontSize: 10),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= data.length) {
                      return const SizedBox.shrink();
                    }
                    final d = data[idx].createdAt;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${d.day}/${d.month}',
                        style:
                            AppTextStyles.title12Grey.copyWith(fontSize: 9.5),
                      ),
                    );
                  },
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => AppColors.textPrimary,
                getTooltipItems: (spots) => spots
                    .map(
                      (s) => LineTooltipItem(
                        '${s.y.toStringAsFixed(0)} mg/dL',
                        AppTextStyles.title12WhiteBold,
                      ),
                    )
                    .toList(),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.35,
                color: color,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, idx) =>
                      FlDotCirclePainter(
                    radius: 4,
                    color: color,
                    strokeWidth: 2.5,
                    strokeColor: Colors.white,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.25),
                      color.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.width * 0.05),
      child: Row(
        children: [
          _legendDot(AppColors.success, 'Normal (70–99)'),
          SizedBox(width: SizeConfig.width * 0.06),
          _legendDot(AppColors.error, 'High (>140)'),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.title12Grey.copyWith(fontSize: 11)),
      ],
    );
  }
}
