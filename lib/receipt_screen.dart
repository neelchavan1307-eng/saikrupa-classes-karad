import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReceiptScreen extends StatefulWidget {
  final String studentName, amount, joiningDate, paidDate, monthPaid, mode, receiptNo;
  const ReceiptScreen({super.key, required this.studentName, required this.amount, required this.joiningDate, required this.paidDate, required this.monthPaid, required this.mode, required this.receiptNo});
  @override State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  GlobalKey _key = GlobalKey();
  bool loading=false;
  String tAddr="कराड, महाराष्ट्र", tMobile="9822001122", tName="प्रा. प्रदीप चव्हाण";

  @override void initState(){ super.initState(); _load(); }
  _load() async {
    var p=await SharedPreferences.getInstance();
    setState((){
      tAddr=p.getString('t_addr')??"कराड, महाराष्ट्र";
      tMobile=p.getString('t_mobile')??"9822001122";
      tName=p.getString('t_name')??"प्रा. प्रदीप चव्हाण";
    });
  }

  Future<void> shareImage() async {
    setState(()=> loading=true);
    try{
      RenderRepaintBoundary b = _key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image img = await b.toImage(pixelRatio: 3.0);
      ByteData? bd = await img.toByteData(format: ui.ImageByteFormat.png);
      Uint8List bytes = bd!.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = await File('${dir.path}/Receipt_${widget.receiptNo}.png').create();
      await file.writeAsBytes(bytes);
      // FAKT PHOTO - KHALCHA TEXT NAHI
      await Share.shareXFiles([XFile(file.path)]);
    }catch(e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
    setState(()=> loading=false);
  }

  @override Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xFFFFFEF5),
      appBar: AppBar(title: Text("Fee Receipt"), backgroundColor: Color(0xFF0A2351), foregroundColor: Colors.white),
      body: SingleChildScrollView(padding: EdgeInsets.all(12), child: Column(children: [
        RepaintBoundary(
          key: _key,
          child: Container(decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Color(0xFFD4AF37), width:3), borderRadius: BorderRadius.circular(12)), padding: EdgeInsets.all(16), child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width:75,height:75,decoration:BoxDecoration(shape:BoxShape.circle,border:Border.all(color: Color(0xFFD4AF37),width:2)),child: ClipOval(child: Image.asset('assets/logo.png', fit:BoxFit.cover, errorBuilder: (_,__,___)=> Icon(Icons.school,size:40,color:Colors.orange)))),
              SizedBox(width:10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("SAIKRUPA",style: TextStyle(fontSize:20,fontWeight:FontWeight.w900,color:Color(0xFF0A2351))),
                Text("CLASSES",style: TextStyle(fontSize:12,letterSpacing:3,color:Color(0xFF8B5E3C),fontWeight:FontWeight.bold)),
                Text("॥ श्री साईनाथाय नमः ॥",style: TextStyle(fontSize:10,color:Colors.orange)),
              ])
            ]),
            SizedBox(height:10),
            Text("FEE RECEIPT",style: TextStyle(fontSize:24,fontWeight:FontWeight.bold,color:Color(0xFF8B5E3C))),
            SizedBox(height:8),
            Container(width:double.infinity,color:Color(0xFF0A2351),padding:EdgeInsets.all(8),child: Column(children:[
              Text("SAIKRUPA CLASSES - Faith Devotion Education",textAlign:TextAlign.center,style:TextStyle(color:Color(0xFFD4AF37),fontWeight:FontWeight.bold,fontSize:11)),
              SizedBox(height:3),
              Text("$tAddr | Mob: $tMobile | $tName",textAlign:TextAlign.center,style:TextStyle(color:Colors.white,fontSize:9)),
            ])),
            SizedBox(height:14),
            _r("Receipt No:",widget.receiptNo), _r("Student:",widget.studentName), _r("Amount:","Rs. ${widget.amount}"), _r("Month:",widget.monthPaid), _r("Paid Date:",widget.paidDate), _r("Joining:",widget.joiningDate), _r("Mode:",widget.mode),
            SizedBox(height:10),
            Container(width:double.infinity,padding:EdgeInsets.all(10),decoration:BoxDecoration(color:Color(0xFFE6F0FF),borderRadius:BorderRadius.circular(8)),child: Text("Total Paid: Rs. ${widget.amount} - Paid in Full",style:TextStyle(fontWeight:FontWeight.bold,color:Color(0xFF0A2351)),textAlign:TextAlign.center)),
          ]))),
        SizedBox(height:18),
        SizedBox(width:double.infinity,height:52,child: ElevatedButton.icon(onPressed: loading?null:shareImage, icon: loading?SizedBox(width:18,height:18,child:CircularProgressIndicator(color:Colors.white,strokeWidth:2)):Icon(Icons.share, color: Colors.white), label: Text(loading?"Banvatoy...":"WhatsApp वर फोटो रिसिप्ट पाठवा",style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF25D366),shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(12))))),
      ])),
    );
  }
  Widget _r(String t,String v)=> Padding(padding: EdgeInsets.symmetric(vertical:3), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(t,style:TextStyle(color:Colors.black54,fontSize:12)), Flexible(child: Text(v,style:TextStyle(fontWeight:FontWeight.bold,fontSize:12), textAlign: TextAlign.right))]));
}
