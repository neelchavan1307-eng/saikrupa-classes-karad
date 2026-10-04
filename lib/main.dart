import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';1
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const MyApp());
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData(useMaterial3: true), home: const HomePage());
  }
}

class Student {
  String name; int age; String month; int fee; List<String> paidMonths; String phone;
  Student({required this.name, required this.age, required this.month, required this.fee, required this.paidMonths, this.phone = ''});
  Map<String,dynamic> toJson() => {'name':name,'age':age,'month':month,'fee':fee,'paid':paidMonths,'phone':phone};
  factory Student.fromJson(Map<String,dynamic> j) => Student(name:j['name'], age:j['age'], month:j['month'], fee:j['fee'], paidMonths:List<String>.from(j['paid']), phone:j['phone']??'');
}

class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState() => _HomePageState(); }

class _HomePageState extends State<HomePage> {
  List<Student> students = []; String filter='सर्व'; String search='';
  String className='SAIKRUPA CLASSES'; String teacherName='प्रा. प्रदीप चव्हाण'; String location='कराड, महाराष्ट्र'; String phoneNo='9822001122';
  String? profileImageBase64;
  final months = ['J','F','M','A','M','J','J','A','S','O','N','D'];
  final monthNames = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  @override void initState(){ super.initState(); _loadData(); }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('students');
    if(data!=null){
      setState(()=> students = (jsonDecode(data) as List).map((e)=>Student.fromJson(e)).toList());
    } else {
      students = [
        Student(name:'Vihan Tupe',age:6,month:'Sep 2025',fee:1000,paidMonths:['J','F','M','A']),
        Student(name:'Krisha Kirme',age:10,month:'Sep 2025',fee:1200,paidMonths:['J','F','M']),
        Student(name:'Anshuman Itape',age:10,month:'Sep 2025',fee:1000,paidMonths:[]),
        Student(name:'Aaradhya Yadav',age:8,month:'Sep 2025',fee:1000,paidMonths:['J','F','M','A','M','J','J','A','S']),
        Student(name:'Samyak Shirke',age:5,month:'Sep 2025',fee:800,paidMonths:['J','F','M','A','M','J','J','A','S']),
        Student(name:'Shreya Gadekar',age:11,month:'Sep 2025',fee:800,paidMonths:['J','F','M','A','M','J','J','A','S','O','N']),
        Student(name:'Swara Patil',age:3,month:'Sep 2025',fee:800,paidMonths:['J']),
        Student(name:'Swaroop Patil',age:3,month:'Sep 2025',fee:800,paidMonths:['J','F','M','A','M']),
        Student(name:'Tejal Patil',age:25,month:'Sep 2025',fee:1500,paidMonths:['J','F']),
        Student(name:'Poorva Patil',age:20,month:'Sep 2025',fee:1500,paidMonths:['J','F','M','A','M','J','J','A','S','O']),
        Student(name:'Samskurti',age:14,month:'Sep 2025',fee:1200,paidMonths:['J','F','M','A','M','J','J','A','S','O']),
        Student(name:'Swaransh',age:10,month:'Sep 2025',fee:1000,paidMonths:['J','F','M']),
      ];
    }
    className = prefs.getString('className')??className;
    teacherName = prefs.getString('teacherName')??teacherName;
    location = prefs.getString('location')??location;
    phoneNo = prefs.getString('phoneNo')??phoneNo;
    profileImageBase64 = prefs.getString('profileImage');
    setState((){});
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('students', jsonEncode(students.map((e)=>e.toJson()).toList()));
    prefs.setString('className', className);
    prefs.setString('teacherName', teacherName);
    prefs.setString('location', location);
    prefs.setString('phoneNo', phoneNo);
    if(profileImageBase64!=null) prefs.setString('profileImage', profileImageBase64!);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if(img!=null){
      final bytes = await img.readAsBytes();
      setState(()=> profileImageBase64 = base64Encode(bytes));
      _save();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('DP बदलला ✓')));
    }
  }

  void _editProfile(){
    final c1=TextEditingController(text:className);
    final c2=TextEditingController(text:teacherName);
    final c3=TextEditingController(text:location);
    final c4=TextEditingController(text:phoneNo);
    showDialog(context: context, builder: (_)=>AlertDialog(
      title: const Text('माहिती बदला (Edit Profile)'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(onTap: (){ Navigator.pop(context); _pickImage(); },
          child: profileImageBase64==null
           ? ClipRRect(borderRadius: BorderRadius.circular(40), child: Image.asset('assets/logo.png', width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (c,e,s)=> CircleAvatar(radius: 40, backgroundColor: Colors.orange.shade100, child: const Icon(Icons.camera_alt, size: 30))))
            : CircleAvatar(radius: 40, backgroundImage: MemoryImage(base64Decode(profileImageBase64!)))
        ),
        const SizedBox(height: 8),
        const Text('DP बदलण्यासाठी फोटोवर Click करा', style: TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 10),
        TextField(controller: c1, decoration: const InputDecoration(labelText: 'Class Name')),
        TextField(controller: c2, decoration: const InputDecoration(labelText: 'Teacher Name')),
        TextField(controller: c3, decoration: const InputDecoration(labelText: 'Location')),
        TextField(controller: c4, decoration: const InputDecoration(labelText: 'Phone')),
      ])),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: (){ setState((){ className=c1.text; teacherName=c2.text; location=c3.text; phoneNo=c4.text; }); _save(); Navigator.pop(context); }, child: const Text('Save'))
      ]
    ));
  }

  void _addOrEditStudent({Student? edit, int? idx}){
    final n=TextEditingController(text:edit?.name??'');
    final a=TextEditingController(text:edit?.age.toString()??'');
    final f=TextEditingController(text:edit?.fee.toString()??'');
    final ph=TextEditingController(text:edit?.phone??'');
    showDialog(context: context, builder: (_)=>AlertDialog(
      title: Text(edit==null?'+ नवीन विद्यार्थी':'Edit करा'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: n, decoration: const InputDecoration(labelText: 'नाव')),
        TextField(controller: a, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'वय')),
        TextField(controller: f, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monthly Fee')),
        TextField(controller: ph, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number')),
      ]),
      actions: [
        if(edit!=null) TextButton(onPressed: (){ setState(()=> students.removeAt(idx!)); _save(); Navigator.pop(context); }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
        TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: (){ if(n.text.isEmpty) return; final s=Student(name:n.text, age:int.tryParse(a.text)??10, month:'Sep 2025', fee:int.tryParse(f.text)??1000, paidMonths:edit?.paidMonths??[], phone:ph.text); setState((){ if(edit==null) students.add(s); else students[idx!]=s; }); _save(); Navigator.pop(context); }, child: Text(edit==null?'Add':'Save'))
      ]
    ));
  }

  void _showDigitalReceipt(Student s, String monthChar){
    int idx = months.indexOf(monthChar);
    String mName = monthNames[idx];
    int fee = s.fee;
    String date = "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    String receiptNo = "#SK-${s.name.substring(0,2).toUpperCase()}${DateTime.now().millisecondsSinceEpoch%10000}";

    showDialog(context: context, builder: (_)=>Dialog(
      insetPadding: const EdgeInsets.all(12),
      child: SingleChildScrollView(child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          // RECEIPT CARD WITH LOGO
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: Colors.orange, width: 2), borderRadius: BorderRadius.circular(12)), child: Column(children: [
            Row(children: [
              ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/logo.png', width: 55, height: 55, fit: BoxFit.cover, errorBuilder: (c,e,s)=> Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.school, color: Colors.orange, size: 32)))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(className, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                Text(teacherName, style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
                Text('$location', style: const TextStyle(fontSize: 10)),
                Text('Ph: $phoneNo', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ]))
            ]),
            const Divider(thickness: 2, color: Colors.orange),
            const Text('FEE RECEIPT - फी पावती', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
            const Divider(),
            Table(columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)}, children: [
              TableRow(children: [const Padding(padding: EdgeInsets.all(5), child: Text('Receipt No:', style: TextStyle(fontSize: 12))), Padding(padding: const EdgeInsets.all(5), child: Text(receiptNo, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))]),
              TableRow(children: [const Padding(padding: EdgeInsets.all(5), child: Text('Date:', style: TextStyle(fontSize: 12))), Padding(padding: EdgeInsets.all(5), child: Text(date, style: const TextStyle(fontSize: 12)))]),
              TableRow(children: [const Padding(padding: EdgeInsets.all(5), child: Text('Student Name:', style: TextStyle(fontSize: 12))), Padding(padding: EdgeInsets.all(5), child: Text(s.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)))]),
              TableRow(children: [const Padding(padding: EdgeInsets.all(5), child: Text('Age:', style: TextStyle(fontSize: 12))), Padding(padding: EdgeInsets.all(5), child: Text('${s.age} वर्ष', style: const TextStyle(fontSize: 12)))]),
              TableRow(children: [const Padding(padding: EdgeInsets.all(5), child: Text('Month:', style: TextStyle(fontSize: 12))), Padding(padding: EdgeInsets.all(5), child: Text('$mName 2025 ($monthChar)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)))]),
              TableRow(children: [const Padding(padding: EdgeInsets.all(5), child: Text('Amount:', style: TextStyle(fontSize: 12))), Padding(padding: EdgeInsets.all(5), child: Text('₹$fee/-', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)))]),
              TableRow(children: [const Padding(padding: EdgeInsets.all(5), child: Text('Status:', style: TextStyle(fontSize: 12))), const Padding(padding: EdgeInsets.all(5), child: Text('PAID ✓', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)))]),
            ]),
            const SizedBox(height: 12),
            Container(width: double.infinity, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)), child: const Column(children: [Text('फी मिळाली, धन्यवाद! 🙏', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)), SizedBox(height: 2), Text('Fee Received Successfully', style: TextStyle(fontSize: 10, color: Colors.grey))])),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Column(children: [Text('__________', style: TextStyle(fontSize: 10)), Text('पालक स्वाक्षरी', style: TextStyle(fontSize: 10))]),
              Column(children: [Text(teacherName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), const Text('__________', style: TextStyle(fontSize: 10)), const Text('संचालक स्वाक्षरी', style: TextStyle(fontSize: 10)), Text(className, style: const TextStyle(fontSize: 8, color: Colors.grey))])
            ]),
          ])),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: ElevatedButton.icon(onPressed: ()=>Navigator.pop(context), icon: const Icon(Icons.close, size: 18), label: const Text('बंद करा'), style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white))),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: ElevatedButton.icon(onPressed: (){ Navigator.pop(context); _shareReceipt(s, mName, fee, date, receiptNo); }, icon: const Icon(Icons.send, size: 18), label: const Text('WhatsApp पाठवा'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white))),
          ])
        ])
      ))
    ));
  }

  Future<void> _shareReceipt(Student s, String mName, int fee, String date, String receiptNo) async {
    final msg = """*${className} - Digital Fee Receipt* 🧾
━━━━━━━━━━━━━━━
*Receipt No:* $receiptNo
*Date:* $date
*Student:* ${s.name} (वय ${s.age})
*Month:* $mName 2025
*Amount:* ₹$fee/- *PAID ✓*
━━━━━━━━━━━━━━━
*फी मिळाली, धन्यवाद!* 🙏

*${className}*
*${teacherName}*
*$location | $phoneNo*""";
    final url = Uri.parse("https://wa.me/${s.phone.isNotEmpty?'91${s.phone}':''}?text=${Uri.encodeComponent(msg)}");
    if(await canLaunchUrl(url)){
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("WhatsApp Message:\n$msg")));
    }
  }

  Future<void> _whatsappBal(Student s) async {
    int bal=(12-s.paidMonths.length)*s.fee;
    final msg='नमस्कार, ${s.name} यांची Fee बाकी आहे - ₹$bal. $className - $phoneNo';
    final url=Uri.parse('https://wa.me/${s.phone.isNotEmpty?'91${s.phone}':''}?text=${Uri.encodeComponent(msg)}');
    if(await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  List<Student> get filtered => students.where((s){ bool m=search.isEmpty || s.name.toLowerCase().contains(search.toLowerCase()); bool f=true; if(filter=='बाकी') f=s.paidMonths.length<12; if(filter=='संपलेला') f=s.paidMonths.length==12; return m&&f; }).toList();
  int get totalPaid => students.fold(0, (sum,s)=> sum + s.paidMonths.length*s.fee);
  int get totalBal => students.fold(0, (sum,s)=> sum + (12-s.paidMonths.length)*s.fee);

  @override Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.asset('assets/logo.png', width: 36, height: 36, fit: BoxFit.cover, errorBuilder: (c,e,s)=> CircleAvatar(backgroundColor: Colors.orange.shade100, child: const Icon(Icons.school, color: Colors.orange)))),
          const SizedBox(width: 8),
          Text(className, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))
        ]),
        actions: [
          IconButton(onPressed: ()=>_addOrEditStudent(), icon: const Icon(Icons.person_add, color: Colors.green)),
          IconButton(onPressed: _editProfile, icon: const Icon(Icons.edit, color: Colors.blue))
        ]
      ),
      body: SingleChildScrollView(child: Column(children: [
        Container(width: double.infinity, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFE040FB)])), child: Container(margin: const EdgeInsets.all(12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(children: [
          GestureDetector(onTap: _pickImage, child: Stack(children: [
            profileImageBase64==null
             ? ClipRRect(borderRadius: BorderRadius.circular(45), child: Image.asset('assets/logo.png', width: 90, height: 90, fit: BoxFit.cover, errorBuilder: (c,e,s)=> CircleAvatar(radius: 45, backgroundColor: Colors.orange.shade100, child: const Icon(Icons.person, size: 40, color: Colors.brown))))
              : CircleAvatar(radius: 45, backgroundImage: MemoryImage(base64Decode(profileImageBase64!))),
            Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle), child: const Icon(Icons.camera_alt, size: 18, color: Colors.white)))
          ])),
          const SizedBox(height: 6),
          const Text('DP बदलण्यासाठी फोटोवर Click करा', style: TextStyle(fontSize: 9, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(className, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(teacherName, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [ActionChip(label: const Text('सेटिंग्स', style: TextStyle(fontSize: 10)), onPressed: _editProfile), const SizedBox(width: 8), ActionChip(label: const Text('माहिती बदला', style: TextStyle(fontSize: 10)), onPressed: _editProfile)]),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: ()=>_addOrEditStudent(), style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('+ नवीन विद्यार्थी', style: TextStyle(color: Colors.white))),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.location_on, size: 14), Text(' $location', style: const TextStyle(fontSize: 12)), const SizedBox(width: 15), const Icon(Icons.phone, size: 14), Text(' $phoneNo', style: const TextStyle(fontSize: 12))]),
        ]))),
        Padding(padding: const EdgeInsets.all(12), child: Column(children: [
          Row(children: [Expanded(child: _dash('एकूण विद्यार्थी','${students.length}','', Colors.blue.shade50)), const SizedBox(width: 8), Expanded(child: _dash('एकूण जमा (PAID)','₹$totalPaid','', Colors.green.shade50))]),
          const SizedBox(height: 8),
          Row(children: [Expanded(child: _dash('एकूण बाकी (BALANCE)','₹$totalBal','', Colors.red.shade50)), const SizedBox(width: 8), Expanded(child: _dash('बाकी असलेले','${students.where((s)=>s.paidMonths.length<12).length} विद्यार्थी','', Colors.yellow.shade50))]),
          const SizedBox(height: 12),
          TextField(onChanged: (v)=>setState(()=>search=v), decoration: InputDecoration(hintText: 'विद्यार्थी शोधा...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white)),
          const SizedBox(height: 10),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [_fBtn('सर्व (${students.length})','सर्व'), _fBtn('बाकी (${students.where((s)=>s.paidMonths.length<12).length})','बाकी'), _fBtn('संपलेला (${stu_sampलेला (${students.where((s)=>s.paidMonths.length==12).length})','संपलेला')])),
          const SizedBox(height: 10),...filtered.asMap().entries.map((e)=> _studentCard(e.key+1, e.value)),
        ])),
      ])),
    );
  }
  Widget _dash(String t,String v,String sub,Color c)=>Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontSize: 10)), const SizedBox(height: 4), Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), if(sub.isNotEmpty) Text(sub, style: const TextStyle(fontSize: 9))]));
  Widget _fBtn(String l,String val){ bool sel=filter==val; return Padding(padding: const EdgeInsets.only(right:6), child: ChoiceChip(label: Text(l, style: TextStyle(fontSize:12, color: sel?Colors.white:Colors.black)), selected: sel, selectedColor: Colors.green, onSelected: (v){ setState(()=> filter=val); })); }
  Widget _studentCard(int index, Student s){
    int paid=s.paidMonths.length*s.fee; int bal=(12-s.paidMonths.length)*s.fee;
    return GestureDetector(onLongPress: ()=>_addOrEditStudent(edit: s, idx: students.indexOf(s)), child: Container(margin: const EdgeInsets.only(bottom:10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [const BoxShadow(color: Colors.black12, blurRadius:3)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Text('$index', style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(width:8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${s.name} | वय ${s.age}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize:13)), Text('नोंदणी / ${s.month}${s.phone.isNotEmpty?" | ${s.phone}":""}', style: const TextStyle(fontSize:10, color: Colors.grey))])), Column(children: [Container(padding: const EdgeInsets.symmetric(horizontal:6, vertical:2), decoration: BoxDecoration(color: s.paidMonths.length<12?Colors.orange.shade100:Colors.green.shade100, borderRadius: BorderRadius.circular(10)), child: Text(s.paidMonths.length<12?'Fee बाकी':'Paid', style: TextStyle(fontSize:9, color: s.paidMonths.length<12?Colors.orange:Colors.green))), const SizedBox(height:4), Container(padding: const EdgeInsets.symmetric(horizontal:8, vertical:2), decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)), child: Text('₹${s.fee}', style: const TextStyle(fontSize:11, fontWeight: FontWeight.bold)))])]),
      const SizedBox(height:10),
      GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:6, childAspectRatio:1.3, crossAxisSpacing:4, mainAxisSpacing:4), itemCount:12, itemBuilder: (c,i){ bool isPaid=s.paidMonths.contains(months[i]); return InkWell(onTap: (){ if(isPaid) _showDigitalReceipt(s, months[i]); else { setState(()=> s.paidMonths.add(months[i])); _save(); _showDigitalReceipt(s, months[i]); } }, child: Container(decoration: BoxDecoration(color: isPaid?Colors.green:Colors.red.shade100, borderRadius: BorderRadius.circular(6), border: Border.all(color: isPaid?Colors.green:Colors.red.shade200)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(months[i], style: TextStyle(fontSize:11, fontWeight: FontWeight.bold, color: isPaid?Colors.white:Colors.red)), Text(isPaid?'✓':'x', style: TextStyle(fontSize:9, color: isPaid?Colors.white:Colors.red)), Text(monthNames[i], style: TextStyle(fontSize:6, color: isPaid?Colors.white70:Colors.red))]))); }),
      const SizedBox(height:8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('जमा\n₹$paid', style: const TextStyle(fontSize:10, fontWeight: FontWeight.bold)), Text('बाकी\n₹$bal', style: const TextStyle(fontSize:10, fontWeight: FontWeight.bold, color: Colors.red)), Row(children: [InkWell(onTap: (){ if(s.paidMonths.isNotEmpty) _showDigitalReceipt(s, s.paidMonths.last); }, child: _b('पावती', Colors.blue)), InkWell(onTap: ()=>_addOrEditStudent(edit: s, idx: students.indexOf(s)), child: _b('माहिती', Colors.orange)), InkWell(onTap: ()=>_whatsappBal(s), child: _b('WhatsApp', Colors.green))])]),
      const SizedBox(height:4), const Text('महिन्यावर Click करा - Digital पावती येईल', style: TextStyle(fontSize:7, color: Colors.grey)),
    ])));
  }
  Widget _b(String t, Color c)=>Container(margin: const EdgeInsets.only(left:4), padding: const EdgeInsets.symmetric(horizontal:8, vertical:4), decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(15)), child: Text(t, style: const TextStyle(color: Colors.white, fontSize:10)));
                                                                                                                                                                                                                                                 }
