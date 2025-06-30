// ignore_for_file: unnecessary_nullable_for_final_variable_declarations

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService  {
  signInWithGoogle() async{

    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? gAuth = await gUser!.authentication;
    
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth!.accessToken,
      idToken: gAuth.idToken
      );
     return await FirebaseAuth.instance.signInWithCredential(credential);
  }
  
}

