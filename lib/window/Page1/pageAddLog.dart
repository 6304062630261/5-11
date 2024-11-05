import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import '../../../imageOCR/pick_picture.dart';
import '../../../database/db_manage.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddTransaction extends StatefulWidget {
  const AddTransaction({super.key});

  @override
  _AddTransactionState createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  final _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  final ImageOcrHelper _imageOcrHelper = ImageOcrHelper();
  final int maxMemo = 36;
  int currentMemo = 0;

  String? _transactionType = '1';

  @override
  void dispose() {
    _amountController.dispose();
    _dateTimeController.dispose();
    _memoController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  Future<void> _pickImageAndExtractText() async {
    final extractedData = await _imageOcrHelper.pickImageAndExtractText();
    setState(() {
      _amountController.text = extractedData['amount'] ?? '';
      _dateTimeController.text = extractedData['datetime'] ?? '';
      _memoController.text = extractedData['memo'] ?? '';
      _referralController.text = extractedData['referral'] ?? '';
      _formKey.currentState?.fields['transactionType']?.didChange('1');
      _transactionType = '1';
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(localizations.expenseIncomeLog),
        elevation: 500.0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 9, 209, 220), Color(0xFEF7FFFF)
              ], // ไล่สีพื้นหลัง
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: Text(localizations.income, style: TextStyle(fontSize: 16)),
                      selected: _transactionType == "0",
                      selectedColor: Colors.greenAccent[700],
                      backgroundColor: Colors.grey[200],
                      onSelected: (selected) {
                        setState(() {
                          _transactionType = selected ? "0" : "1";
                          _formKey.currentState?.fields['transactionType']?.didChange(_transactionType);
                        });
                      },
                    ),
                    SizedBox(width: 15),
                    ChoiceChip(
                      label: Text(localizations.expense, style: TextStyle(fontSize: 16)),
                      selected: _transactionType == "1",
                      selectedColor: Colors.redAccent,
                      backgroundColor: Colors.grey[200],
                      onSelected: (selected) {
                        setState(() {
                          _transactionType = selected ? "1" : "0";
                          _formKey.currentState?.fields['transactionType']?.didChange(_transactionType);
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),

                Text(localizations.appointmentDate, style: TextStyle(fontSize: 16)),
                FormBuilderDateTimePicker(
                  name: 'dateTimeController',
                  controller: _dateTimeController,
                  initialValue: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  inputType: InputType.date,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    isDense: true,
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 20),

                if (_transactionType == "1") ...[
                  Text(localizations.category, style: TextStyle(fontSize: 16)),
                  FormBuilderDropdown<String>(
                    name: 'category',
                    decoration: InputDecoration(
                      hintText: localizations.selectCategory,
                      border: UnderlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 'Food', child: Text(AppLocalizations.of(context)!.food)),
                      DropdownMenuItem(value: 'Travel expenses', child: Text(AppLocalizations.of(context)!.travelexpenses)),
                      DropdownMenuItem(value: 'Water bill', child: Text(AppLocalizations.of(context)!.waterbill)),
                      DropdownMenuItem(value: 'Electricity bill', child: Text(AppLocalizations.of(context)!.electricitybill)),
                      DropdownMenuItem(value: 'Internet cost', child: Text(AppLocalizations.of(context)!.internetcost)),
                      DropdownMenuItem(value: 'House cost', child: Text(AppLocalizations.of(context)!.housecost)),
                      DropdownMenuItem(value: 'Car fare', child: Text(AppLocalizations.of(context)!.carfare)),
                      DropdownMenuItem(value: 'Gasoline cost', child: Text(AppLocalizations.of(context)!.gasolinecost)),
                      DropdownMenuItem(value: 'Medical expenses', child: Text(AppLocalizations.of(context)!.medicalexpenses)),
                      DropdownMenuItem(value: 'Beauty expenses', child: Text(AppLocalizations.of(context)!.beautyexpenses)),
                      DropdownMenuItem(value: 'Other', child: Text(AppLocalizations.of(context)!.other)),
                    ],
                    validator: FormBuilderValidators.required(errorText: localizations.pleaseselectacategory),
                  ),
                  SizedBox(height: 20),
                ],

                Text(localizations.amount, style: TextStyle(fontSize: 16)),
                FormBuilderTextField(
                  name: 'amountController',
                  controller: _amountController,
                  decoration: InputDecoration(
                    hintText: localizations.pleaseentertheamountofmoney,
                    border: UnderlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [LengthLimitingTextInputFormatter(13)],
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.numeric(),
                  ]),
                ),
                SizedBox(height: 20),

                Text(localizations.memo, style: TextStyle(fontSize: 16)),
                FormBuilderTextField(
                  name: 'memoController',
                  controller: _memoController,
                  decoration: InputDecoration(
                    hintText: localizations.memoDescription,
                    border: UnderlineInputBorder(),
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(maxMemo)],

                    onChanged: (value) {
                    setState(() {
                      currentMemo = value?.length ?? 0;
                    });
                    },
                ),
                SizedBox(height: 5),
                Text('$currentMemo / $maxMemo',style: TextStyle(fontSize: 12,color: currentMemo >= maxMemo ? Colors.red : Colors.grey,),),
                SizedBox(height: 20),

                Center(
                  child: ElevatedButton(
                    onPressed: _pickImageAndExtractText,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      backgroundColor: Colors.grey[200],
                      side: BorderSide(color: Colors.black54, width: 1),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.image, color: Colors.black54),
                          SizedBox(width: 10),
                          Text(
                            localizations.pickImage,
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),


                SizedBox(height: 20),

                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.saveAndValidate()) {
                        // Check for duplicate referral
                        bool referralExists = await DatabaseManagement.instance.checkReferralExists(_referralController.text);
                        if (referralExists) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations.thissliphasalreadybeenrecorded)));
                          return;
                        }

                        // Process data for saving
                        DateTime dateTimeValue = _formKey.currentState!.fields['dateTimeController']?.value ?? DateTime.now();
                        String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTimeValue);
                        var category = _transactionType == '0' ? "IC" : _formKey.currentState?.value['category'];
                        var amount = double.parse(_amountController.text);
                        var memo = _memoController.text;

                        Map<String, dynamic> row = {
                          'date_user': formattedDate,
                          'amount_transaction': amount,
                          'type_expense': _transactionType == '1' ? 1 : 0,
                          'memo_transaction': memo,
                          'ID_type_transaction': await DatabaseManagement.instance.getTypeTransactionId(category),
                          'referral_code': _referralController.text,
                        };

                        await DatabaseManagement.instance.insertTransaction(row);
                        Navigator.pop(context, true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      backgroundColor: Color.fromARGB(255, 125, 221, 225) ,
                      side: BorderSide(color: Colors.black54, width: 1),
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40), // ขยายขนาดปุ่ม
                     ),
                    child: Text(localizations.save,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,color: Colors.black54), // ขนาดและน้ำหนักฟอนต์ที่ใหญ่ขึ้น
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
