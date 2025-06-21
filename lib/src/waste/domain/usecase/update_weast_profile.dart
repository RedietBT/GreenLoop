import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/waste/domain/entitty/weste.dart';
import 'package:greenloop/src/waste/domain/repos/weast_repo.dart';

class UpdateWeastProfile {

  final WeastRepo repository;

  UpdateWeastProfile(this.repository);
 
 ResultFuture<Weast> call({
    required String weastId,
    required Map<String, dynamic> data,
  }) {
    return repository.updateWeastProfile(
      weastId: weastId, 
      data: data,
    );
  }
}