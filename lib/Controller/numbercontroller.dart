import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class NumberController extends GetxController {
  Rx<PhoneNumber> phoneNumber = PhoneNumber(isoCode: 'CG').obs; // Congo pour exemple 242
  RxString phoneNumberValue = ''.obs;
  RxString formattedPhoneNumber = ''.obs;
  RxString cleanDialCode = ''.obs; // Nouvelle variable pour le code sans +

  void onPhoneNumberChange(PhoneNumber number) {
    // Nettoyer le dialCode en retirant le +
    cleanDialCode.value = number.dialCode?.replaceFirst('+', '') ?? '';
    
    // Mettre à jour les autres valeurs
    phoneNumber.value = number;
    phoneNumberValue.value = number.phoneNumber ?? '';
    formattedPhoneNumber.value = number.parseNumber() ?? '';
  }
}