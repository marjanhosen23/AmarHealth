import 'package:flutter/material.dart';
import 'package:hospital_app/patient/serial/waiting_time.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SerialInput extends StatefulWidget {
  final Map<String, dynamic> doctor;
  final String hospital;

  const SerialInput({
    super.key,
    required this.doctor,
    required this.hospital,
  });

  @override
  State<SerialInput> createState() => _SerialInputState();
}

class _SerialInputState extends State<SerialInput> {

  final TextEditingController serialCtrl = TextEditingController();

  @override
  void dispose() {
    serialCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text("Serial",style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold
        ),),
      ),

      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),

            //  glass style background
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.7),
                Colors.white.withOpacity(0.3),
              ],
            ),

            border: Border.all(
              color: Colors.white.withOpacity(0.5),
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Text(
                "আপনার সিরিয়াল নম্বর",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              ///  Input Field
              TextField(
                controller: serialCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,

                decoration: InputDecoration(
                  hintText: "Serial Number",
                  hintStyle: TextStyle(color: Colors.grey),

                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Color(0xFF8CCBFF), // 🔵 blue border
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Color(0xFF6FA8DC), // 🔵 darker blue
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              ///  Button (Glass Style)
              GestureDetector(
                onTap: () async {
                  if (serialCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Serial number দিন")),
                    );
                    return;
                  }

                  final serial = serialCtrl.text;
                  final hospitalKey = widget.hospital.trim().toLowerCase();

                  await FirebaseFirestore.instance
                      .collection('hospitals')
                      .doc(hospitalKey)
                      .collection('serials')
                      .doc(widget.doctor['name'])
                      .collection('queue')
                      .doc(serial)
                      .set({
                    "serial": serial,
                    "time": DateTime.now().toString(),
                  });

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WaitingTime(
                        doctor: widget.doctor,
                        hospital: widget.hospital,
                        serial: serial,
                      ),
                    ),
                  );
                },

                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),

                    // glass gradient
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF8CCBFF),
                        Color(0xFF6FA8DC),
                      ],
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),

                  child: const Center(
                    child: Text(
                      "দেখুন",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}