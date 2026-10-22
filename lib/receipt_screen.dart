import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class ReceiptScreen extends StatefulWidget {
  final String studentName, amount, joiningDate, paidDate, monthPaid, mode, receiptNo;
  const ReceiptScreen({super.key, required this.studentName, required this.amount, required this.joiningDate, required this.paidDate, required this.monthPaid, required this.mode, required this.receiptNo});
  @override State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  GlobalKey _receiptKey = GlobalKey();
  bool loading = false;

  Future<void> shareImage() async {
    setState(()=> loading=true);
    try{
      RenderRepaintBoundary boundary = _receiptKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = await File('${dir.path}/Receipt_${widget.receiptNo}.png').create();
      await file.writeAsBytes(pngBytes);
      await Share.shareXFiles([XFile(file.path)], text: "SAIKRUPA CLASSES - ${widget.studentName} Rs.${widget.amount} - Logo sah Receipt");
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
    setState(()=> loading=false);
  }

  @override Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xFFFFFEF5),
      appBar: AppBar(title: Text("Fee Receipt"), backgroundColor: Color(0xFF0A2351), foregroundColor: Colors.white),
      body: SingleChildScrollView(padding: EdgeInsets.all(12), child: Column(children: [
        RepaintBoundary(
          key: _receiptKey,
          child: Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Color(0xFFD4AF37), width: 3), borderRadius: BorderRadius.circular(12)), padding: EdgeInsets.all(16), child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width:80,height:80,decoration:BoxDecoration(shape:BoxShape.circle,border:Border.all(color: Color(0xFFD4AF37),width:2)),child: ClipOval(child: Image.asset('assets/logo.png', fit:BoxFit.cover, errorBuilder: (_,__,___)=> Icon(Icons.school,size:40,color:Colors.orange)))),
              SizedBox(width:12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("SAIKRUPA",style: TextStyle(fontSize:22,fontWeight:FontWeight.w900,color:Color(0xFF0A2351))), Text("CLASSES",style: TextStyle(fontSize:14,letterSpacing:3,color:Color(0xFF8B5E3C),fontWeight:FontWeight.bold)), Text("॥ श्री साईनाथाय नमः ॥",style: TextStyle(fontSize:10,color:Colors.orange))])
            ]),
            SizedBox(height:10), Text("FEE RECEIPT",style: TextStyle(fontSize:26,fontWeight:FontWeight.bold,color:Color(0xFF8B5E3C))),
            SizedBox(height:8), Container(width:double.infinity,color:Color(0xFF0A2351),padding:EdgeInsets.all(8),child: Text("SAIKRUPA CLASSES - Faith Devotion Education",textAlign:TextAlign.center,style:TextStyle(color:Color(0xFFD4AF37),fontWeight:FontWeight.bold,fontSize:12))),
            SizedBox(height:14),
            _r("Receipt No:",widget.receiptNo), _r("Student:",widget.studentName), _r("Amount:","Rs. ${widget.amount}"), _r("Month:",widget.monthPaid), _r("Paid Date:",widget.paidDate), _r("Joining:",widget.joiningDate), _r("Mode:",widget.mode),
            SizedBox(height:12), Container(width:double.infinity,padding:EdgeInsets.all(12),decoration:BoxDecoration(color:Color(0xFFE6F0FF),borderRadius:BorderRadius.circular(8)),child: Text("Total Paid: Rs. ${widget.amount} - Paid in Full",style:TextStyle(fontWeight:FontWeight.bold,color:Color(0xFF0A2351)),textAlign:TextAlign.center)),
          ]))),
        SizedBox(height:20),
        SizedBox(width:double.infinity,height:54,child: ElevatedButton.icon(onPressed: loading?null:shareImage, icon: loading?SizedBox(width:20,height:20,child:CircularProgressIndicator(color:Colors.white,strokeWidth:2)):Icon(Icons.image,color:Colors.white), label: Text(loading?"Image Banvatoy...":"WhatsApp वर फोटो रिसिप्ट पाठवा (Logo sah)",style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF25D366),shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(12))))),
      ])),
    );
  }
  Widget _r(String t,String v)=>Padding(padding: EdgeInsets.symmetric(vertical:4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(t,style:TextStyle(color:Colors.black54,fontSize:13)), Flexible(child: Text(v,style:TextStyle(fontWeight:FontWeight.bold,fontSize:13), textAlign: TextAlign.right))]));
}
