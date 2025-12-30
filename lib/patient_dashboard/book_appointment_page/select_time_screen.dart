// lib/patient_dashboard/book_appointment_page/select_time_screen.dart
import 'package:flutter/material.dart';

class SelectTimeScreen extends StatefulWidget {
  const SelectTimeScreen({super.key});

  @override
  State<SelectTimeScreen> createState() => _SelectTimeScreenState();
}

class _SelectTimeScreenState extends State<SelectTimeScreen> {
  // --- STATE MANAGEMENT FOR DYNAMIC CALENDAR ---
  late DateTime _selectedDateTime;
  late List<DateTime> _daysInMonth;
  late int _selectedDateIndex;

  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with the current date
    _selectedDateTime = DateTime.now();
    _daysInMonth = [];
    // Set the selected date index to today's date minus one
    _selectedDateIndex = _selectedDateTime.day - 1;
    // Populate the calendar for the initial month
    _updateCalendarDates();
  }

  /// Calculates and updates the list of days for the currently selected month and year.
  void _updateCalendarDates() {
    setState(() {
      _daysInMonth =
          _getDaysInMonth(_selectedDateTime.year, _selectedDateTime.month);
      // Safety check: if the new month has fewer days, adjust the selected index.
      if (_selectedDateIndex >= _daysInMonth.length) {
        _selectedDateIndex = _daysInMonth.length - 1;
      }
    });
  }

  /// Returns a list of DateTime objects for each day in a given month and year.
  List<DateTime> _getDaysInMonth(int year, int month) {
    final firstDayOfMonth = DateTime(year, month, 1);
    // The '0' day of the next month gives the last day of the current month.
    final lastDayOfMonth = DateTime(year, month + 1, 0);
    final List<DateTime> days = [];
    for (int i = 0; i < lastDayOfMonth.day; i++) {
      days.add(firstDayOfMonth.add(Duration(days: i)));
    }
    return days;
  }

  /// Converts a weekday number (1=Mon, 7=Sun) to a 3-letter string.
  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // The UI structure remains the same as your original code
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _CustomAppBar(),
      body: Column(
        children: [
          _buildDateSelector(),
          const SizedBox(height: 24),
          Expanded(child: _buildTimeline()),
        ],
      ),
    );
  }

  // --- WIDGET WITH DYNAMIC LOGIC ---
  Widget _buildDateSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _months[_selectedDateTime.month - 1],
                    icon: const Icon(Icons.arrow_drop_down),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          final newMonthIndex = _months.indexOf(newValue) + 1;
                          _selectedDateTime =
                              DateTime(_selectedDateTime.year, newMonthIndex);
                          _updateCalendarDates();
                        });
                      }
                    },
                    items:
                        _months.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    selectedItemBuilder: (BuildContext context) {
                      return _months.map<Widget>((String item) {
                        return Text(
                          _months[_selectedDateTime.month - 1],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                Icon(Icons.calendar_today_outlined, color: Colors.grey[600]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 65,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              // FIX: Use the dynamic _daysInMonth list
              itemCount: _daysInMonth.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                // FIX: Get data from the dynamic list of DateTime objects
                final date = _daysInMonth[index];
                final dayName = _getWeekdayName(date.weekday);
                final dayNumber = date.day.toString();
                final isSelected = index == _selectedDateIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDateIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF8FE1FF)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayName, // DYNAMIC DATA
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dayNumber, // DYNAMIC DATA
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    // No changes needed here, it remains a simulation as per your code
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const _TimelineSlot(
          time: '8:00 AM',
          child: _AppointmentCard(
            status: 'Ongoing',
            details: 'Finish at 8:30',
            statusColor: Color(0xFFF9E4D4),
            borderColor: Color(0xFFF9E4D4),
          ),
        ),
        const _TimelineSlot(
          time: '8:30 AM',
          child: _AppointmentCard(
            status: 'Booked',
            details: 'Finish at 12:00',
            statusColor: Color(0xFFE2E2E2),
            borderColor: Color(0xFFE2E2E2),
          ),
        ),
        const _TimelineSlot(
          time: '12:00 AM',
          child: _AppointmentCard.lunch(),
        ),
        _TimelineSlot(
          time: '1:30 PM',
          child: _AppointmentCard.selectable(
              status: 'Empty',
              details: 'you can book',
              onSelect: () {
                final selectedDay = _daysInMonth[_selectedDateIndex];
                final formattedDate =
                    "1:30 PM, ${_getWeekdayName(selectedDay.weekday)} ${selectedDay.day} ${_months[selectedDay.month - 1]}";
                Navigator.pop(context, formattedDate);
              }),
        ),
        const _TimelineSlot(
          time: '2:00 PM',
          child: _AppointmentCard(
            status: 'Booked',
            details: 'Finish at 2:30',
            statusColor: Color(0xFFE2E2E2),
            borderColor: Color(0xFFE2E2E2),
          ),
        ),
        _TimelineSlot(
          time: '2:30 PM',
          child: _AppointmentCard.selectable(
              status: 'Empty',
              details: 'you can book',
              onSelect: () {
                final selectedDay = _daysInMonth[_selectedDateIndex];
                final formattedDate =
                    "2:30 PM, ${_getWeekdayName(selectedDay.weekday)} ${selectedDay.day} ${_months[selectedDay.month - 1]}";
                Navigator.pop(context, formattedDate);
              }),
        ),
        _TimelineSlot(
          time: '3:00 PM',
          child: _AppointmentCard.selectable(
              status: 'Canceled',
              details: 'you can book',
              onSelect: () {
                final selectedDay = _daysInMonth[_selectedDateIndex];
                final formattedDate =
                    "3:00 PM, ${_getWeekdayName(selectedDay.weekday)} ${selectedDay.day} ${_months[selectedDay.month - 1]}";
                Navigator.pop(context, formattedDate);
              }),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// Your existing _CustomAppBar (unchanged)
class _CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF76E8E8),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2EB5FA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'Select',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              ' Time',
              style: TextStyle(
                  color: Color(0xFF76E8E8),
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            )
          ],
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}

// Your existing _TimelineSlot (unchanged)
class _TimelineSlot extends StatelessWidget {
  final String time;
  final Widget child;

  const _TimelineSlot({required this.time, required this.child});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              time,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: child,
          )),
        ],
      ),
    );
  }
}

// --- THIS WIDGET IS NOW CORRECTED ---
class _AppointmentCard extends StatelessWidget {
  final String status;
  final String details;
  final IconData? icon;
  final Color statusColor;
  final Color borderColor;
  final Color iconColor;
  final bool isSelectable;
  final VoidCallback? onSelect;

  // --- FIX: The main constructor now initializes all final variables ---
  const _AppointmentCard({
    required this.status,
    required this.details,
    required this.statusColor,
    required this.borderColor,
    this.icon, // Made optional with default values
    this.iconColor = Colors.black, // Default color
    this.isSelectable = false, // Default value
    this.onSelect,
  });

  // FIX: This named constructor now correctly initializes all fields.
  const _AppointmentCard.lunch()
      : status = 'Lunch Break',
        details = 'Finish at 1:30',
        icon = Icons.restaurant_menu,
        statusColor = const Color(0xFFC0EEFF),
        borderColor = const Color(0xFF8FE1FF),
        iconColor = const Color(0xFF38B6FF),
        isSelectable = false,
        onSelect = null;

  // FIX: This named constructor now correctly initializes all fields.
  const _AppointmentCard.selectable(
      {required this.status, required this.details, this.onSelect})
      : icon = null,
        statusColor = Colors.white,
        borderColor = const Color(0xFFE2E2E2),
        iconColor = Colors.black,
        isSelectable = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: iconColor),
                const SizedBox(width: 12),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    details,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isSelectable)
            ElevatedButton(
              onPressed: onSelect,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC0EEFF),
                foregroundColor: const Color(0xFF38B6FF),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: const BorderSide(color: Color(0xFF8FE1FF)),
              ),
              child: const Text(
                'Select',
                style: TextStyle(color: Colors.black),
              ),
            ),
        ],
      ),
    );
  }
}
