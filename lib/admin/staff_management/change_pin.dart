import 'package:flutter/material.dart';
import 'package:hospital_app/theme/app_colors.dart';
import 'package:hospital_app/theme/app_textstyles.dart';

class ChangePin extends StatefulWidget {
  final String oldPin;

  const ChangePin({super.key, required this.oldPin});

  @override
  State<ChangePin> createState() => _ChangePinState();
}

class _ChangePinState extends State<ChangePin> {
  final oldPinCtrl = TextEditingController();
  final newPinCtrl = TextEditingController();
  final confirmPinCtrl = TextEditingController();

  bool showOld = false;
  bool showNew = false;
  bool showConfirm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Change PIN",
          style: app_textstyles.appBarTitle.copyWith(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// OLD PIN
              Text(
                "Enter Old PIN",
                style: app_textstyles.body.copyWith(fontSize: 15),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: oldPinCtrl,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: !showOld,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Old PIN',
                  suffixIcon: IconButton(
                    icon: Icon(
                      showOld ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        showOld = !showOld;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// NEW PIN
              Text(
                "Create New PIN",
                style: app_textstyles.body.copyWith(fontSize: 15),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: newPinCtrl,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: !showNew,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'New PIN',
                  suffixIcon: IconButton(
                    icon: Icon(
                      showNew ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        showNew = !showNew;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// CONFIRM PIN
              Text(
                "Confirm New PIN",
                style: app_textstyles.body.copyWith(fontSize: 15),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: confirmPinCtrl,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: !showConfirm,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Confirm PIN',
                  suffixIcon: IconButton(
                    icon: Icon(
                      showConfirm ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        showConfirm = !showConfirm;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// SAVE BUTTON
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    /// OLD PIN CHECK
                    if (oldPinCtrl.text != widget.oldPin) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Wrong old PIN")),
                      );
                      return;
                    }

                    /// LENGTH CHECK
                    if (newPinCtrl.text.length != 4) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("PIN must be 4 digit")),
                      );
                      return;
                    }

                    /// MATCH CHECK
                    if (newPinCtrl.text != confirmPinCtrl.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("PIN does not match")),
                      );
                      return;
                    }

                    /// SUCCESS
                    Navigator.pop(context, newPinCtrl.text);
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,

                    padding: EdgeInsets.symmetric(horizontal: 90, vertical: 14),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ).copyWith(
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),

                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),

                      // normal gradient
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF8BCAFE),
                          Color(0xFF70AADE),
                        ],
                      ),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        "Save",
                        style: app_textstyles.appBarTitle.copyWith(
                          fontSize: 18,
                          color: Colors.white,
                        ),
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

  @override
  void dispose() {
    oldPinCtrl.dispose();
    newPinCtrl.dispose();
    confirmPinCtrl.dispose();
    super.dispose();
  }
}
