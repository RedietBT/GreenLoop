import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/recycling/domain/entity/recycling_user.dart';
import 'package:greenloop/src/waste/domain/repos/weast_repo.dart';

class FetchRecylingProfile {

  final WeastRepo repository;
  FetchRecylingProfile(this.repository);

  ResultFuture<Recycling_User> call(String resyclingId) async {
    return await repository.fetchRecylingProfile(resyclingId);
  }
}