import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/recycling/domain/entity/recycling_user.dart';
import 'package:greenloop/src/profile/recycling/domain/repos/recycling_user_repo.dart';

class UpdateRecyclingUserProfile {
  final RecyclingUserRepo repository;

  UpdateRecyclingUserProfile(this.repository);

  ResultFuture<Recycling_User> call({
    required String userId,
    required Map<String, dynamic> data,
  }) {
    return repository.updateUserProfile(
      userId: userId,
      data: data,
    );
  }
} 