// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/Controller/features/features_controller.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/utils/testInternet.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:onyfast/Controller/verifier_identite/soumissionjustificatif_controller.dart';
import 'package:onyfast/Controller/verifier_identite/type_justificatif.dart';

class JustificatifDomicilePage extends StatefulWidget {
  const JustificatifDomicilePage({super.key});

  @override
  State<JustificatifDomicilePage> createState() =>
      _JustificatifDomicilePageState();
}

class _JustificatifDomicilePageState extends State<JustificatifDomicilePage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _numeroDocumentController = TextEditingController();

  String? _selectedTypeDocument;

  // NOUVELLES VARIABLES - Logique du justificatif d'identité
  final List<File> _selectedImages = [];
  File? _selectedPdfFile;
  bool _isPdfMode = false;
  final int _maxImages = 2;
  final int _targetSizeKB = 400;
  final int _maxPdfSizeKB = 2048; // 2 Mo max pour le PDF
  bool _isProcessing = false;

  final controller = Get.put(JustificatifDomicileController());
  final ImagePicker _picker = ImagePicker();

  late AnimationController _uploadAnimationController;
  late AnimationController _fadeController;
  late Animation<double> _uploadAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    print('=== INITIALISATION ===');
    controller.fetchJustificatifs();

    _uploadAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _uploadAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _uploadAnimationController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    ValidationTokenController.to.validateToken();

    print('=== FIN INITIALISATION ===');
  }

  @override
  void dispose() {
    _uploadAnimationController.dispose();
    _fadeController.dispose();
    _numeroDocumentController.dispose();
    super.dispose();
  }

  // FONCTION DE COMPRESSION PDF - Validation stricte
  Future<File> _compressPdfToTarget(File inputPdf) async {
    print('\n📦 Vérification du PDF...');

    try {
      final fileSize = await inputPdf.length();
      final fileSizeKB = fileSize / 1024;
      final fileSizeMB = fileSize / (1024 * 1024);

      print(
          '📊 Taille du PDF : ${fileSizeMB.toStringAsFixed(2)} Mo (${fileSizeKB.toStringAsFixed(0)} Ko)');
      print(
          '🎯 Limite : ${(_maxPdfSizeKB / 1024).toStringAsFixed(0)} Mo ($_maxPdfSizeKB Ko)');

      if (fileSizeKB > _maxPdfSizeKB) {
        print('❌ PDF trop volumineux !');
        throw Exception(
            'Le fichier PDF dépasse la taille autorisée (${fileSizeMB.toStringAsFixed(2)} Mo). '
            'Maximum : ${(_maxPdfSizeKB / 1024).toStringAsFixed(0)} Mo.');
      }

      print('✅ PDF conforme !');
      return inputPdf;
    } catch (e) {
      print('❌ Erreur : $e');
      rethrow;
    }
  }

  // FONCTION DE SÉLECTION PDF - Avec validation stricte
  Future<void> _pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        File pdfFile = File(result.files.single.path!);

        final fileSize = await pdfFile.length();
        final fileSizeKB = fileSize / 1024;
        final fileSizeMB = fileSize / (1024 * 1024);

        print('📄 PDF sélectionné : ${fileSizeMB.toStringAsFixed(2)} Mo');

        // Vérification stricte
        if (fileSizeKB > _maxPdfSizeKB) {
          print(
              '❌ PDF refusé : ${fileSizeKB.toStringAsFixed(0)} Ko > $_maxPdfSizeKB Ko');

          SnackBarService.error('PDF trop volumineux !\n'
              'Taille : ${fileSizeMB.toStringAsFixed(2)} Mo\n'
              'Maximum autorisé : ${(_maxPdfSizeKB / 1024).toStringAsFixed(0)} Mo\n\n'
              'Veuillez sélectionner un fichier plus léger ou utilisez le mode "Photos".');

          return;
        }

        print('✅ PDF conforme');

        setState(() {
          _selectedPdfFile = pdfFile;
          _isPdfMode = true;
          _selectedImages.clear();
        });

        _uploadAnimationController.forward();
        _fadeController.forward();

        SnackBarService.warning('PDF sélectionné avec succès !\n'
            'Taille : ${fileSizeMB.toStringAsFixed(2)} Mo (${fileSizeKB.toStringAsFixed(0)} Ko)');
      }
    } catch (e) {
      print('Erreur sélection PDF: $e');
      SnackBarService.warning('Erreur lors de la sélection du fichier PDF');
    }
  }

  // FONCTION DE PRISE DE PHOTO
  void _pickImage(ImageSource source) async {
    if (_selectedImages.length >= _maxImages) {
      SnackBarService.warning('Vous pouvez ajouter maximum $_maxImages photos');
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1600,
      );

      if (photo != null) {
        setState(() {
          _selectedImages.add(File(photo.path));
        });

        if (_selectedImages.length == 1) {
          _uploadAnimationController.forward();
          _fadeController.forward();
        }
      }
    } catch (e) {
      SnackBarService.warning(source == ImageSource.camera
          ? 'Erreur lors de la capture de la photo'
          : 'Erreur lors de la sélection de la photo');
      print('Erreur pick image: $e');
    }
  }

  // DIALOGUE DE CHOIX SOURCE IMAGE
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
              leading: const Icon(Icons.camera_alt,
                  color: Color.fromARGB(255, 6, 11, 116)),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library,
                  color: Color.fromARGB(255, 6, 11, 116)),
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

  // SUPPRIMER UNE IMAGE
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);

      if (_selectedImages.isEmpty) {
        _uploadAnimationController.reset();
        _fadeController.reset();
      }
    });
  }

  // SUPPRIMER TOUT
  void _removeAllImages() {
    setState(() {
      _selectedImages.clear();
      _selectedPdfFile = null;
      _isPdfMode = false;
      _uploadAnimationController.reset();
      _fadeController.reset();
    });
  }

  // COMPRESSION IMAGE
  Future<Uint8List> _compressImage(File imageFile, int quality) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Impossible de décoder l\'image');
      }

      if (image.width > 1000) {
        image = img.copyResize(image, width: 1000);
      }

      return Uint8List.fromList(img.encodeJpg(image, quality: quality));
    } catch (e) {
      print('Erreur compression image: $e');
      rethrow;
    }
  }

  // CRÉER PDF COMPRESSÉ À PARTIR DES IMAGES
  Future<File> _createCompressedPdf(List<File> images) async {
    int quality = 75;
    File? pdfFile;
    int attempts = 0;
    final maxAttempts = 5;

    while (attempts < maxAttempts) {
      try {
        final pdf = pw.Document();

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

        final output = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        pdfFile = File('${output.path}/justificatif_domicile_$timestamp.pdf');
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

        if (quality < 15) {
          break;
        }
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

  // FONCTION DE VALIDATION - Logique du justificatif d'identité
  void _valider() async {
    if (_isProcessing) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTypeDocument == null) {
      SnackBarService.warning('Veuillez sélectionner un type de justificatif');
      return;
    }

    if (_selectedImages.isEmpty && _selectedPdfFile == null) {
      SnackBarService.warning('Veuillez ajouter des photos ou un fichier PDF');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    bool isConnected = await hasInternetConnection();

    if (!isConnected) {
      setState(() {
        _isProcessing = false;
      });
      SnackBarService.error('Pas de connexion Internet');
      return;
    }

    final service = FeaturesService();
    final isActive =
        await service.isFeatureActive(AppFeature.uploadJustificatifDomicile);

    if (!isActive) {
      setState(() {
        _isProcessing = false;
      });
      Get.back();
      SnackBarService.error('❌ Ce service est momentanément indisponible');
      return;
    }

    File? pdfFile;

    try {
      // Créer ou compresser le PDF selon le mode
      if (_isPdfMode && _selectedPdfFile != null) {
        print('🔄 Compression du PDF sélectionné...');
        pdfFile = await _compressPdfToTarget(_selectedPdfFile!);
      } else if (_selectedImages.isNotEmpty) {
        print('🔄 Création du PDF à partir des images...');
        pdfFile = await _createCompressedPdf(_selectedImages);
      } else {
        throw Exception('Aucun fichier sélectionné');
      }

      final fileSize = await pdfFile.length();
      final fileSizeKB = (fileSize / 1024).toStringAsFixed(2);
      print('Taille finale du PDF : $fileSizeKB Ko');

      // Soumettre
      final soumis = Get.put(SoumissionJustificatifController());
      await soumis.soumettre(
        fichier: pdfFile,
        typeIdString: _selectedTypeDocument!,
      );

      if (mounted) {
        setState(() {
          _numeroDocumentController.clear();
          _selectedTypeDocument = null;
          _selectedImages.clear();
          _selectedPdfFile = null;
          _isPdfMode = false;
        });
      }
    } catch (e) {
      print('Erreur complète: $e');
      if (mounted) {
        SnackBarService.warning('Erreur lors de l\'envoi, veuillez réessayer');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }

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

  // Vérifier si le formulaire est désactivé
  bool get _isFormDisabled => _isProcessing || controller.isLoading.value;
  bool get _hasSelectedFile =>
      _selectedImages.isNotEmpty || _selectedPdfFile != null;

  // WIDGET SECTION UPLOAD
  Widget _buildUploadSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color.fromARGB(255, 6, 11, 116).withOpacity(0.05),
            const Color.fromARGB(255, 6, 11, 116).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color.fromARGB(255, 6, 11, 116).withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 6, 11, 116).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 6, 11, 116).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_upload_outlined,
              size: 48,
              color: const Color.fromARGB(255, 6, 11, 116),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Joindre votre document',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 6, 11, 116),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choisissez Photos ou PDF',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),

          // Boutons de choix du mode
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
                        : const Color.fromARGB(255, 6, 11, 116),
                  ),
                  label: Text(
                    'Photos',
                    style: TextStyle(
                      color: !_isPdfMode
                          ? Colors.white
                          : const Color.fromARGB(255, 6, 11, 116),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: !_isPdfMode
                        ? const Color.fromARGB(255, 6, 11, 116)
                        : Colors.white,
                    side: const BorderSide(
                        color: Color.fromARGB(255, 6, 11, 116), width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                        : const Color.fromARGB(255, 6, 11, 116),
                  ),
                  label: Text(
                    'PDF',
                    style: TextStyle(
                      color: _isPdfMode
                          ? Colors.white
                          : const Color.fromARGB(255, 6, 11, 116),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _isPdfMode
                        ? const Color.fromARGB(255, 6, 11, 116)
                        : Colors.white,
                    side: const BorderSide(
                        color: Color.fromARGB(255, 6, 11, 116), width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // MODE PDF
          if (_isPdfMode)
            ElevatedButton.icon(
              onPressed: _isFormDisabled ? null : _pickPdfFile,
              icon: const Icon(Icons.folder_open),
              label: const Text('Sélectionner un PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 6, 11, 116),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            )
          else
            // MODE PHOTOS
            ElevatedButton.icon(
              onPressed: _isFormDisabled || _selectedImages.length >= _maxImages
                  ? null
                  : _showImageSourceDialog,
              icon: const Icon(Icons.add_a_photo),
              label: Text(_selectedImages.isEmpty
                  ? 'Ajouter une photo'
                  : 'Ajouter une photo (${_selectedImages.length}/$_maxImages)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 6, 11, 116),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilePreview() {
    return AnimatedBuilder(
      animation: _uploadAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _uploadAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.withOpacity(0.1),
                  Colors.green.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: Colors.green.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Affichage PDF
                if (_selectedPdfFile != null)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PDF sélectionné',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 9.sp,
                                color: Colors.green[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedPdfFile!.path.split('/').last,
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: Colors.green[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            FutureBuilder<int>(
                              future: _selectedPdfFile!.length(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final sizeMB = snapshot.data! / (1024 * 1024);
                                  return Text(
                                    '${sizeMB.toStringAsFixed(2)} Mo',
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _isFormDisabled ? null : _removeAllImages,
                        icon: Icon(
                          Icons.close,
                          color:
                              _isFormDisabled ? Colors.grey : Colors.red[400],
                        ),
                      ),
                    ],
                  ),

                // Affichage Photos
                if (_selectedImages.isNotEmpty) ...[
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green, width: 2),
                              image: DecorationImage(
                                image: FileImage(_selectedImages[index]),
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
                                  : () => _removeImage(index),
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: _isFormDisabled
                                      ? Colors.grey
                                      : Colors.red,
                                  shape: BoxShape.circle,
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Photo ${index + 1}',
                                style:  TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.bold,
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
                    onPressed: _isFormDisabled ? null : _removeAllImages,
                    icon: const Icon(Icons.delete_sweep),
                    label: const Text('Supprimer tout'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormFields() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
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
            child: DropdownButtonFormField<String>(
              value: _selectedTypeDocument,
              decoration: InputDecoration(
                labelText: 'Type de justificatif',
                labelStyle: TextStyle(
                  color: const Color.fromARGB(255, 6, 11, 116),
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(
                  Icons.description,
                  color: const Color.fromARGB(255, 6, 11, 116),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              items: controller.justificatifs.map((justif) {
                return DropdownMenuItem<String>(
                  enabled: !_isFormDisabled,
                  value: justif.id.toString(),
                  child: Text(
                    justif.designation,
                    style:  TextStyle(fontSize: 9.sp),
                  ),
                );
              }).toList(),
              onChanged: _isFormDisabled
                  ? null
                  : (value) {
                      print('Type de document sélectionné: $value');
                      setState(() {
                        _selectedTypeDocument = value;
                      });
                    },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez sélectionner un type de justificatif';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildValidateButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: (_isFormDisabled || !_hasSelectedFile)
              ? [Colors.grey[300]!, Colors.grey[400]!]
              : [
                  const Color.fromARGB(255, 6, 11, 116),
                  const Color.fromARGB(255, 8, 15, 140),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: (_isFormDisabled || !_hasSelectedFile)
            ? []
            : [
                BoxShadow(
                  color: const Color.fromARGB(255, 6, 11, 116).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: (_isFormDisabled || !_hasSelectedFile) ? null : _valider,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isProcessing
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:  [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: CupertinoActivityIndicator(
                      color: Colors.white,
                      radius: 12,
                    ),
                  ),
                  SizedBox(width: 15),
                  Text(
                    'Traitement en cours...',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 9.sp,
                    ),
                  ),
                ],
              )
            : controller.isLoading.value
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: CupertinoActivityIndicator(
                          color: Colors.white,
                          radius: 12,
                        ),
                      ),
                      SizedBox(width: 15),
                      Text(
                        'Envoi en cours...',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  )
                : Text(
                    "VALIDER LE JUSTIFICATIF",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
              color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Justificatif de Domicile',
          style: TextStyle(
            color: Colors.white,
            fontSize:
                MediaQuery.of(Get.context!).size.width > 600 ? 18.sp : 16.sp,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 6, 11, 116),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 6, 11, 116),
                const Color.fromARGB(255, 8, 15, 140),
              ],
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Obx(() {
          if (controller.isLoading.value && !_isProcessing) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const CupertinoActivityIndicator(
                      color: Color.fromARGB(255, 6, 11, 116),
                      radius: 15,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Chargement...',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header avec icône
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 6, 11, 116)
                                      .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.description,
                                  size: 40,
                                  color: const Color.fromARGB(255, 6, 11, 116),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Document Justificatif',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ajoutez votre document puis renseignez les informations',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Section Upload
                        if (!_hasSelectedFile) _buildUploadSection(),

                        // Prévisualisation du fichier
                        if (_hasSelectedFile) _buildFilePreview(),

                        // Champs du formulaire
                        if (_hasSelectedFile) _buildFormFields(),

                        // Bouton de validation
                        _buildValidateButton(),

                        // Notes importantes
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.amber[700],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Important',
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber[800],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '• Le document doit être lisible et complet\n'
                                '• Formats acceptés: PDF (max 2 Mo) ou Photos\n'
                                '• L\'adresse doit correspondre exactement',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: Colors.amber[800],
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Veuillez patienter',
                                style: TextStyle(
                                  fontSize: 14,
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
          );
        }),
      ),
    );
  }
}
