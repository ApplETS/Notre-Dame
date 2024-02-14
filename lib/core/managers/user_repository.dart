// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:ets_api_clients/clients.dart';
import 'package:ets_api_clients/exceptions.dart';
import 'package:ets_api_clients/models.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

// Project imports:
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/networking_service.dart';
import 'package:notredame/core/utils/cache_exception.dart';
import 'package:notredame/locator.dart';

class UserRepository {
  static const String tag = "UserRepository";

  static const String usernameSecureKey = "usernameKey";
  static const String passwordSecureKey = "passwordKey";
  @visibleForTesting
  static const String infoCacheKey = "infoCache";
  @visibleForTesting
  static const String programsCacheKey = "programsCache";

  final Logger _logger = locator<Logger>();

  /// Will be used to report event and error.
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  /// Used to verify if the user has connectivity
  final NetworkingService _networkingService = locator<NetworkingService>();

  /// Secure storage manager to access and update the cache.
  final FlutterSecureStorage _secureStorage = locator<FlutterSecureStorage>();

  /// Cache manager to access and update the cache.
  final CacheManager _cacheManager = locator<CacheManager>();

  /// Used to access the Signets API
  final SignetsAPIClient _signetsApiClient = locator<SignetsAPIClient>();

  /// Used to access the MonÉTS API
  final MonETSAPIClient _monEtsApiClient = locator<MonETSAPIClient>();

  /// Mon ETS user for the student
  MonETSUser? _monETSUser;

  MonETSUser? get monETSUser => _monETSUser;

  /// Information for the student profile
  ProfileStudent? _info;

  ProfileStudent? get info => _info;

  /// List of the programs for the student
  List<Program>? _programs;

  List<Program>? get programs => _programs;

  /// Authenticate the user using the [username] (for a student should be the
  /// universal code like AAXXXXX).
  /// If the authentication is successful the credentials ([username] and [password])
  /// will be saved in the secure storage of the device to authorize a silent
  /// authentication next time.
  Future<bool> authenticate(
      {required String username,
      required String password,
      bool isSilent = false}) async {
    try {
      _monETSUser = await _monEtsApiClient.authenticate(
          username: username, password: password);
    } on Exception catch (e, stacktrace) {
      // Try login in from signets if monETS failed
      if (e is HttpException) {
        try {
          // ignore: deprecated_member_use
          if (await _signetsApiClient.authenticate(
              username: username, password: password)) {
            _monETSUser = MonETSUser(
                domain: MonETSUser.mainDomain,
                typeUsagerId: MonETSUser.studentRoleId,
                username: username);
          } else {
            _analyticsService.logError(
                tag, "Authenticate - $e", e, stacktrace);
            return false;
          }
        } on Exception catch (e, stacktrace) {
          _analyticsService.logError(
              tag, "Authenticate - $e", e, stacktrace);
          return false;
        }
      } else {
        _analyticsService.logError(
            tag, "Authenticate - $e", e, stacktrace);
        return false;
      }
    }

    await _analyticsService.setUserProperties(
        userId: username, domain: _monETSUser!.domain);

    // Save the credentials in the secure storage
    if (!isSilent) {
      try {
        await _secureStorage.write(key: usernameSecureKey, value: username);
        await _secureStorage.write(key: passwordSecureKey, value: password);
      } on PlatformException catch (e, stacktrace) {
        await _secureStorage.deleteAll();
        _analyticsService.logError(
            tag,
            "Authenticate - PlatformException - $e",
            e,
            stacktrace);
        return false;
      }
    }

    return true;
  }

  /// Check if there are credentials saved and so authenticate the user, otherwise
  /// return false
  Future<bool> silentAuthenticate() async {
    try {
      final username = await _secureStorage.read(key: usernameSecureKey);
      if (username != null) {
        final password = await _secureStorage.read(key: passwordSecureKey);
        if(password == null) {
          await _secureStorage.deleteAll();
          _analyticsService.logError(
          tag,
          "SilentAuthenticate - PlatformException(Handled) - $passwordSecureKey not found");
          return false;
        }
        return await authenticate(
            username: username, password: password, isSilent: true);
      }
    } on PlatformException catch (e, stacktrace) {
      await _secureStorage.deleteAll();
      _analyticsService.logError(
          tag,
          "SilentAuthenticate - PlatformException(Handled) - $e",
          e,
          stacktrace);
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
    } on PlatformException catch (e, stacktrace) {
      await _secureStorage.deleteAll();
      _analyticsService.logError(tag,
          "Authenticate - PlatformException - $e", e, stacktrace);
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
    try {
      final password = await _secureStorage.read(key: passwordSecureKey);
      if(password == null) {
        throw const ApiException(prefix: tag, message: "Not authenticated");
      }
      return password;
    } on PlatformException catch (e, stacktrace) {
      await _secureStorage.deleteAll();
      _analyticsService.logError(tag,
          "getPassword - PlatformException - $e", e, stacktrace);
      throw const ApiException(prefix: tag, message: "Not authenticated");
    }
  }

  /// Get the list of programs on which the student was active.
  /// The list from the [CacheManager] is loaded than updated with the results
  /// from the [SignetsApi].
  Future<List<Program>> getPrograms({bool fromCacheOnly = false}) async {
    // Force fromCacheOnly mode when user has no connectivity
    if (!(await _networkingService.hasConnectivity())) {
      // ignore: parameter_assignments
      fromCacheOnly = !await _networkingService.hasConnectivity();
    }

    // Load the programs from the cache if the list doesn't exist
    if (_programs == null) {
      try {
        _programs = [];

        final List programsCached =
            jsonDecode(await _cacheManager.get(programsCacheKey))
                as List<dynamic>;

        // Build list of programs loaded from the cache.
        _programs = programsCached
            .map((e) => Program.fromJson(e as Map<String, dynamic>))
            .toList();
        _logger.d(
            "$tag - getPrograms: ${_programs!.length} programs loaded from cache.");
      } on CacheException catch (_) {
        _logger.e(
            "$tag - getPrograms: exception raised while trying to load the programs from cache.");
      }
    }

    if (fromCacheOnly) {
      return _programs!;
    }

    try {
      // getPassword will try to authenticate the user if not authenticated.
      final String password = await getPassword();

      if(_monETSUser != null) {
        _programs = await _signetsApiClient.getPrograms(
          username: _monETSUser!.universalCode, password: password);
        
        _logger.d("$tag - getPrograms: ${_programs!.length} programs fetched.");

        // Update cache
        _cacheManager.update(programsCacheKey, jsonEncode(_programs));
      }
    } on CacheException catch (_) {
      _logger.e(
          "$tag - getPrograms: exception raised while trying to update the cache.");
      return _programs!;
    } on Exception catch (e, stacktrace) {
      _analyticsService.logError(
          tag, "Exception raised during getPrograms: $e", e, stacktrace);
      rethrow;
    }

    return _programs!;
  }

  /// Get the profile information.
  /// The information from the [CacheManager] is loaded than updated with the results
  /// from the [SignetsApi].
  Future<ProfileStudent> getInfo({bool fromCacheOnly = false}) async {
    // Force fromCacheOnly mode when user has no connectivity
    if (!(await _networkingService.hasConnectivity())) {
      // ignore: parameter_assignments
      fromCacheOnly = true;
    }

    // Load the student profile from the cache if the information doesn't exist
    if (_info == null) {
      try {
        final infoCached = jsonDecode(await _cacheManager.get(infoCacheKey))
            as Map<String, dynamic>;

        // Build info loaded from the cache.
        _info = ProfileStudent.fromJson(infoCached);
        _logger.d("$tag - getInfo: $_info info loaded from cache.");
      } on CacheException catch (_) {
        _logger.e(
            "$tag - getInfo: exception raised while trying to load the info from cache.");
      }
    }

    if (fromCacheOnly) {
      return _info!;
    }

    try {
      // getPassword will try to authenticate the user if not authenticated.
      final String password = await getPassword();

      if(_monETSUser != null) {
        final fetchedInfo = await _signetsApiClient.getStudentInfo(
            username: _monETSUser!.universalCode, password: password);

        _logger.d("$tag - getInfo: $fetchedInfo info fetched.");

        if (_info != fetchedInfo) {
          _info = fetchedInfo;

          // Update cache
          _cacheManager.update(infoCacheKey, jsonEncode(_info));
        }
      }
      
    } on CacheException catch (_) {
      _logger.e(
          "$tag - getInfo: exception raised while trying to update the cache.");
      return _info!;
    } on Exception catch (e, stacktrace) {
      _analyticsService.logError(
          tag, "Exception raised during getInfo: $e", e, stacktrace);
      rethrow;
    }

    return _info!;
  }

  /// Check whether the user was previously authenticated.
  Future<bool> wasPreviouslyLoggedIn() async {
    try {
      final username = await _secureStorage.read(key: passwordSecureKey);
      if (username != null) {
        final password =
            await _secureStorage.read(key: passwordSecureKey);
        return password != null && password.isNotEmpty;
      }
    } on PlatformException catch (e, stacktrace) {
      await _secureStorage.deleteAll();
      _analyticsService.logError(tag,
          "getPassword - PlatformException - $e", e, stacktrace);
    }
    return false;
  }
}
