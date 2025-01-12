// ignore_for_file: depend_on_referenced_packages, curly_braces_in_flow_control_structures, unnecessary_import

import 'package:caku/controllers/db_helper.dart';
import 'package:caku/models/Transaction_model.dart';
import 'package:caku/pages/Add_rename.dart';
import 'package:caku/pages/add_transaction.dart';
import 'package:caku/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caku/static.dart' as Static;

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late Box box;
  late SharedPreferences preferences;
  DbHelper dbHelper = DbHelper();
  Map? data;
  int totalBalance = 0;
  int totalPemasukan = 0;
  int totalPengeluaran = 0;

  DateTime today = DateTime.now();
  DateTime now = DateTime.now();
  int index = 1;
  List<String> months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  @override
  void initState() {
    super.initState();
    getPreference();
    box = Hive.box('money');
    fetch();
  }

  getPreference() async {
    preferences = await SharedPreferences.getInstance();
  }

  Future<List<TransactionModel>> fetch() async {
    if (box.values.isEmpty) {
      return Future.value([]);
    } else {
      // return Future.value(box.toMap());
      List<TransactionModel> items = [];
      box.toMap().values.forEach((element) {
        // print(element);
        items.add(
          TransactionModel(
            element['amount'] as int,
            element['note'],
            element['date'] as DateTime,
            element['type'],
          ),
        );
      });
      return items;
    }
  }

  getTotalBalance(List<TransactionModel> entiredata) {
    totalPengeluaran = 0;
    totalPemasukan = 0;
    totalBalance = 0;

    for (TransactionModel data in entiredata) {
      if (data.date.month == today.month) if (data.type == "Pemasukan") {
        totalBalance += data.amount;
        totalPemasukan += data.amount;
      } else {
        totalBalance -= data.amount;
        totalPengeluaran += data.amount;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0,
      ),

      persistentFooterButtons: [
        Container(
          width: 900,
          child: Text(
            'CAKU 1.0.1 | ©akbarhamid',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.black,
                letterSpacing: 1,
                fontWeight: FontWeight.bold),
          ),
        )
      ],

      //backgroundColor: Color(0xffe2e7ef),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (context) => AddTransaction(),
            ),
          )
              .whenComplete(() {
            setState(() {});
          });
        },
        backgroundColor: Static.PrimaryMaterialColor[800],
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: Icon(
          Icons.add,
          size: 32.0,
        ),
      ),
      body: FutureBuilder<List<TransactionModel>>(
          future: fetch(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("Error!"),
              );
            }
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return Center(
                  child: Text("Tambahkan Daftar Traksaksi"),
                );
              }
              getTotalBalance(snapshot.data!);
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32.0),
                              color: Colors.white70,
                            ),
                            child: CircleAvatar(
                              maxRadius: 32.0,
                              child: Image.asset(
                                "assets/face.png",
                                width: 64.0,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                          Text(
                            "${preferences.getString('name')}",
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.w700,
                              color: Static.PrimaryMaterialColor[800],
                            ),
                          ),
                        ]),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color: Colors.white70,
                          ),
                          padding: EdgeInsets.all(12.0),
                          child: IconButton(
                            icon: Icon(Icons.settings,
                                size: 32.0, color: Color(0xff3E454C)),
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => AddreName(),
                                ),
                              );
                            },
                          ),
                        ),
                        // child: Icon(Icons.settings,
                        // size: 32.0,
                        //   color: Color(0xff3E454C),
                        // ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    margin: EdgeInsets.all(12.0),
                    child: Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 0, 157, 196),
                              Color.fromARGB(255, 0, 157, 196),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.all(Radius.circular(24.0))),
                      padding:
                          EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
                      child: Column(
                        children: [
                          Text(
                            "Total Saldo",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26.0,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 12.0,
                          ),
                          Text(
                            "Rp. $totalBalance",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 12.0,
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child:
                                      cardPemasukan(totalPemasukan.toString()),
                                ),
                                Expanded(
                                    child: cardPengeluaran(
                                        totalPengeluaran.toString())),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  /////
                  ////
                  ////
                  Padding(
                    padding: const EdgeInsets.all(
                      12.0,
                    ),
                    child: Text(
                      "Riwayat Transaksi",
                      style: TextStyle(
                        fontSize: 26.0,
                        color: Colors.black87,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length + 1,
                      itemBuilder: (context, index) {
                        TransactionModel dataAtIndex;
                        try {
                          // dataAtIndex = snapshot.data![index];
                          dataAtIndex = snapshot.data![index];
                        } catch (e) {
                          // deleteAt deletes that key and value,
                          // hence makign it null here., as we still build on the length.
                          return Container();
                        }

                        if (dataAtIndex.type == "Pemasukan") {
                          return PemasukanTile(dataAtIndex.amount,
                              dataAtIndex.note, dataAtIndex.date, index);
                        } else {
                          return pengeluaranTile(dataAtIndex.amount,
                              dataAtIndex.note, dataAtIndex.date, index);
                        }
                      }),
                  SizedBox(
                    height: 60.0,
                  ),
                ],
              );
            } else {
              return Center(
                child: Text("Error!"),
              );
            }
          }),
    );
  }

  Widget cardPemasukan(String value) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              20.0,
            ),
          ),
          padding: EdgeInsets.all(6.0),
          child: Icon(
            Icons.arrow_upward,
            size: 28.0,
            color: Colors.green[700],
          ),
          margin: EdgeInsets.only(right: 8.0),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pemasukan",
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.white70,
                ),
              ),
              Text(
                "Rp. $value",
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ///////////////

  Widget cardPengeluaran(String value) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              20.0,
            ),
          ),
          padding: EdgeInsets.all(6.0),
          child: Icon(
            Icons.arrow_downward,
            size: 28.0,
            color: Colors.red[700],
          ),
          margin: EdgeInsets.only(right: 8.0),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pengeluaran",
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.white70,
                ),
              ),
              Text(
                "Rp. $value",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

/////////////

  Widget pengeluaranTile(int value, String note, DateTime date, int index) {
    return InkWell(
      onLongPress: () async {
        bool? answer = await showConfirmDialog(
          context,
          "PERINGATAN",
          "Tindakan ini akan menghapus riwayat transaksi. Apakah ingin melanjutkan ?",
        );
        if (answer != null && answer) {
          await dbHelper.deleteData(index);
          setState(() {});
        }
      },
      child: Container(
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(18.0),
        decoration: BoxDecoration(
            color: Color(0xfffac5c5), borderRadius: BorderRadius.circular(8.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.arrow_circle_down_outlined,
                      size: 28.0,
                      color: Colors.red[700],
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      "Pengeluaran ",
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    "${date.day} ${months[date.month - 1]} ${date.year}",
                    style: TextStyle(
                      color: Colors.grey[800],
                      // fontSize: 24.0,
                      // fontWeight: FontWeight.w700
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "-Rp. $value",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    note,
                    style: TextStyle(color: Colors.grey[800]
                        // fontSize: 24.0,
                        // fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

////////////////

  Widget PemasukanTile(int value, String note, DateTime date, int index) {
    Size screenSize = MediaQuery.of(context).size;
    Orientation orientation = MediaQuery.of(context).orientation;
    return InkWell(
      onLongPress: () async {
        bool? answer = await showConfirmDialog(
          context,
          "PERINGATAN",
          "Tindakan ini akan menghapus riwayat transaksi. Apakah ingin melanjutkan ?",
        );
        if (answer != null && answer) {
          await dbHelper.deleteData(index);
          setState(() {});
        }
      },
      child: Container(
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(18.0),
        decoration: BoxDecoration(
            color: Color(0xffd8fac5),
            // Color(0xffced4eb),
            borderRadius: BorderRadius.circular(8.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.arrow_circle_up_outlined,
                      size: 28.0,
                      color: Colors.green[700],
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      "Pemasukan ",
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    "${date.day} ${months[date.month - 1]} ${date.year}",
                    style: TextStyle(
                      color: Colors.grey[800],
                      // fontSize: 24.0,
                      // fontWeight: FontWeight.w700
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "+Rp.$value",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    note,
                    style: TextStyle(
                      color: Colors.grey[800],
                      // fontSize: 24.0,
                      // fontWeight: FontWeight.w700
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
