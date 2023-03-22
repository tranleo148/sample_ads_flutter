import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class AdLoadingController extends GetxController {
  bool hideLoading = false;

  hideLoadingEffect(bool status) {
    hideLoading = status;
    update();
  }
}
