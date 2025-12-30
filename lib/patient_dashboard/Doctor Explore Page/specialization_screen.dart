// frontend/specialization_screen.dart

import 'package:flutter/material.dart';

class SpecializationScreen extends StatefulWidget {
  const SpecializationScreen({super.key});

  @override
  State<SpecializationScreen> createState() => _SpecializationScreenState();
}

class _SpecializationScreenState extends State<SpecializationScreen> {
  final List<String> _allSpecialties = [
    'General Physician',
    'Family Medicine Doctor',
    'General Practitioner (GP)',
    'Internal Medicine Specialist',
    'Preventive Medicine Specialist',
    'Community Medicine Doctor',
    'Cardiologist',
    'Cardiothoracic Surgeon',
    'Vascular Surgeon',
    'Neurologist',
    'Neurosurgeon',
    'Neuropsychiatrist',
    'Neurophysiologist',
    'Ophthalmologist',
    'Retina Specialist',
    'Glaucoma Specialist',
    'Cornea Specialist',
    'Pediatric Ophthalmologist',
    'Oculoplastic Surgeon',
    'ENT Specialist (Otorhinolaryngologist)',
    'Audiologist',
    'Head and Neck Surgeon',
    'Laryngologist',
    'Rhinologist',
    'Orthopedic Surgeon',
    'Spine Surgeon',
    'Sports Medicine Specialist',
    'Joint Replacement Specialist',
    'Hand Surgeon',
    'Pediatric Orthopedic Surgeon',
    'Pediatrician',
    'Neonatologist',
    'Pediatric Cardiologist',
    'Pediatric Surgeon',
    'Pediatric Neurologist',
    'Pediatric Endocrinologist',
    'Gynecologist',
    'Obstetrician',
    'Fertility Specialist (Reproductive Endocrinologist)',
    'Gynecologic Oncologist',
    'Maternal-Fetal Medicine Specialist',
    'Urogynecologist',
    'Andrologist',
    'Urologist',
    'Hematologist',
    'Oncologist (Cancer Specialist)',
    'Surgical Oncologist',
    'Radiation Oncologist',
    'Pediatric Oncologist',
    'Gastroenterologist',
    'Hepatologist (Liver Specialist)',
    'Colorectal Surgeon',
    'Pulmonologist (Chest Specialist)',
    'Thoracic Surgeon',
    'Critical Care Specialist',
    'Endocrinologist',
    'Diabetologist',
    'Metabolic Specialist',
    'Infectious Disease Specialist',
    'Immunologist',
    'Allergist',
    'Tropical Medicine Specialist',
    'Nephrologist',
    'Kidney Transplant Specialist',
    'Dermatologist',
    'Cosmetologist',
    'Trichologist',
    'Aesthetic Medicine Specialist',
    'Plastic & Reconstructive Surgeon',
    'Dentist (General)',
    'Orthodontist',
    'Oral and Maxillofacial Surgeon',
    'Periodontist',
    'Endodontist',
    'Prosthodontist',
    'Pedodontist (Child Dentist)',
    'Psychiatrist',
    'Child Psychiatrist',
    'Clinical Psychologist',
    'Addiction Psychiatrist',
    'Pathologist',
    'Clinical Pathologist',
    'Microbiologist',
    'Biochemist',
    'Molecular Geneticist',
    'Forensic Pathologist',
    'Radiologist',
    'Interventional Radiologist',
    'Nuclear Medicine Specialist',
    'Physiotherapist',
    'Physical Medicine & Rehabilitation Specialist (Physiatrist)',
    'Pain Management Specialist',
    'Occupational Therapist',
    'Chiropractor',
    'Forensic Medicine Specialist',
    'Medicolegal Expert',
    'Public Health Specialist',
    'Epidemiologist',
    'Occupational Medicine Specialist',
    'Aerospace Medicine Specialist',
    'Sports Medicine Specialist',
    'Lifestyle Medicine Specialist',
    'Geriatric Specialist (Elderly Care)',
    'Palliative Care Specialist',
    'Sleep Medicine Specialist',
    'Genetic Counselor',
    'Clinical Pharmacologist',
    'Regenerative Medicine Specialist',
    'Stem Cell Specialist',
    'Transplant Surgeon',
    'Immuno-Oncologist',
    'Medical Geneticist',
    'Psychologist',
  ];

  List<String> _filteredSpecialties = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredSpecialties = _allSpecialties;
    _searchController.addListener(_filterList);
  }

  void _filterList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSpecialties = _allSpecialties.where((specialty) {
        return specialty.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Select Specialization',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color(0xFF76E8E8),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a specialization...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Colors.blueAccent,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _filteredSpecialties.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final specialty = _filteredSpecialties[index];
                return ListTile(
                  title: Text(specialty),
                  onTap: () {
                    // This correctly returns the selected specialty string
                    Navigator.pop(context, specialty);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
