import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/widget/app_update_dialog.dart';

class AppUpdateController extends GetxController {
  static AppUpdateController get to => Get.find();
  
  // Observable variables
  final RxBool isCheckingForUpdates = false.obs;
  final RxBool isUpdateAvailable = false.obs;
  final RxBool isForceUpdate = false.obs;
  final RxString latestVersion = ''.obs;
  final RxString updateMessage = ''.obs;
  final RxString updateUrl = ''.obs;
  final RxString currentVersion = ''.obs;
  
  // Private variables
  String? _minRequiredVersion;
  StreamSubscription<DocumentSnapshot>? _updateSubscription;
  
  @override
  void onInit() {
    super.onInit();
    _initializeCurrentVersion();
  }
  
  @override
  void onClose() {
    _updateSubscription?.cancel();
    super.onClose();
  }
  
  /// Initialize current app version
  Future<void> _initializeCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      currentVersion.value = packageInfo.version;
      print('📱 Current App Version: ${packageInfo.version}+${packageInfo.buildNumber}');
    } catch (e) {
      print('❌ Error getting current version: $e');
      currentVersion.value = '1.0.0';
    }
  }
  
  /// Check for app updates
  Future<void> checkForUpdates() async {
    if (isCheckingForUpdates.value) return;
    
    try {
      isCheckingForUpdates.value = true;
      print('🔍 Checking for updates...');
      
      // Get current version if not already set
      if (currentVersion.value.isEmpty) {
        await _initializeCurrentVersion();
      }
      
      // Listen for real-time updates from Firestore
      await _setupUpdateListener();
      
      // Also do an immediate check
      await _performUpdateCheck();
      
    } catch (e) {
      print('❌ Error checking for updates: $e');
    } finally {
      isCheckingForUpdates.value = false;
    }
  }
  
  /// Setup real-time listener for app updates
  Future<void> _setupUpdateListener() async {
    try {
      _updateSubscription?.cancel();
      
      _updateSubscription = FirebaseFirestore.instance
          .collection(Constant.appSettingsCollection)
          .doc(Constant.restaurantAppId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          _processUpdateData(snapshot.data()!);
        }
      });
      
      print('👂 Set up real-time update listener');
    } catch (e) {
      print('❌ Error setting up update listener: $e');
    }
  }
  
  /// Perform immediate update check
  Future<void> _performUpdateCheck() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(Constant.appSettingsCollection)
          .doc(Constant.restaurantAppId)
          .get();
      
      if (snapshot.exists) {
        _processUpdateData(snapshot.data()!);
      } else {
        print('⚠️ No app settings found in Firestore');
      }
    } catch (e) {
      print('❌ Error performing update check: $e');
    }
  }
  
  /// Process update data from Firestore
  void _processUpdateData(Map<String, dynamic> data) {
    try {
      print('📊 Processing update data: $data');
      
      // Extract data from Firestore
      final latestVersionFromFirestore = data['latest_version']?.toString() ?? '';
      final forceUpdate = data['force_update'] == true;
      final updateUrlFromFirestore = data['update_url']?.toString() ?? '';
      final updateMessageFromFirestore = data['update_message']?.toString() ?? 'Update available!';
      final minRequiredVersion = data['min_required_version']?.toString();
      
      // Update observable variables
      latestVersion.value = latestVersionFromFirestore;
      isForceUpdate.value = forceUpdate;
      updateUrl.value = updateUrlFromFirestore;
      updateMessage.value = updateMessageFromFirestore;
      _minRequiredVersion = minRequiredVersion;
      
      print('📱 Current: ${currentVersion.value}');
      print('🚀 Latest: ${latestVersion.value}');
      print('⚡ Force Update: $forceUpdate');
      
      // Check if update is available
      final updateAvailable = _isUpdateAvailable();
      isUpdateAvailable.value = updateAvailable;
      
      if (updateAvailable) {
        print('✅ Update available! Force: $forceUpdate');
        _showUpdateDialog();
      } else {
        print('✅ App is up to date');
      }
      
    } catch (e) {
      print('❌ Error processing update data: $e');
    }
  }
  
  /// Check if update is available
  bool _isUpdateAvailable() {
    if (latestVersion.value.isEmpty) return false;
    
    try {
      // Check minimum required version first
      if (_minRequiredVersion != null && _isVersionLower(currentVersion.value, _minRequiredVersion!)) {
        print('🚨 Current version is below minimum required version');
        isForceUpdate.value = true; // Force update if below minimum
        return true;
      }
      
      // Check if current version is lower than latest
      return _isVersionLower(currentVersion.value, latestVersion.value);
    } catch (e) {
      print('❌ Error comparing versions: $e');
      return false;
    }
  }
  
  /// Compare two semantic versions
  bool _isVersionLower(String current, String latest) {
    try {
      final currentParts = current.split('.').map(int.parse).toList();
      final latestParts = latest.split('.').map(int.parse).toList();
      
      // Pad with zeros if needed
      while (currentParts.length < 3) currentParts.add(0);
      while (latestParts.length < 3) latestParts.add(0);
      
      for (int i = 0; i < 3; i++) {
        if (currentParts[i] < latestParts[i]) return true;
        if (currentParts[i] > latestParts[i]) return false;
      }
      
      return false; // Versions are equal
    } catch (e) {
      print('❌ Error parsing versions: $e');
      return false;
    }
  }
  
  /// Show update dialog
  void _showUpdateDialog() {
    if (Get.isDialogOpen == true) return; // Prevent multiple dialogs
    
    Get.dialog(
      AppUpdateDialog(
        isForceUpdate: isForceUpdate.value,
        updateMessage: updateMessage.value,
        onUpdate: _launchUpdateUrl,
        onDismiss: isForceUpdate.value ? null : () => Get.back(),
      ),
      barrierDismissible: !isForceUpdate.value,
    );
  }
  
  /// Launch update URL
  Future<void> _launchUpdateUrl() async {
    try {
      if (updateUrl.value.isEmpty) {
        // Fallback to default URLs
        if (Platform.isAndroid) {
          updateUrl.value = 'https://play.google.com/store/apps/details?id=${Constant.packageName}';
        } else if (Platform.isIOS) {
          updateUrl.value = 'https://apps.apple.com/app/id${Constant.appStoreId}';
        }
      }
      
      final uri = Uri.parse(updateUrl.value);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('🚀 Launched update URL: ${updateUrl.value}');
      } else {
        print('❌ Could not launch update URL: ${updateUrl.value}');
        ShowToastDialog.showToast('Could not open update link');
      }
    } catch (e) {
      print('❌ Error launching update URL: $e');
      ShowToastDialog.showToast('Error opening update link');
    }
  }
  
  /// Manual update check (for profile screen)
  Future<void> manualUpdateCheck() async {
    print('🔍 Manual update check triggered');
    await checkForUpdates();
  }
  
  /// Get update available status
  bool getUpdateAvailable() => isUpdateAvailable.value;
  
  /// Get latest version
  String getLatestVersion() => latestVersion.value;
  
  /// Get update message
  String getUpdateMessage() => updateMessage.value;
  
  /// Get current version
  String getCurrentVersion() => currentVersion.value;
  
  /// Get force update status
  bool getForceUpdate() => isForceUpdate.value;
}
