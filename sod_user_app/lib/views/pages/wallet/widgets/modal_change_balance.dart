import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';

class ModalChangeBalance extends StatefulWidget {
  final Function(String amount) onSubmit;

  const ModalChangeBalance({super.key, required this.onSubmit});

  @override
  State<ModalChangeBalance> createState() => _ModalChangeBalanceState();
}

class _ModalChangeBalanceState extends State<ModalChangeBalance> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  void _handleSubmit() {
    final value = _controller.text.trim();

    // Simple validation
    if (value.isEmpty || double.tryParse(value) == null || double.parse(value) <= 0) {
      setState(() {
        _errorText = "Please enter a valid amount";
      });
      return;
    }

    widget.onSubmit(value); // Call the parent function
    Navigator.pop(context); // Close the modal
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.3,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Center(
              child: Text(
                "Change Balance".tr(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // TextField
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter the amount".tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                errorText: _errorText,
              ),
              onChanged: (value) {
                setState(() {
                  _errorText = null; // Clear error on input
                });
              },
            ),
            const SizedBox(height: 20),

            // Submit Button
          CustomButton(
              title: "Submit".tr(),
              onPressed: _handleSubmit,

          ),
            // Spacer to balance modal
            const Spacer(),

            // Hint text
            Center(
              child: Text(
                "Make sure the amount is correct!".tr(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
