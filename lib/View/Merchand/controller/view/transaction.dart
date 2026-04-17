import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:onyfast/View/Notification/notification.dart';
import 'package:onyfast/Widget/alerte.dart';
import 'package:onyfast/Widget/notificationWidget.dart';
import '../../../../Color/app_color_model.dart';
import '../../../../Widget/container.dart';
import '../transaction_controller.dart';
import '../../model/merchand.dart';
import '../widget/merchand_icon.dart';
class TransactionView extends StatefulWidget {
  final MerchantType merchantType;
  final String subType;

  const TransactionView({
    super.key,
    required this.merchantType,
    required this.subType,
  });

  @override
  State<TransactionView> createState() => _TransactionViewState();
}

class _TransactionViewState extends State<TransactionView> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _transactionController = Get.put(TransactionController());

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
      body: Padding(
        padding:  EdgeInsets.all(24.dp),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                MerchantIcon(
                  type: widget.merchantType,
                  size: 80.dp,
                ),
               SizedBox(height: 03.h),
                Text(
                  '${widget.merchantType.displayName} > ${widget.subType}',
                  style: TextStyle(
                    fontSize: 17.dp,
                    color: widget.merchantType.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
               SizedBox(height: 05.h),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Montant',
                    prefixIcon: Icon(
                      Icons.money,
                      color: widget.merchantType.color,
                    ),
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: widget.merchantType.color,
                        width: 2.w,
                      ),
                    ),
                    labelStyle: TextStyle(
                      color: widget.merchantType.color,
                    ),
                  ),
                
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un montant';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Montant invalide';
                    }
                    return null;
                  },
                ),
               SizedBox(height: 44.h),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorModel.Bluecolor242,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.dp),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _transactionController.addTransaction(
                          widget.merchantType,
                          widget.subType,
                          double.parse(_amountController.text),
                        );
                        Get.back();
 SnackBarService.warning(    

                        title:'Transaction enregistrée',
                          '${widget.subType} - ${_amountController.text}F',
                          
                        );
                      }
                    },
                    child: Text(
                      'VALIDER',
                      style: TextStyle(
                        fontSize: 15.dp,
                        fontWeight: FontWeight.bold, color: AppColorModel.WhiteColor
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
