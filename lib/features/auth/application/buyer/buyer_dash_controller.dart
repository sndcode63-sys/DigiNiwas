import 'package:get/get.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/buer_dashboard_model.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/widgets/app_toast.dart';


class BuyerController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final buyerList = <BuyerModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBuyers();
  }

  String get nameInitials {
    if (buyerList.isEmpty) return 'U';
    final name = buyerList.first.name?.trim() ?? '';
    if (name.isEmpty) return 'U';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name[0].toUpperCase();
  }

  void fetchBuyers() async {
    try {
      // 1. Loading start
      isLoading.value = true;
      errorMessage.value = '';

      // 2. API Call
      final response = await ApiService.instance.get(ApiConstants.getBuyers);

      // 3. Parse Data
      final buyerResponse = BuyerResponseModel.fromJson(response.data);

      if (buyerResponse.data != null) {
        buyerList.value = buyerResponse.data!;

        // Optional: Agar success toast dikhana ho
        // AppToast.success(Get.context!, "Buyers fetched successfully");
      }

    } catch (e) {
      errorMessage.value = e.toString().replaceAll("Exception: ", "");

      if (Get.context != null) {
        AppToast.error(Get.context!, errorMessage.value);
      }

    } finally {
      // 5. Loading stop
      isLoading.value = false;
    }
  }
}