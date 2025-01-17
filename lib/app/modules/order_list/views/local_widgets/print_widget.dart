import 'dart:convert' show utf8;
import 'dart:typed_data';
import 'package:flutter/material.dart' hide Image;
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'package:get/get.dart';
import 'dart:io' show Platform;
import 'package:intl/intl.dart';
import 'package:waiter/app/modules/order_list/controllers/order_view_controller.dart';
import 'package:charset_converter/charset_converter.dart';
class PrintWidget extends StatefulWidget {
  // PrintWidget(data);
  // final List<Map<String, dynamic>> data=[];
  // Print(this.data);
  @override
  _PrintWidgetState createState() => _PrintWidgetState();
}

class _PrintWidgetState extends State<PrintWidget> {

  PrinterBluetoothManager _printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  String _devicesMsg;
  BluetoothManager bluetoothManager = BluetoothManager.instance;
  final orderDetailsController=Get.find<OrderViewController>();
  @override
  void initState() {

    print('widget.data.length');
    print(orderDetailsController.sales.id);
    print(orderDetailsController.sales.items.length);
    if (Platform.isAndroid) {
      bluetoothManager.state.listen((val) {
        print('state = $val');
        if (!mounted) return;
        if (val == 12) {
          print('on');
          initPrinter();
        } else if (val == 10) {
          print('off');
          setState(() => _devicesMsg = 'Bluetooth Disconnect!');
        }
      });
    } else {
      initPrinter();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Print'),
      ),
      body: _devices.isEmpty
          ? Center(child: Text(_devicesMsg ?? ''))
          : ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (c, i) {
                return ListTile(
                  leading: Icon(Icons.print),
                  title: Text(_devices[i].name),
                  subtitle: Text(_devices[i].address),
                  onTap: () {
                    _startPrint(_devices[i]);

                  },
                );
              },
            ),

    );
  }

  void initPrinter() {
    _printerManager.startScan(Duration(seconds: 2));
    _printerManager.scanResults.listen((val) {
      if (!mounted) return;
      setState(() => _devices = val);
      if (_devices.isEmpty) setState(() => _devicesMsg = 'No Devices');
    });
  }

  Future<void> _startPrint(PrinterBluetooth printer) async {
    _printerManager.selectPrinter(printer);
    final result = await _printerManager.printTicket(await _ticket(PaperSize.mm58));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(result.msg),
      ),
    );
  }

  Future<Ticket> _ticket(PaperSize paper) async {
    final ticket = Ticket(paper);
    // Image assets
    // final ByteData data = await rootBundle.load('assets/images/store.png');
    // final Uint8List bytes = data.buffer.asUint8List();
    // final Image image = decodeImage(bytes);
    // ticket.image(image);
 /*   final arabicText = utf8.encode('ألاما');
    ticket.text('Alama360',
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);*/

    // ticket.textEncoded(arabicText, styles: PosStyles(codeTable: PosCodeTable.arabic));
    // ticket.text('ألاما',styles:PosStyles(codeTable: PosCodeTable.arabic));
    // ticket.text('Watson',styles:PosStyles(codeTable: PosCodeTable.arabic));
  /*  Uint8List encArabic = await CharsetConverter.encode("windows-1256", "ألامااهلا");
    ticket.textEncoded(encArabic,styles: PosStyles(codeTable: PosCodeTable.arabic));
    ticket.hr();*/
    ticket.text('Alama360', styles: PosStyles(align: PosAlign.center));
    ticket.text('Tel: ${orderDetailsController.sales.billerdetails.phone}', styles: PosStyles(align: PosAlign.center));
    ticket.text('SaleNumber : ${orderDetailsController.sales.id??""}',
      styles: PosStyles(align: PosAlign.center, bold: true,codeTable:PosCodeTable.pc850 ),
    );
    ticket.text(
      'SaleReference'.tr+': ${orderDetailsController.sales.reference_no??""}',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    ticket.text(
      'Date'.tr+': ${orderDetailsController.sales.date??""}',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    // ticket.text(
    //   'SalesAssociate'.tr+': ${Get.find<AuthController>().currentUser.username??""}',
    //   styles: PosStyles(align: PosAlign.center, bold: true),
    // );
    // ticket.text(
    //   'Customer'.tr+': ${orderDetailsController.sales.customer??""}',
    //   styles: PosStyles(align: PosAlign.center, bold: true),
    // );
    ticket.hr();
    ticket.row([
      PosColumn(text: 'Qty', width: 2),
      PosColumn(text: 'Item', width: 7),
      PosColumn(
          text: 'Price', width: 3, ),

    ]);
    ticket.hr(ch: '=', linesAfter: 1);
    for (var i = 0; i < orderDetailsController.sales.items.length; i++) {
      print(orderDetailsController.sales.items[i].id);
      ticket.row([
        PosColumn(text: '${orderDetailsController.sales.items[i].id}', width: 2),
        PosColumn(text: 'ONION RINGS', width: 7),
        PosColumn(
          text: '${orderDetailsController.sales.items[i].subtotal}', width: 3, ),

      ]);
    }
    ticket.hr(ch: '-', linesAfter: 1);
    ticket.row([
      PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size2,
            width: PosTextSize.size1,
          )),
      PosColumn(
          text: '${orderDetailsController.sales.total}',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size2,
            width: PosTextSize.size1,
          )),
    ]);
    ticket.row([
      PosColumn(
          text: 'VAT',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size2,
            width: PosTextSize.size1,
          )),
      PosColumn(
          text: '${orderDetailsController.sales.total_tax}',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size2,
            width: PosTextSize.size1,
          )),
    ]);
    ticket.row([
      PosColumn(
          text: 'Total With Vat',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size2,
            width: PosTextSize.size1,
          )),
      PosColumn(
          text: '${orderDetailsController.sales.grand_total}',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size2,
            width: PosTextSize.size1,
          )),
    ]);

    ticket.hr(ch: '-', linesAfter: 1);
    ticket.row([
      PosColumn(
          text: 'Cash',
          width: 6,
          styles: PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size2,
            width: PosTextSize.size1,
          )),
      PosColumn(
          text: '${orderDetailsController.sales.grand_total}',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size2,
            width: PosTextSize.size1,
          )),
    ]);
    ticket.row([
      PosColumn(
          text: 'Change',
          width: 6,
          styles: PosStyles(align: PosAlign.left, width: PosTextSize.size2)),
      PosColumn(
          text: '${orderDetailsController.sales.payment_term}',
          width: 6,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    ]);


    ticket.feed(2);
    ticket.text('Thank you!',
        styles: PosStyles(align: PosAlign.center, bold: true));

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    ticket.text(timestamp,
        styles: PosStyles(align: PosAlign.center), linesAfter: 2);


    ticket.feed(1);
    // ticket.row([
    //   PosColumn(text: 'Total', width: 6, styles: PosStyles(bold: true)),
    //   PosColumn(text: 'SAR ${orderDetailsController.sales.grand_total}', width: 6, styles: PosStyles(bold: true)),
    // ]);

    ticket.cut();

    return ticket;
  /*  final Ticket ticket = Ticket(paper);
    // ticket.printCustom("السلام ",2,1,charset: "UTF-8");
    // ticket.text(
    //     'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
    // ticket.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
    //     styles: PosStyles(codeTable: PosCodeTable.westEur));
    // ticket.text('Special 2: blåbærgrød',
    //     styles: PosStyles(codeTable: PosCodeTable.westEur));
    Uint8List encoded2 =
    await CharsetConverter.encode('ISO-8859-6', 'مابيقرا شي وهو بيستخدم');

    ticket.textEncoded(encoded2,
        styles: PosStyles(align: PosAlign.center,width: PosTextSize.size1,codeTable: PosCodeTable.arabic) );
    final arabicText = utf8.encode('شي وهو بيستخدم');

    ticket.textEncoded(arabicText,styles: PosStyles(codeTable: PosCodeTable.pc864_2));*/
    // var encoded = utf8.encode("Special 3: ألامااهلا");
    // ticket.text(utf8.decode(encoded),
    //     styles: PosStyles(codeTable: PosCodeTable.arabic));

    // ticket.text('Bold text', styles: PosStyles(bold: true));
    // ticket.text('Reverse text', styles: PosStyles(reverse: true));
    // ticket.text('Underlined text',
    //     styles: PosStyles(underline: true), linesAfter: 1);
    // ticket.text('Align left', styles: PosStyles(align: PosAlign.left));
    // ticket.text('Align center', styles: PosStyles(align: PosAlign.center));
    // ticket.text('Align right',
    //     styles: PosStyles(align: PosAlign.right), linesAfter: 1);
    //
    // ticket.row([
    //   PosColumn(
    //     text: 'col3',
    //     width: 3,
    //     styles: PosStyles(align: PosAlign.center, underline: true),
    //   ),
    //   PosColumn(
    //     text: 'col6',
    //     width: 6,
    //     styles: PosStyles(align: PosAlign.center, underline: true),
    //   ),
    //   PosColumn(
    //     text: 'col3',
    //     width: 3,
    //     styles: PosStyles(align: PosAlign.center, underline: true),
    //   ),
    // ]);
    //
    // ticket.text('Text size 200%',
    //     styles: PosStyles(
    //       height: PosTextSize.size2,
    //       width: PosTextSize.size2,
    //     ));
    //
    // // Print barcode
    // final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    // ticket.barcode(Barcode.upcA(barData));

    // Print mixed (chinese + latin) text. Only for printers supporting Kanji mode
    // ticket.text(
    //   'hello ! 中文字 # world @ éphémère &',
    //   styles: PosStyles(codeTable: PosCodeTable.westEur),
    //   containsChinese: true,
    // );

    ticket.feed(2);

    ticket.cut();
    return ticket;
  }
 /* Future<Ticket> demoReceipt(PaperSize paper) async {
    final Ticket ticket = Ticket(paper);

    // Print image
    final ByteData data = await rootBundle.load('assets/rabbit_black.jpg');
    final Uint8List bytes = data.buffer.asUint8List();
    final Image image = decodeImage(bytes);
    // ticket.image(image);

    ticket.text('GROCERYLY',
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    ticket.text('889  Watson Lane', styles: PosStyles(align: PosAlign.center));
    ticket.text('New Braunfels, TX', styles: PosStyles(align: PosAlign.center));
    ticket.text('Tel: 830-221-1234', styles: PosStyles(align: PosAlign.center));
    ticket.text('Web: www.example.com',
        styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    ticket.hr();
    ticket.row([
      PosColumn(text: 'Qty', width: 1),
      PosColumn(text: 'Item', width: 7),
      PosColumn(
          text: 'Price', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: 'Total', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);

    ticket.row([
      PosColumn(text: '2', width: 1),
      PosColumn(text: 'ONION RINGS', width: 7),
      PosColumn(
          text: '0.99', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: '1.98', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);
    ticket.row([
      PosColumn(text: '1', width: 1),
      PosColumn(text: 'PIZZA', width: 7),
      PosColumn(
          text: '3.45', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: '3.45', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);
    ticket.row([
      PosColumn(text: '1', width: 1),
      PosColumn(text: 'SPRING ROLLS', width: 7),
      PosColumn(
          text: '2.99', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: '2.99', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);
    ticket.row([
      PosColumn(text: '3', width: 1),
      PosColumn(text: 'CRUNCHY STICKS', width: 7),
      PosColumn(
          text: '0.85', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: '2.55', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);
    ticket.hr();

    ticket.row([
      PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: PosStyles(
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
      PosColumn(
          text: '\$10.97',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          )),
    ]);

    ticket.hr(ch: '=', linesAfter: 1);

    ticket.row([
      PosColumn(
          text: 'Cash',
          width: 7,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
      PosColumn(
          text: '\$15.00',
          width: 5,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    ]);
    ticket.row([
      PosColumn(
          text: 'Change',
          width: 7,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
      PosColumn(
          text: '\$4.03',
          width: 5,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    ]);

    ticket.feed(2);
    ticket.text('Thank you!',
        styles: PosStyles(align: PosAlign.center, bold: true));

    final now = DateTime.now();
    final formatter = DateFormat('MM/dd/yyyy H:m');
    final String timestamp = formatter.format(now);
    ticket.text(timestamp,
        styles: PosStyles(align: PosAlign.center), linesAfter: 2);

    // Print QR Code from image
    // try {
    //   const String qrData = 'example.com';
    //   const double qrSize = 200;
    //   final uiImg = await QrPainter(
    //     data: qrData,
    //     version: QrVersions.auto,
    //     gapless: false,
    //   ).toImageData(qrSize);
    //   final dir = await getTemporaryDirectory();
    //   final pathName = '${dir.path}/qr_tmp.png';
    //   final qrFile = File(pathName);
    //   final imgFile = await qrFile.writeAsBytes(uiImg.buffer.asUint8List());
    //   final img = decodeImage(imgFile.readAsBytesSync());

    //   ticket.image(img);
    // } catch (e) {
    //   print(e);
    // }

    // Print QR Code using native function
    // ticket.qrcode('example.com');

    ticket.feed(2);
    ticket.cut();
    return ticket;
  }*/
  @override
  void dispose() {
    _printerManager.stopScan();
    super.dispose();
  }

}
