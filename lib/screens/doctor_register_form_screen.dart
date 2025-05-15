import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restart_app/restart_app.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import '../services/firebase_services.dart';

class DoctorRegisterFormScreen extends StatefulWidget {
  const DoctorRegisterFormScreen({super.key});

  @override
  State<DoctorRegisterFormScreen> createState() =>
      _DoctorRegisterFormScreenState();
}

class _DoctorRegisterFormScreenState extends State<DoctorRegisterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseServices _services = FirebaseServices();
  final FirebaseStorage storage = FirebaseStorage.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  File? imagePicked;
  String? imgUrl;

  final nameController = TextEditingController(text: "Lata Grover Bisht");
  final specializationController = TextEditingController(text: "Homeopathy");
  final mondayTimings = TextEditingController(text: "09:00AM - 06:00PM");
  final tuesdayTimings = TextEditingController(text: "09:00AM - 06:00PM");
  final wednesdayTimings = TextEditingController(text: "09:00AM - 06:00PM");
  final thursdayTimings = TextEditingController(text: "09:00AM - 06:00PM");
  final fridayTimings = TextEditingController(text: "09:00AM - 06:00PM");
  final saturdayTimings = TextEditingController(text: "09:00AM - 06:00PM");
  final sundayTimings = TextEditingController(text: "Closed");
  final aboutMeController = TextEditingController(
      text:
          "Dr. Sweta is a highly skilled cardiologist with years of experience in diagnosing and treating various cardiovascular conditions. She is a compassionate and caring doctor who takes the time to listen to her patients and understand their concerns. Dr. Sweta is known for her expertise in the field of cardiology and her ability to provide personalized care to each of her patients. She is committed to staying up-to-date with the latest advancements in cardiovascular medicine and uses the most advanced techniques and technologies to provide the best possible care.");

  Future<void> pickImage() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          imagePicked = File(pickedImage.path);
        });
      } else {
        Fluttertoast.showToast(msg: "No image selected");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Image picker error: $e");
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (imagePicked == null) {
        Fluttertoast.showToast(msg: "Please select a profile image");
      }

      final progressDialog = ProgressDialog(context: context);
      progressDialog.show(
        max: 100,
        msg: "Uploading Image...",
        progressValueColor: const Color.fromRGBO(70, 212, 153, 1),
        progressBgColor: Colors.white,
      );

      try {
        final ref = storage
            .ref()
            .child("uploads/doctor_profile_picture/doctor_${user?.uid}");

        final uploadTask = ref.putFile(imagePicked!);

        uploadTask.snapshotEvents.listen((event) {
          final progress = event.bytesTransferred / event.totalBytes * 100;
          progressDialog.update(value: progress.toInt());
        });

        final snapshot = await uploadTask.timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            progressDialog.close();
            Fluttertoast.showToast(
                msg: "Upload timed out", backgroundColor: Colors.greenAccent);
            throw TimeoutException("Upload timed out");
          },
        );

        imgUrl = await snapshot.ref.getDownloadURL();
        progressDialog.close();

        await _services.registerDoctorProfile(
          doctorId: user?.uid,
          doctorName: nameController.text,
          doctorSpecialization: specializationController.text,
          doctorAbout: aboutMeController.text,
          doctorProfilePic: imgUrl ?? "",
          mondayTiming: mondayTimings.text,
          tuesdayTiming: tuesdayTimings.text,
          wednesdayTiming: wednesdayTimings.text,
          thursdayTiming: thursdayTimings.text,
          fridayTiming: fridayTimings.text,
          saturdayTiming: saturdayTimings.text,
          sundayTiming: sundayTimings.text,
        );

        Fluttertoast.showToast(
          msg: "Profile successfully updated",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        await Future.delayed(const Duration(seconds: 2));
        Restart.restartApp();
      } catch (e) {
        progressDialog.close();
        Fluttertoast.showToast(
          msg: "Upload failed: ${e.toString()}",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(70, 212, 153, 1),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Doctor Registration"),
            centerTitle: true,
            backgroundColor: const Color.fromRGBO(70, 212, 153, 1),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: imagePicked != null
                          ? FileImage(imagePicked!)
                          : const AssetImage("assets/images/blank_profile.png")
                              as ImageProvider,
                      child: const Align(
                        alignment: Alignment.bottomRight,
                        child: CircleAvatar(
                          backgroundColor: Color.fromRGBO(70, 212, 153, 1),
                          radius: 18,
                          child:
                              Icon(Icons.edit, size: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildTextField("Full Name", nameController),
                  buildTextField("Specialization", specializationController),
                  buildTextField("About Me", aboutMeController, maxLines: 3),
                  const Divider(),
                  const Text("Consultation Timings",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  buildTextField("Monday", mondayTimings),
                  buildTextField("Tuesday", tuesdayTimings),
                  buildTextField("Wednesday", wednesdayTimings),
                  buildTextField("Thursday", thursdayTimings),
                  buildTextField("Friday", fridayTimings),
                  buildTextField("Saturday", saturdayTimings),
                  buildTextField("Sunday", sundayTimings),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(70, 212, 153, 1),
                          ),
                          onPressed: () {
                            submitForm();
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              "SUBMIT FORM",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        validator: (val) => val == null || val.isEmpty ? "Required" : null,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
