import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/shared_ride.dart';
import 'package:sod_user/view_models/shared_ride.vm.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:sod_user/utils/utils.dart';

class EditNotePage extends StatefulWidget {
  final SharedRide sharedRide;
  final SharedRideViewModel model;
  const EditNotePage({Key? key, required this.sharedRide, required this.model})
      : super(key: key);

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        title: Text("Note".tr()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const SizedBox(height: 15),
              Text(
                "Note for passenger".tr(),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 200,
                child: TextField(
                  controller: widget.model.noteController,
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.black26, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.red, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.black26, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    prefixIcon: const Icon(Icons.chat_bubble),
                    filled: true,
                    hintText: 'Write a note for passenger'.tr(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomButton(
        onPressed: () async {
          final forbiddenWord = Utils.checkForbiddenWordsInString(
              widget.model.noteController.text);
          if (forbiddenWord != null) {
            await CoolAlert.show(
              context: context,
              type: CoolAlertType.error,
              title: "Warning forbidden words".tr(),
              text: "Your information contains forbidden word".tr() +
                  ": $forbiddenWord",
            );
            return;
          }

          await widget.model.updateSharedRide(type: "note");
          Navigator.pop(context);
          Navigator.pop(context);
        },
        title: "Confirm".tr(),
      ).p(16),
    );
  }
}
