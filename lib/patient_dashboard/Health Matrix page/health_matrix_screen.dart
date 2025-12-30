// frontend/patient_dashboard/Health Matrix page/health_matrix_screen.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:health_chatbot/common/app_background.dart';

class HealthMatrixScreen extends StatefulWidget {
  const HealthMatrixScreen({super.key});

  @override
  State<HealthMatrixScreen> createState() => _HealthMatrixScreenState();
}

class _HealthMatrixScreenState extends State<HealthMatrixScreen> {
  // Hardcoded values for display
  final double _pulse = 80;
  final double _spo2 = 98;
  final double _water = 0.8;
  final double _calories = 35;

  // Data for the pedometer chart design
  final List<double> _weeklySteps = [1500, 2100, 1550, 1000, 1700, 2300, 1500];

  String _indexesFilter = 'Today';
  final List<String> _indexesOptions = ['Today', 'Yesterday', 'This Week'];

  String _pedometerFilter = 'Past Week';
  final List<String> _pedometerOptions = ['Past Week', 'Past Month'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2EB5FA),
      appBar: _CustomAppBar(),
      body: Stack(
        children: [
          const AppBackground(), // Your doodle background
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  const Color(0xFF2EB5FA).withAlpha(450),
                  Colors.white.withAlpha(450),
                ])),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // --- Indexes Section Card ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC0EEFF).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSectionHeader(
                          "Indexes",
                          _indexesFilter,
                          _indexesOptions,
                          (newValue) {
                            if (newValue != null) {
                              setState(() {
                                _indexesFilter = newValue;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildIndexesGrid(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // --- Pedometer Section Card ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC0EEFF).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSectionHeader(
                          "Pedometer",
                          _pedometerFilter,
                          _pedometerOptions,
                          (newValue) {
                            if (newValue != null) {
                              setState(() {
                                _pedometerFilter = newValue;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildPedometerChart(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String selectedValue,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
              items: options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIndexesGrid() {
    return LayoutBuilder(builder: (context, constraints) {
      double cardWidth = (constraints.maxWidth - 16) / 2;
      return Wrap(
        spacing: 16.0,
        runSpacing: 16.0,
        alignment: WrapAlignment.center,
        children: [
          _StatCard(
            width: cardWidth,
            title: "Pulse",
            value: _pulse.toStringAsFixed(0),
            unit: "BPM",
            icon: Icons.show_chart_rounded,
          ),
          _StatCard(
            width: cardWidth,
            title: "SpO2",
            value: _spo2.toStringAsFixed(0),
            unit: "%",
            icon: Icons.show_chart_rounded,
          ),
          _StatCard(
            width: cardWidth,
            title: "Water",
            value: _water.toStringAsFixed(1),
            unit: "liters",
            icon: Icons.water_drop_outlined,
          ),
          _StatCard(
            width: cardWidth,
            title: "Calories",
            value: _calories.toStringAsFixed(0),
            unit: "kcal",
            icon: Icons.local_fire_department_outlined,
          ),
        ],
      );
    });
  }

  // --- FIX: THIS IS THE ONLY WIDGET THAT HAS BEEN CHANGED ---
  Widget _buildPedometerChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(8, 24, 24, 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 2500,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const style = TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold);
                  String text;
                  switch (value.toInt()) {
                    case 0:
                      text = 'Sun';
                      break;
                    case 1:
                      text = 'Mon';
                      break;
                    case 2:
                      text = 'Tue';
                      break;
                    case 3:
                      text = 'Wed';
                      break;
                    case 4:
                      text = 'Thu';
                      break;
                    case 5:
                      text = 'Fri';
                      break;
                    case 6:
                      text = 'Sat';
                      break;
                    default:
                      text = '';
                      break;
                  }
                  return SideTitleWidget(
                      axisSide: meta.axisSide, child: Text(text, style: style));
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value % 500 == 0) {
                    return Text('${value.toInt()}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left);
                  }
                  return const Text('');
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey[400]!, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            7,
            (index) {
              final isLightBlue = index % 2 == 0;
              final color = isLightBlue
                  ? const Color(0xFFD7F1FF)
                  : const Color(0xFF76E8E8);
              final borderColor = isLightBlue
                  ? const Color(0xFF87CEFA)
                  : const Color(0xFF4682B4);

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: _weeklySteps[index],
                    // Use a gradient to create the border effect
                    gradient: LinearGradient(
                      colors: [borderColor, color],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    width: 20,
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    borderSide: BorderSide(color: borderColor, width: 2),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF76E8E8),
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              color: Color(0xFF6DD8FE),
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NuroCare',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                'Health Matrix',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}

class _StatCard extends StatelessWidget {
  final double width;
  final String title;
  final String value;
  final String unit;
  final IconData icon;

  const _StatCard({
    required this.width,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD7F1FF),
        borderRadius: BorderRadius.circular(20),
        // --- Dark border is preserved ---
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                // --- Made text darker and bolder ---
                style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              Icon(icon, color: Colors.black87, size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                // --- Made text darker and bolder ---
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                // --- Made text darker and bolder ---
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
