import 'dart:io';
import 'package:onyfast/View/Facture_PDF/Model/invoice_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<File> generateAndSaveInvoice(Invoice invoice) async {
    try {
      // Générer le document PDF
      final pdf = await _generateDocument(invoice);
      
      // Obtenir le répertoire de stockage
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      
      // Créer le fichier
      final file = File('$path/facture_${invoice.invoiceNumber}.pdf');
      
      // Sauvegarder le PDF
      await file.writeAsBytes(await pdf.save());
      
      return file;
    } catch (e) {
      throw Exception('Erreur lors de la génération du PDF: $e');
    }
  }

  static Future<void> saveAndLaunchFile(File file, String fileName) async {
    try {
      // Pour Android: utiliser le répertoire de téléchargement
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        final downloads = Directory('${directory?.path}/Download');
        if (!await downloads.exists()) {
          await downloads.create(recursive: true);
        }
        directory = downloads;
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final newPath = '${directory?.path}/$fileName';
      final savedFile = await file.copy(newPath);
      
      // Ouvrir le fichier
      await OpenFile.open(savedFile.path);
    } catch (e) {
      throw Exception('Erreur lors de l\'ouverture du fichier: $e');
    }
  }

  static Future<pw.Document> _generateDocument(Invoice invoice) async {
    final pdf = pw.Document(
      title: 'Facture ${invoice.invoiceNumber}',
      author: 'Votre Entreprise',
    );

    // Définir une police par défaut qui supporte les caractères spéciaux
    final font = await PdfGoogleFonts.robotoRegular();
//
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(invoice, font),
              pw.SizedBox(height: 24),
              _buildInvoiceInfo(invoice, font),
              pw.SizedBox(height: 24),
              _buildItemsTable(invoice, font),
              pw.SizedBox(height: 24),
              _buildTotal(invoice, font),
              pw.SizedBox(height: 40),
              _buildFooter(font),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildHeader(Invoice invoice, pw.Font font) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'FACTURE',
              style: pw.TextStyle(
                font: font,
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              'N° ${invoice.invoiceNumber}',
              style: pw.TextStyle(font: font),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'Votre Entreprise',
              style: pw.TextStyle(
                font: font,
                fontWeight: pw.FontWeight.bold,
                fontSize: 16,
              ),
            ),
            pw.Text(
              '123 Avenue des Champs\n75008 Paris, France',
              style: pw.TextStyle(font: font),
            ),
            pw.Text(
              'contact@entreprise.com',
              style: pw.TextStyle(font: font),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildInvoiceInfo(Invoice invoice, pw.Font font) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.5),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      padding: pw.EdgeInsets.all(12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Facturé à:',
                style: pw.TextStyle(
                  font: font,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                invoice.clientName,
                style: pw.TextStyle(font: font),
              ),
              pw.Text(
                invoice.clientAddress,
                style: pw.TextStyle(font: font),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Date: ${_formatDate(invoice.date)}',
                style: pw.TextStyle(font: font),
              ),
              pw.Text(
                'Échéance: ${_formatDate(invoice.dueDate)}',
                style: pw.TextStyle(font: font),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(Invoice invoice, pw.Font font) {
    return pw.TableHelper.fromTextArray(
      border: pw.TableBorder.all(
        width: 0.5,
        color: PdfColors.grey400,
      ),
      headerStyle: pw.TextStyle(
        font: font,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: pw.BoxDecoration(
        color: PdfColors.blue700,
      ),
      headers: ['Description', 'Quantité', 'Prix Unitaire', 'Total'],
      data: invoice.items.map((item) => [
        item.description,
        item.quantity.toString(),
        '${item.unitPrice.toStringAsFixed(2)} €',
        '${item.total.toStringAsFixed(2)} €',
      ]).toList(),
      cellStyle: pw.TextStyle(font: font),
      cellAlignment: pw.Alignment.centerRight,
      columnWidths: {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(1),
        3: pw.FlexColumnWidth(1),
      },
      cellPadding: pw.EdgeInsets.all(8),
      headerPadding: pw.EdgeInsets.all(8),
    );
  }

  static pw.Widget _buildTotal(Invoice invoice, pw.Font font) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Sous-total: ${invoice.subtotal.toStringAsFixed(2)} €',
                style: pw.TextStyle(font: font),
              ),
              pw.Text(
                'TVA (${(invoice.taxRate * 100).toStringAsFixed(0)}%): ${invoice.tax.toStringAsFixed(2)} €',
                style: pw.TextStyle(font: font),
              ),
              pw.Divider(),
              pw.Text(
                'TOTAL: ${invoice.total.toStringAsFixed(2)} €',
                style: pw.TextStyle(
                  font: font,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Font font) {
    return pw.Center(
      child: pw.Text(
        'Merci pour votre confiance !',
        style: pw.TextStyle(
          font: font,
          fontStyle: pw.FontStyle.italic,
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}