import 'package:expense_mate_flutter/constatnts/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();

  Rx<User?> firebaseUser = Rx<User?>(null);

  @override
  void onReady() {
    super.onReady();
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        Get.snackbar("Success", "Account created successfully");

        // Navigate to the login page
        Get.offAllNamed('/login');
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> updateUserProfile({
    required String name,
    required String email,
    required String username,
  }) async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        // 1. Update details in Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'name': name,
          'email': email, // Updates the email record in your database
          'username': username,
        });

        // 2. Update email in FirebaseAuth (The Fix)
        if (user.email != email) {
          // This sends a verification link to the NEW email address.
          // The auth email will NOT change until the user clicks that link.
          await user.verifyBeforeUpdateEmail(email);

          Get.snackbar(
            "Verification Sent",
            "Please check your new email to verify the change.",
            duration: const Duration(seconds: 5),
          );
        } else {
          Get.snackbar("Success", "Profile updated successfully!");
        }
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.snackbar("Success", "Logged in successfully");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  // Future<UserCredential?> signInWithGoogle() async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) return null; // User canceled sign-in

  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;

  //     final OAuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     return await _auth.signInWithCredential(credential);
  //   } catch (e) {
  //     print("Google Sign-In Error: $e");
  //     return null;
  //   }
  // }

  Future<void> signOut() async {
    Get.defaultDialog(
      title: "Confirm Sign Out",
      middleText: "Are you sure you want to sign out?",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: AppColors.fontWhite,
      onConfirm: () async {
        // await _googleSignIn.signOut();
        await _auth.signOut();
        Get.offAllNamed('/login'); // Navigate to login page
      },
    );
  }
}
