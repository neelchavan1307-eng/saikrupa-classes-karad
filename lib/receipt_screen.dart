import 'package:flutter/material.dart';

class ReceiptScreen extends StatefulWidget {
  final String studentName, amount, joiningDate, paidDate, monthPaid, mode, receiptNo, fee;
  const ReceiptScreen({super.key, required this.studentName, required this.amount, required this.joiningDate, required this.paidDate, required this.monthPaid, required this.mode, required this.receiptNo, this.fee = "500"});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  late TextEditingController amountC;
  late TextEditingController monthC;

  @override
  void initState() {
    super.initState();
    amountC = TextEditingController(text: widget.amount);
    monthC = TextEditingController(text: widget.monthPaid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9EFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF162447),
        foregroundColor: Colors.white,
        title: const Text("Fee Receipt"),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // MAIN RECEIPT CARD - Screenshot sarkha
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFD4AF37), width: 2)),
                          child: ClipOval(child: Image.asset('assets/logo.png', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.school, color: Colors.orange, size: 30))),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text("SAIKRUPA", style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Color(0xFF1A2A4A), letterSpacing: 0.5)),
                            Text("CLASSES", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54, letterSpacing: 3)),
                            Text("॥ श्री साईनाथाय नमः ॥", style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold)),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  const Text("FEE RECEIPT", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF8B5A2B), letterSpacing: 1)),
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: const Color(0xFF1A2A4A),
                    child: const Center(child: Text("SAIKRUPA CLASSES - Faith Devotion Education", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Receipt No:", style: TextStyle(color: Colors.black54)), Text(widget.receiptNo, style: const TextStyle(fontWeight: FontWeight.bold))]),
                        const SizedBox(height: 10),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Student:", style: TextStyle(color: Colors.black54)), Text(widget.studentName, style: const TextStyle(fontWeight: FontWeight.bold))]),
                        const SizedBox(height: 10),
                        // EDITABLE AMOUNT
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Amount:", style: TextStyle(color: Colors.black54)), SizedBox(width: 120, height: 36, child: TextField(controller: amountC, keyboardType: TextInputType.number, decoration: InputDecoration(isDense: true, prefixText: "Rs. ", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8))))]),
                        const SizedBox(height: 10),
                        // EDITABLE MONTH
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Month:", style: TextStyle(color: Colors.black54)), SizedBox(width: 140, height: 36, child: TextField(controller: monthC, decoration: InputDecoration(isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), hintText: "Ex: Jan")))]),
                        const SizedBox(height: 4),
                        const Align(alignment: Alignment.centerRight, child: Text("Single month - Edit karu shakta", style: TextStyle(fontSize: 9, color: Colors.grey, fontStyle: FontStyle.italic))),
                        const SizedBox(height: 10),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Paid Date:", style: TextStyle(color: Colors.black54)), Text(widget.paidDate)]),
                        const SizedBox(height: 10),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Joining:", style: TextStyle(color: Colors.black54)), Text(widget.joiningDate)]),
                        const SizedBox(height: 10),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Mode:", style: TextStyle(color: Colors.black54)), Text(widget.mode)]),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(10)),
                          child: Center(child: Text("Total Paid: Rs. ${amountC.text} - ${monthC.text} Only", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A2A4A)))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Receipt Ready: ${widget.studentName} - ${monthC.text} - Rs.${amountC.text}")));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                icon: const Icon(Icons.share, color: Colors.white),
                label: Text("WhatsApp वर फोटो रिसिप्ट पाठवा - ${monthC.text}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
