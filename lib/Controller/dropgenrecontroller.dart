import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DropGenreController extends GetxController {
  var selectedGenre = ''.obs; // Variable observée pour le genre
  final TextEditingController nameController = TextEditingController(); // Controller pour le nom

  // Liste des genres
  final List<String> genres = ['Homme', 'Femme'];

  void updateGenre(String? genre) {
    if (genre != null) {
      selectedGenre.value = genre;
    }
  }
}
