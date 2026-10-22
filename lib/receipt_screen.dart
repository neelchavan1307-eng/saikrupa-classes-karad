import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ReceiptScreen extends StatefulWidget {
  final String studentName, amount, joiningDate, paidDate, monthPaid, mode, receiptNo;
  const ReceiptScreen({super.key, required this.studentName, required this.amount, required this.joiningDate, required this.paidDate, required this.monthPaid, required this.mode, required this.receiptNo});
  @override State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final ScreenshotController ssController = ScreenshotController();

  Future<void> shareImage() async {
    final bytes = await ssController.capture();
    if (bytes == null) return;
    final dir = await getTemporaryDirectory();
    final file = await File('${dir.path}/receipt_${widget.receiptNo}.png').create();
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: "Saikrupa Classes - Fee Receipt - ${widget.studentName}");
  }

  @override Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: Text("Fee Receipt"), backgroundColor: Color(0xFF1A2A4A), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          Screenshot(
            controller: ssController,
            child: Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Color(0xFFD4AF37), width: 2.5)),
              child: Column(children: [
                Row(children: [
                  Container(width: 65, height: 65, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Color(0xFFD4AF37))), child: ClipOval(child: Image.asset('assets/logo.png', errorBuilder: (_, __, ___) => Icon(Icons.school)))),
                  SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("SAIKRUPA", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1A2A4A))),
                    Text("CLASSES", style: TextStyle(fontSize: 13, letterSpacing: 3, color: Colors.brown)),
                    Text("॥ श्री साईनाथाय नमः ॥", style: TextStyle(fontSize: 10, color: Colors.orange)),
                  ])
                ]),
                SizedBox(height: 10),
                Text("FEE RECEIPT", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF8B5E3C))),
                SizedBox(height: 10),
                // ORANGE CIRCLE WALA TEXT KADHLA - FACTA EKACH LINE THEVLI
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  color: Color(0xFF1A2A4A),
                  child: Center(child: Text("SAIKRUPA CLASSES - Faith Devotion Education", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold))),
                ),
                SizedBox(height: 14),
                _row("Receipt No:", widget.receiptNo, bold: true),
                _row("Student:", widget.studentName, bold: true),
                _row("Amount:", "Rs. ${widget.amount}"),
                _row("Month:", widget.monthPaid),
                _row("Paid Date:", widget.paidDate),
                _row("Joining:", widget.joiningDate),
                _row("Mode:", widget.mode),
                SizedBox(height: 14),
                Container(width: double.infinity, padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Color(0xFFEAF1FF), borderRadius: BorderRadius.circular(10)), child: Center(child: Text("Total Paid: Rs. ${widget.amount} - Paid in Full", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A2A4A))))),
              ]),
            ),
          ),
          SizedBox(height: 18),
          SizedBox(width: double.infinity, height: 56, child: ElevatedButton.icon(onPressed: shareImage, icon: Icon(Icons.share, color: Colors.white), label: Text("WhatsApp वर फोटो रिसिप्ट पाठवा", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF25D366), shape: StadiumBorder()))),
        ]),
      ),
    );
  }

  Widget _row(String l, String v, {bool bold = false}) {
    return Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: TextStyle(color: Colors.black54, fontSize: 13)), Text(v, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w500, fontSize: 13))]));
  }
}
