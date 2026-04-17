import 'dart:io';
import 'package:get/get.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class RibController extends GetxController {
  Future<void> shareRibAsPdf({
    required String swift,
    required int codebank,
    required String nombank,
    required String titulairecompte,
    required String numcompte,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("RIB - Releve d'Identite Bancaire", style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 20),
            pw.Text("SWIFT : $swift"),
            pw.Text("Code banque : $codebank"),
            pw.Text("Nom de la banque : $nombank"),
            pw.Text("Titulaire du compte : $titulairecompte"),
            pw.Text("Numero de compte : $numcompte"),
            pw.SizedBox(height: 20),
            pw.Text("Ce document peut etre utilise pour effectuer un virement bancaire."),
          ],
        ),
      ),
    );

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/rib.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles([XFile(file.path)], text: 'Voici mon RIB en PDF');
    } catch (e) {
       SnackBarService.warning( 'Impossible de generer ou partager le PDF : ${e.toString()}');
    }
  }
}
