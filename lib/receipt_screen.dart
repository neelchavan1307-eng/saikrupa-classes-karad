import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class ReceiptScreen extends StatefulWidget {
  final String studentName;
  final String amount;
  final String joiningDate;
  final String paidDate;
  final String monthPaid;
  final String mode;
  final String receiptNo;
  const ReceiptScreen({super.key, required this.studentName, required this.amount, required this.joiningDate, required this.paidDate, required this.monthPaid, required this.mode, required this.receiptNo});
  @override State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  ScreenshotController screenshotController = ScreenshotController();
  bool isSharing = false;

  Future<void> shareImageOnWhatsApp() async {
    setState(()=> isSharing = true);
    try {
      // screenshot 2.0.0 madhe pixelRatio param nahi
      final imageBytes = await screenshotController.capture();
      if (imageBytes == null) throw "Failed";
      final dir = await getTemporaryDirectory();
      final file = await File('${dir.path}/Receipt_${widget.receiptNo}.png').create();
      await file.writeAsBytes(imageBytes);
      await Share.shareXFiles([XFile(file.path)], text: "SAIKRUPA CLASSES - ${widget.studentName} - Rs.${widget.amount}");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
    setState(()=> isSharing = false);
  }

  void shareTextOnWhatsApp() async {
    String msg = "SAIKRUPA CLASSES - Fee Receipt%0AStudent: ${widget.studentName}%0AAmount: Rs. ${widget.amount}%0AMonth: ${widget.monthPaid}%0AReceipt: ${widget.receiptNo}";
    final Uri url = Uri.parse("https://wa.me/?text=$msg");
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFEF5),
      appBar: AppBar(title: Text("Fee Receipt"), backgroundColor: Color(0xFF0A2351), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(children: [
          Screenshot(
            controller: screenshotController,
            child: Container(
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Color(0xFFD4AF37), width: 3), borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.all(16),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Color(0xFFD4AF37), width: 2)), child: ClipOval(child: Image.asset('assets/logo.png', fit: BoxFit.cover))),
                  SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("SAIKRUPA", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0A2351))),
                    Text("CLASSES", style: TextStyle(fontSize: 14, letterSpacing: 3, color: Color(0xFF8B5E3C), fontWeight: FontWeight.bold)),
                    Text("॥ श्री साईनाथाय नमः ॥", style: TextStyle(fontSize: 10, color: Colors.orange)),
                  ])
                ]),
                SizedBox(height: 10),
                Text("FEE RECEIPT", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF8B5E3C))),
                SizedBox(height: 8),
                Container(width: double.infinity, color: Color(0xFF0A2351), padding: EdgeInsets.all(8), child: Text("SAIKRUPA CLASSES - Faith Devotion Education", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12))),
                SizedBox(height: 14),
                _row("Receipt No:", widget.receiptNo),
                _row("Student:", widget.studentName),
                _row("Amount:", "Rs. ${widget.amount}"),
                _row("Month Paid:", widget.monthPaid),
                _row("Paid Date:", widget.paidDate),
                _row("Joining:", widget.joiningDate),
                _row("Mode:", widget.mode),
                SizedBox(height: 12),
                Container(width: double.infinity, padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Color(0xFFE6F0FF), borderRadius: BorderRadius.circular(8)), child: Text("Total Paid: Rs. ${widget.amount} - Paid in Full", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0A2351)), textAlign: TextAlign.center)),
              ]),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 54, child: ElevatedButton.icon(onPressed: isSharing ? null : shareImageOnWhatsApp, icon: isSharing ? SizedBox(width:20,height:20,child:CircularProgressIndicator(color:Colors.white,strokeWidth:2)) : Icon(Icons.image, color: Colors.white), label: Text(isSharing ? "Image Banvatoy..." : "WhatsApp वर फोटो रिसिप्ट पाठवा", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF25D366), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
        ]),
      ),
    );
  }
  Widget _row(String t, String v)=> Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(t, style: TextStyle(color: Colors.black54, fontSize: 13)), Text(v, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]));
}
