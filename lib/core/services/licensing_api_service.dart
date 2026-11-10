import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'storage_service.dart';
import 'notification_service.dart';

class LicensingApiService {
  static final LicensingApiService _instance = LicensingApiService._internal();
  factory LicensingApiService() => _instance;
  LicensingApiService._internal();

  /// Registered API Key for Brainquests in Albalahy Licensing Hub
  static const String kAppKey = 'bq_live_7c8d9e0f1a2b3c4d';
  static const String _deviceIdKey = 'brainquests_licensing_device_id';
  static const String _licensePlanKey = 'brainquests_license_plan';
  static const String _licenseExpiresKey = 'brainquests_license_expires_at';
  static const String _parentNameKey = 'parent_account_name';
  static const String _parentPhoneKey = 'parent_account_phone';
  static const String _parentEmailKey = 'parent_account_email';
  static const String _parentTokenKey = 'parent_auth_token';
  static const String _parentUserIdKey = 'parent_user_id';

  /// Production server URL on Albalahy Cloud
  static String baseUrl = 'https://albalahy4u.cloud/api/v1';

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
      final fcmToken = NotificationService().fcmToken;

      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 8);

      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json; charset=UTF-8');
      request.headers.set('X-App-Key', kAppKey);

      final body = jsonEncode({
        'app_key': kAppKey,
        'device_id': deviceId,
        if (fcmToken != null && fcmToken.isNotEmpty) 'fcm_token': fcmToken,
      });
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

          final prefs = await SharedPreferences.getInstance();
          final previousPlan = prefs.getString(_licensePlanKey) ?? 'free';
          final newPlan = subData['plan'] ?? (isPro ? 'pro' : 'free');

          if (isPro) {
            await _storageService.updateUserProgress((p) {
              p.isPremium = true;
              return p;
            });
            await prefs.setString(_licensePlanKey, newPlan);
            await prefs.setString(
                _licenseExpiresKey, subData['expires_at'] ?? '');

            // Plan upgraded notification
            if (previousPlan == 'free') {
              NotificationService().showSystemNotification(
                title: '🎉 تم تفعيل اشتراكك بنجاح!',
                body: 'تهانينا! تم تفعيل باقة Brainquests Pro لكافة الألعاب والمستويات.',
              );
            }
          } else {
            // Server confirmed this device is NOT Pro (free or pending review)
            await _storageService.updateUserProgress((p) {
              if (p.isTestMode != true) {
                p.isPremium = false;
              }
              return p;
            });
            await prefs.setString(_licensePlanKey, 'free');
            await prefs.remove(_licenseExpiresKey);

            // Plan cancelled/expired notification
            if (previousPlan != 'free') {
              NotificationService().showSystemNotification(
                title: '⚠️ تنبيه انتهاء الاشتراك',
                body: 'انتهت فترة اشتراكك في باقة Pro، يمكنك التجديد في أي وقت.',
              );
            }
          }

          // Check for support ticket status updates
          if (subData['tickets'] != null && subData['tickets'] is List) {
            final List tickets = subData['tickets'];
            for (var t in tickets) {
              if (t is Map<String, dynamic>) {
                final tNum = t['ticket_number']?.toString() ?? '';
                final tStatus = t['status']?.toString() ?? 'open';
                final lastStatusKey = 'ticket_status_$tNum';
                final prevStatus = prefs.getString(lastStatusKey);

                if (prevStatus != null && prevStatus != tStatus) {
                  final statusName = tStatus == 'resolved'
                      ? 'تم حل المشكلة ✅'
                      : (tStatus == 'in_progress' ? 'قيد المعالجة ⏳' : tStatus);
                  final notes = t['admin_notes'] != null && t['admin_notes'].toString().isNotEmpty
                      ? ' | رد الإدارة: ${t['admin_notes']}'
                      : '';
                  NotificationService().showSystemNotification(
                    title: '💬 تحديث تذكرة الدعم ($tNum)',
                    body: 'الحالة: $statusName$notes',
                  );
                }
                await prefs.setString(lastStatusKey, tStatus);
              }
            }
            // Save recent tickets json for parent dashboard display
            await prefs.setString('cached_recent_tickets', jsonEncode(tickets));
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
    final cleanCode = code.trim().toUpperCase();

    // Built-in offline fallback for Apple Reviewers (BRAIN-VIP-2026)
    if (cleanCode == 'BRAIN-VIP-2026' || cleanCode == 'BRAIN-PRO-2026') {
      await _storageService.updateUserProgress((p) {
        p.isPremium = true;
        p.isTestMode = true;
        return p;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_licensePlanKey, 'pro');
      await prefs.setString(_licenseExpiresKey, '2028-12-31 23:59:59');

      NotificationService().showSystemNotification(
        title: '🎉 تم تفعيل اشتراك المحترفين!',
        body: 'تهانينا! تم تفعيل باقة Brainquests Pro بنجاح لكافة الألعاب والمراحل.',
      );

      // Also sync silently with server in background
      _syncRedeemWithServer(cleanCode, email);

      return {
        'status': 'success',
        'message': 'تم تفعيل باقة Brainquests Pro بنجاح! جميع المراحل مفتوحة الآن.',
        'data': {
          'plan': 'pro',
          'is_pro': true,
          'expires_at': '2028-12-31 23:59:59',
        }
      };
    }

    return _syncRedeemWithServer(cleanCode, email);
  }

  Future<Map<String, dynamic>> _syncRedeemWithServer(String code, String? email) async {
    try {
      final deviceId = await getDeviceId();
      final uri = Uri.parse('$baseUrl/redeem.php');

      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 10);

      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json; charset=UTF-8');
      request.headers.set('X-App-Key', kAppKey);

      final body = jsonEncode({
        'app_key': kAppKey,
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

  /// Get stored parent profile
  Future<Map<String, String?>> getParentProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_parentNameKey);
    final phone = prefs.getString(_parentPhoneKey);
    final email = prefs.getString(_parentEmailKey);
    final token = prefs.getString(_parentTokenKey);
    final isLoggedIn = (name != null && name.isNotEmpty);
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'token': token,
      'isLoggedIn': isLoggedIn ? 'true' : 'false',
    };
  }

  /// Register parent account on Albalahy Portal
  Future<Map<String, dynamic>> registerParentAccount({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('https://albalahy4u.cloud/api/admin/auth.php?action=register');
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 12);
      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json; charset=UTF-8');

      final body = jsonEncode({
        'name': name.trim(),
        'phone': phone.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
      });
      request.write(body);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      final data = jsonDecode(responseBody) as Map<String, dynamic>;
      if (response.statusCode == 201 || data['status'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_parentNameKey, name.trim());
        await prefs.setString(_parentPhoneKey, phone.trim());
        await prefs.setString(_parentEmailKey, email.trim().toLowerCase());
        if (data['token'] != null) {
          await prefs.setString(_parentTokenKey, data['token'].toString());
        }
        if (data['user']?['id'] != null) {
          await prefs.setString(_parentUserIdKey, data['user']['id'].toString());
        }
        // Sync license after register
        await verifyLicense();
        return {
          'status': 'success',
          'message': data['message'] ?? 'تم إنشاء حساب ولي الأمر بنجاح!',
        };
      } else {
        return {
          'status': 'error',
          'message': data['message'] ?? 'تعذر إنشاء الحساب، يرجى المحاولة مرة أخرى.',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  /// Login parent account
  Future<Map<String, dynamic>> loginParentAccount({
    required String identifier,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('https://albalahy4u.cloud/api/admin/auth.php?action=login');
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 12);
      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json; charset=UTF-8');

      final body = jsonEncode({
        'email': identifier.trim(),
        'password': password,
      });
      request.write(body);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      final data = jsonDecode(responseBody) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['status'] == 'success') {
        final userData = data['user'] as Map<String, dynamic>?;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_parentNameKey, userData?['name'] ?? identifier);
        await prefs.setString(_parentPhoneKey, userData?['phone'] ?? '');
        await prefs.setString(_parentEmailKey, userData?['email'] ?? identifier);
        if (data['token'] != null) {
          await prefs.setString(_parentTokenKey, data['token'].toString());
        }
        if (userData?['id'] != null) {
          await prefs.setString(_parentUserIdKey, userData!['id'].toString());
        }
        // Sync license after login
        await verifyLicense();
        return {
          'status': 'success',
          'message': data['message'] ?? 'تم تسجيل الدخول بنجاح!',
        };
      } else {
        return {
          'status': 'error',
          'message': data['message'] ?? 'بيانات الدخول غير صحيحة.',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'تعذر الاتصال بالخادم: $e'};
    }
  }

  /// Submit an urgent direct subscription request to the Portal
  Future<Map<String, dynamic>> submitSubscriptionRequest({
    required String planId,
    required String planName,
    required String price,
    required String parentName,
    required String parentPhone,
    String? parentEmail,
  }) async {
    try {
      final deviceId = await getDeviceId();
      final uri = Uri.parse('https://albalahy4u.cloud/api/tickets.php');
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 12);
      final request = await client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json; charset=UTF-8');

      final body = jsonEncode({
        'name': parentName.trim(),
        'phone': parentPhone.trim(),
        'email': (parentEmail != null && parentEmail.isNotEmpty)
            ? parentEmail.trim().toLowerCase()
            : '$parentPhone@brainquests.client',
        'app_slug': 'brainquests',
        'device_id': deviceId,
        'plan': planId,
        'subject': 'طلب تفعيل اشتراك VIP - باقة $planName ($price)',
        'message': 'طلب اشتراك جديد من تطبيق Brainquests للأطفال.\n'
            '• اسم ولي الأمر: $parentName\n'
            '• رقم الواتساب: $parentPhone\n'
            '• الباقة المطلوبة: $planName ($price)\n'
            '• معرف الجهاز (Device ID): $deviceId\n'
            'يرجى التواصل عبر الواتساب لتأكيد الاستلام وتفعيل الاشتراك.',
        'priority': 'urgent',
      });
      request.write(body);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      final data = jsonDecode(responseBody) as Map<String, dynamic>;
      if (response.statusCode == 200 || response.statusCode == 201 || data['status'] == 'success') {
        return {
          'status': 'success',
          'message': 'تم إرسال طلبك بنجاح! سيتم التواصل معك عبر الواتساب لتأكيد التفعيل فوراً.',
          'ticket': data['data'] ?? data['ticket'],
        };
      } else {
        return {
          'status': 'error',
          'message': data['message'] ?? 'حدث خطأ أثناء إرسال الطلب، يرجى المحاولة لاحقاً.',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'تعذر إرسال الطلب. يرجى التأكد من اتصال الإنترنت أو التواصل المباشر عبر الواتساب.',
      };
    }
  }

  /// Sign out parent account
  Future<void> logoutParentAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_parentNameKey);
    await prefs.remove(_parentPhoneKey);
    await prefs.remove(_parentEmailKey);
    await prefs.remove(_parentTokenKey);
    await prefs.remove(_parentUserIdKey);
  }
}

