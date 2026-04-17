import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:onyfast/Api/user_inscription.dart';
import 'package:onyfast/Controller/RecenteTransaction/recenttransactcontroller.dart';
import 'package:onyfast/Controller/history/history_activiticontroller.dart';

Future miseAjourView()  async{
   try {
      final AuthController connexion = Get.find();
      await connexion.fetchSolde();

     RecentTransactionsController recentTransactionsController = Get.find();
      await recentTransactionsController.fetchTransactions();

      TransactionsController controller = Get.find();
       await controller.refreshTransactions();
       printCurrentRoute();
       if(Get.currentRoute=="/ManageCardsPage"){
        
       }
    } catch (e) {
      
    }
}


void printCurrentRoute() {
  print("🧪🧪🧪🧪🧪 ✅ ✅Route actuelle: ${Get.currentRoute}");
}