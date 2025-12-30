// frontend/doctor_model.dart

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String location;
  final String hospital;
  final String experience;
  final String availability;
  final String initials;
  double rating;
  int reviewCount;
  final String phone;
  final int age;
  final String gender;
  final bool isVerified;
  final double distance; // <-- 1. ADD THIS NEW FIELD

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.location,
    required this.hospital,
    required this.experience,
    required this.availability,
    required this.initials,
    required this.rating,
    required this.reviewCount,
    required this.phone,
    required this.age,
    required this.gender,
    this.isVerified = false,
    required this.distance, // <-- 2. ADD THIS TO THE CONSTRUCTOR
  });

  void updateRating(int newRating) {
    double totalRating = (rating * reviewCount) + newRating;
    reviewCount++;
    rating = double.parse((totalRating / reviewCount).toStringAsFixed(1));
  }
}
