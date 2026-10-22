import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'receipt_screen.dart';

void main()=>runApp(const SaikrupaApp());
class SaikrupaApp extends StatelessWidget{
  const SaikrupaApp({super.key});
  @override Widget build(BuildContext c)=>MaterialApp(debugShowCheckedModeBanner:false,home:const Dashboard());
}
class Dashboard extends StatefulWidget{
  const Dashboard({super.key});
  @override State<Dashboard> createState()=>_DashboardState();
}
class _DashboardState extends State<Dashboard>{
  final backupRaw=[
    {"n":"Vihan Tupe","a":9,"s":3,"f":600,"p":[7,8,9,1]},
    {"n":"Krisha Kirme","a":10,"s":10,"f":1200,"p":[7,8,1]},
    {"n":"Anshuman","a":6,"s":3,"f":600,"p":[9,7,8]},
    {"n":"samayak","a":6,"s":1,"f":500,"p":[7,8,9]},
    {"n":"Aradhya","a":6,"s":4,"f":700,"p":[8,9]},
    {"n":"shreya","a":6,"s":2,"f":500,"p":[8]},
    {"n":"Aravi","a":6,"s":1,"f":500,"p":[8]},
    {"n":"Swarangi","a":6,"s":6,"f":700,"p":[7]},
    {"n":"swaransh","a":6,"s":1,"f":500,"p":[7,8,9]},
    {"n":"Tejal","a":6,"s":5,"f":400,"p":[]},
    {"n":"Poorva","a":6,"s":5,"f":200,"p":[8]},
    {"n":"Sanskruti","a":6,"s":6,"f":850,"p":[9]},
    {"n":"piyush","a":6,"s":3,"f":600,"p":[]}
  ];
  late List<Map<String,dynamic>> students; 
  String filter="Sarv"; String search="";
  String tName="टीचर-स्नेहल चव्हाण", tMobile="9822001122", tAddr="मोरया पार्क, सांगोडी रोड, येलवाडी.";

  @override void initState(){
    super.initState();
    students=backupRaw.map((b){
      List<int> m12=List.filled(12,0);
      for(var m in (b['p'] as List)){ int mm = m is int ? m : 0; if(mm>=1 && mm<=12) m12[mm-1]=1; }
      return <String,dynamic>{"name":(b['n'] as String).trim(),"age":b['a'].toString(),"std":b['s'].toString(),"fee":b['f'],"mobile":"","months":m12};
    }).toList();
    _loadProfile();
  }
  _loadProfile() async { var p=await SharedPreferences.getInstance(); setState((){ tName=p.getString('t_name')??tName; tMobile=p.getString('t_mobile')??tMobile; tAddr=p.getString('t_addr')??tAddr; }); }
  _saveProfile() async { var p=await SharedPreferences.getInstance(); await p.setString('t_name', tName); await p.setString('t_mobile', tMobile); await p.setString('t_addr', tAddr); }
  void editProfile(){
    var nC=TextEditingController(text:tName); var mC=TextEditingController(text:tMobile); var aC=TextEditingController(text:tAddr);
    showDialog(context: context, builder: (_)=> AlertDialog(title: Text("माहिती बदला"), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: nC, decoration: InputDecoration(labelText: "Teachers Name")), TextField(controller: mC, decoration: InputDecoration(labelText: "Contact Number")), TextField(controller: aC, decoration: InputDecoration(labelText: "Address"))]), actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: Text("Cancel")), ElevatedButton(onPressed: (){ setState((){ tName=nC.text; tMobile=mC.text; tAddr=aC.text; }); _saveProfile(); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: Text("Save", style: TextStyle(color: Colors.white)))]));
  }
  void openReceipt(Map<String,dynamic> s){
    List<int> months = List<int>.from(s['months']); int paidCount = months.where((e)=>e==1).length; if(paidCount==0) paidCount=1;
    List<String> mNames = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]; List<String> paidM = []; for(int i=0;i<12;i++) if(months[i]==1) paidM.add(mNames[i]);
    String monthStr = paidM.isEmpty ? "Not Paid" : paidM.join(", "); int totalAmt = paidCount * (s['fee'] as int);
    Navigator.push(context, MaterialPageRoute(builder: (_)=> ReceiptScreen(studentName: s['name'], amount: totalAmt.toString(), joiningDate: "01/06/2024", paidDate: "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}", monthPaid: monthStr, mode: "Cash", receiptNo: "SK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}")));
  }
  Future<void> addNewStudent() async { var result = await showDialog<dynamic>(context: context, builder: (_)=> AddStudentDialog()); if(result!=null && result is Map){ setState(()=> students.add(Map<String,dynamic>.from(result))); } }

  @override Widget build(BuildContext c){
    var filtered=students.where((s){ if(search.isNotEmpty && !s['name'].toLowerCase().contains(search.toLowerCase())) return false; bool hasB=(s['months'] as List).contains(0); if(filter=="Baki" && !hasB) return false; if(filter=="Jama" && hasB) return false; return true; }).toList();
    return Scaffold(
      body: Stack(children:[
        Positioned.fill(child: Image.asset('assets/saibaba_bg.jpg', fit: BoxFit.cover, errorBuilder: (_,__,___)=> Container(color: Color(0xFFFFE6D5)))),
        Positioned.fill(child: Container(color: Colors.white.withOpacity(0.78))),
        SafeArea(child: Column(children:[
          // PROFILE CHOTA KELA
          Container(
            margin: EdgeInsets.symmetric(horizontal:14, vertical:8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(colors: [Color(0xFFFF8C00), Color(0xFFE94057)])),
            child: Column(children: [
              Container(padding: EdgeInsets.symmetric(vertical:5), decoration: BoxDecoration(color: Color(0xFF4E2A0B), borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))), child: Center(child: Text("वर्ष 2026", style: TextStyle(color: Colors.white, fontSize:12, fontWeight: FontWeight.bold)))),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
                padding: EdgeInsets.symmetric(horizontal:12, vertical:10),
                child: Row(children: [
                  Container(width:55,height:55, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.orange, width:2)), child: ClipOval(child: Image.asset('assets/logo.png', fit: BoxFit.cover, errorBuilder: (_,__,___)=> Icon(Icons.school, color: Colors.orange)))),
                  SizedBox(width:10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("SAIKRUPA CLASSES", style: TextStyle(fontSize:15, fontWeight: FontWeight.w900)),
                    Text(tName, style: TextStyle(fontSize:12, color: Colors.red, fontWeight: FontWeight.bold)),
                    SizedBox(height:2),
                    Row(children: [Icon(Icons.location_on, size:12), Flexible(child: Text(tAddr, style: TextStyle(fontSize:10), overflow: TextOverflow.ellipsis)), SizedBox(width:6), Icon(Icons.phone, size:12), Text(tMobile, style: TextStyle(fontSize:10, fontWeight: FontWeight.bold))]),
                  ])),
                  IconButton(icon: Icon(Icons.edit, size:18, color: Colors.orange), onPressed: editProfile)
                ]),
              )
            ]),
          ),
          Padding(padding:EdgeInsets.symmetric(horizontal:14),child: TextField(onChanged:(v)=>setState(()=>search=v),decoration:InputDecoration(hintText:"Search students...",prefixIcon:Icon(Icons.search),filled:true,fillColor:Colors.white.withOpacity(0.9),border:OutlineInputBorder(borderRadius:BorderRadius.circular(16),borderSide:BorderSide.none), contentPadding: EdgeInsets.symmetric(horizontal:12, vertical:10)))),
          SizedBox(height:6),
          Padding(padding:EdgeInsets.symmetric(horizontal:14),child: Row(children: ["Sarv","Baki","Jama"].map((f)=>Padding(padding:EdgeInsets.only(right:8),child: ChoiceChip(label:Text(f, style: TextStyle(fontSize:12)),selected:filter==f,onSelected:(_)=>setState(()=>filter=f),selectedColor:Colors.orange.shade200,backgroundColor:Colors.white.withOpacity(0.85)))).toList())),
          SizedBox(height:6),
          Expanded(child: ListView.builder(padding:EdgeInsets.all(14),itemCount:filtered.length,itemBuilder:(_,i){
            var s=filtered[i];
            return Container(margin:EdgeInsets.only(bottom:10),decoration:BoxDecoration(color:Colors.white.withOpacity(0.93),borderRadius:BorderRadius.circular(16),boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.06),blurRadius:8)]),
              child: ListTile(
                dense: true,
                leading: CircleAvatar(radius:18, backgroundColor:Colors.orange.shade100,child: Text(s['name'][0].toUpperCase(),style:TextStyle(color:Colors.orange,fontWeight:FontWeight.bold, fontSize:14))),
                title: Text(s['name'],style:TextStyle(fontWeight:FontWeight.bold,fontSize:15)),
                subtitle: Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                  Text("Vay: ${s['age']} • Std: ${s['std']} • Fee: ₹${s['fee']}",style:TextStyle(fontSize:11)),
                  SizedBox(height:4),
                  Row(children: List.generate(12,(mi){ bool paid=(s['months'] as List)[mi]==1; return Container(margin:EdgeInsets.only(right:2),width:15,height:15,decoration:BoxDecoration(color:paid?Colors.green:Colors.pink.shade100,borderRadius:BorderRadius.circular(3)),child: Center(child: Text(["J","F","M","A","M","J","J","A","S","O","N","D"][mi],style: TextStyle(fontSize:6,fontWeight:FontWeight.bold,color:paid?Colors.white:Colors.black54))));}))
                ]),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [ IconButton(icon: Icon(Icons.receipt_long, color: Colors.green, size:20), onPressed: ()=> openReceipt(s)), IconButton(icon: Icon(Icons.edit, color: Colors.orange, size:18), onPressed: () async { var u= await Navigator.push(c,MaterialPageRoute(builder:(_)=>EditFull(student:s))); if(u!=null && u is Map) setState((){ int idx=students.indexWhere((e)=>e['name']==s['name']); if(idx!=-1) students[idx]=Map<String,dynamic>.from(u); }); }) ]),
              ));
          })),
          Container(width: double.infinity, color: Colors.black.withOpacity(0.05), padding: EdgeInsets.symmetric(vertical:5), child: Center(child: Text("Made by Pradip Chavan ✨", style: TextStyle(fontSize:10, color: Colors.black54, fontWeight: FontWeight.w600)))),
        ]))
      ]),
      floatingActionButton: FloatingActionButton.extended(onPressed: addNewStudent, backgroundColor: Colors.orange, icon: Icon(Icons.add,color:Colors.white),label: Text("नवीन विद्यार्थी",style:TextStyle(color:Colors.white))),
    );
  }
}
class EditFull extends StatefulWidget{ final Map student; const EditFull({super.key,required this.student}); @override State<EditFull> createState()=>_EditFullState(); }
class _EditFullState extends State<EditFull>{
  late TextEditingController nameC,feeC,ageC,stdC,mobileC; late List<int> months;
  @override void initState(){ super.initState(); nameC=TextEditingController(text:widget.student['name']); feeC=TextEditingController(text:widget.student['fee'].toString()); ageC=TextEditingController(text:widget.student['age']); stdC=TextEditingController(text:widget.student['std']); mobileC=TextEditingController(text:widget.student['mobile']); months=List<int>.from(widget.student['months']); }
  @override Widget build(BuildContext c){
    return Scaffold(body: Stack(children:[ Positioned.fill(child: Image.asset('assets/saibaba_bg.jpg',fit:BoxFit.cover, errorBuilder: (_,__,___)=> Container(color: Colors.white))), Positioned.fill(child: Container(color:Colors.white.withOpacity(0.35))), SafeArea(child: SingleChildScrollView(padding:EdgeInsets.all(18),child: Column(children:[ Container(padding:EdgeInsets.all(8),decoration:BoxDecoration(color:Colors.white.withOpacity(0.9),borderRadius:BorderRadius.circular(14)),child: Row(children:[IconButton(icon:Icon(Icons.arrow_back),onPressed:()=>Navigator.pop(c)),Text("VIDYARTHI EDIT",style:TextStyle(fontWeight:FontWeight.bold))])) , SizedBox(height:16), Container(padding:EdgeInsets.all(16),decoration:BoxDecoration(color:Colors.white.withOpacity(0.93),borderRadius:BorderRadius.circular(20)),child: Column(children:[ TextField(controller:nameC,decoration:InputDecoration(labelText:"Nav",prefixIcon:Icon(Icons.person))), TextField(controller:ageC,decoration:InputDecoration(labelText:"Vay")), TextField(controller:stdC,decoration:InputDecoration(labelText:"Std")), TextField(controller:feeC,decoration:InputDecoration(labelText:"Fee")), TextField(controller:mobileC,decoration:InputDecoration(labelText:"Mobile")), SizedBox(height:12), Wrap(spacing:8,runSpacing:8,children: List.generate(12,(i){ bool p=months[i]==1; return GestureDetector(onTap:()=>setState(()=>months[i]=p?0:1),child: Container(width:60,padding:EdgeInsets.all(10),decoration:BoxDecoration(color:p?Colors.green:Colors.pink.shade100,borderRadius:BorderRadius.circular(12)),child: Column(children:[Text(["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"][i],style:TextStyle(fontSize:10,color:p?Colors.white:Colors.black)),Icon(p?Icons.check:Icons.close,size:14,color:p?Colors.white:Colors.pink)])));})), ])), SizedBox(height:20), ElevatedButton(onPressed:(){ var u=<String,dynamic>{"name":nameC.text,"age":ageC.text,"std":stdC.text,"fee":int.tryParse(feeC.text)??600,"mobile":mobileC.text,"months":months}; Navigator.pop(c,u); },style:ElevatedButton.styleFrom(backgroundColor:Colors.orange,minimumSize:Size(double.infinity,54)),child:Text("SAVE CHANGES",style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold))) ]))) ])), );
  }
}
class AddStudentDialog extends StatefulWidget{ @override State<AddStudentDialog> createState()=> _AddStudentDialogState(); }
class _AddStudentDialogState extends State<AddStudentDialog>{
  var nameC=TextEditingController(); var feeC=TextEditingController(text:"500"); var ageC=TextEditingController(text:"6"); var stdC=TextEditingController(text:"1"); var mobC=TextEditingController();
  @override Widget build(BuildContext c){ return AlertDialog(title: Text("नवीन विद्यार्थी जोडा"), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [ TextField(controller: nameC, decoration: InputDecoration(labelText: "नाव *", prefixIcon: Icon(Icons.person))), SizedBox(height:8), TextField(controller: ageC, decoration: InputDecoration(labelText: "वय")), TextField(controller: stdC, decoration: InputDecoration(labelText: "इयत्ता")), TextField(controller: feeC, decoration: InputDecoration(labelText: "Fee"), keyboardType: TextInputType.number), TextField(controller: mobC, decoration: InputDecoration(labelText: "Mobile"), keyboardType: TextInputType.phone), ])), actions: [ TextButton(onPressed: ()=>Navigator.pop(c), child: Text("Cancel")), ElevatedButton(onPressed: (){ if(nameC.text.trim().isEmpty){ ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text("नाव टाका"))); return; } var s=<String,dynamic>{"name":nameC.text.trim(),"age":ageC.text,"std":stdC.text,"fee":int.tryParse(feeC.text)??500,"mobile":mobC.text,"months":List.filled(12,0)}; Navigator.pop(c, s); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: Text("Add करा", style: TextStyle(color: Colors.white))) ], ); }
}
