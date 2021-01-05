// FLUTTER / DART / THIRD-PARTIES
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

// SERVICES
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/mon_ets_api.dart';
import 'package:notredame/core/services/signets_api.dart';

// MODELS
import 'package:notredame/core/models/mon_ets_user.dart';
import 'package:notredame/core/models/profile_student.dart';
import 'package:notredame/core/models/program.dart';

// UTILS
import 'package:notredame/core/utils/api_exception.dart';
import 'package:notredame/core/utils/cache_exception.dart';

// OTHER
import 'package:notredame/locator.dart';
import 'cache_manager.dart';

class UserRepository {
  static const String tag = "UserRepository";

  static const String usernameSecureKey = "usernameKey";
  static const String passwordSecureKey = "passwordKey";
  @visibleForTesting
  static const String infoCacheKey = "infoCache";
  @visibleForTesting
  static const String programsCacheKey = "programsCache";

  final Logger _logger = locator<Logger>();
  final MonETSApi _monETSApi = locator<MonETSApi>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  final FlutterSecureStorage _secureStorage = locator<FlutterSecureStorage>();

  /// Cache manager to access and update the cache.
  final CacheManager _cacheManager = locator<CacheManager>();

  /// Principal access to the SignetsAPI
  final SignetsApi _signetsApi = locator<SignetsApi>();

  MonETSUser _monETSUser;

  MonETSUser get monETSUser => _monETSUser;

  List<ProfileStudent> _info;

  ProfileStudent get info =>
      _info == null || _info.isEmpty ? null : _info.first;

  List<Program> _programs;

  List<Program> get programs => _programs;

  /// Authenticate the user using the [username] (for a student should be the
  /// universal code like AAXXXXX).
  /// If the authentication is successful the credentials ([username] and [password])
  /// will be saved in the secure storage of the device to authorize a silent
  /// authentication next time.
  Future<bool> authenticate(
      {@required String username,
      @required String password,
      bool isSilent = false}) async {
    try {
      _monETSUser =
          await _monETSApi.authenticate(username: username, password: password);
    } catch (e) {
      _analyticsService.logError(tag, "Authenticate - ${e.toString()}");
      return false;
    }

    await _analyticsService.setUserProperties(
        userId: username, domain: _monETSUser.domain);

    // Save the credentials in the secure storage
    if (!isSilent) {
      try {
        await _secureStorage.write(key: usernameSecureKey, value: username);
        await _secureStorage.write(key: passwordSecureKey, value: password);
      } on PlatformException catch (e) {
        _analyticsService.logError(
            tag, "Authenticate - PlatformException - ${e.toString()}");
        return false;
      }
    }

    return true;
  }

  /// Check if there are credentials saved and so authenticate the user, otherwise
  /// return false
  Future<bool> silentAuthenticate() async {
    final String username = await _secureStorage.read(key: usernameSecureKey);

    if (username != null) {
      final String password = await _secureStorage.read(key: passwordSecureKey);

      return authenticate(
          username: username, password: password, isSilent: true);
    }

    return false;
  }

  /// Log out the user
  Future<bool> logOut() async {
    _monETSUser = null;

    // Delete the credentials from the secure storage
    try {
      await _secureStorage.delete(key: usernameSecureKey);
      await _secureStorage.delete(key: passwordSecureKey);
    } on PlatformException catch (e) {
      _analyticsService.logError(
          tag, "Authenticate - PlatformException - ${e.toString()}");
      return false;
    }
    return true;
  }

  /// Retrieve and get the password for the current authenticated user.
  /// WARNING This isn't a good practice but currently the password has to be sent in clear.
  Future<String> getPassword() async {
    if (_monETSUser == null) {
      _analyticsService.logEvent(
          tag, "Trying to acquire password but not authenticated");
      final result = await silentAuthenticate();

      if (!result) {
        throw const ApiException(prefix: tag, message: "Not authenticated");
      }
    }

    final String password = await _secureStorage.read(key: passwordSecureKey);

    return password;
  }

  /// Get the list of programs on which the student was active.
  /// The list from the [CacheManager] is loaded than updated with the results
  /// from the [SignetsApi].
  Future<List<Program>> getPrograms() async {
    // Load the programs from the cache if the list doesn't exist
    if (_programs == null) {
      try {
        _programs = [];
        final String res = await _cacheManager.get(programsCacheKey);
        final List programsCached = jsonDecode(res) as List<dynamic>;

        // Build list of activities loaded from the cache.
        _programs = programsCached
            .map((e) => Program.fromJson(e as Map<String, dynamic>))
            .toList();
        _logger.d(
            "$tag - getPrograms: ${_programs.length} programs loaded from cache.");
      } on CacheException catch (_) {
        _logger.e(
            "$tag - getPrograms: exception raised will trying to load the programs from cache.");
      }
    }

    try {
      // getPassword will try to authenticate the user if not authenticated.
      final String password = await getPassword();

      final List<Program> fetchedProgram = await _signetsApi.getPrograms(
          username: monETSUser.universalCode, password: password);
      _logger
          .d("$tag - getPrograms: ${fetchedProgram.length} programs fetched.");
      for (final Program program in fetchedProgram) {
        if (!_programs.contains(program)) {
          _programs.add(program);
        }
      }

      // Update cache
      _cacheManager.update(programsCacheKey, jsonEncode(_programs));
    } on CacheException catch (_) {
      _logger.e(
          "$tag - getPrograms: exception raised will trying to update the cache.");
      return _programs;
    } on Exception catch (e) {
      _analyticsService.logError(
          tag, "Exception raised during getPrograms: $e");
      rethrow;
    }

    return _programs;
  }

  /// Get the list of session on which the student was active.
  /// The list from the [CacheManager] is loaded than updated with the results
  /// from the [SignetsApi].
  Future<ProfileStudent> getInfo() async {
    // Load the sessions from the cache if the list doesn't exist
    if (_info == null) {
      try {
        _info = [];
        final String res = await _cacheManager.get(infoCacheKey);
        final List infoCached = jsonDecode(res) as List<dynamic>;

        // Build list of activities loaded from the cache.
        _info = infoCached
            .map((e) => ProfileStudent.fromJson(e as Map<String, dynamic>))
            .toList();
        _logger.d("$tag - getInfo: ${_info.length} info loaded from cache.");
      } on CacheException catch (_) {
        _logger.e(
            "$tag - getInfo: exception raised will trying to load the info from cache.");
      }
    }

    try {
      // getPassword will try to authenticate the user if not authenticated.
      final String password = await getPassword();

      final ProfileStudent fetchedInfo = await _signetsApi.getStudentInfo(
          username: monETSUser.universalCode, password: password);
      _logger.d("$tag - getInfo: $fetchedInfo info fetched.");

      if (!_info.contains(fetchedInfo)) {
        _info.add(fetchedInfo);
      }

      // Update cache
      _cacheManager.update(infoCacheKey, jsonEncode(_info));
    } on CacheException catch (_) {
      _logger.e(
          "$tag - getInfo: exception raised will trying to update the cache.");
      return _info.first;
    } on Exception catch (e) {
      _analyticsService.logError(tag, "Exception raised during getInfo: $e");
      rethrow;
    }
    return _info.first;
  }
}
