import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxString userName = "".obs;
  RxString email = "".obs;

  @override
  void onReady() {
    super.onReady();
    getUserCredentials();
  }

  Future<void> getUserCredentials() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        Get.snackbar("Error", "No user is logged in");
        return;
      }
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists || userDoc.data() == null) {
        Get.snackbar("Error", "User document not found.");
        return;
      }
      String fetchedName =
          (userDoc.data() as Map<String, dynamic>)['name'] ?? "Unknown";
      userName.value = fetchedName;

      String fetchedEmail =
          (userDoc.data() as Map<String, dynamic>)['email'] ?? "Unknown";
      email.value = fetchedEmail;
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch user name");
    }
  }

  //TODO: Get profile picture
}
