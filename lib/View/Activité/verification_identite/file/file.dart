import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';



class PdfPickerPage extends StatefulWidget {
  const PdfPickerPage({super.key});

  @override
  State<PdfPickerPage> createState() => _PdfPickerPageState();
}

class _PdfPickerPageState extends State<PdfPickerPage> {
  String? _fileName;
  String? _filePath;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  /// 🎯 Choix entre caméra, galerie ou PDF
  Future<void> _showChoiceDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Prendre une photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Depuis la galerie"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text("Choisir un fichier PDF"),
                onTap: () {
                  Navigator.pop(context);
                  pickPDF();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 📷 Choix image (caméra ou galerie)
  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: source, imageQuality: 80);

    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _fileName = picked.name;
        _filePath = picked.path;
      });
    }
  }

  /// 📄 Choix fichier PDF
  Future<void> pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _fileName = result.files.single.name;
        _filePath = result.files.single.path!;
        _imageFile = null; // On ne veut pas afficher une image ici
      });

      // Ouvrir le PDF automatiquement
      OpenFile.open(_filePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sélection de fichier ou image')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _showChoiceDialog,
              icon: const Icon(Icons.add),
              label: const Text("Choisir un fichier"),
            ),
            const SizedBox(height: 20),
            if (_fileName != null)
              Column(
                children: [
                  const Text('Fichier sélectionné :'),
                  Text(
                    _fileName!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (_imageFile != null)
                    Image.file(_imageFile!, height: 150),
                ],
              )
          ],
        ),
      ),
    );
  }
}
