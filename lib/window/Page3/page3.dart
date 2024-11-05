import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'Income_list.dart';
import 'package:collection/collection.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class Page3 extends StatefulWidget {
  @override
  _Page3State createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  String selectedPeriod = 'Day'; // ตัวแปรสำหรับเก็บค่าตัวเลือก
  DateTime currentDate = DateTime.now(); // วันที่ปัจจุบัน
  String? selectedDate;
  DateTime? startDate;
  DateTime? endDate;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    selectedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentDate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(localizations.wallet)),
        elevation: 500.0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade100, Colors.pink.shade100], // ไล่สีพื้นหลัง
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color:  Colors.pink[300],
            height: 1.0,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                selectedPeriod = value;
                selectedDate = null; // รีเซ็ต selectedDate
                if (value != 'Custom') {
                  startDate = null;
                  endDate = null;
                  // เซ็ตให้เลือกปุ่มแรกของ GestureDetector
                  if (selectedPeriod == 'Day') {
                    selectedDate = DateFormat('yyyy-MM-dd').format(currentDate); // ตั้งค่าเป็นวันที่ปัจจุบัน
                  } else if (selectedPeriod == 'Month') {
                    selectedDate = DateFormat('yyyy-MM').format(DateTime(currentDate.year, currentDate.month)); // ตั้งค่าเป็นเดือนปัจจุบัน
                  } else if (selectedPeriod == 'Year') {
                    selectedDate = currentDate.year.toString(); // ตั้งค่าเป็นปีปัจจุบัน
                  }
                }
              });
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(value: 'Day', child: Text(localizations.day)),
                PopupMenuItem(value: 'Month', child: Text(localizations.month)),
                PopupMenuItem(value: 'Year', child: Text(localizations.year)),
                PopupMenuItem(value: 'Custom', child: Text(localizations.custom)),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (selectedPeriod == 'Custom') ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [Colors.red.shade100, Colors.green.shade100],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Start Date Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(
                                startDate != null
                                    ? DateFormat('dd MMM yyyy').format(startDate!)
                                    : 'Select a date',
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton.icon(
                                icon: Icon(Icons.calendar_today),
                                label: Text('Select Date'),
                                onPressed: () async {
                                  DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: startDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (picked != null && picked != startDate) {
                                    setState(() {
                                      startDate = picked;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white, // สีปุ่มเป็นสีขาว
                                  foregroundColor: Colors.black, // สีข้อความในปุ่ม
                                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16), // เพิ่มระยะห่างระหว่างสองคอลัมน์
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(
                                endDate != null
                                    ? DateFormat('dd MMM yyyy').format(endDate!)
                                    : 'Select a date',
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton.icon(
                                icon: Icon(Icons.calendar_today),
                                label: Text('Select Date'),
                                onPressed: () async {
                                  DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: endDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (picked != null && picked != endDate) {
                                    setState(() {
                                      endDate = picked;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white, // สีปุ่มเป็นสีขาว
                                  foregroundColor: Colors.black, // สีข้อความในปุ่ม
                                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (selectedPeriod == 'Day') ...[
            Container(
              height: 80, // เพิ่มความสูงของ container
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: 15, // 14 days before + 1 current day
                itemBuilder: (context, index) {
                  DateTime date = currentDate.subtract(Duration(days: 14 - index));
                  bool isSelected = selectedDate == DateFormat('yyyy-MM-dd').format(date);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDate = DateFormat('yyyy-MM-dd').format(date);
                      });
                    },
                    child: Container(
                      width: 90,
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(horizontal: 2), // เพิ่ม margin ข้างซ้ายขวา
                      padding: EdgeInsets.symmetric(vertical: 10), // เพิ่ม padding ข้างบนล่าง
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5), // เปลี่ยนจากมุมมนเล็กน้อย
                        color: isSelected ? Colors.pink[400] : Colors.pink[300], // เปลี่ยนสีให้สดขึ้น


                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('MMM').format(date), // แสดงเดือนเป็นแบบตัวอักษร
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          Text(
                            DateFormat('d').format(date), // แสดงวัน
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          ]
          else if (selectedPeriod == 'Month') ...[
            Container(
              height: 80,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: 15, // 14 months before + 1 current month
                itemBuilder: (context, index) {
                  DateTime monthDate = DateTime(currentDate.year, currentDate.month - (14 - index));
                  bool isSelected = selectedDate == DateFormat('yyyy-MM').format(monthDate);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDate = DateFormat('yyyy-MM').format(monthDate);
                      });
                    },
                    child: Container(
                      width: 90,
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(horizontal: 2), // เพิ่ม margin ข้างซ้ายขวา
                      padding: EdgeInsets.symmetric(vertical: 10), // เพิ่ม padding ข้างบนล่าง
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5), // เปลี่ยนจากมุมมนเล็กน้อย
                        color: isSelected ? Colors.pink[400] : Colors.pink[300], // เปลี่ยนสีให้สดขึ้น
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('MMM').format(monthDate), // แสดงเดือนเป็นแบบตัวอักษร
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          Text(
                            DateFormat('yyyy').format(monthDate), // แสดงวัน
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ]
          else if (selectedPeriod == 'Year') ...[
              Container(
                height: 80,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: 5, // 5 years
                  itemBuilder: (context, index) {
                    int year = currentDate.year - (4 - index);
                    bool isSelected = selectedDate == year.toString();
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDate = year.toString();
                        });
                      },
                      child: Container(
                        width: 90,
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(horizontal: 2), // เพิ่ม margin ข้างซ้ายขวา
                        padding: EdgeInsets.symmetric(vertical: 10), // เพิ่ม padding ข้างบนล่าง
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5), // เปลี่ยนจากมุมมนเล็กน้อย
                          color: isSelected ? Colors.pink[400] : Colors.pink[300], // เปลี่ยนสีให้สดขึ้น


                        ),
                        child: Text(
                          year.toString(),
                          style: TextStyle(color: Colors.white, fontSize: 22,fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          Expanded(
            child: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
              future: fetchData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data found'));
                }
                return TransactionList(transactions: snapshot.data!);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToCurrentDate() {
    // เลื่อนตำแหน่งไปที่วันปัจจุบัน
    if (selectedPeriod == 'Day') {
      _scrollController.animateTo(
        100.0 * 14, // ขนาดของแต่ละ item * index ของวันที่ปัจจุบัน
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (selectedPeriod == 'Month') {
      _scrollController.animateTo(
        100.0 * 11, // ปรับให้ถูกต้องตามจำนวนเดือนที่แสดง
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (selectedPeriod == 'Year') {
      _scrollController.animateTo(
        100.0 * 4, // ปรับให้ตรงกับตำแหน่งปีปัจจุบัน
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchData() async {
    final db = await openDatabase('transaction.db');
    List<Map<String, dynamic>> results = [];
    print('Selected Date: $selectedDate');


    if (selectedPeriod == 'Day' && selectedDate != null) {
      results = await db.rawQuery(
          'SELECT Transactions.*, Type_transaction.type_transaction '
              'FROM Transactions '
              'JOIN Type_transaction ON Transactions.ID_type_transaction = Type_transaction.ID_type_transaction '
              'WHERE Transactions.date_user LIKE ? ',
          ['${selectedDate}%']); // ใช้ LIKE เพื่อรวมเวลา
    } else if (selectedPeriod == 'Month' && selectedDate != null) {
      results = await db.rawQuery(
          'SELECT Transactions.*, Type_transaction.type_transaction '
              'FROM Transactions '
              'JOIN Type_transaction ON Transactions.ID_type_transaction = Type_transaction.ID_type_transaction '
              'WHERE Transactions.date_user LIKE ? ',
          ['${selectedDate}%']);
    } else if (selectedPeriod == 'Year' && selectedDate != null) {
      results = await db.rawQuery(
          'SELECT Transactions.*, Type_transaction.type_transaction '
              'FROM Transactions '
              'JOIN Type_transaction ON Transactions.ID_type_transaction = Type_transaction.ID_type_transaction '
              'WHERE strftime("%Y", Transactions.date_user) = ? ',
          [selectedDate]);
    } else if (selectedPeriod == 'Custom' && startDate != null && endDate != null) {
      results = await db.rawQuery(
          'SELECT Transactions.*, Type_transaction.type_transaction '
              'FROM Transactions '
              'JOIN Type_transaction ON Transactions.ID_type_transaction = Type_transaction.ID_type_transaction '
              'WHERE strftime(\'%Y-%m-%d\', Transactions.date_user) BETWEEN ? AND ? ',
          [
            DateFormat('yyyy-MM-dd').format(startDate!),
            DateFormat('yyyy-MM-dd').format(endDate!),
          ]);
    }

    // จัดกลุ่มข้อมูลที่ได้
    final groupedResults = groupBy(results, (Map<String, dynamic> transaction) {
      return DateFormat('yyyy-MM-dd').format(DateTime.parse(transaction['date_user']));
    });

    // ตรวจสอบและแสดงผลข้อมูล
    for (var entry in groupedResults.entries) {
      print('Date: ${entry.key}, Transactions: ${entry.value}');
    }

    return groupedResults; // คืนค่าผลลัพธ์ที่ได้
  }

}
