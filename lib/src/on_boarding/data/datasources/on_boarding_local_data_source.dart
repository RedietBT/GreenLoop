// ignore: depend_on_referenced_packages
import 'package:greenloop/core/errors/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class OnBoardingLocalDataSource {
  const OnBoardingLocalDataSource();
  static const kFirstTimeUserKey = 'isFirstTimeUser';
  Future<void> casheFirstTimeUser();Future<bool> checkIfUserisFirstTimer();
}

class OnBoardingLocalDataSourceImpl implements OnBoardingLocalDataSource {
  const OnBoardingLocalDataSourceImpl(this._sharedPreferences);
  final SharedPreferences _sharedPreferences;

  @override
  Future<void> casheFirstTimeUser() async {
    try{
      await _sharedPreferences.setBool(OnBoardingLocalDataSource.kFirstTimeUserKey, false);
    } catch (e) {
      throw CacheException(
        message: e.toString(),
      );
    }
  }

  @override
  Future<bool> checkIfUserisFirstTimer() async {
    final result = _sharedPreferences.getBool(OnBoardingLocalDataSource.kFirstTimeUserKey);
    if (result != null) {
      return result;
    }
    return true; // Default to true if result is null
  }
}