import 'package:get/get.dart';
import 'package:onyfast/Api/type_piece_service_Api.dart';
import 'package:onyfast/model/type_piece/typepiece.dart';

class TypePieceController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<TypePieceModel> listeTypePieces = <TypePieceModel>[].obs;

  final TypePieceService _service = TypePieceService();




  Future<void> getAllTypePieces() async {
    try {
      final data = await _service.getAllRaw();
      listeTypePieces.value =
          data.map((e) => TypePieceModel.fromJson(e)).toList();

          print(listeTypePieces.value.length);
    } catch (e) {
    }
  }

  @override
  void onInit() {
    super.onInit();
    getAllTypePieces();
  }
}
