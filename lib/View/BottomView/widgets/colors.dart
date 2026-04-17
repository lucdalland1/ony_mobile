import 'package:flutter/material.dart';

class C {
  static const bg           = Color(0xFFFFFFFF);
  static const primary      = Color(0xFF1A3CBF);
  static const cardDark     = Color(0xFF1B3BAD);
  static const cardMid      = Color(0xFF2748C8);
  static const cardLight    = Color(0xFF3358D4);
  static const textDark     = Color(0xFF1A1A2E);
  static const textGrey     = Color(0xFF9AA0B2);
  static const navGrey      = Color(0xFFB0B8C8);
  static const green        = Color(0xFF22C55E);
  static const badgeGreen   = Color(0xFF16A34A);
  static const divider      = Color(0xFFF1F3F8);
  static const icoTransfBg  = Color(0xFF1E40AF);
  static const icoTransf    = Color(0xFFFFFFFF);
  static const icoMarchBg   = Color(0xFFDBEAFE);
  static const icoMarch     = Color(0xFF3B82F6);
  static const icoCartesBg  = Color(0xFFFEF3C7);
  static const icoCartes    = Color(0xFFF59E0B);
  static const icoRechBg    = Color(0xFFD1FAE5);
  static const icoRech      = Color(0xFF10B981);
  static const txIconBg     = Color(0xFFEEF2FF);
  static const txIcon       = Color(0xFF4F6EF7);
}

double rf(BuildContext ctx, double base) {
  final w = MediaQuery.of(ctx).size.width.clamp(300.0, 500.0);
  return base * (w / 390.0);
}