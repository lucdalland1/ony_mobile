import 'package:get/get.dart';

class FrequencyController extends GetxController {
  var selectedFrequency = 'Quotidien'.obs;
  var selectedDay = 'Lundi'.obs;
  var selectedWeekDay = 'Lundi'.obs;
  var selectedWeekNumber = '1'.obs;
  var selectedMonth = 'Janvier'.obs;
  
  final days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
  final weekNumbers = List.generate(52, (index) => (index + 1).toString());
  final months = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
  ];

  void setFrequency(String frequency) => selectedFrequency.value = frequency;
  void setDay(String day) => selectedDay.value = day;
  void setWeekDay(String day) => selectedWeekDay.value = day;
  void setWeekNumber(String number) => selectedWeekNumber.value = number;
  void setMonth(String month) => selectedMonth.value = month;
}