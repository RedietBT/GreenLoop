import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/waste/domain/repos/weast_repo.dart';

class IncrementUserWasteCount {
  final WeastRepo repository;

  IncrementUserWasteCount(this.repository);

  ResultFuture<void> call(String userId, String userType) async {
    return await repository.incrementUserWasteCount(userId, userType);
  }
} 