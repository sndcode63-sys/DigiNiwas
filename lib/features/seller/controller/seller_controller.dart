import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/models/seller_model.dart';
import '../data/seller_repository.dart';

/// GetX Controller for managing Seller Dashboard state & API integrations
class SellerController extends GetxController {
  final SellerRepository _repository;

  SellerController({SellerRepository? repository})
      : _repository = repository ?? SellerRepository();

  // Observable state variables
  final RxBool isLoading = false.obs;
  final RxBool isSubmittingKYC = false.obs;
  final RxString errorMessage = ''.obs;

  final Rxn<SellerModel> sellerProfile = Rxn<SellerModel>();
  final Rxn<SellerSummaryModel> summaryStats = Rxn<SellerSummaryModel>();
  final RxList<dynamic> sellerProperties = <dynamic>[].obs;
  final Rxn<SellerApplicationModel> currentApplication = Rxn<SellerApplicationModel>();

  /// Load complete dashboard data for a given Seller ID
  Future<void> fetchSellerDashboardData(String sellerId) async {
    if (sellerId.isEmpty) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // 1. Fetch Profile
      try {
        final profile = await _repository.getSellerById(sellerId);
        sellerProfile.value = profile;
        debugPrint('✅ Seller Profile loaded: ${profile.name} (${profile.sellerId})');
      } catch (e) {
        debugPrint('⚠️ Seller Profile fetch notice: $e');
      }

      // 2. Fetch Summary Stats
      try {
        final summary = await _repository.getSellerSummary(sellerId);
        summaryStats.value = summary;
        debugPrint('✅ Seller Summary loaded: Total=${summary.totalProperties}, Listed=${summary.listedProperties}');
      } catch (e) {
        debugPrint('⚠️ Seller Summary fetch notice: $e');
      }

      // 3. Fetch Properties
      try {
        final properties = await _repository.getSellerProperties(sellerId);
        sellerProperties.assignAll(properties);
        debugPrint('✅ Seller Properties loaded: ${properties.length} properties');
      } catch (e) {
        debugPrint('⚠️ Seller Properties fetch notice: $e');
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Send Login OTP to Seller Email
  Future<bool> sendSellerLoginOtp(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _repository.sendLoginOtp(email: email);
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify Login OTP and Login Seller
  Future<bool> loginWithOtp(String email, String otp) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await _repository.loginWithOtp(email: email, otp: otp);
      if (response['success'] == true && response['data'] != null) {
        sellerProfile.value = SellerModel.fromJson(response['data']);
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Login Failed', errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Submit Seller Registration Application (no KYC — plain registration
  /// per the API guide: name, email, phone, address, city, state, pinCode,
  /// country, latitude, longitude).
  Future<bool> submitRegistrationApplication({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String city,
    required String state,
    required String pinCode,
    required String country,
    double? latitude,
    double? longitude,
  }) async {
    try {
      isSubmittingKYC.value = true;
      errorMessage.value = '';

      final appResult = await _repository.registerSellerApplication(
        name: name,
        email: email,
        phone: phone,
        address: address,
        city: city,
        state: state,
        pinCode: pinCode,
        country: country,
        latitude: latitude,
        longitude: longitude,
      );

      currentApplication.value = appResult;
      Get.snackbar('Success', 'Registration submitted. Please verify your email.');
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Submission Failed', errorMessage.value);
      return false;
    } finally {
      isSubmittingKYC.value = false;
    }
  }

  /// Change Seller Password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
