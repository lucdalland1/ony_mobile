import 'package:get/get.dart';
import 'package:onyfast/Crypte%20&%20Decrypte/crypte.dart';
import 'package:onyfast/View/Facture_PDF/Model/invoice_model.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class InvoiceController extends GetxController {
  var invoice = Invoice(
    invoiceNumber: '',
    date: DateTime.now(),
    dueDate: DateTime.now().add(Duration(days: 30)),
    clientName: '',
    clientAddress: '',
    items: [],
  ).obs;

  void setInvoice(String number, DateTime date, DateTime dueDate, String name,
      String address, List<InvoiceItem> items) {
    invoice.value = Invoice(
      invoiceNumber: number,
      date: date,
      dueDate: dueDate,
      clientName: name,
      clientAddress: address,
      items: items,
    );
  }

  String encryptedText = "";
  String decryptedText = "";
  final EncryptionController controller = Get.put(EncryptionController());

  Future<void> generatePdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Row(
                children: [
                  pw.Column(
                    children: [
                      pw.Text("Facture",
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                          )),
                      pw.SizedBox(
                        height: 05,
                      ),
                      pw.Text("N° 12478847375",
                          style: pw.TextStyle(fontSize: 14)),
                      pw.SizedBox(
                        height: 03,
                      ),
                      pw.Text("Date : ${invoice.value.date.toLocal()}",
                          style: pw.TextStyle(fontSize: 14)),
                      pw.SizedBox(
                        height: 03,
                      ),
                      pw.Text('Due Date: ${invoice.value.dueDate.toLocal()}',
                          style: pw.TextStyle(fontSize: 14)),
                    ],
                  ),
                  pw.SizedBox(
                    width: 50,
                  ),
                  pw.Column(
                    children: [
                      pw.Row(children: [
                        pw.Text("Company name :",
                            style: pw.TextStyle(
                              fontSize: 14,
                            )),
                        pw.Text("ONYFAST",
                            style: pw.TextStyle(
                              fontSize: 17,
                              fontWeight: pw.FontWeight.bold,
                            )),
                      ]),
                      pw.SizedBox(
                        height: 03,
                      ),
                      pw.Row(children: [
                        pw.Text("Adresse :",
                            style: pw.TextStyle(
                              fontSize: 14,
                            )),
                        pw.Text("21 rue mmmmmmmm",
                            style: pw.TextStyle(
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold,
                            )),
                      ]),
                      //   pw.SizedBox(height: 04,),
                      // pw.Text("Company name :", style: pw.TextStyle(fontSize: 14, )),
                      // pw.SizedBox(height: 05,),
                      //   pw.Text("N° 12478847375", style: pw.TextStyle(fontSize: 14 )),
                      //   pw.SizedBox(height: 03,),
                      //     pw.Text("Date : ${invoice.value.date.toLocal()}", style: pw.TextStyle(fontSize: 14 )),
                      //      pw.SizedBox(height: 03,),
                      //     pw.Text('Due Date: ${invoice.value.dueDate.toLocal()}', style: pw.TextStyle(fontSize: 14 )),
                    ],
                  ),
                ],
              ),
              // pw.Text('Invoice #${invoice.value.invoiceNumber}', style: pw.TextStyle(fontSize: 24)),
              // pw.Text('Date: ${invoice.value.date.toLocal()}'),
              // pw.Text('Due Date: ${invoice.value.dueDate.toLocal()}'),
              // pw.Text('Client:'),
              // pw.Text('Address: ${invoice.value.clientAddress}'),
              // pw.SizedBox(height: 20),
              // pw.Text('Items:', style: pw.TextStyle(fontSize: 20)),
              pw.SizedBox(
                height: 20,
              ),
              pw.Divider(),
              pw.SizedBox(
                height: 20,
              ),
              pw.Container(
                  height: 20,
                  width: 580,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue,
                  ),
                  child: pw.Row(
                    children: [
                      pw.Text("Description",
                          style: pw.TextStyle(
                              fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(width: 30),
                      pw.Text("Prix unitair",
                          style: pw.TextStyle(
                              fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(width: 30),
                      pw.Text("Quantité",
                          style: pw.TextStyle(
                              fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(width: 30),
                      pw.Text("Total",
                          style: pw.TextStyle(
                              fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ],
                  )),
              pw.SizedBox(
                height: 04,
              ),
              pw.Row(children: [
                pw.Text("Ordinateur",
                    style: pw.TextStyle(
                      fontSize: 14,
                    )),
                pw.SizedBox(width: 30),
                pw.Text("120.000f",
                    style: pw.TextStyle(
                      fontSize: 14,
                    )),
                pw.SizedBox(width: 80),
                pw.Text("2",
                    style: pw.TextStyle(
                      fontSize: 14,
                    )),
                pw.SizedBox(width: 50),
                pw.Text("140.000f",
                    style: pw.TextStyle(
                      fontSize: 14,
                    )),
              ]),
              pw.SizedBox(
                height: 20,
              ),
              pw.Container(
                  height: 20,
                  width: 580,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue,
                  ),
                  child: pw.Row(
                    children: [
                      pw.SizedBox(width: 30),
                      pw.Text("Nom",
                          style: pw.TextStyle(
                              fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(width: 30),
                      pw.Text("Prénom",
                          style: pw.TextStyle(
                              fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(width: 30),
                      pw.Text("Téléphone",
                          style: pw.TextStyle(
                              fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(width: 30),
                      pw.Text("Adresse",
                          style: pw.TextStyle(
                              fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ],
                  )),
              pw.SizedBox(
                height: 04,
              ),
              pw.Row(children: [
                pw.Text(" ${invoice.value.clientName}",
                    style: pw.TextStyle(
                      fontSize: 13,
                    )),
                pw.SizedBox(width: 30),
                pw.Text(" ${invoice.value.clientName}",
                    style: pw.TextStyle(
                      fontSize: 13,
                    )),
                pw.SizedBox(width: 30),
                pw.Text("065487121",
                    style: pw.TextStyle(
                      fontSize: 13,
                    )),
                pw.SizedBox(width: 30),
                pw.Text("${invoice.value.clientAddress}",
                    style: pw.TextStyle(
                      fontSize: 13,
                    )),
              ]),
              //             QrImageView(
              //   data: controller.encryptData(controller.connexion.getUser()?.telephone ?? "Numéro indisponible"),
              //   version: QrVersions.auto,
              //   size: 280.0,
              // ),
              // pw.SizedBox(height: 20),

              // pw.Row(
              //   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              //   children: [
              //     pw.Text('Subtotal:'),
              //     pw.Text('\$${invoice.value.subtotal.toStringAsFixed(2)}'),
              //   ],
              // ),
              // pw.Row(
              //   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              //   children: [
              //     pw.Text('Tax (${(invoice.value.taxRate * 100).toStringAsFixed(0)}%):'),
              //     pw.Text('\$${invoice.value.tax.toStringAsFixed(2)}'),
              //   ],
              // ),
              // pw.Row(
              //   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              //   children: [
              //     pw.Text('Total:'),
              //     pw.Text('\$${invoice.value.total.toStringAsFixed(2)}'),
              //   ],
              // ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/onyfast.pdf');
    await file.writeAsBytes(await pdf.save());
    OpenFile.open(file.path);
    SnackBarService.success('Invoice saved as PDF in ${file.path}');
  }
}
