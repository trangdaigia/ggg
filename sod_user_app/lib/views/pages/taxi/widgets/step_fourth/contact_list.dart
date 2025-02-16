import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/view_models/taxi_new_ship_order_contact.vm.dart';
import 'package:velocity_x/velocity_x.dart';

class ContactList extends StatefulWidget {
  final List<Contact> contacts;
  final TextEditingController contactNameController;
  final TextEditingController phoneNumberController;
  const ContactList(
    this.newTaxiShipOrderContactViewModel, {
    Key? key,
    required this.contacts,
    required this.contactNameController,
    required this.phoneNumberController,
  }) : super(key: key);

  @override
  State<ContactList> createState() => _ContactListState();
  final NewTaxiShipOrderContactViewModel newTaxiShipOrderContactViewModel;
}

class _ContactListState extends State<ContactList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.contacts.length,
      itemBuilder: ((context, index) {
        final numbers = widget.contacts[index].phones!.toList();
        return InkWell(
          onTap: () {
            widget.contactNameController.text =
                widget.contacts[index].displayName!;
            widget.phoneNumberController.text =
                numbers.isNotEmpty ? numbers[0].value! : "";
            Navigator.pop(context);
            widget.newTaxiShipOrderContactViewModel.textformOnChange();
          },
          child: ListTile(
            title: Text(widget.contacts[index].displayName!),
            subtitle:
                Text(numbers.isNotEmpty ? numbers[0].value! : "No number".tr()),
          ),
        );
      }),
    );
  }
}
