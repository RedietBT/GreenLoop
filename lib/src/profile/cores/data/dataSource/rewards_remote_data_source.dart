import 'package:greenloop/src/profile/cores/data/model/user_rewards_model.dart';
import 'package:greenloop/src/profile/cores/domain/entity/user_rewards.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:greenloop/core/errors/exceptions.dart';
import 'package:greenloop/src/profile/cores/domain/entity/rewards.dart';
import 'package:greenloop/src/profile/cores/data/model/rewards_model.dart';


abstract class RewardsRemoteDataSource {
  const RewardsRemoteDataSource();

 
  Future<List<Rewards>> fetchAvailableRewards();

 
  Future<List<UserRewards>> fetchUserRedeemedRewards(String userId);

  Future<void> redeemReward({
    required String userId,
    required String rewardId,
  });
}

class RewardsRemoteDataSourceImpl implements RewardsRemoteDataSource {
  final SupabaseClient _supabaseClient;

  const RewardsRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<List<Rewards>> fetchAvailableRewards() async {
    try {
      final response = await _supabaseClient
          .from('rewards') 
          .select();

      final List<Rewards> rewards = (response as List)
          .map((map) => RewardsModel.fromJson(map as Map<String, dynamic>))
          .toList();

      return rewards;
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.code ?? '') ?? 500,
      );
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }
  
  @override
  Future<List<UserRewards>> fetchUserRedeemedRewards(String userId) async {
    try {
          final response = await _supabaseClient
          .from('user_rewards')
          .select('id, user_id, reward_id, redeemed_at')
          .eq('user_id', userId)
          .order('redeemed_at', ascending: false);
          
          final List<UserRewards> redeemedRewards = (response as List).map((map) {
            return UserRewardsModel.fromJson(map as Map<String, dynamic>);
            }).toList();
            
            return redeemedRewards;
            } on PostgrestException catch (e) {
              throw ServerException(
                message: e.message,
                statusCode: int.tryParse(e.code ?? '') ?? 500,
                );
              } catch (e) {
                  throw ServerException(message: e.toString(), statusCode: 500);
                }
           }

  @override
  Future<void> redeemReward({
    required String userId,
    required String rewardId,
  }) async {
    try {
      await _supabaseClient.from('user_rewards').insert({
        'user_id': userId,
        'reward_id': rewardId,
        'redeemed_at': DateTime.now().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        statusCode: int.tryParse(e.code ?? '') ?? 500,
      );
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }
}