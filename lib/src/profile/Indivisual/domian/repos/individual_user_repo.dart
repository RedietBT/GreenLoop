import 'dart:ffi';
import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/Indivisual/domian/entity/individual_user.dart';

abstract class IndividualUserRepo {
  const IndividualUserRepo();

ResultFuture<IndividualUser> fetchUserProfile(String userId);

ResultFuture<Void> updateUserProfile({
    required String userId,
    required String firstName, 
    required String lastName,  
    required String email,     
    required String? avatarUrl, 
    required String? points,    
  });
}