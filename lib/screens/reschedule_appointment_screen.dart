import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sn_progress_dialog/enums/progress_types.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import 'confirmation_page.dart';

class RescheduleAppointmentScreen extends StatefulWidget {
  const RescheduleAppointmentScreen(
      {super.key,
      this.patientName,
      this.patientPhoneNumber,
      this.documentId,
      this.patientEmailAddress});

  final String? patientName;
  final String? patientPhoneNumber;
  final String? documentId;
  final String? patientEmailAddress;

  @override
  State<RescheduleAppointmentScreen> createState() =>
      _RescheduleAppointmentScreenState();
}

class _RescheduleAppointmentScreenState
    extends State<RescheduleAppointmentScreen> {
  DateTime? date;
  TimeOfDay? time;
  bool loading = false;

  String getText() {
    if (date == null) {
      return 'Select Date';
    } else {
      return DateFormat('dd/MM/yyyy').format(date!);
    }
  }

  String getTimeText() {
    if (time == null) {
      return 'Select Time';
    } else {
      final hours = time?.hour.toString().padLeft(2, '0');
      final minutes = time?.minute.toString().padLeft(2, '0');
      return '$hours:$minutes';
    }
  }

  Future<void> bookAppointment() async {
    final ProgressDialog pr = ProgressDialog(context: context);
    pr.show(
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressType: ProgressType.determinate,
        max: 100,
        elevation: 10.0,
        msg: "Rescheduling...");

    String collectionName = "appointments";
    final hours = time?.hour.toString().padLeft(2, '0');
    final minutes = time?.minute.toString().padLeft(2, '0');

    final CollectionReference appointments =
        FirebaseFirestore.instance.collection(collectionName);

    final AudioPlayer audioPlayer = AudioPlayer();
    Future playAssetAudio() async {
      await audioPlayer.setAsset('assets/notification.mp3');
      audioPlayer.play();
    }

    if (date == null || time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Error ! Field(s) are missing",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // await pr.show(
      //     borderRadius: 10.0,
      //     backgroundColor: Colors.white,
      //     progressType: ProgressType.determinate,
      //     max: 100,
      //     elevation: 10.0,
      //     msg: "Rescheduling..."
      // );
      try {
        await appointments.doc(widget.documentId).update({
          "selectedTime": '$hours:$minutes',
          "selectedDate": DateFormat('dd/MM/yyyy').format(date!),
        });
        pr.close();
        playAssetAudio()
            .then((value) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Appointment Rescheduled Successfully",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.green,
                  ),
                ))
            .then(
              (value) => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const SuccessfullyBooked(bookingStatus: "Rescheduled"),
                ),
              ),
            );
      } catch (e) {
        print(e.toString());
      }
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return initWidget(context);
  }

  Widget initWidget(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (BuildContext context,
          AsyncSnapshot<List<ConnectivityResult>> snapshot) {
        if (snapshot.hasData && snapshot.data != ConnectivityResult.none) {
          return Container(
            color: const Color.fromRGBO(70, 212, 153, 1),
            child: SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  elevation: 0.0,
                  backgroundColor: const Color.fromRGBO(70, 212, 153, 1),
                  centerTitle: true,
                  leading: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                  actions: [
                    GestureDetector(
                      child: Container(
                        margin: const EdgeInsets.only(right: 15),
                        child: const Icon(
                          Icons.notifications_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                body: SingleChildScrollView(
                  reverse: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                            color: Color.fromRGBO(70, 212, 153, 1),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30))),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 30.0, top: 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "Name: ",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 22,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    "${widget.patientName}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text(
                                    "Phone Number: ",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "${widget.patientPhoneNumber}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text(
                                    'Email: ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${widget.patientEmailAddress}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 20, top: 30),
                        child: const Text(
                          'Reschedule Date',
                          style: TextStyle(
                            color: Color(0xff363636),
                            fontSize: 25,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.07,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(70, 212, 153, 0.8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20))),
                            onPressed: () => pickDate(context),
                            child: Text(
                              getText(),
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 20, top: 30),
                        child: const Text(
                          'Reschedule Time',
                          style: TextStyle(
                            color: Color(0xff363636),
                            fontSize: 25,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.07,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(70, 212, 153, 0.8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              pickTime(context);
                            },
                            child: Text(
                              getTimeText(),
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                bottomSheet: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff107163),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: () {
                        setState(() {
                          loading = true;
                        });
                        bookAppointment();
                      },
                      child: const Text(
                        "Reschedule Appointment",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: Icon(
                Icons.wifi_off,
                size: 100,
              ),
            ),
          );
        }
      },
    );
  }

  Future pickDate(BuildContext context) async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: date ?? initialDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (newDate == null) {
      return;
    }
    setState(() {
      date = newDate;
    });
  }

  Future pickTime(BuildContext context) async {
    const initialTime = TimeOfDay(hour: 9, minute: 0);
    final newTime = await showTimePicker(
        context: context, initialTime: time ?? initialTime);
    if (newTime == null) {
      return;
    }
    setState(() {
      time = newTime;
    });
  }
}
