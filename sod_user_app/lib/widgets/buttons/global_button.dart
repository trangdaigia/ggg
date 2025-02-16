import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlobalButton {
  const GlobalButton({Key? key});

  static buildButton(
    BuildContext context, {
    required String title,
    required Color btnColor,
    required Color txtColor,
    double btnHeight = 50,
    double txtSize = 14,
    double btnWidthRatio = 0.9,
    required Function() onPress,
    bool isVisible = true,
    bool upperCase = true,
    double borderRadius = 15.0,
  }) {
    return Visibility(
      visible: isVisible,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * btnWidthRatio,
        child: MaterialButton(
          onPressed: onPress,
          height: btnHeight,
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          color: btnColor,
          child: Text(
            upperCase ? title.toUpperCase() : title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: txtColor,
              fontSize: txtSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  static buildBorderButton(
    BuildContext context, {
    required String title,
    required Color btnColor,
    required Color btnBorderColor,
    required Color txtColor,
    double btnHeight = 50,
    double txtSize = 14,
    double btnWidthRatio = 0.9,
    required Function() onPress,
    bool isVisible = true,
  }) {
    return Visibility(
      visible: isVisible,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * btnWidthRatio,
        height: btnHeight,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(btnColor),
            foregroundColor: MaterialStateProperty.all<Color>(txtColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: BorderSide(
                  color: btnBorderColor,
                ),
              ),
            ),
          ),
          onPressed: onPress,
          child: Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                color: txtColor,
                fontSize: txtSize,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  static buildIconButton(
    BuildContext context, {
    required String title,
    required Color btnColor,
    required Color txtColor,
    required Color iconColor,
    required IconData icon,
    double? width,
    double? btnHeight,
    double txtSize = 16,
    double iconSize = 18.0,
    required Function() onPress,
    bool isVisible = true,
    double borderRadius = 6.0,
  }) {
    return Visibility(
      visible: isVisible,
      child: InkWell(
        onTap: onPress,
        child: SizedBox(
          width: width,
          height: btnHeight,
          child: ElevatedButton.icon(
            onPressed: onPress,
            icon: Icon(icon,
                color: iconColor,
                size: iconSize), //icon data for elevated button
            label: Text(
              title,
              style: TextStyle(color: txtColor, fontSize: txtSize),
              overflow: TextOverflow.ellipsis,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: btnColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius)),
            ),
          ),
        ),
      ),
    );
  }

  static buildStatus({
    required String text,
    required double textSize,
    required Color txtColor,
    isVisible = true,
  }) {
    return Visibility(
      visible: isVisible,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          // border: Border.all(color: Colors.black87),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.blackOpsOne(
            color: txtColor,
            fontSize: textSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
