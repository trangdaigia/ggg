import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/services/contact.service.dart';
import 'package:sod_user/view_models/base.view_model.dart';
import 'package:sod_user/view_models/taxi.vm.dart';
import 'package:sod_user/views/pages/taxi/widgets/step_fourth/contact_list.dart';
import "package:velocity_x/velocity_x.dart";

class NewTaxiShipOrderContactViewModel extends MyBaseViewModel {
  //
  NewTaxiShipOrderContactViewModel(BuildContext context, this.taxiViewModel) {
    this.viewContext = context;
  }

  final TaxiViewModel taxiViewModel;

  List<Contact>? contacts;

  initialise() async {
    if (taxiViewModel.isShipOrder()) {
      if (true) {
        bool permission = await ContactsPermissionService.permissionRequest();
        if (permission) {
          contacts = await ContactsService.getContacts(withThumbnails: false);
        }
      }
    }
  }

  closeContactform() async {
    clearFocus();
    taxiViewModel.setCurrentStep(3);
    print("checkstep");
    print(taxiViewModel.currentStep(3));
    notifyListeners();
  }

  textformOnChange() {
    notifyListeners();
  }

  clearFocus() {
    FocusScope.of(taxiViewModel.viewContext).requestFocus(new FocusNode());
  }

  showContactsDialog(BuildContext context) {
    List<Contact> searchContacts = [];
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              color: Colors.transparent,
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.6,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        onChanged: (value) async {
                          if (taxiViewModel
                              .searchContactController.text.isNotEmpty) {
                            searchContacts = contacts!
                                .where(
                                  (contact) => contact.displayName!
                                              .toLowerCase()
                                              .contains(value.toLowerCase()) ||
                                          contact.phones!.isNotEmpty
                                      ? contact.phones![0].value!.contains(
                                          taxiViewModel
                                              .searchContactController.text
                                              .toLowerCase())
                                      : false,
                                )
                                .toList();
                          }
                        },
                        controller: taxiViewModel.searchContactController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          border: UnderlineInputBorder(),
                          hintText: "Search contacts".tr(),
                        ),
                      ),
                      ContactList(
                        this,
                        contacts: taxiViewModel
                                .searchContactController.text.isNotEmpty
                            ? searchContacts
                            : contacts ?? [],
                        phoneNumberController: taxiViewModel.contactNumber,
                        contactNameController: taxiViewModel.contactName,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
