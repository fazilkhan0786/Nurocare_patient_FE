// 1. IMPORT YOUR APP BACKGROUND WIDGET
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_chatbot/common/app_background.dart';
import 'package:health_chatbot/patient_dashboard/Doctor%20Explore%20Page/doctor_model.dart';
import 'package:health_chatbot/patient_dashboard/Doctor%20Explore%20Page/specialization_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 2. DEFINE THE CORRECT COLOR PALETTE
const Color kPrimaryGreen = Color(0xFF76E8E8);
const Color kPrimaryBlue = Color(0xFF2EB5FA);
const Color kLightBlue = Color(0xFFD7F1FF);
const Color kLightGreen = Color(0xFFC4FDFD);

// --- Main Screen Widget ---
class ExploreDoctorScreen extends StatefulWidget {
  const ExploreDoctorScreen({super.key});

  @override
  State<ExploreDoctorScreen> createState() => _ExploreDoctorScreenState();
}

class _ExploreDoctorScreenState extends State<ExploreDoctorScreen> {
  late List<Doctor> _allDoctors;
  List<Doctor> _filteredDoctors = [];
  final TextEditingController _searchController = TextEditingController();

  bool _isNearbyEnabled = false;
  String _selectedSpecialty = 'All';

  // The set now holds the state loaded from device storage.
  final Set<String> _ratedDoctorIds = {};

  @override
  void initState() {
    super.initState();
    // Initialize the doctor list here
    _allDoctors = [
      Doctor(
          id: 'doc1',
          name: 'Dr. Evelyn Reed',
          specialty: 'Dermatologist',
          location: 'Sola Ahmedabad',
          hospital: 'Sal Hospital',
          experience: '12+ Years',
          availability: 'Next: Today 3:00 PM',
          initials: 'ER',
          rating: 4.8,
          reviewCount: 210,
          phone: '+1 123 456 7890',
          age: 45,
          gender: 'Female',
          isVerified: true,
          distance: 2.5),
      Doctor(
          id: 'doc2',
          name: 'Dr. Benjamin Carter',
          specialty: 'Cardiologist',
          location: 'Navrangpura',
          hospital: 'Apollo Hospital',
          experience: '15+ Years',
          availability: 'Next: Tomorrow 10:00 AM',
          initials: 'BC',
          rating: 4.9,
          reviewCount: 340,
          phone: '+1 234 567 8901',
          age: 52,
          gender: 'Male',
          isVerified: true,
          distance: 5.1),
      Doctor(
          id: 'doc3',
          name: 'Dr. Olivia Martinez',
          specialty: 'Pediatrician',
          location: 'Vastrapur',
          hospital: 'CIMS Hospital',
          experience: '10+ Years',
          availability: 'Next: Fri, 2:00 PM',
          initials: 'OM',
          rating: 4.7,
          reviewCount: 180,
          phone: '+1 345 678 9012',
          age: 41,
          gender: 'Female',
          isVerified: true,
          distance: 1.2),
      Doctor(
          id: 'doc4',
          name: 'Dr. Liam Goldberg',
          specialty: 'General Practitioner (GP)',
          location: 'Bodakdev',
          hospital: 'Zydus Hospital',
          experience: '8+ Years',
          availability: 'Next: Today 5:00 PM',
          initials: 'LG',
          rating: 4.5,
          reviewCount: 155,
          phone: '+1 456 789 0123',
          age: 38,
          gender: 'Male',
          isVerified: true,
          distance: 8.7),
      Doctor(
          id: 'doc5',
          name: 'Dr. Sophia Patel',
          specialty: 'Neurologist',
          location: 'Satellite',
          hospital: 'Sterling Hospital',
          experience: '14+ Years',
          availability: 'Next: Sat, 11:00 AM',
          initials: 'SP',
          rating: 4.9,
          reviewCount: 280,
          phone: '+1 567 890 1234',
          age: 49,
          gender: 'Female',
          isVerified: true,
          distance: 4.3),
    ];
    _applyAllFilters();
    _searchController.addListener(_applyAllFilters);

    _loadRatedDoctorIds();
  }

  Future<void> _loadRatedDoctorIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ratedIds = prefs.getStringList('ratedDoctorIds') ?? [];
    setState(() {
      _ratedDoctorIds.addAll(ratedIds);
    });
  }

  Future<void> _saveRatedDoctorId(String doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    _ratedDoctorIds.add(doctorId);
    await prefs.setStringList('ratedDoctorIds', _ratedDoctorIds.toList());
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyAllFilters);
    _searchController.dispose();
    super.dispose();
  }

  void _applyAllFilters() {
    final String query = _searchController.text.toLowerCase();
    setState(() {
      List<Doctor> tempDoctors = List.from(_allDoctors);

      if (query.isNotEmpty) {
        tempDoctors = tempDoctors.where((doctor) {
          return doctor.name.toLowerCase().contains(query) ||
              doctor.specialty.toLowerCase().contains(query) ||
              doctor.hospital.toLowerCase().contains(query);
        }).toList();
      }

      if (_selectedSpecialty != 'All') {
        tempDoctors = tempDoctors.where((doctor) {
          return doctor.specialty == _selectedSpecialty;
        }).toList();
      }

      if (_isNearbyEnabled) {
        tempDoctors.sort((a, b) => a.distance.compareTo(b.distance));
      }

      _filteredDoctors = tempDoctors;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const AppBackground(),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xCC2EB5FA).withAlpha(380),
                const Color(0xCCFFFFFF),
              ],
              stops: const [0.4, 1.0],
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: kPrimaryGreen,
            elevation: 0,
            automaticallyImplyLeading: false,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            title: const Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child:
                      FaIcon(FontAwesomeIcons.userDoctor, color: kPrimaryBlue),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NuroCare',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Text("Explore Doctor's",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              _buildSearchBarAndFilter(),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredDoctors.length,
                  itemBuilder: (context, index) {
                    return _buildDoctorCard(_filteredDoctors[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBarAndFilter() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: kLightBlue,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryBlue.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search doctor, specialty...',
                hintStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.8), fontSize: 14),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.grey, size: 26),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => _showFilterDialog(),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: kPrimaryBlue,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryBlue.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(FontAwesomeIcons.sliders,
                color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  void _showFilterDialog() {
    bool tempIsNearby = _isNearbyEnabled;
    String tempSpecialty = _selectedSpecialty;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text('Filters', textAlign: TextAlign.center),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Nearby'),
                    value: tempIsNearby,
                    onChanged: (bool value) {
                      setDialogState(() {
                        tempIsNearby = value;
                      });
                    },
                    activeThumbColor: kPrimaryBlue,
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Speciality'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(tempSpecialty,
                            style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SpecializationScreen()),
                      );
                      if (result != null && result is String) {
                        setDialogState(() {
                          tempSpecialty = result;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child:
                      const Text('Clear', style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    setDialogState(() {
                      tempIsNearby = false;
                      tempSpecialty = 'All';
                    });
                  },
                ),
                TextButton(
                  child: const Text('Apply'),
                  onPressed: () {
                    setState(() {
                      _isNearbyEnabled = tempIsNearby;
                      _selectedSpecialty = tempSpecialty;
                    });
                    _applyAllFilters();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRatingDialog(Doctor doctor) {
    if (_ratedDoctorIds.contains(doctor.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have already rated this doctor.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    double tempRating = doctor.rating;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Rate Dr. ${doctor.name}', textAlign: TextAlign.center),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < tempRating ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                    size: 35,
                  ),
                  onPressed: () {
                    setDialogState(() {
                      tempRating = index + 1.0;
                    });
                  },
                );
              }),
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Submit'),
                onPressed: () {
                  final int doctorIndex =
                      _allDoctors.indexWhere((d) => d.id == doctor.id);
                  if (doctorIndex != -1) {
                    final currentTotalRating = _allDoctors[doctorIndex].rating *
                        _allDoctors[doctorIndex].reviewCount;
                    final newReviewCount =
                        _allDoctors[doctorIndex].reviewCount + 1;
                    final newAverageRating =
                        (currentTotalRating + tempRating) / newReviewCount;

                    setState(() {
                      _allDoctors[doctorIndex].rating = newAverageRating;
                      _allDoctors[doctorIndex].reviewCount = newReviewCount;
                      _saveRatedDoctorId(doctor.id);
                      _applyAllFilters();
                    });
                  }
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thank you for your feedback!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            ],
          );
        });
      },
    );
  }

  // --- Doctor Card (MODIFIED to use Initials) ---
  Widget _buildDoctorCard(Doctor doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: kLightGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // --- Left Column: Avatar & Rating ---
            SizedBox(
              width: 70,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // MODIFICATION: Using Initials instead of an image
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: Text(
                        doctor.initials,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showRatingDialog(doctor),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          doctor.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // --- Right Column: Details ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Doctor Name and Verified Icon
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              doctor.specialty,
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      if (doctor.isVerified)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.verified,
                              color: kPrimaryBlue, size: 20),
                        ),
                    ],
                  ),
                  // Location and Hospital
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              color: Colors.grey[600], size: 15),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Location: ${doctor.location}',
                              style: TextStyle(
                                  color: Colors.grey[800], fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(FontAwesomeIcons.hospital,
                              color: Colors.grey[600], size: 13),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Hospital: ${doctor.hospital}',
                              style: TextStyle(
                                  color: Colors.grey[800], fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Star Rating, Experience, and Distance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => _showRatingDialog(doctor),
                        child: Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              index < doctor.rating.floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.orange,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          "${doctor.distance} km away",
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: kPrimaryBlue),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Experience: ${doctor.experience}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
