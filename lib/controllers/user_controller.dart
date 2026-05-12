import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxString userName = "".obs;
  RxString email = "".obs;

  @override
  void onInit() {
    super.onInit();
    getUserCredentials();
  }

  Future<void> getUserCredentials() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        Get.snackbar("Error", "No user is logged in");
        return;
      }
      
      // Try to get user document from Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      
      String fetchedName = "Unknown";
      String fetchedEmail = "Unknown";
      
      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data() as Map<String, dynamic>;
        
        // Try multiple field names for user name
        fetchedName = userData['name'] ?? 
                      userData['displayName'] ?? 
                      userData['fullName'] ?? 
                      user.displayName ?? 
                      user.email?.split('@')[0] ?? 
                      "User";
        
        fetchedEmail = userData['email'] ?? user.email ?? "Unknown";
      } else {
        // Fallback to Firebase Auth data if Firestore document doesn't exist
        fetchedName = user.displayName ?? 
                      user.email?.split('@')[0] ?? 
                      "User";
        fetchedEmail = user.email ?? "Unknown";
      }
      
      userName.value = fetchedName;
      email.value = fetchedEmail;
      
      // Debug print to verify data is being set
      print("User name set to: $fetchedName");
      print("User email set to: $fetchedEmail");
      
    } catch (e) {
      print("Error fetching user credentials: $e");
      // Set fallback values
      final user = _auth.currentUser;
      if (user != null) {
        userName.value = user.displayName ?? user.email?.split('@')[0] ?? "User";
        email.value = user.email ?? "Unknown";
      } else {
        userName.value = "User";
        email.value = "Unknown";
      }
    }
  }

  // Method to manually refresh user credentials
  Future<void> refreshUserCredentials() async {
    await getUserCredentials();
  }

  //TODO: Get profile picture
}
