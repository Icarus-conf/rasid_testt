import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive/hive.dart';
import 'package:rasid_test/Core/util/custom_btn.dart';
import 'package:rasid_test/Core/util/custom_text_field.dart';

class HomeViewBody extends StatefulWidget {
  const HomeViewBody({super.key});

  @override
  State<HomeViewBody> createState() => _HomeViewBodyState();
}

class _HomeViewBodyState extends State<HomeViewBody> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  DateTime? selectedBirthday;
  String? jobRole;
  String? experience;
  String? educationLevel;
  bool offlineMode = false;
  String connectivityMessage = '';
  String? cvFilePath;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _streamSubscription;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();

    _streamSubscription = _connectivity.onConnectivityChanged.listen((result) {
      _handleConnectivityChange(result);
    });
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  Future<void> _checkInitialConnectivity() async {
    List<ConnectivityResult> connectivityResults =
        await _connectivity.checkConnectivity();
    _handleConnectivityChange(connectivityResults);
  }

  void _handleConnectivityChange(List<ConnectivityResult> connectivityResults) {
    setState(() {
      offlineMode = connectivityResults.contains(ConnectivityResult.none);
    });

    if (!offlineMode) {
      if (connectivityResults.contains(ConnectivityResult.mobile)) {
        log("Mobile network available.");
      } else if (connectivityResults.contains(ConnectivityResult.wifi)) {
        log("Wi-Fi is available.");
      }

      _submitStoredData();
    }
  }

  Future<void> _submitStoredData() async {
    var box = await Hive.openBox('offlineData');
    if (box.containsKey('formData')) {
      Map<String, dynamic>? storedData = box.get('formData');
      String? storedCvPath = box.get('cvFilePath');

      await submitToFirebase(storedData!, storedCvPath);

      box.delete('formData');
      box.delete('cvFilePath');
      setState(() {
        cvFilePath = null;
      });
    }
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedBirthday ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedBirthday) {
      setState(() {
        selectedBirthday = picked;
      });
    }
  }

  Future<void> _pickCV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        cvFilePath = result.files.first.path;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("CV selected successfully!"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Application"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text("Full Name"),
            CustomTextField(
              controller: nameController,
              hintText: "Enter your full name",
            ),
            const Gap(12),
            const Text("Email"),
            CustomTextField(
              controller: emailController,
              hintText: "Enter your email",
            ),
            const Gap(12),
            const Text("Phone Number"),
            CustomTextField(
              controller: phoneController,
              hintText: "Enter your phone number",
            ),
            const Gap(12),
            const Text("Choose your birthday"),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedBirthday == null
                          ? 'Select Birthday'
                          : '${selectedBirthday!.day}/${selectedBirthday!.month}/${selectedBirthday!.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectBirthday(context),
                  ),
                ],
              ),
            ),
            const Gap(12),
            const Text("Select your job title"),
            DropdownButtonFormField<String>(
              value: jobRole,
              items: ["Developer", "Designer", "Manager"]
                  .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => jobRole = value),
              decoration: InputDecoration(
                hintText: "Job Role",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const Gap(12),
            const Text("Select your job experience"),
            DropdownButtonFormField<String>(
              value: experience,
              items: ["Junior", "Mid-level", "Senior"]
                  .map((exp) => DropdownMenuItem(
                        value: exp,
                        child: Text(exp),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => experience = value),
              decoration: InputDecoration(
                hintText: "Experience Level",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const Gap(12),
            const Text("Select your education degree"),
            DropdownButtonFormField<String>(
              value: educationLevel,
              items: ["High School", "Bachelor's", "Master's"]
                  .map((edu) => DropdownMenuItem(
                        value: edu,
                        child: Text(edu),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => educationLevel = value),
              decoration: InputDecoration(
                hintText: "Education Level",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const Gap(12),
            Row(
              children: [
                CustomBtn(onPressed: _pickCV, text: "Pick your CV"),
                const Gap(16),
                const Text(
                  "Please pick your cv..",
                ),
              ],
            ),
            if (cvFilePath != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Selected CV: ${cvFilePath!.split('/').last}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            CustomBtn(onPressed: submitForm, text: "Submit"),
          ],
        ),
      ),
    );
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      final formData = {
        "name": nameController.text,
        "email": emailController.text,
        "phone": phoneController.text,
        "birthday": selectedBirthday?.toIso8601String(),
        "jobRole": jobRole,
        "experience": experience,
        "educationLevel": educationLevel,
        "submittedAt": DateTime.now().toIso8601String(),
      };

      await saveDataOffline(formData);

      if (offlineMode) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("You are offline. Data will be submitted when online."),
        ));
      } else {
        await submitToFirebase(formData, cvFilePath);
      }
    }
  }

  Future<void> saveDataOffline(Map<String, dynamic> formData) async {
    var box = await Hive.openBox('offlineData');
    box.put('formData', formData);
    box.put('cvFilePath', cvFilePath);
  }

  Future<void> submitToFirebase(
      Map<String, dynamic> formData, String? cvFilePath) async {
    final docRef = FirebaseFirestore.instance
        .collection('applications')
        .doc(emailController.text);

    if (cvFilePath != null) {
      String fileName =
          'CVs/${emailController.text}/${DateTime.now().millisecondsSinceEpoch}.pdf';
      File file = File(cvFilePath);
      try {
        await FirebaseStorage.instance.ref(fileName).putFile(file);
        formData['cvUrl'] =
            await FirebaseStorage.instance.ref(fileName).getDownloadURL();
      } catch (e) {
        log("Error uploading CV: $e");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Error uploading CV."),
        ));
      }
    }

    await docRef.set(formData, SetOptions(merge: true));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Form submitted successfully!"),
    ));
  }
}
