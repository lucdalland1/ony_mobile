import 'package:get/get.dart';

class CountryCodeController extends GetxController {
  RxString selectedCountryCode = '+242'.obs;
  RxString selectedFlag = 'img_flag_congo.png'.obs;
  RxString selectedCountryName = 'congo_brazzaville'.obs;
  RxString selectedCode = 'CG'.obs;

  void changeCountry(String code, String flag, String name) {
    selectedCountryCode.value = code;
    selectedFlag.value = flag;
    selectedCountryName.value = name;
  }


  void changeCountryCode(String name, String code) {
    selectedCountryName.value = name;
    selectedCode.value = code;
  }
}


final List<Map<String, String>> countries = [
      {
        'name': 'algeria',
        'code': '+213',
        'flag': 'img_flag_algeria.png',
      },
      {
        'name': 'andorra',
        'code': '+376',
        'flag': 'img_flag_andorra.png',
      },
      {
        'name': 'angola',
        'code': '+244',
        'flag': 'img_flag_angola.png',
      },
      {
        'name': 'antigua_and_barbuda',
        'code': '+1',
        'flag': 'img_flag_antigua-and-barbuda.png',
      },
      {
        'name': 'argentina',
        'code': '+54',
        'flag': 'img_flag_argentina.png',
      },
      {
        'name': 'armenia',
        'code': '+374',
        'flag': 'img_flag_armenia.png',
      },
      {
        'name': 'australia',
        'code': '+61',
        'flag': 'img_flag_australia.png',
      },
      {
        'name': 'austria',
        'code': '+43',
        'flag': 'img_flag_austria.png',
      },
      {
        'name': 'azerbaijan',
        'code': '+994',
        'flag': 'img_flag_azerbaijan.png',
      },
      {
        'name': 'bahamas',
        'code': '+1',
        'flag': 'img_flag_bahamas.png',
      },
      {
        'name': 'bangladesh',
        'code': '+880',
        'flag': 'img_flag_bangladesh.png',
      },
      {
        'name': 'belarus',
        'code': '+375',
        'flag': 'img_flag_belarus.png',
      },
      {
        'name': 'belgium',
        'code': '+32',
        'flag': 'img_flag_belgium.png',
      },
      {
        'name': 'brazil',
        'code': '+55',
        'flag': 'img_flag_brazil.png',
      },
      {
        'name': 'britain',
        'code': '+44',
        'flag': 'img_flag_britain.png',
      },
      {
        'name': 'cameroon',
        'code': '+237',
        'flag': 'img_flag_cameroon.png',
      },
      {
        'name': 'canada',
        'code': '+1',
        'flag': 'img_flag_canada.png',
      },
      {
        'name': 'chad',
        'code': '+235',
        'flag': 'img_flag_chad.png',
      },
      {
        'name': 'chile',
        'code': '+56',
        'flag': 'img_flag_chile.png',
      },
      {
        'name': 'china',
        'code': '+86',
        'flag': 'img_flag_china.png',
      },
      {
        'name': 'colombia',
        'code': '+57',
        'flag': 'img_flag_colombia.png',
      },
      {
        'name': 'congo_brazzaville',
        'code': '+242',
        'flag': 'img_flag_congo.png',
      },
      {
        'name': 'croatia',
        'code': '+385',
        'flag': 'img_flag_croatia.png',
      },
      {
        'name': 'cuba',
        'code': '+53',
        'flag': 'img_flag_cuba.png',
      },
      {
        'name': 'cyprus',
        'code': '+357',
        'flag': 'img_flag_cyprus.png',
      },
      {
        'name': 'czech_republic',
        'code': '+420',
        'flag': 'img_flag_czech_republic.png',
      },
      {
        'name': 'democratic_republic_of_the_congo',
        'code': '+243',
        'flag': 'img_flag_democratic_republic_congo.png',
      },
      {
        'name': 'denmark',
        'code': '+45',
        'flag': 'img_flag_denmark.png',
      },
      {
        'name': 'djibouti',
        'code': '+253',
        'flag': 'img_flag_djibouti.png',
      },
      {
        'name': 'dominican_republic',
        'code': '+1',
        'flag': 'img_flag_dominican_republic.png',
      },
      {
        'name': 'ecuador',
        'code': '+593',
        'flag': 'img_flag_ecuador.png',
      },
      {
        'name': 'egypt',
        'code': '+20',
        'flag': 'img_flag_egypt.png',
      },
      {
        'name': 'england',
        'code': '+44',
        'flag': 'img_flag_england.png',
      },
      {
        'name': 'finland',
        'code': '+358',
        'flag': 'img_flag_finland.png',
      },
      {
        'name': 'france',
        'code': '+33',
        'flag': 'img_flag_france.png',
      },
      {
        'name': 'germany',
        'code': '+49',
        'flag': 'img_flag_germany.png',
      },
      {
        'name': 'greece',
        'code': '+30',
        'flag': 'img_flag_greece.png',
      },
      {
        'name': 'hong_kong',
        'code': '+852',
        'flag': 'img_flag_hongkong.png',
      },
      {
        'name': 'iceland',
        'code': '+354',
        'flag': 'img_flag_iceland.png',
      },
      {
        'name': 'india',
        'code': '+91',
        'flag': 'img_flag_india.png',
      },
      {
        'name': 'iran',
        'code': '+98',
        'flag': 'img_flag_iran.png',
      },
      {
        'name': 'ireland',
        'code': '+353',
        'flag': 'img_flag_ireland.png',
      },
      {
        'name': 'israel',
        'code': '+972',
        'flag': 'img_flag_israel.png',
      },
      {
        'name': 'italy',
        'code': '+39',
        'flag': 'img_flag_italy.png',
      },
      {
        'name': 'jamaica',
        'code': '+1',
        'flag': 'img_flag_jamaica.png',
      },
      {
        'name': 'japan',
        'code': '+81',
        'flag': 'img_flag_japan.png',
      },
      {
        'name': 'mexico',
        'code': '+52',
        'flag': 'img_flag_mexico.png',
      },
      {
        'name': 'netherlands',
        'code': '+31',
        'flag': 'img_flag_netherland.png',
      },
      {
        'name': 'new_zealand',
        'code': '+64',
        'flag': 'img_flag_new_zealand.png',
      },
      {
        'name': 'north_korea',
        'code': '+850',
        'flag': 'img_flag_north_korea.png',
      },
      {
        'name': 'northern_ireland',
        'code': '+44',
        'flag': 'img_flag_northern_ireland.png',
      },
      {
        'name': 'norway',
        'code': '+47',
        'flag': 'img_flag_norway.png',
      },
      {
        'name': 'poland',
        'code': '+48',
        'flag': 'img_flag_poland.png',
      },
      {
        'name': 'portugal',
        'code': '+351',
        'flag': 'img_flag_portugal.png',
      },
      {
        'name': 'russian_federation',
        'code': '+7',
        'flag': 'img_flag_russian_federation.png',
      },
      {
        'name': 'scotland',
        'code': '+44',
        'flag': 'img_flag_scotland.png',
      },
      {
        'name': 'south_africa',
        'code': '+27',
        'flag': 'img_flag_south_africa.png',
      },
      {
        'name': 'south_korea',
        'code': '+82',
        'flag': 'img_flag_south_korea.png',
      },
      {
        'name': 'spain',
        'code': '+34',
        'flag': 'img_flag_spain.png',
      },
      {
        'name': 'sweden',
        'code': '+46',
        'flag': 'img_flag_sweden.png',
      },
      {
        'name': 'switzerland',
        'code': '+41',
        'flag': 'img_flag_switzerland.png',
      },
      {
        'name': 'thailand',
        'code': '+66',
        'flag': 'img_flag_thailand.png',
      },
      {
        'name': 'turkey',
        'code': '+90',
        'flag': 'img_flag_turkey.png',
      },
      {
        'name': 'ukraine',
        'code': '+380',
        'flag': 'img_flag_ukraine.png',
      },
      {
        'name': 'united_arab_emirates',
        'code': '+971',
        'flag': 'img_flag_united_arab_emirates.png',
      },
      {
        'name': 'usa',
        'code': '+1',
        'flag': 'img_flag_usa.png',
      },
      {
        'name': 'wales',
        'code': '+44',
        'flag': 'img_flag_wales.png',
      },
    ];

