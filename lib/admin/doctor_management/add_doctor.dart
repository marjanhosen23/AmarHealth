import 'package:flutter/material.dart';
import 'package:hospital_app/theme/app_colors.dart';
import 'package:hospital_app/theme/app_textstyles.dart';

class AddDoctor extends StatefulWidget {
  final String? name;
  final String? dept;
  final String? time;

  const AddDoctor({this.name, this.dept, this.time, super.key});

  @override
  State<AddDoctor> createState() => _AddDoctorState();
}

class _AddDoctorState extends State<AddDoctor> {
  final nameCtrl = TextEditingController();
  final timeCtrl = TextEditingController();
  final deptCtrl = TextEditingController();

  final List<String> departments = [
    'General Medicine',
    'General Surgery',
    'Pediatrics',
    'Obstetrics & Gynecology',
    'Orthopedics',
    'Cardiology',
    'Neurology',
    'Pulmonology',
    'Gastroenterology',
    'Nephrology',
    'Urology',
    'Dermatology',
    'Psychiatry',
    'Ophthalmology',
    'ENT',
    'Endocrinology',
    'Rheumatology',
    'Hematology',
    'Oncology',
    'Infectious Diseases',
  ];

  @override
  void initState() {
    super.initState();
    nameCtrl.text = widget.name ?? '';
    timeCtrl.text = widget.time ?? '';
    deptCtrl.text = widget.dept ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Doctor',
          style: app_textstyles.appBarTitle.copyWith(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Name
              Text('Doctor Name'),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.7),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF8BCAFE)),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF70AADE), width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// Dept
              Text('Department'),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) {
                      return ListView(
                        children: departments.map((d) {
                          return ListTile(
                            title: Text(d),
                            onTap: () {
                              deptCtrl.text = d;
                              Navigator.pop(context);
                            },
                          );
                        }).toList(),
                      );
                    },
                  );
                },
                child: TextField(
                  controller: deptCtrl,
                  enabled: false,
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.arrow_drop_down),

                    filled: true,
                    fillColor: Colors.white.withOpacity(0.7),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF8BCAFE)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// Time
              Text('Avg Time'),
              TextField(controller: timeCtrl),

              const SizedBox(height: 30),

              /// SAVE BUTTON
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'name': nameCtrl.text,
                      'dept': deptCtrl.text,
                      'time': timeCtrl.text,
                    });
                  },
                  style:
                      ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ).copyWith(
                        overlayColor: MaterialStateProperty.all(
                          Colors.transparent,
                        ),
                      ),

                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),

                      gradient: LinearGradient(
                        colors: [Color(0xFF8BCAFE), Color(0xFF70AADE)],
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
