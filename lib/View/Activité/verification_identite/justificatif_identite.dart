import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onyfast/Api/piecesjustificatif_Api/pieces_justificatif_api.dart';
import 'package:onyfast/Controller/NewTokenSecours/NewTokenSecours.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/features/features_controller.dart';
import 'package:onyfast/utils/testInternet.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:onyfast/Controller/verifier_identite/pieceidentitecontrollor.dart';
import 'package:onyfast/Controller/verifier_identite/soumissionjustificatif_controller.dart';
import 'package:onyfast/Controller/verifier_identite/type_piece.dart';
import 'package:onyfast/View/const.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:math' as math;

class JustificatifIdentite extends StatefulWidget {
  const JustificatifIdentite({super.key});

  @override
  State<JustificatifIdentite> createState() => _JustificatifIdentiteState();
}

class _JustificatifIdentiteState extends State<JustificatifIdentite> {
  String? _selectedPieceType;
  final List<File> _selectedImages = [];
  File? _selectedPdfFile; // NOUVEAU
  bool _isPdfMode = false; // NOUVEAU - pour savoir si on est en mode PDF
  final int _maxImages = 2;
  final int _targetSizeKB = 400;
  final int _maxPdfSizeKB = 2048; // NOUVEAU - 2 Mo max pour le PDF

  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _typePieceController = Get.find<TypePieceController>();
  final controller = Get.put(JustificatifIdentiteController());
  final ImagePicker _picker = ImagePicker();

  // Photo de profil
  File? _photoIdentite;
  bool _hasPhotoIdentite = false;

// Champs texte (tu initialises toi-même les controllers)
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();

  // String? _selectedPieceType;
  // List<File> _selectedImages = [];
  // final int _maxImages = 2;
  // final int _targetSizeKB = 400;

  // Variable pour gérer le c  pdfium_bindings: ^2.0.1
  bool _isProcessing = false;
  void initialisation() {
    final storage = GetStorage();
    final userInfo = storage.read('userInfo') ?? {};

    final nom = userInfo['name']?.toString() ?? '';
    final prenom = userInfo['prenom']?.toString() ?? '';
    final email = userInfo['email']?.toString() ?? '';

    _nomController.text = nom;
    _prenomController.text = prenom;
    _telephoneController.text = SecureTokenController.to.telephone.value ?? '';
  }

  @override
  void initState() {
    super.initState();
    _typePieceController.getAllTypePieces();
    ValidationTokenController.to.validateToken();
    initialisation();
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAndCropImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(source: source);
      if (picked == null) return;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recadrer la photo',
            toolbarColor: const Color.fromARGB(255, 6, 11, 116),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Recadrer la photo'),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _photoIdentite = File(croppedFile.path);
          _hasPhotoIdentite = true;
        });
      }
    } catch (e) {
      print('luc ${e.toString()}');
      SnackBarService.warning('Erreur lors de la sélection de la photo');
    }
  }

  void _showPhotoSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt,
                  color: Color.fromARGB(255, 6, 11, 116)),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _pickAndCropImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library,
                  color: Color.fromARGB(255, 6, 11, 116)),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickAndCropImage(ImageSource.gallery);
              },
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction de compression PDF ULTRA PERFORMANTE - Objectif: MAX 2 Mo
// Fonction de vérification PDF - Le fichier est déjà validé à la sélection
  Future<File> _compressPdfToTarget(File inputPdf) async {
    print('\n📦 Vérification du PDF...');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      final fileSize = await inputPdf.length();
      final fileSizeKB = fileSize / 1024;
      final fileSizeMB = fileSize / (1024 * 1024);

      print(
          '📊 Taille du PDF : ${fileSizeMB.toStringAsFixed(2)} Mo (${fileSizeKB.toStringAsFixed(0)} Ko)');
      print(
          '🎯 Limite : ${(_maxPdfSizeKB / 1024).toStringAsFixed(0)} Mo ($_maxPdfSizeKB Ko)');

      // Vérification de sécurité (normalement déjà fait à la sélection)
      if (fileSizeKB > _maxPdfSizeKB) {
        print('❌ PDF trop volumineux !');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        throw Exception(
            'Le fichier PDF dépasse la taille autorisée (${fileSizeMB.toStringAsFixed(2)} Mo). '
            'Maximum : ${(_maxPdfSizeKB / 1024).toStringAsFixed(0)} Mo.');
      }

      print('✅ PDF conforme !');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return inputPdf; // Retourner le fichier tel quel
    } catch (e) {
      print('❌ Erreur : $e');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      rethrow;
    }
  }

// Fonction auxiliaire pour recompresser les bytes du PDF
  Future<Uint8List> _recompressPdfBytes(
      Uint8List inputBytes, int quality, double scaleFactor) async {
    try {
      // Créer un nouveau PDF avec compression maximale
      final newPdf = pw.Document();

      // Pour simplifier, on crée une page avec le contenu compressé
      // Note: Cette méthode fonctionne mieux avec des PDFs générés par l'app
      // Pour des PDFs externes complexes, on fait une compression "best effort"

      // Stratégie : Réduire la qualité globale du PDF
      // En copiant le contenu avec des paramètres de compression agressifs

      return inputBytes; // Placeholder - voir note ci-dessous
    } catch (e) {
      print('Erreur recompression: $e');
      return inputBytes;
    }
  }

// Fonction pour sélectionner un fichier PDF
// Fonction pour sélectionner un fichier PDF - AVEC LIMITE STRICTE 2048 Ko
  Future<void> _pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        File pdfFile = File(result.files.single.path!);

        // Vérifier la taille du fichier
        final fileSize = await pdfFile.length();
        final fileSizeKB = fileSize / 1024;
        final fileSizeMB = fileSize / (1024 * 1024);

        print(
            '📄 PDF sélectionné : ${fileSizeMB.toStringAsFixed(2)} Mo (${fileSizeKB.toStringAsFixed(0)} Ko)');

        // 🎯 VÉRIFICATION STRICTE : MAX 2048 Ko (2 Mo)
        if (fileSizeKB > _maxPdfSizeKB) {
          // Fichier trop gros - REFUSÉ
          print(
              '❌ PDF refusé : ${fileSizeKB.toStringAsFixed(0)} Ko > $_maxPdfSizeKB Ko');

          SnackBarService.error('PDF trop volumineux !\n'
              'Taille : ${fileSizeMB.toStringAsFixed(2)} Mo\n'
              'Maximum autorisé : ${(_maxPdfSizeKB / 1024).toStringAsFixed(0)} Mo\n\n'
              'Veuillez sélectionner un fichier plus léger ou utilisez le mode "Photos".');

          return; // On ne sélectionne PAS le fichier
        }

        // Fichier conforme ✅
        print(
            '✅ PDF conforme : ${fileSizeKB.toStringAsFixed(0)} Ko ≤ $_maxPdfSizeKB Ko');

        setState(() {
          _selectedPdfFile = pdfFile;
          _isPdfMode = true;
          _selectedImages.clear(); // Vider les images si on sélectionne un PDF
        });

        SnackBarService.warning('PDF sélectionné avec succès !\n'
            'Taille : ${fileSizeMB.toStringAsFixed(2)} Mo (${fileSizeKB.toStringAsFixed(0)} Ko)');
      }
    } catch (e) {
      print('Erreur sélection PDF: $e');
      SnackBarService.warning('Erreur lors de la sélection du fichier PDF');
    }
  }

  // Fonction pour prendre une photo avec la caméra ou choisir depuis la galerie
  void _pickImage(ImageSource source) async {
    if (_selectedImages.length >= _maxImages) {
      SnackBarService.warning('Vous pouvez ajouter maximum $_maxImages photos');
      return;
    }

    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (picked == null) return;

      // Vérifier que le fichier existe
      final pickedFile = File(picked.path);
      if (!await pickedFile.exists()) {
        SnackBarService.warning('Impossible de récupérer l\'image');
        return;
      }

      // Recadrage
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: picked.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recadrer la photo',
            toolbarColor: Colors.indigo,
            toolbarWidgetColor: Colors.white,
            statusBarColor: Colors.indigo,
            activeControlsWidgetColor: Colors.indigo,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: false,
            showCropGrid: true,
          ),
          IOSUiSettings(
            title: 'Recadrer la photo',
            cancelButtonTitle: 'Annuler',
            doneButtonTitle: 'Valider',
            resetButtonHidden: false,
            rotateButtonsHidden: false,
            aspectRatioLockEnabled: false,
          ),
        ],
      );

      // Si l'utilisateur annule le recadrage → on garde l'image originale
      final File finalFile;
      if (croppedFile != null) {
        finalFile = File(croppedFile.path);
      } else {
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        finalFile = await pickedFile.copy(
            '${tempDir.path}/piece_jointe_${timestamp}_${_selectedImages.length}.jpg');
      }

      if (!await finalFile.exists()) {
        SnackBarService.warning('Impossible de sauvegarder la photo');
        return;
      }

      setState(() {
        _selectedImages.add(finalFile);
      });
    } on PlatformException catch (e) {
      print('PlatformException piece jointe: ${e.code} - ${e.message}');
      if (e.code == 'photo_access_denied' || e.code == 'camera_access_denied') {
        SnackBarService.error(
            'Permission refusée.\nVeuillez autoriser l\'accès dans les paramètres.');
      } else {
        SnackBarService.warning('Erreur lors de la sélection de la photo');
      }
    } catch (e) {
      print('Erreur piece jointe: $e');
      SnackBarService.warning(source == ImageSource.camera
          ? 'Erreur lors de la capture de la photo'
          : 'Erreur lors de la sélection de la photo');
    }
  }

  Widget _buildPhotoIdentiteSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Aperçu photo
          GestureDetector(
            onTap: _isFormDisabled ? null : _showPhotoSourceDialog,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 6, 11, 116).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color.fromARGB(255, 6, 11, 116).withOpacity(0.3),
                  width: 2,
                ),
                image: _hasPhotoIdentite
                    ? DecorationImage(
                        image: FileImage(_photoIdentite!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _hasPhotoIdentite
                  ? null
                  : Icon(
                      Icons.person,
                      size: 40,
                      color: const Color.fromARGB(255, 6, 11, 116)
                          .withOpacity(0.4),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // Texte + bouton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Photo',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(255, 6, 11, 116),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _hasPhotoIdentite ? 'Photo ajoutée ✓' : 'Ajouter votre photo',
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: _hasPhotoIdentite ? Colors.green : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _isFormDisabled ? null : _showPhotoSourceDialog,
                  icon: Icon(
                    _hasPhotoIdentite ? Icons.edit : Icons.add_a_photo,
                    size: 16,
                  ),
                  label: Text(_hasPhotoIdentite ? 'Modifier' : 'Ajouter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 6, 11, 116),
                    side: const BorderSide(
                        color: Color.fromARGB(255, 6, 11, 116)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          // Supprimer
          if (_hasPhotoIdentite)
            IconButton(
              onPressed: _isFormDisabled
                  ? null
                  : () => setState(() {
                        _photoIdentite = null;
                        _hasPhotoIdentite = false;
                      }),
              icon: const Icon(Icons.close, color: Colors.red),
            ),
        ],
      ),
    );
  }

  // Afficher le dialogue pour choisir la source
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.indigo),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.indigo),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour supprimer une image spécifique
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // Fonction pour supprimer toutes les images
  // Fonction pour supprimer toutes les images/PDF
  void _removeAllImages() {
    setState(() {
      _selectedImages.clear();
      _selectedPdfFile = null;
      _isPdfMode = false;
    });
  }

  // Fonction pour compresser une image
  Future<Uint8List> _compressImage(File imageFile, int quality) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Impossible de décoder l\'image');
      }

      // Réduire la taille si nécessaire
      if (image.width > 1000) {
        image = img.copyResize(image, width: 1000);
      }

      // Compresser en JPEG
      return Uint8List.fromList(img.encodeJpg(image, quality: quality));
    } catch (e) {
      print('Erreur compression image: $e');
      rethrow;
    }
  }

  // Fonction pour créer un PDF compressé
  Future<File> _createCompressedPdf(List<File> images) async {
    initialisation();
    int quality = 75;
    File? pdfFile;
    int attempts = 0;
    final maxAttempts = 5;

    while (attempts < maxAttempts) {
      try {
        final pdf = pw.Document();

        // ── PAGE 1 : Fiche récapitulative ──────────────────────
        Uint8List? photoBytes;
        if (_photoIdentite != null) {
          photoBytes = await _compressImage(_photoIdentite!, quality);
        }

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(40),
            build: (context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Titre
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.indigo900,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text(
                      'FICHE JUSTIFICATIF D\'IDENTITÉ',
                      style: pw.TextStyle(
                        fontSize: 12.sp,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.SizedBox(height: 24),

                  // Photo + Infos côte à côte
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Photo
                      pw.Container(
                        width: 110,
                        height: 130,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                            color: PdfColors.indigo900,
                            width: 2,
                          ),
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: photoBytes != null
                            ? pw.ClipRRect(
                                horizontalRadius: 6,
                                verticalRadius: 6,
                                child: pw.Image(
                                  pw.MemoryImage(photoBytes),
                                  fit: pw.BoxFit.cover,
                                ),
                              )
                            : pw.Center(
                                child: pw.Text(
                                  'Pas de\nphoto',
                                  style: pw.TextStyle(
                                    fontSize: 9.sp,
                                    color: PdfColors.grey600,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                      ),
                      pw.SizedBox(width: 24),

                      // Infos
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _buildPdfField('Nom', _nomController.text),
                            pw.SizedBox(height: 12),
                            _buildPdfField('Prénom', _prenomController.text),
                            pw.SizedBox(height: 12),
                            _buildPdfField(
                                'Téléphone', _telephoneController.text),
                            pw.SizedBox(height: 12),
                            _buildPdfField('N° Pièce', _numeroController.text),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 24),
                  pw.Divider(color: PdfColors.grey400, thickness: 1),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Documents joints : ${images.length} page(s)',
                    style: pw.TextStyle(
                      fontSize: 9.sp,
                      color: PdfColors.grey600,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ],
              );
            },
          ),
        );

        // ── PAGES SUIVANTES : images du justificatif ───────────
        for (int i = 0; i < images.length; i++) {
          final compressedBytes = await _compressImage(images[i], quality);
          final pdfImage = pw.MemoryImage(compressedBytes);

          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4,
              build: (context) {
                return pw.Center(
                  child: pw.Image(
                    pdfImage,
                    fit: pw.BoxFit.contain,
                  ),
                );
              },
            ),
          );
        }

        // Sauvegarder
        final output = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        pdfFile = File('${output.path}/piece_identite_$timestamp.pdf');
        await pdfFile.writeAsBytes(await pdf.save());

        final fileSize = await pdfFile.length();
        final fileSizeKB = fileSize / 1024;

        print(
            'Tentative ${attempts + 1}: Taille du PDF = ${fileSizeKB.toStringAsFixed(2)} Ko (qualité: $quality)');

        if (fileSizeKB <= _targetSizeKB) {
          print('✓ PDF créé avec succès : ${fileSizeKB.toStringAsFixed(2)} Ko');
          return pdfFile;
        }

        quality -= 15;
        attempts++;

        if (quality < 20) {
          print('⚠ Qualité minimale atteinte');
          quality = 50;
        }
      } catch (e) {
        print(
            'Erreur lors de la création du PDF (tentative ${attempts + 1}): $e');
        attempts++;
        quality -= 10;
        if (quality < 15) break;
      }
    }

    if (pdfFile != null && await pdfFile.exists()) {
      final finalSize = (await pdfFile.length()) / 1024;
      print(
          '⚠ PDF final : ${finalSize.toStringAsFixed(2)} Ko (objectif: $_targetSizeKB Ko)');
      return pdfFile;
    }

    throw Exception('Impossible de créer le PDF après $maxAttempts tentatives');
  }

// ── Helper champ PDF ───────────────────────────────────────
  pw.Widget _buildPdfField(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 9.sp,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: pw.BorderRadius.circular(4),
            color: PdfColors.grey100,
          ),
          child: pw.Text(
            value.trim().isEmpty ? '—' : value.trim(),
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Fonction de validation - VERSION CORRIGÉE
  void _valider() async {
    // Vérifier si un traitement est déjà en cours
    if (_isProcessing) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPieceType == null) {
      SnackBarService.warning('Veuillez sélectionner un type de pièce');
      return;
    }

    if (_selectedImages.isEmpty && _selectedPdfFile == null) {
      SnackBarService.warning('Veuillez ajouter des photos ou un fichier PDF');
      return;
    }

    // Activer le chargement local
    setState(() {
      _isProcessing = true;
    });

    bool isConnected = await hasInternetConnection();

    if (isConnected) {
      print('Connexion Internet disponible');
    } else {
      setState(() {
        _isProcessing = false;
      });
      SnackBarService.error('Pas de connexion Internet');
      return;
    }

    final service = FeaturesService();

    final isActive =
        await service.isFeatureActive(AppFeature.uploadPieceIdentite);

    if (isActive) {
      print('✅ Ajout de la Piece Identité');
    } else {
      Get.back();
      SnackBarService.error('❌ Ce service est momentanément indisponible');

      return;
    }

    File? pdfFile;

    try {
      controller.numero.value = _numeroController.text.trim();
      controller.typePieceId.value = _selectedPieceType!;

      // Créer ou compresser le PDF selon le mode
      if (_isPdfMode && _selectedPdfFile != null) {
        // Mode PDF : compresser le PDF sélectionné
        print('🔄 Compression du PDF sélectionné...');
        pdfFile = await _compressPdfToTarget(_selectedPdfFile!);
      } else if (_selectedImages.isNotEmpty) {
        // Mode Photos : créer un PDF à partir des images
        print('🔄 Création du PDF à partir des images...');
        pdfFile = await _createCompressedPdf(_selectedImages);
      } else {
        throw Exception('Aucun fichier sélectionné');
      }
      // Vérifier la taille finale
      final fileSize = await pdfFile.length();
      final fileSizeKB = (fileSize / 1024).toStringAsFixed(2);
      print('Taille finale du PDF : $fileSizeKB Ko');

      controller.fichier.value = pdfFile;
      controller.photoIdentite.value = _photoIdentite;
      // Soumettre
      await controller.soumettre();
      PiecesController controllerTest = Get.find();
      await controllerTest.fetchPieces();

      // Si la soumission réussit, réinitialiser le formulaire
      if (controller.isLoading.isFalse && mounted) {
        setState(() {
          _numeroController.clear();
          _selectedPieceType = null;
          _selectedImages.clear();
        });
      }
    } catch (e) {
      print('Erreur complète: $e');
      if (mounted) {
        SnackBarService.warning('Erreur lors de l\'envoi, veuillez réessayer');
      }
    } finally {
      // Désactiver le chargement local
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }

      // Nettoyer le fichier temporaire après l'envoi
      if (pdfFile != null && await pdfFile.exists()) {
        try {
          await pdfFile.delete();
          print('Fichier temporaire supprimé');
        } catch (e) {
          print('Erreur suppression fichier temporaire: $e');
        }
      }
    }
  }

  String? _validateNumero(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir le numéro de la pièce';
    }
    if (value.length < 5) {
      return 'Le numéro doit contenir au moins 5 caractères';
    }
    return null;
  }

  // Vérifier si le formulaire est désactivé
  bool get _isFormDisabled => _isProcessing || controller.isLoading.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _isFormDisabled ? null : () => Get.back(),
        ),
        title: Text(
          'Justificatif d\'identité',
          style: TextStyle(
            fontSize:
                MediaQuery.of(Get.context!).size.width > 600 ? 18.sp : 16.sp,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo[600],
        elevation: 0,
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // En-tête
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.verified_user,
                                size: 40, color: Colors.indigo[600]),
                            const SizedBox(height: 15),
                            Text('Vérification d\'identité',
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800])),
                            const SizedBox(height: 8),
                            Text(
                              'Renseignez les informations de votre pièce d\'identité',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 9.sp, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Formulaire
                      Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ✅ AJOUTE ICI
                            _buildPhotoIdentiteSection(),
                            const SizedBox(height: 16),

                            // Type de pièce
                            Text('Type de pièce d\'identité *',
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800])),
                            const SizedBox(height: 8),
                            Obx(() {
                              final typePieces =
                                  _typePieceController.listeTypePieces;

                              if (typePieces.isEmpty) {
                                return const Center(
                                  child: CupertinoActivityIndicator(),
                                );
                              }

                              return DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue: typePieces.any((e) =>
                                        e.id.toString() == _selectedPieceType)
                                    ? _selectedPieceType
                                    : null,
                                decoration: InputDecoration(
                                  hintText: 'Sélectionnez un type de pièce',
                                  prefixIcon: Icon(Icons.badge,
                                      color: Colors.indigo[600]),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                items: typePieces.map((piece) {
                                  return DropdownMenuItem<String>(
                                    enabled: !_isFormDisabled,
                                    value: piece.id.toString(),
                                    child: Text(piece.designation),
                                  );
                                }).toList(),
                                onChanged: _isFormDisabled
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _selectedPieceType = value;
                                        });
                                      },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Veuillez sélectionner un type';
                                  }
                                  return null;
                                },
                              );
                            }),

                            const SizedBox(height: 25),

                            // Numéro de pièce
                            Text('Numéro de la pièce *',
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800])),
                            const SizedBox(height: 8),
                            TextFormField(
                              textCapitalization: TextCapitalization.characters,
                              enabled: !_isFormDisabled,
                              controller: _numeroController,
                              onChanged: (val) => controller.numero.value = val,
                              decoration: InputDecoration(
                                hintText: 'Saisissez le numéro',
                                prefixIcon: Icon(Icons.perm_identity,
                                    color: Colors.indigo[600]),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              validator: _validateNumero,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(30),
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[A-Z0-9]')),
                              ],
                            ),

                            const SizedBox(height: 25),

                            // Photos
                            // Documents justificatifs (PHOTOS OU PDF)
                            Text('Joindre la piece *',
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800])),
                            const SizedBox(height: 8),

// Boutons de choix du mode (Photos ou PDF)
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _isFormDisabled
                                        ? null
                                        : () {
                                            setState(() {
                                              _isPdfMode = false;
                                              _selectedPdfFile = null;
                                            });
                                          },
                                    icon: Icon(
                                      Icons.camera_alt,
                                      color: !_isPdfMode
                                          ? Colors.white
                                          : Colors.indigo,
                                    ),
                                    label: Text(
                                      'Photos',
                                      style: TextStyle(
                                        color: !_isPdfMode
                                            ? Colors.white
                                            : Colors.indigo,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: !_isPdfMode
                                          ? Colors.indigo
                                          : Colors.white,
                                      side: BorderSide(
                                          color: Colors.indigo, width: 2),
                                      padding:  EdgeInsets.symmetric(
                                          vertical: 9.sp),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _isFormDisabled
                                        ? null
                                        : () {
                                            setState(() {
                                              _isPdfMode = true;
                                              _selectedImages.clear();
                                            });
                                          },
                                    icon: Icon(
                                      Icons.picture_as_pdf,
                                      color: _isPdfMode
                                          ? Colors.white
                                          : Colors.indigo,
                                    ),
                                    label: Text(
                                      'PDF',
                                      style: TextStyle(
                                        color: _isPdfMode
                                            ? Colors.white
                                            : Colors.indigo,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: _isPdfMode
                                          ? Colors.indigo
                                          : Colors.white,
                                      side: BorderSide(
                                          color: Colors.indigo, width: 2),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),

// MODE PDF
                            if (_isPdfMode)
                              Column(
                                children: [
                                  // Affichage du PDF sélectionné
                                  if (_selectedPdfFile != null)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 15),
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.green, width: 2),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.picture_as_pdf,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'PDF sélectionné',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  _selectedPdfFile!.path
                                                      .split('/')
                                                      .last,
                                                  style: TextStyle(
                                                    fontSize: 9.sp,
                                                    color: Colors.grey[700],
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                FutureBuilder<int>(
                                                  future: _selectedPdfFile!
                                                      .length(),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData) {
                                                      final sizeMB =
                                                          snapshot.data! /
                                                              (1024 * 1024);
                                                      return Text(
                                                        '${sizeMB.toStringAsFixed(2)} Mo',
                                                        style: TextStyle(
                                                          fontSize: 9.sp,
                                                          color:
                                                              Colors.grey[600],
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      );
                                                    }
                                                    return const SizedBox
                                                        .shrink();
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: _isFormDisabled
                                                ? null
                                                : () {
                                                    setState(() {
                                                      _selectedPdfFile = null;
                                                    });
                                                  },
                                            icon: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Bouton pour sélectionner un PDF
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: _selectedPdfFile != null
                                            ? Colors.green
                                            : Colors.indigo,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      color: _selectedPdfFile != null
                                          ? Colors.green[50]
                                          : Colors.indigo[50],
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          _selectedPdfFile != null
                                              ? Icons.check_circle
                                              : Icons.upload_file,
                                          size: 40,
                                          color: _selectedPdfFile != null
                                              ? Colors.green
                                              : Colors.indigo,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          _selectedPdfFile == null
                                              ? 'Sélectionner un fichier PDF'
                                              : 'PDF sélectionné avec succès',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 5),
                                        const SizedBox(height: 15),
                                        ElevatedButton.icon(
                                          onPressed: _isFormDisabled
                                              ? null
                                              : _pickPdfFile,
                                          icon: const Icon(Icons.folder_open),
                                          label: Text(_selectedPdfFile == null
                                              ? 'Parcourir'
                                              : 'Changer de fichier'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            else
                              // MODE PHOTOS (ton code existant)
                              Column(
                                children: [
                                  // Affichage des images sélectionnées
                                  if (_selectedImages.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 15),
                                      child: Column(
                                        children: [
                                          // Grille des images
                                          GridView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 10,
                                              mainAxisSpacing: 10,
                                              childAspectRatio: 1.2,
                                            ),
                                            itemCount: _selectedImages.length,
                                            itemBuilder: (context, index) {
                                              return Stack(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                          color: Colors.green,
                                                          width: 2),
                                                      image: DecorationImage(
                                                        image: FileImage(
                                                            _selectedImages[
                                                                index]),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 5,
                                                    right: 5,
                                                    child: IconButton(
                                                      onPressed: _isFormDisabled
                                                          ? null
                                                          : () => _removeImage(
                                                              index),
                                                      icon: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: _isFormDisabled
                                                              ? Colors.grey
                                                              : Colors.red,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: const Icon(
                                                          Icons.close,
                                                          color: Colors.white,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 5,
                                                    left: 5,
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black
                                                            .withOpacity(0.6),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Text(
                                                        'Photo ${index + 1}',
                                                        style:  TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 9.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 10),
                                          ElevatedButton.icon(
                                            onPressed: _isFormDisabled
                                                ? null
                                                : _removeAllImages,
                                            icon:
                                                const Icon(Icons.delete_sweep),
                                            label: const Text('Supprimer tout'),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Bouton pour ajouter une photo
                                  Center(
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: _selectedImages.isNotEmpty
                                                ? Colors.green
                                                : Colors.indigo,
                                            width: 2),
                                        borderRadius: BorderRadius.circular(12),
                                        color: _selectedImages.isNotEmpty
                                            ? Colors.green[50]
                                            : Colors.indigo[50],
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            _selectedImages.isNotEmpty
                                                ? Icons.add_photo_alternate
                                                : Icons.camera_alt_outlined,
                                            size: 40,
                                            color: _selectedImages.isNotEmpty
                                                ? Colors.green
                                                : Colors.indigo,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            _selectedImages.isEmpty
                                                ? 'Prendre une photo de votre pièce'
                                                : 'Ajouter une autre photo',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            '${_selectedImages.length}/$_maxImages photo(s) ajoutée(s)',
                                            style: TextStyle(
                                                color: Colors.grey[600]),
                                          ),
                                          const SizedBox(height: 15),
                                          ElevatedButton.icon(
                                            onPressed: _isFormDisabled ||
                                                    _selectedImages.length >=
                                                        _maxImages
                                                ? null
                                                : _showImageSourceDialog,
                                            icon: const Icon(Icons.add_a_photo),
                                            label: Text(_selectedImages.isEmpty
                                                ? 'Ajouter une photo'
                                                : 'Ajouter une photo'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            const SizedBox(height: 35),

                            // Soumettre
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _isFormDisabled ? null : _valider,
                                child: _isProcessing
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CupertinoActivityIndicator(
                                            color: globalColor,
                                            radius: 12,
                                          ),
                                          const SizedBox(width: 15),
                                           Text(
                                            'Traitement en cours...',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 9.sp,
                                            ),
                                          ),
                                        ],
                                      )
                                    : controller.isLoading.value
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CupertinoActivityIndicator(
                                                color: globalColor,
                                                radius: 12,
                                              ),
                                              const SizedBox(width: 15),
                                               Text(
                                                'Envoi en cours...',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 9.sp,
                                                ),
                                              ),
                                            ],
                                          )
                                        : const Text(
                                            'VALIDER',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,

                                            ),
                                          ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Overlay de chargement pour bloquer toute interaction
              if (_isFormDisabled)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child:  Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CupertinoActivityIndicator(radius: 20),
                            SizedBox(height: 15),
                            Text(
                              'Traitement en cours...',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Veuillez patienter',
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
