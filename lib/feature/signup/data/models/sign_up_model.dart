import 'package:chat_app/feature/signup/domain/entities/sign_up_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpModel extends SignUpEntity {
  SignUpModel({
    required super.user,
  });

  static Map<String, dynamic> toMap({required User user}) {
    if(user.photoURL == null){
      return {
        'name': user.displayName,
        'email': user.email,
        'uid': user.uid,
        'groupId': '',
        'isActive': true,
        'photoUrl':
        'https://letsenhance.io/static/8f5e523ee6b2479e26ecc91b9c25261e/1015f/MainAfter.jpg',
      };
    }
    else {
      return {
        'name': user.displayName,
        'email': user.email,
        'uid': user.uid,
        'groupId': '',
        'isActive': true,
        'photoUrl': user.photoURL,
      };
    }
  }
}
