// ignore: file_names
import 'package:accordion/accordion_section.dart';
import 'package:flutter/material.dart';
import 'package:onyfast/View/Epargne/epargne%20group%C3%A9/widget/body.dart';
import 'package:onyfast/model/Epargne/epargnegroupe.dart';

class CustomAccordion extends AccordionSection {
  final Groupe groupe;
  CustomAccordion({super.key ,required this.groupe})
      : super(
          isOpen: true,
          headerBackgroundColor: const Color(0xFF0A2149),
          headerBackgroundColorOpened: const Color(0xFF0A2149).withOpacity(0.2),
          headerBorderColor: Colors.black54,
          headerBorderColorOpened: Colors.black54,
          contentVerticalPadding: 20,
          leftIcon: const Icon(Icons.circle, color: Colors.white),
          header: Text(
            groupe.nom,
            style: TextStyle(
              color: Color(0xffffffff),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: body(groupe:groupe,),
        );
}
