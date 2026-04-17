import 'package:get/get.dart';
import 'package:onyfast/View/Activit%C3%A9/Boutique.dart';
import 'package:onyfast/View/Activit%C3%A9/verification_identite/justificatif_domicile.dart';
import 'package:onyfast/View/Activit%C3%A9/verification_identite/justificatif_identite.dart';
import 'package:onyfast/View/BottomView/associerCompte.dart';
import 'package:onyfast/View/Connecter/View/KeyOublie.dart';
import 'package:onyfast/View/Facture/canalBox.dart';
import 'package:onyfast/View/Facture/congoTelecom.dart';
import 'package:onyfast/View/Gerer_cartes/CardDetailPage.dart';
import 'package:onyfast/View/Notification/notification.dart';
import 'package:onyfast/View/Coffre/ajoutercoffre.dart';
import 'package:onyfast/View/Coffre/coffre.dart';
import 'package:onyfast/View/Coffre/model/coffreModel.dart';
import 'package:onyfast/View/Coffre/modifierCoffre.dart';
import 'package:onyfast/View/Epargne/Eparne%20individuel/epargne_groupe_type.dart';
import 'package:onyfast/View/Epargne/epargne%20group%C3%A9/epargne_groupe_commune.dart';
import 'package:onyfast/View/Epargne/epargne%20group%C3%A9/epargne_groupe_rotative_transition.dart';
import 'package:onyfast/View/Facture/canalBox.dart';
import 'package:onyfast/View/Facture/congoTelecom.dart';
import 'package:onyfast/View/InscriptionSuplementaire/InscritInfoSuplementaire.dart';
import 'package:onyfast/View/Operation/achatCredit.dart';
import 'package:onyfast/View/Configuration/configuration.dart';
import 'package:onyfast/View/Connecter/View/connect.dart';
import 'package:onyfast/View/ResetPassword/resetpassword.dart';
import 'package:onyfast/View/ResetPassword/resetpassword2.dart';
import 'package:onyfast/View/deconnecter.dart';
import 'package:onyfast/View/home.dart';
import 'package:onyfast/View/hometoken.dart';
import 'package:onyfast/View/inscrit.dart';
import 'package:onyfast/View/menuscreen.dart';
import 'package:onyfast/View/otp_mail.dart';
import 'package:onyfast/View/parametre.dart';
import 'package:onyfast/View/Operation/virementCemac.dart';
import 'package:onyfast/otplogin.dart';
import 'package:onyfast/verouillage.dart';

class AppRoutes {
  static const String hometoken = '/hometoken';
  static const String home = '/';
  static const String connect = '/connect';
  static const String inscrit = '/inscrit';
  static const String menuscreen = '/menuscreen';
  static const String parametre = '/parametre';
  static const String profil = '/profil';
  static const String associer = '/associercompte';
  static const String virement = '/virement';
  static const String paiement = '/paiement';
  static const String canalbox = '/canalbox';
  static const String congotelecom = '/congotelecom';
  static const String achatcredit = '/achatcredit';
  static const String mtn = '/mtn';
  static const String airtel = '/airtel';
  static const String deconnecter = '/deconnecter';
  static const String configuration = '/configuration';
  static const String mespoints = '/mespoints';
  static const String notifications = '/notifications';
  ////Boutique
  static const String boutique = '/shopping';

  static const String coffre = '/coffre';
  static const String ajoutercoffre = '/ajoutercoffre';
  static const String inscriptioninformation = '/inscription_information';

  static const String modifiercoffre = '/modifiercoffre';
  static const String epargneGroupeType = '/epargnegroupetype';
  static const String epargneGroupeCommune = '/epargnegroupecommune';
  static const String epargneGroupeRotativeTransition =
      '/epargnegrouperotativetransition';
  static const String lock = '/lock';

  static const String conditiongeneraleutilisation =
      '/conditiongeneraleutilisation';

  static const String justificatifIdentite = '/justificatifIdentite';
  static const String justificatifDomicile = '/justificatifDomicile';

  static const String resetPassword = '/resetpassword';
  static const String otpMail = '/otpMail';
  static const String card_details = '/card_details';
  static const String numeroRenitialisation = '/numeroRenitialisation';
  static const String otplogin = '/otplogin';
  static const String resetPasswordSansToken = '/resetpasswordSansToken';

  static List<GetPage> routes = [
    GetPage(name: home, page: () => HomeToken()),
    GetPage(name: home, page: () => Home()),
    // GetPage(name: home, page: () => Configuration()),
    GetPage(name: connect, page: () => Connect()),
    GetPage(name: inscrit, page: () => Inscrit()),
    GetPage(name: otpMail, page: () => OtpMail()),
    GetPage(name: otpMail, page: () => OtpMail()),
    GetPage(name: resetPasswordSansToken, page: () => ResetpasswordSansToken()),
    //Boutique

    // GetPage(name: menuscreen, page: () => MenuScreen(user: user,)),
    GetPage(name: parametre, page: () => Parametre()),
    GetPage(name: notifications, page: () => NotificationsPage()),
    GetPage(
        name: inscriptioninformation, page: () => InscritInfoSuplementaire()),

    //CCoffre
    GetPage(
        name: modifiercoffre,
        page: () => Modifiercoffre(
            objectif: ObjectifModel(
                id: 1,
                coffreId: 37,
                nom: 'nom',
                montantCible: 1,
                montantActuel: 1,
                isActive: true,
                delai: "",
                dateLimite: '2025-07-31',
                startDate: DateTime.now(),
                endDate: DateTime.now()))),

    GetPage(name: lock, page: () => const LockScreen()),

    // GetPage(name: menuscreen, page: () => MenuScreen(user: user,)),
    GetPage(name: parametre, page: () => Parametre()),
    GetPage(name: associer, page: () => AssocierCompte()),
    GetPage(name: virement, page: () => Virement()),
    GetPage(name: canalbox, page: () => CanalBox()),
    GetPage(name: congotelecom, page: () => CongoTelecom()),
    GetPage(name: achatcredit, page: () => AchatCredit()),
    GetPage(name: deconnecter, page: () => Deconnecter()),
    GetPage(name: coffre, page: () => CoffreAccueilScreen()),
    GetPage(name: ajoutercoffre, page: () => AjouterCoffreScreen()),
    GetPage(name: epargneGroupeType, page: () => EpargneGroupeType()),
    GetPage(name: epargneGroupeCommune, page: () => EpargneGroupeCommune()),
    GetPage(
        name: epargneGroupeRotativeTransition,
        page: () => EpargneGroupeRotativeTransition()),
    GetPage(name: justificatifIdentite, page: () => JustificatifIdentite()),
    GetPage(name: justificatifDomicile, page: () => JustificatifDomicilePage()),
    GetPage(name: resetPassword, page: () => Resetpassword()),
    GetPage(name: numeroRenitialisation, page: () => NumeroRenitialisation()),
    GetPage(name: otplogin, page: () => Otplogin(iswhatssap: true, isTelephone: true)),
  ];
}
