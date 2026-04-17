// ignore: file_names
import 'package:onyfast/Widget/alerte.dart';

bool commenceParIndicatif(String telephone) {
  
  telephone=telephone.replaceAll('+','');
  print("✅✅✅✅✅✅   $telephone");
   if (telephone.length!=12){
       SnackBarService.info(
        "Numéro de téléphone invalide",
      );
      
      return false  ;
    }else{
      var tel242=telephone.replaceFirst('242', "");
      tel242=tel242.replaceAll('+', '');
      return tel242.startsWith("06") ||
         tel242.startsWith("04") ||
         tel242.startsWith("05") ||
         tel242.startsWith("22");
    }
print("✅✅✅✅✅✅  deuxieme  $telephone");
}


