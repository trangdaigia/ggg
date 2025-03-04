import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sod_user/flavors.dart';
import 'package:sod_user/view_models/login.view_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class SocialMediaLoginService {
  //

  //Google login
  void googleLogin(LoginViewModel model) async {
    //
    model.setBusy(true);
    try {
      //
      GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          "https://www.googleapis.com/auth/userinfo.profile",
        ],
        clientId: F.appFlavor == Flavor.inux && Platform.isAndroid
            ? "666683520616-df26tpferggi48tim13go1jiodln8m8g.apps.googleusercontent.com"
            : null,
      );
      try {
        // Trigger the authentication flow
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.disconnect();
        }
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        //
        if (googleUser == null) {
          throw "Google login failed".tr();
        }

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        // Once signed in, return the UserCredential
        await FirebaseAuth.instance.signInWithCredential(credential);
        //Login to with firebase token
        //
        // Sign the user in (or link) with the credential
        try {
          final apiResponse = await model.authRequest.socialLogin(
            googleUser.email,
            googleAuth.idToken,
            "google",
          );
          print("Google login: ${apiResponse?.message}");
          if (apiResponse != null) {
            await model.handleDeviceLogin(apiResponse);
          } else {
            model.openRegister(
                email: googleUser.email, name: googleUser.displayName);
          }
        } catch (error) {
          model.toastError("$error");
        }
        //
      } on FirebaseAuthException catch (error) {
        model.toastError(
          "${error.message}",
          length: Toast.LENGTH_LONG,
        );
      } catch (error) {
        model.toastError("$error");
      }
    } catch (error) {
      model.toastError("$error");
    }
    model.setBusy(false);
  }

  //Facebook login
  void facebookLogin(LoginViewModel model) async {
    //
    model.setBusy(true);
    //
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ["email", "public_profile"],
      );
      if (result.status == LoginStatus.success) {
        // you are logged
        final AccessToken? accessToken = result.accessToken;
        if (accessToken == null) {
          throw "Facebook login failed".tr();
        }
        try {
          // Create a credential from the access token
          final OAuthCredential facebookAuthCredential =
              FacebookAuthProvider.credential(
            accessToken.tokenString,
          );

          // Once signed in, return the UserCredential
          UserCredential userAccount =
              await FirebaseAuth.instance.signInWithCredential(
            facebookAuthCredential,
          );

          //
          final apiResponse = await model.authRequest.socialLogin(
            userAccount.user!.email!,
            accessToken.tokenString,
            "facebook",
          );
          //
          if (apiResponse != null) {
            await model.handleDeviceLogin(apiResponse);
          } else {
            model.openRegister(
              email: userAccount.user!.email!,
              name: userAccount.user!.displayName ?? "",
            );
          }
        } on FirebaseAuthException catch (error) {
          model.toastError(
            "${error.message}",
            length: Toast.LENGTH_LONG,
          );
        } catch (error) {
          model.toastError("$error");
        }
      } else {
        print(result.status);
        print(result.message);
        model.toastError("${result.message}");
      }
    } catch (error) {
      model.toastError("$error");
    }
    //
    model.setBusy(false);
  }

  //apple login
  void appleLogin(LoginViewModel model) async {
    //
    model.setBusy(true);
    try {
      //
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      //
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        rawNonce: rawNonce,
      );

      //
      UserCredential userAccount =
          await FirebaseAuth.instance.signInWithCredential(
        oauthCredential,
      );

      // Sign the user in (or link) with the credential
      try {
        //
        final apiResponse = await model.authRequest.socialLogin(
          userAccount.user!.email ?? "",
          credential.identityToken,
          "apple",
          nonce: rawNonce,
          uid: userAccount.user?.uid,
        );
        //
        if (apiResponse != null) {
          await model.handleDeviceLogin(apiResponse);
        } else {
          model.openRegister(
            email: userAccount.user!.email,
            name: userAccount.user!.displayName,
          );
        }
      } catch (error) {
        model.toastError("$error");
      }
      //
    } on FirebaseAuthException catch (error) {
      model.toastError(
        "${error.message}",
        length: Toast.LENGTH_LONG,
      );
    } catch (error) {
      model.toastError("$error");
    }
    model.setBusy(false);
  }

  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
