
/*marjan hosen Oni
Daffodil international University
*/

import 'package:flutter/material.dart';
import 'package:hospital_app/theme/app_colors.dart';
import 'package:hospital_app/theme/app_textstyles.dart';

class AddStaff extends StatefulWidget {
  final String? name;
  final String? role;
  final String? pin;
  AddStaff({this.name,this.role,this.pin,super.key});


  @override
  State<AddStaff> createState() => _AddStaffState();
}

class _AddStaffState extends State<AddStaff> {
  final nameCtrl = TextEditingController();
  final pinCtrl = TextEditingController();

  String? selectedRole;
  final roleCtrl = TextEditingController();

  final List<String> role =[
    "Counter staff",
    "Nurse",
    "Reception",
  ];
  @override
  void initState()
  {
    super.initState();
    nameCtrl.text=widget.name ?? '';
    pinCtrl.text=widget.pin ?? '';
    roleCtrl.text = widget.role ?? '';
    selectedRole = widget.role;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset('assets/icons/arrow.png', color: Colors.white),
        ),
        title: Text(
          'Add New Staff',
          style: app_textstyles.appBarTitle.copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(child:
      Padding(padding: EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Staff Name",style: app_textstyles.body.copyWith(fontSize: 15),),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.7),

                hintText: 'Enter Staff Name',
                hintStyle: TextStyle(color: AppColors.hint_text, fontSize: 16),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.inputNormal_border,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Color(0xFF70AADE),
                    width: 2,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            Text('Role', style: app_textstyles.body),
            const SizedBox(height: 6),

            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) {
                    return ListView(
                      children: role.map((role) {
                        return ListTile(
                          title: Text(role),
                          onTap: () {
                            roleCtrl.text = role;
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    );
                  },
                );
              },
              child: TextField(
                controller: roleCtrl,
                enabled: false,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.7),

                  hintText: 'Select Role',
                  hintStyle: TextStyle(color: AppColors.hint_text, fontSize: 16),

                  suffixIcon: Icon(Icons.arrow_drop_down, size: 40),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.inputNormal_border,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            // PIN
            Text('Create PIN (4 digit)', style: app_textstyles.body),
            const SizedBox(height: 6),
            TextField(
              controller: pinCtrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                counterText: '',
                hintText: 'Enter PIN',
                hintStyle: TextStyle(
                  color: AppColors.hint_text,
                  fontSize: 16,
                ),

                filled: true,
                fillColor: Colors.white.withOpacity(0.7),

                /// NORMAL BORDER (black → replace)
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.inputNormal_border,
                  ),
                ),

                ///FOCUS BORDER
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.inputfocas_border,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            /// Save Button
            Center(
              child: GestureDetector(
                onTap: () {

                  if (nameCtrl.text.isEmpty ||
                      roleCtrl.text.isEmpty ||
                      pinCtrl.text.length != 4) {

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please fill all fields correctly'),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context, {
                    'name': nameCtrl.text,
                    'role': roleCtrl.text,
                    'pin': pinCtrl.text,
                  });
                },
                child: Container(
                  width: 160,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),

                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF8BCAFE),
                        Color(0xFF70AADE),
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
                  child: Center(
                    child: Text(
                      'Save',
                      style: app_textstyles.appBarTitle.copyWith(
                        fontSize: 20,
                        color: Colors.white

                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      )
      ),
    );
  }
  @override
  void dispose() {
    nameCtrl.dispose();
    roleCtrl.dispose();
    pinCtrl.dispose();
    super.dispose();
  }

}
