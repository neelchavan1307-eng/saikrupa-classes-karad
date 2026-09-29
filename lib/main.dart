import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Saikrupa Classes', debugShowCheckedModeBanner: false, theme: ThemeData(primarySwatch: Colors.orange, useMaterial3: true), home: const HomePage());
  }
}

class Student {
  String name, phone; int monthlyFee; DateTime joiningDate; List<bool> months;
  Student({required this.name, required this.phone, required this.monthlyFee, required this.joiningDate, required this.months});
  int get paidAmount => months.where((e)=>e).length * monthlyFee;
  int get balance => (12*monthlyFee) - paidAmount;
  Map<String,dynamic> toJson()=>{'name':name,'phone':phone,'monthlyFee':monthlyFee,'joiningDate':joiningDate.toIso8601String(),'months':months};
  factory Student.fromJson(Map<String,dynamic> j)=>Student(name:j['name'],phone:j['phone'],monthlyFee:j['monthlyFee'],joiningDate:DateTime.parse(j['joiningDate']),months:List<bool>.from(j['months']));
}

class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState()=>_HomePageState(); }

class _HomePageState extends State<HomePage> {
  List<Student> students=[]; String search=""; String profileName="SAIKRUPA CLASSES"; String profileAddr="Malakapur, Karad"; String profilePhone="90220022XX"; String? profileImageBase64;
  final monthsShort=["J","F","M","A","M","J","J","A","S","O","N","D"]; final monthsFull=["January","February","March","April","May","June","July","August","September","October","November","December"];
  @override void initState(){super.initState(); loadAll();}

  loadAll() async {
    final p=await SharedPreferences.getInstance();
    profileName=p.getString('pName')??"SAIKRUPA CLASSES"; profileAddr=p.getString('pAddr')??"Malakapur, Karad"; profilePhone=p.getString('pPhone')??"90220022XX"; profileImageBase64=p.getString('pImg');
    String? d=p.getString('students_pro'); if(d!=null){ List l=jsonDecode(d); setState(()=>students=l.map((e)=>Student.fromJson(e)).toList()); } else { setState(() {}); }
  }
  saveAll() async {
    final p=await SharedPreferences.getInstance();
    p.setString('pName',profileName); p.setString('pAddr',profileAddr); p.setString('pPhone',profilePhone); if(profileImageBase64!=null) p.setString('pImg',profileImageBase64!);
    p.setString('students_pro', jsonEncode(students.map((e)=>e.toJson()).toList()));
  }

  Future<void> pickProfileImage() async {
    final picker=ImagePicker(); final XFile? img=await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if(img!=null){ final bytes=await img.readAsBytes(); setState(()=>profileImageBase64=base64Encode(bytes)); saveAll(); }
  }

  void editProfileDialog(){
    String n=profileName,a=profileAddr,ph=profilePhone;
    showDialog(context:context,builder:(c)=>AlertDialog(title:const Text('Profile Edit Kara'), content:Column(mainAxisSize:MainAxisSize.min, children:[
      GestureDetector(onTap: pickProfileImage, child: CircleAvatar(radius: 40, backgroundImage: profileImageBase64!=null? MemoryImage(base64Decode(profileImageBase64!)):null, child: profileImageBase64==null? const Icon(Icons.camera_alt,size: 30):null)),
      const SizedBox(height:10), const Text('DP var click karun photo badla',style:TextStyle(fontSize:11)),
      TextField(decoration: const InputDecoration(labelText:'Classes Name'), controller: TextEditingController(text:n), onChanged:(v)=>n=v),
      TextField(decoration: const InputDecoration(labelText:'Address'), controller: TextEditingController(text:a), onChanged:(v)=>a=v),
      TextField(decoration: const InputDecoration(labelText:'Mobile'), controller: TextEditingController(text:ph), onChanged:(v)=>ph=v),
    ]), actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Cancel')), ElevatedButton(onPressed:(){setState(()=>{profileName=n,profileAddr=a,profilePhone=ph}); saveAll(); Navigator.pop(c);}, child:const Text('Save'))]));
  }

  void addStudentDialog(){
    String name="",phone=""; int fee=500; DateTime joinDate=DateTime.now();
    showDialog(context:context,builder:(c)=> StatefulBuilder(builder:(context,setD){ return AlertDialog(title:const Text('Navin Vidyarthi'), content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min, children:[
      TextField(decoration:const InputDecoration(labelText:'Nav (Ex: Vihan Tope)'), onChanged:(v)=>name=v),
      TextField(decoration:const InputDecoration(labelText:'Contact Number'), keyboardType:TextInputType.phone, onChanged:(v)=>phone=v),
      TextField(decoration:const InputDecoration(labelText:'Monthly Amount'), keyboardType:TextInputType.number, controller:TextEditingController(text:"500"), onChanged:(v)=>fee=int.tryParse(v)??500),
      const SizedBox(height:10),
      Row(children:[const Text('Joining Date:'), const SizedBox(width:10), Text(DateFormat('dd-MM-yyyy').format(joinDate)), IconButton(icon:const Icon(Icons.calendar_today), onPressed:() async { DateTime? d=await showDatePicker(context:context,initialDate:joinDate,firstDate:DateTime(2020),lastDate:DateTime(2030)); if(d!=null) setD(()=>joinDate=d); })]),
    ])), actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Cancel')), ElevatedButton(onPressed:(){ if(name.isNotEmpty){ setState(()=>students.add(Student(name:name,phone:phone,monthlyFee:fee,joiningDate:joinDate,months:List.filled(12,false)))); saveAll(); Navigator.pop(c); } }, child:const Text('Add'))]]);}));
  }

  void sendReceipt(Student s, int monthIndex) async {
    String msg="*${profileName}*\n*Fee Receipt*\n\nVidhyarthi: ${s.name}\nMahina: ${monthsFull[monthIndex]}\nAmount: Rs.${s.monthlyFee}\nDate: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}\n\nPaid: Rs.${s.paidAmount} | Baki: Rs.${s.balance}\n\n- $profileName\n$profileAddr\n$profilePhone";
    final url=Uri.parse("https://wa.me/91${s.phone}?text=${Uri.encodeComponent(msg)}"); if(await canLaunchUrl(url)) await launchUrl(url,mode:LaunchMode.externalApplication);
  }

  void sendReminder(Student s) async {
    int currentMonth=DateTime.now().month-1;
    if(s.months[currentMonth]) return;
    String msg="Namaskar 🙏 ${s.name} Palak,\n\n${monthsFull[currentMonth]} chi fee Rs.${s.monthlyFee} baki aahe.\nEkun Baki: Rs.${s.balance}\n\nKrupa karun lavkarat lavkar jama kara.\n\n- $profileName\n$profilePhone";
    final url=Uri.parse("https://wa.me/91${s.phone}?text=${Uri.encodeComponent(msg)}"); if(await canLaunchUrl(url)) await launchUrl(url,mode:LaunchMode.externalApplication);
  }

  @override Widget build(BuildContext context){
    int totalPaid=students.fold(0,(a,b)=>a+b.paidAmount); int totalBal=students.fold(0,(a,b)=>a+b.balance);
    var filtered=students.where((e)=>e.name.toLowerCase().contains(search.toLowerCase())||e.phone.contains(search)).toList();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(child: SingleChildScrollView(child: Column(children:[
        Container(color:Colors.white, padding:const EdgeInsets.all(16), child:Column(children:[
          Row(children:[
            GestureDetector(onTap: editProfileDialog, child: CircleAvatar(radius:30, backgroundColor:Colors.orange.shade100, backgroundImage: profileImageBase64!=null? MemoryImage(base64Decode(profileImageBase64!)):null, child: profileImageBase64==null? Text(profileName.isNotEmpty?profileName[0]:"S",style:const TextStyle(fontWeight:FontWeight.bold,fontSize:22,color:Colors.deepOrange)):null)),
            const SizedBox(width:12),
            Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text(profileName,style:const TextStyle(fontWeight:FontWeight.bold,fontSize:17)), Text(profileAddr,style:const TextStyle(fontSize:12,color:Colors.grey)), Text(profilePhone,style:const TextStyle(fontSize:11))])),
            IconButton(onPressed:editProfileDialog, icon:const Icon(Icons.edit,size:20))
          ]),
          const SizedBox(height:12),
          Row(children:[Expanded(child:_card("${students.length}","एकूण विद्यार्थी",const Color(0xFFFFE0B2))),const SizedBox(width:8),Expanded(child:_card("Rs.$totalPaid","एकूण जमा",const Color(0xFFC8E6C9)))]),
          const SizedBox(height:8),
          Row(children:[Expanded(child:_card("Rs.$totalBal","एकूण बाकी",const Color(0xFFFFCDD2))),const SizedBox(width:8),Expanded(child:_card("${students.where((e)=>e.balance>0).length}","फी बाकी",const Color(0xFFFFF9C4)))]),
        ])),
        const SizedBox(height:8),
        Container(color:Colors.white, padding:const EdgeInsets.all(8), child:TextField(decoration:InputDecoration(prefixIcon:const Icon(Icons.search),hintText:'Nav / Mobile ne shodha...',border:OutlineInputBorder(borderRadius:BorderRadius.circular(12))),onChanged:(v)=>setState(()=>search=v))),
        SingleChildScrollView(scrollDirection:Axis.horizontal, child:Column(children:[
          Container(color:const Color(0xFF1E1E2F), width:1100, padding:const EdgeInsets.symmetric(vertical:12,horizontal:8), child:Row(children:[
            const SizedBox(width:130,child:Text('नाव',style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:12))),
            const SizedBox(width:110,child:Text('कॉन्टॅक्ट',style:TextStyle(color:Colors.white,fontSize:11))),
            const SizedBox(width:70,child:Text('अमाउंट',style:TextStyle(color:Colors.white,fontSize:11))),
            const SizedBox(width:90,child:Text('जॉइनिंग डेट',style:TextStyle(color:Colors.white,fontSize:11))),
           ...monthsShort.map((m)=>Container(width:36,margin:const EdgeInsets.symmetric(horizontal:2),child:Center(child:Text(m,style:const TextStyle(color:Colors.white70,fontWeight:FontWeight.bold,fontSize:12))))),
            const SizedBox(width:70,child:Text('रिसीट',style:TextStyle(color:Colors.white,fontSize:11))),
            const SizedBox(width:80,child:Text('रिमाइंडर',style:TextStyle(color:Colors.white,fontSize:11))),
          ])),
         ...filtered.map((s){ int idx=students.indexOf(s); return Container(color:Colors.white,width:1100,margin:const EdgeInsets.only(bottom:1),padding:const EdgeInsets.symmetric(vertical:10,horizontal:8),child:Row(children:[
            SizedBox(width:130,child:Text(s.name,style:const TextStyle(fontWeight:FontWeight.bold,fontSize:12))),
            SizedBox(width:110,child:Text(s.phone,style:const TextStyle(fontSize:11))),
            SizedBox(width:70,child:Text('Rs.${s.monthlyFee}',style:const TextStyle(fontSize:11,fontWeight:FontWeight.bold))),
            SizedBox(width:90,child:Text(DateFormat('dd-MM-yy').format(s.joiningDate),style:const TextStyle(fontSize:11))),
           ...List.generate(12,(mi){ bool ok=s.months[mi]; return GestureDetector(onTap:(){ setState(()=>students[idx].months[mi]=!students[idx].months[mi]); saveAll(); }, child:Container(width:36,height:28,margin:const EdgeInsets.symmetric(horizontal:2),decoration:BoxDecoration(color:ok?Colors.green:Colors.red.shade300,borderRadius:BorderRadius.circular(6)),child:Icon(ok?Icons.check:Icons.close,size:16,color:Colors.white)));}),
            SizedBox(width:70,child:IconButton(icon:const Icon(Icons.receipt,size:20,color:Colors.blue), onPressed:(){ int lastPaid=s.months.lastIndexWhere((e)=>e); if(lastPaid!=-1) sendReceipt(s,lastPaid); else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Aadhi konata tari mahina paid kara'))); })),
            SizedBox(width:80,child:ElevatedButton(onPressed:()=>sendReminder(s), style:ElevatedButton.styleFrom(backgroundColor:Colors.orange,padding:const EdgeInsets.symmetric(horizontal:8,vertical:4)), child:const Text('Remind',style:TextStyle(fontSize:10,color:Colors.white)))),
          ]));}).toList(),
        ])),
        const SizedBox(height:100),
      ]))),
      floatingActionButton: FloatingActionButton.extended(onPressed:addStudentDialog,label:const Text('Add Student'),icon:const Icon(Icons.add),backgroundColor:Colors.deepOrange,foregroundColor:Colors.white),
    );
  }
  Widget _card(String v,String t,Color c){ return Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:c,borderRadius:BorderRadius.circular(10)),child:Column(children:[Text(v,style:const TextStyle(fontWeight:FontWeight.bold,fontSize:16)),Text(t,style:const TextStyle(fontSize:10),textAlign:TextAlign.center)]));}
}
