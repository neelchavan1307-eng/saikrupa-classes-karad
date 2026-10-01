import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ReceiptScreen extends StatelessWidget {
  final String studentName;
  final String amount;
  final String joiningDate;
  final String paidDate;
  final String monthPaid;
  final String mode;
  final String receiptNo;

  const ReceiptScreen({
    super.key,
    required this.studentName,
    required this.amount,
    required this.joiningDate,
    required this.paidDate,
    required this.monthPaid,
    required this.mode,
    required this.receiptNo,
  });

  void shareOnWhatsApp() async {
    String msg = "SAIKRUPA CLASSES - Fee Receipt%0AStudent: $studentName%0AAmount: Rs. $amount%0AMonth: $monthPaid%0AReceipt: $receiptNo";
    final Uri url = Uri.parse("https://wa.me/?text=$msg");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFEF5),
      appBar: AppBar(title: Text("Fee Receipt"), backgroundColor: Color(0xFF0A2351), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(border: Border.all(color: Color(0xFFD4AF37), width: 3), borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Image.asset('assets/logo.png', height: 90),
                  Text("FEE RECEIPT", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF8B5E3C))),
                  Container(width: double.infinity, color: Color(0xFF0A2351), padding: EdgeInsets.all(8), child: Text("SAIKRUPA CLASSES - Faith Devotion Education", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFD4AF37)))),
                  SizedBox(height: 10),
                  Text("Student: $studentName | Amount: Rs. $amount"),
                  Text("Paid Date: $paidDate | Month: $monthPaid"),
                  Text("Receipt No: $receiptNo"),
                  SizedBox(height: 10),
                  Container(padding: EdgeInsets.all(10), color: Color(0xFFE6F0FF), child: Text("Total Paid: Rs. $amount - Paid in Full", style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(onPressed: shareOnWhatsApp, icon: Icon(Icons.share), label: Text("WhatsApp वर पाठवा"), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF25D366), foregroundColor: Colors.white)),
          ],
        ),
      ),
    );
  }
}
