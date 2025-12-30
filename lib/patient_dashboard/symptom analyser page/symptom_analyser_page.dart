import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_chatbot/common/app_background.dart';
import 'package:health_chatbot/models/medical_record.dart';
// ADD THIS IMPORT for camera access
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SymptomAnalyserPage extends StatefulWidget {
  const SymptomAnalyserPage({super.key});

  @override
  State<SymptomAnalyserPage> createState() => _SymptomAnalyserPageState();
}

class _SymptomAnalyserPageState extends State<SymptomAnalyserPage> {
  // --- CONTROLLERS & STATE ---
  final _symptomsController = TextEditingController();
  final _dobController = TextEditingController();
  final _allergiesController = TextEditingController();
  String? _gender;
  String? _bloodGroup;
  File? _symptomImage;
  bool _isAnalysing = false;
  String? _analysisResult;
  DateTime? _analysisTimestamp;

  @override
  void dispose() {
    _symptomsController.dispose();
    _dobController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  // --- UI ACTIONS ---
  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _pickImageFromFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _symptomImage = File(result.files.single.path!);
      });
    }
  }

  // NEW: Method to pick an image from the camera
  void _pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _symptomImage = File(photo.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _symptomImage = null;
    });
  }

  void _startAnalysis() {
    if (_symptomsController.text.isEmpty && _symptomImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe your symptoms or add an image.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() {
      _isAnalysing = true;
      _analysisResult = null; // Clear previous results
    });

    Future.delayed(const Duration(seconds: 3), () {
      _showMockAnalysis();
    });
  }

  void _showMockAnalysis() {
    const mockResponse = 'Based on the symptoms described, potential '
        'considerations could include seasonal allergies or a common cold. '
        'Common symptoms like sneezing, runny nose, and coughing are present. '
        'However, for a definitive diagnosis, it is crucial to consult with a '
        'healthcare professional. They can conduct a thorough examination and '
        'provide an accurate diagnosis.';

    setState(() {
      _analysisResult = mockResponse;
      _analysisTimestamp = DateTime.now();
      _isAnalysing = false;
    });
  }

  // --- PDF & WALLET LOGIC ---
  Future<Uint8List> _generatePdfBytes() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          _buildPdfHeader(_analysisTimestamp),
          _buildPdfSection(
            'Patient Information',
            [
              _buildPdfInfoRow('Date of Birth:', _dobController.text),
              _buildPdfInfoRow('Gender:', _gender ?? 'Not specified'),
              _buildPdfInfoRow('Blood Group:', _bloodGroup ?? 'Not specified'),
              _buildPdfInfoRow('Known Allergies:', _allergiesController.text),
            ],
          ),
          _buildPdfSection(
            'Symptoms Described',
            [
              pw.Paragraph(
                textAlign: pw.TextAlign.center,
                text: _symptomsController.text.isNotEmpty
                    ? _symptomsController.text
                    : 'No symptoms described.',
              ),
            ],
          ),
          _buildPdfSection(
            'AI Analysis Result',
            [
              pw.Text(
                'Disclaimer: This is an AI-generated analysis and not a substitute for professional medical advice.',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColors.red,
                ),
              ),
              pw.Divider(height: 20),
              pw.Paragraph(
                textAlign: pw.TextAlign.center,
                text: _analysisResult ?? 'No result available.',
              ),
            ],
          ),
          if (_symptomImage != null) ...[
            pw.NewPage(),
            _buildPdfSection(
              'Attached Image',
              [
                pw.Center(
                  child: pw.Image(
                      pw.MemoryImage(_symptomImage!.readAsBytesSync())),
                ),
              ],
            ),
          ]
        ],
      ),
    );
    return pdf.save();
  }

  pw.Widget _buildPdfHeader(DateTime? timestamp) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text('NuroCare AI Symptom Analysis Report',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text(
            'Generated on: ${DateFormat('dd MMM yyyy, hh:mm a').format(timestamp ?? DateTime.now())}'),
        pw.Divider(height: 24, thickness: 1),
      ],
    );
  }

  pw.Widget _buildPdfSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        ...children,
        pw.SizedBox(height: 24),
      ],
    );
  }

  pw.Widget _buildPdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(value.isNotEmpty ? value : 'N/A'),
        ],
      ),
    );
  }

  Future<void> _printAnalysis() async {
    final pdfBytes = await _generatePdfBytes();
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes);
  }

  Future<void> _addToWallet() async {
    final pdfBytes = await _generatePdfBytes();
    final tempDir = await getTemporaryDirectory();
    final fileName =
        'AI_Report_${DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now())}.pdf';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(pdfBytes);

    final newRecord = MedicalRecord(
      title: 'AI Analysis Report',
      date: DateTime.now(),
      icon: Icons.analytics_outlined,
      filePath: file.path,
    );

    final prefs = await SharedPreferences.getInstance();
    final recordsJson = prefs.getString('grouped_medical_records');
    Map<String, List<dynamic>> groupedRecords = {};

    if (recordsJson != null) {
      groupedRecords = Map<String, List<dynamic>>.from(jsonDecode(recordsJson));
    }

    List<dynamic> myRecords = groupedRecords['My Records'] ?? [];
    myRecords.insert(0, newRecord.toJson());
    groupedRecords['My Records'] = myRecords;

    await prefs.setString(
        'grouped_medical_records', jsonEncode(groupedRecords));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report successfully saved to your Wallet'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // --- UI WIDGETS ---
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
          appBar: _CustomAppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- ADDITION START ---
                const _DisclaimerBanner(),
                const SizedBox(height: 24),
                // --- ADDITION END ---
                _buildBlueChipTitle('Ai Symptom Anlyser:'),
                const SizedBox(height: 24),
                _buildSectionTitle('1. Background Information:'),
                const SizedBox(height: 16),
                _buildTappableField(
                  hint: _dobController.text.isEmpty
                      ? 'DD/MM/YYYY'
                      : _dobController.text,
                  icon: Icons.calendar_today_outlined,
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                          'Gender', ['Male', 'Female', 'Other'], _gender,
                          (val) {
                        setState(() => _gender = val);
                      }),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownField(
                          'Blood Gr..',
                          ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
                          _bloodGroup, (val) {
                        setState(() => _bloodGroup = val);
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _allergiesController,
                  hint: 'Known Allergies (Optional)',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('2. Describe Your Syptoms:'),
                const SizedBox(height: 16),
                _buildSymptomInputArea(), // Restored Widget
                const SizedBox(height: 24),
                _buildAnalyseButton(),
                const SizedBox(height: 24),
                if (_isAnalysing || _analysisResult != null) ...[
                  _buildBlueChipTitle('Analyser Result:'),
                  const SizedBox(height: 16),
                  _buildResultContent(),
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlueChipTitle(String title) {
    String part1 = '';
    String part2 = '';

    if (title.contains('Anlyser:')) {
      part1 = 'Ai Symptom ';
      part2 = 'Anlyser:';
    } else if (title.contains('Result:')) {
      part1 = 'Analyser ';
      part2 = 'Result:';
    } else {
      part1 = title;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2EB5FA),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2EB5FA).withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            shadows: [
              Shadow(
                blurRadius: 2.0,
                color: Colors.black26,
                offset: Offset(0, 2.0),
              )
            ],
          ),
          children: <TextSpan>[
            TextSpan(text: part1),
            if (part2.isNotEmpty)
              TextSpan(
                text: part2,
                style: const TextStyle(
                  color: Color(0xFF76E8E8),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          color: Color(0xFF3F3F3F),
          fontWeight: FontWeight.bold,
          fontSize: 16,
          shadows: [
            Shadow(
              blurRadius: 1.0,
              color: Colors.black26,
              offset: Offset(0, 1.0),
            )
          ]),
    );
  }

  Widget _buildTappableField(
      {required String hint,
      required IconData icon,
      required VoidCallback onTap}) {
    final bool isDefaultHint = hint == 'DD/MM/YYYY';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF76E8E8),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF76E8E8).withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              hint,
              style: TextStyle(
                color: isDefaultHint ? Colors.grey.shade700 : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                shadows: const [
                  Shadow(
                    blurRadius: 1.0,
                    color: Colors.black26,
                    offset: Offset(0, 1.0),
                  )
                ],
              ),
            ),
            Icon(
              icon,
              color: isDefaultHint ? Colors.grey.shade700 : Colors.white,
              shadows: const [
                Shadow(
                  blurRadius: 1.0,
                  color: Colors.black26,
                  offset: Offset(0, 1.0),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(String hint, List<String> items, String? value,
      ValueChanged<String?> onChanged) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF76E8E8),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF76E8E8).withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          dropdownColor: const Color(0xFF76E8E8),
          style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  blurRadius: 1.0,
                  color: Colors.black26,
                  offset: Offset(0, 1.0),
                )
              ]),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller, required String hint}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  // THIS IS THE RESTORED WIDGET WITH THE CAMERA ICON ADDED
  Widget _buildSymptomInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD7F1FF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF76E8E8).withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _symptomsController,
            maxLines: 1,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              hintText: 'e.g., "I have a sore throat, headache..."',
              hintStyle: TextStyle(color: Colors.black12),
              border: InputBorder.none,
            ),
          ),
          const Divider(color: Colors.black45),
          if (_symptomImage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _symptomImage!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                      child: Text('Image attached',
                          style: TextStyle(color: Colors.white))),
                  IconButton(
                    icon:
                        const Icon(Icons.cancel, color: Colors.white, size: 20),
                    onPressed: _removeImage,
                  )
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon:
                    const Icon(Icons.camera_alt_outlined, color: Colors.black),
                onPressed: _pickImageFromCamera,
                tooltip: 'Open Camera',
              ),
              IconButton(
                icon: const Icon(Icons.attach_file, color: Colors.black),
                onPressed: _pickImageFromFile,
                tooltip: 'Attach Image from Gallery',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyseButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _isAnalysing ? null : _startAnalysis,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2EB5FA),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
          elevation: 5,
        ),
        child: _isAnalysing
            ? const CupertinoActivityIndicator(color: Colors.white)
            : const Text(
                'Analyse Symptoms',
                style: TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  Widget _buildResultContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isAnalysing)
            const Center(child: CupertinoActivityIndicator())
          else if (_analysisResult != null) ...[
            Text(
              _analysisResult!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ResultActionButton(
                    icon: Icons.print_outlined,
                    label: 'Print',
                    onTap: _printAnalysis),
                _ResultActionButton(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Save',
                    onTap: _addToWallet),
              ],
            )
          ]
        ],
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF76E8E8), // Important for the gradient
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      elevation: 0,
      title: const Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.analytics_outlined, color: Color(0xFF6DD8FE)),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NuroCare',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 17)),
              Text('Symptom Analyser',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ResultActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ResultActionButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }
}

// --- NEW WIDGET ADDED HERE ---
class _DisclaimerBanner extends StatelessWidget {
  const _DisclaimerBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Semi-transparent white background to blend in
        color: const Color(0xFFD9534F).withAlpha(940),
        borderRadius: BorderRadius.circular(12),
        // Subtle border to define the shape
        border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.5),
        boxShadow: [
          // Soft shadow to lift it off the background
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded, // Using a more neutral 'info' icon
            color: Colors.red, // A deep but soft blue
            size: 24,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'This tool is for informational purposes only and does not provide medical advice, diagnosis, or treatment. It is not a substitute for professional healthcare. If you are experiencing a medical emergency, call your local emergency services (e.g., 911) immediately.',
              style: TextStyle(
                color: Color.fromARGB(
                    255, 218, 220, 221), // Darker, more readable text
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
