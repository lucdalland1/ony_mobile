import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/View/Notification/notification.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import '../../../../Color/app_color_model.dart';
import '../../../../Widget/container.dart';
import '../../../../Widget/icon.dart';
import '../merchandcontroller.dart';
import '../../model/merchand.dart';
import '../widget/merchand_icon.dart';
import '../widget/serch.dart';
import 'transaction.dart';

class SubTypeSelectionView extends StatefulWidget {
  final MerchantType merchantType;

  const SubTypeSelectionView({super.key, required this.merchantType});

  @override
  State<SubTypeSelectionView> createState() => _SubTypeSelectionViewState();
}

class _SubTypeSelectionViewState extends State<SubTypeSelectionView> {
  final _searchController = TextEditingController();
  final _merchantController = Get.find<MerchantController>();
  late List<String> _filteredSubTypes;

  @override
  void initState() {
    super.initState();
    _filteredSubTypes = widget.merchantType.subTypes ?? [];
  }

  @override
  Widget build(BuildContext context) {


    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColorModel.Bluecolor242,
        leading: BackButton(color: Colors.white),
        title: Text("Marchand", 
          style: TextStyle(
            fontSize: 17.dp, 
            fontWeight: FontWeight.bold, 
            color: AppColorModel.WhiteColor
          ),
        ),
        centerTitle: true,
        actions: [
          NotificationWidget(),
        ],
      ),
      body: Column(
        children: [
        
            MerchantSearchBar(
            controller: _searchController,
            hintText: 'Rechercher un merchand',
            onChanged: (query) {
              setState(() {
                _filteredSubTypes = _merchantController.filterSubTypes(
                  widget.merchantType, 
                  query
                );
              });
            },
          ),
          Expanded(
            child: _filteredSubTypes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: _filteredSubTypes.length,
                    itemBuilder: (context, index) {
                      final subType = _filteredSubTypes[index];
                      return _buildSubTypeCard(subType);
                    },
                  ),
          ),
        ]
      ) ,
    );
  }

  Widget _buildSubTypeCard(String subType) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.dp, vertical: 8.dp),
      // color: widget.merchantType.color.withOpacity(0.1),
      child: ListTile(
        leading: MerchantIcon(type: widget.merchantType, size: 39.dp),
        title: Text(
          subType,
          style: TextStyle(
            color: widget.merchantType.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: widget.merchantType.color),
        onTap: () {
          Get.to(
            () => TransactionView(
              merchantType: widget.merchantType,
              subType: subType,
            ),
            transition: Transition.rightToLeft,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 10.dp,
            color: widget.merchantType.color.withOpacity(0.3),
          ),
     SizedBox(height: 16.h),
          Text(
            'Aucun résultat trouvé',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16.dp,
            ),
          ),
          if (_searchController.text.isNotEmpty)
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _filteredSubTypes = widget.merchantType.subTypes ?? [];
                });
              },
              child: Text(
                'Réinitialiser la recherche',
                style: TextStyle(color: widget.merchantType.color),
              ),
            ),
        ],
      ),
    );
  }
}


        