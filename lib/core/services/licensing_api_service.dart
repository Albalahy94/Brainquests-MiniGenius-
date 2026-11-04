import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'storage_service.dart';

class LicensingApiService {
  static final LicensingApiService _instance = LicensingApiService._internal();
  factory LicensingApiService() => _instance;
  LicensingApiService._internal();

  /// Registered API Key for Brainquests in Albalahy Licensing Hub
  static const String kAppKey = 'bq_live_7c8d9e0f1a2b3c4d';
  static const String _deviceIdKey = 'brainquests_licensing_device_id';
  static const String _licensePlanKey = 'brainquests_license_plan';
  static const String _licenseExpiresKey = 'brainquests_license_expires_at';

  /// Production server URL (can be customized via remote config or environment)
  /// For local server development: 'http://10.0.2.2:8080/backend/api/v1' or 'http://localhost:8080/backend/api/v1'
  static String baseUrl = 'https://portal.albalahy4u.com/licensing_hub/backend/api/v1';

  final StorageService _storageService = StorageService();

  /// Retrieve or generate a persistent unique Device ID
  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString(_deviceIdKey);
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = const Uuid().v4();
      await prefs.setString(_deviceIdKey, deviceId);
    }
    return deviceId;
  }

  /// Verify device license status with the central licensing server
  Future<Map<String, dynamic>> verifyLicense() async {
    try {
      final deviceId = await getDeviceId();
      final uri = Uri.parse('$baseUrl/verify.php');

      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 8);

      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json; charset=UTF-8');
      request.headers.set('X-App-Key', kAppKey);

      final body = jsonEncode({'device_id': deviceId});
      request.write(body);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody) as Map<String, dynamic>;
        final subData = data['data'] as Map<String, dynamic>?;

        if (subData != null) {
          final isPro = subData['is_pro'] == true ||
              subData['plan'] == 'pro' ||
              subData['plan'] == 'ultimate';

          if (isPro) {
            await _storageService.updateUserProgress((p) {
              p.isPremium = true;
              return p;
            });
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_licensePlanKey, subData['plan'] ?? 'pro');
            await prefs.setString(
                _licenseExpiresKey, subData['expires_at'] ?? '');
          }
        }

        return data;
      } else {
        return {
          'status': 'error',
          'message': 'HTTP ${response.statusCode}: $responseBody',
        };
      }
    } catch (e) {
      debugPrint('⚠️ Central license verification failed: $e');
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }

  /// Redeem an official license / promo key issued by Albalahy Licensing Hub
  Future<Map<String, dynamic>> redeemCode(String code, {String? email}) async {
    try {
      final deviceId = await getDeviceId();
      final uri = Uri.parse('$baseUrl/redeem.php');

      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json; charset=UTF-8');
      request.headers.set('X-App-Key', kAppKey);

      final body = jsonEncode({
        'device_id': deviceId,
        'code': code.trim().toUpperCase(),
        if (email != null && email.isNotEmpty) 'email': email.trim(),
      });
      request.write(body);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      final data = jsonDecode(responseBody) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == 'success') {
        // Activate VIP / Pro locally
        await _storageService.updateUserProgress((p) {
          p.isPremium = true;
          return p;
        });

        final subData = data['data'] as Map<String, dynamic>?;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_licensePlanKey, subData?['plan'] ?? 'pro');
        await prefs.setString(
            _licenseExpiresKey, subData?['expires_at'] ?? '');

        return {
          'status': 'success',
          'message': data['message'] ?? 'تم تفعيل الاشتراك بنجاح!',
          'data': subData,
        };
      } else {
        return {
          'status': 'error',
          'message': data['message'] ?? 'تعذر تفعيل الكود، يرجى التأكد من صحته.',
        };
      }
    } catch (e) {
      debugPrint('⚠️ Central license redeem failed: $e');
      return {
        'status': 'error',
        'message': 'تعذر الاتصال بسيرفر التراخيص. يرجى التحقق من اتصال الإنترنت.',
      };
    }
  }
}

