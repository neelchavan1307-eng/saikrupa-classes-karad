import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ReceiptScreen extends StatefulWidget {
  final String studentName, amount, joiningDate, paidDate, monthPaid, mode, receiptNo, fee;
  const ReceiptScreen({super.key, required this.studentName, required this.amount, required this.joiningDate, required this.paidDate, required this.monthPaid, required this.mode, required this.receiptNo, this.fee = "500"});
  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  late TextEditingController amountC;
  late TextEditingController monthC;
  final GlobalKey _receiptKey = GlobalKey();
  bool isSharing = false;

  @override
  void initState() {
    super.initState();
    amountC = TextEditingController(text: widget.amount);
    monthC = TextEditingController(text: widget.monthPaid);
  }

  Future<void> shareReceiptPhoto() async {
    setState(() => isSharing = true);
    try {
      RenderRepaintBoundary boundary = _receiptKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/receipt_${widget.studentName}_${monthC.text}.png').create();
      await file.writeAsBytes(pngBytes);

      String shareText = "SAIKRUPA CLASSES - Fee Receipt\nStudent: ${widget.studentName}\nMonth: ${monthC.text}\nAmount: Rs.${amountC.text}\nReceipt No: ${widget.receiptNo}\nThank You!";

      await Share.shareXFiles([XFile(file.path)], text: shareText);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
    setState(() => isSharing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9EFFF),
      appBar: AppBar(backgroundColor: const Color(0xFF162447), foregroundColor: Colors.white, title: const Text("Fee Receipt")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            RepaintBoundary(
              key: _receiptKey,
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFD4AF37), width: 2)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [Container(width: 62, height: 62, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFD4AF37), width: 2)), child: ClipOval(child: Image.asset('assets/logo.png', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.school, color: Colors.orange)))), const SizedBox(width: 12), const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("SAIKRUPA", style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)), Text("CLASSES", style: TextStyle(fontSize: 14)), Text("Shri Sainathay Namah", style: TextStyle(fontSize: 11, color: Colors.orange))])]),
                      const SizedBox(height: 12),
                      const Center(child: Text("FEE RECEIPT", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B5A2B)))),
                      const SizedBox(height: 10),
                      Container(width: double.infinity, padding: const EdgeInsets.all(8), color: const Color(0xFF1A2A4A), child: const Center(child: Text("SAIKRUPA CLASSES - Faith Devotion Education", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11)))),
                      const SizedBox(height: 14),
                      Text("Receipt No: ${widget.receiptNo}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("Student: ${widget.studentName}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(children: [const Text("Month: "), Expanded(child: TextField(controller: monthC, decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.all(8))))]),
                      const SizedBox(height: 8),
                      Row(children: [const Text("Amount: Rs. "), Expanded(child: TextField(controller: amountC, keyboardType: TextInputType.number, decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.all(8))))]),
                      const SizedBox(height: 8),
                      Text("Paid Date: ${widget.paidDate}"),
                      Text("Joining: ${widget.joiningDate}"),
                      Text("Mode: ${widget.mode}"),
                      const SizedBox(height: 12),
                      Container(width: double.infinity, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(10)), child: Center(child: Text("Total Paid: Rs. ${amountC.text} - ${monthC.text} Only", style: const TextStyle(fontWeight: FontWeight.bold)))),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: isSharing ? null : shareReceiptPhoto,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                icon: isSharing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.share, color: Colors.white),
                label: Text(isSharing ? "Photo banvat aahe..." : "WhatsApp var Photo Receipt Pathva - ${monthC.text}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
