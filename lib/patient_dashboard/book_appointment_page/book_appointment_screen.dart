// lib/patient_dashboard/book_appointment_page/book_appointment_screen.dart

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:health_chatbot/common/app_background.dart';
import 'package:health_chatbot/patient_dashboard/Doctor%20Explore%20Page/specialization_screen.dart';
import 'package:health_chatbot/patient_dashboard/book_appointment_page/select_time_screen.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  // Your original state variables are preserved
  String? _selectedHospital;
  String _selectedSpeciality = 'Search for a Speciality';
  String? _selectedDoctor;

  final TextEditingController hospitalSearchController =
      TextEditingController();
  final TextEditingController doctorSearchController = TextEditingController();

  // Dummy data lists from your original code
  final List<String> hospitalItems = [
    'Sal Hospital of Sola',
    'Government Hospital',
    'Zydus Hospital',
    'Apollo Hospital',
    'Sterling Hospital',
  ];

  final List<String> doctorItems = [
    'Dr. Gaurang Patel',
    'Dr. Sweeta Bhatt',
    'Dr. John Doe',
    'Dr. Jane Smith',
    'Dr. Emily White',
  ];

  String _selectedTime = '00:00 DD/MM/YYYY';

  @override
  void dispose() {
    hospitalSearchController.dispose();
    doctorSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2EB5FA),
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        backgroundColor: const Color(0xFF76E8E8),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFF38B6FF),
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
                      fontSize: 20),
                ),
                Text(
                  'Book Appointment',
                  style: TextStyle(color: Colors.black87, fontSize: 15),
                ),
              ],
            ),
          ],
        ),
      ),
      // Use the new custom AppBar
      body: Stack(
        children: [
          const AppBackground(), // Your original background is preserved
          Container(
            // Your original gradient overlay
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF2EB5FA).withAlpha(150),
                  Colors.white.withAlpha(150),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- FIX: Booking Form wrapped in a Card ---
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC0EEFF).withAlpha(400),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: _buildBookingForm(),
                ),
                const SizedBox(height: 24),
                // --- FIX: Upcoming Appointments wrapped in a Card ---
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC0EEFF).withAlpha(400),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Upcoming Appointments',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A3A3A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildAppointmentCard(
                        doctor: 'Dr. Gaurang Patel',
                        speciality: 'Psychologist',
                        date: 'DD/MM/YYYY',
                        time: '00:00',
                      ),
                      const SizedBox(height: 16),
                      _buildAppointmentCard(
                        doctor: 'Dr. Sweta Bhatt',
                        speciality: 'Psychologist',
                        date: 'DD/MM/YYYY',
                        time: '00:00',
                      ),
                      const SizedBox(height: 16),
                      _buildAppointmentCard(
                        doctor: 'Dr. Moksha Patel',
                        speciality: 'Psychologist',
                        date: 'DD/MM/YYYY',
                        time: '00:00',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS UPDATED TO MATCH THE NEW STRUCTURE ---

  Widget _buildBookingForm() {
    // This widget now only returns the Column, as the Container is outside
    return Column(
      children: [
        _buildSearchableDropdown(
          label: 'Select Hospital',
          hint: 'Search for a Hospital',
          items: hospitalItems,
          value: _selectedHospital,
          onChanged: (val) => setState(() => _selectedHospital = val),
          searchController: hospitalSearchController,
        ),
        const SizedBox(height: 16),
        _buildNavigatorField(
          label: 'Select Speciality',
          value: _selectedSpeciality,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const SpecializationScreen()),
            );
            if (result != null && result is String) {
              setState(() {
                _selectedSpeciality = result;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        _buildSearchableDropdown(
          label: 'Select Doctor',
          hint: 'Search for a Doctor',
          items: doctorItems,
          value: _selectedDoctor,
          onChanged: (val) => setState(() => _selectedDoctor = val),
          searchController: doctorSearchController,
        ),
        const SizedBox(height: 16),
        _buildTimeSelector(),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF38B6FF),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 5,
          ),
          child: const Text(
            'Book Appointment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard({
    required String doctor,
    required String speciality,
    required String date,
    required String time,
  }) {
    // FIX: Layout and style changed to match the image
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFAEFFE9), // Inner green color
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black),
                ),
                const SizedBox(height: 8),
                Text('Speciality: $speciality',
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Date: $date',
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Timing: $time',
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD7F1FF),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: const Text('Reschedule'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC4FDFD),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- UNCHANGED ORIGINAL HELPER WIDGETS ---

  Widget _buildNavigatorField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final bool isHint = value == 'Search for a Speciality';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF3A3A3A),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFC4FDFD),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: isHint ? Colors.grey.shade600 : Colors.black,
                  ),
                ),
                Icon(Icons.search, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchableDropdown({
    required String label,
    required String hint,
    required List<String> items,
    String? value,
    required ValueChanged<String?> onChanged,
    required TextEditingController searchController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF3A3A3A),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            hint: Text(
              hint,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            items: items
                .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ))
                .toList(),
            value: value,
            onChanged: onChanged,
            buttonStyleData: ButtonStyleData(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFC4FDFD),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 40,
            ),
            dropdownSearchData: DropdownSearchData(
              searchController: searchController,
              searchInnerWidgetHeight: 50,
              searchInnerWidget: Container(
                height: 50,
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 4,
                  right: 8,
                  left: 8,
                ),
                child: TextFormField(
                  expands: true,
                  maxLines: null,
                  controller: searchController,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    hintText: 'Search...',
                    hintStyle: const TextStyle(fontSize: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              searchMatchFn: (item, searchValue) {
                return item.value
                    .toString()
                    .toLowerCase()
                    .contains(searchValue.toLowerCase());
              },
            ),
            onMenuStateChange: (isOpen) {
              if (!isOpen) {
                searchController.clear();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Time',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF3A3A3A),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          // The onTap action is now changed to navigate
          onTap: () async {
            // Navigate to SelectTimeScreen and wait for a result
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SelectTimeScreen()),
            );

            // If the user selects a time and comes back, the result will not be null
            if (result != null && result is String) {
              setState(() {
                _selectedTime =
                    result; // Update the display with the selected time
              });
            }
          },
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFC4FDFD),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedTime,
                  style: TextStyle(
                    fontSize: 14,
                    color: _selectedTime == '00:00 DD/MM/YYYY'
                        ? Colors.grey.shade600
                        : Colors.black,
                  ),
                ),
                Icon(Icons.calendar_month_outlined,
                    color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
