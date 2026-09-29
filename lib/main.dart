import 'dart:convert';
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
    return const MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}

class Student {
  String name, phone;
  int monthlyFee;
  DateTime joiningDate;
  List<bool> months;
  Student({required this.name, required this.phone, required this.monthlyFee, required this.joiningDate, required this.months});
  int get paidAmount => months.where((e) => e).length * monthlyFee;
  int get balance => (12 * monthlyFee) - paidAmount;
  Map<String, dynamic> toJson() => {'name': name, 'phone': phone, 'monthlyFee': monthlyFee, 'joiningDate': joiningDate.toIso8601String(), 'months': months};
  factory Student.fromJson(Map<String, dynamic> j) => Student(name: j['name'], phone: j['phone'], monthlyFee: j['monthlyFee'], joiningDate: DateTime.parse(j['joiningDate']), months: List<bool>.from(j['months']));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Student> students = [];
  String search = "";
  String profileName = "SAIKRUPA CLASSES";
  String profileAddr = "Malakapur, Karad";
  String profilePhone = "90220022XX";
  String? profileImageBase64;
  final monthsShort = ["J","F","M","A","M","J","J","A","S","O","N","D"];
  final monthsFull = ["January","February","March","April","May","June","July","August","September","October","November","December"];

  @override
  void initState() { super.initState(); loadAll(); }

  Future<void> loadAll() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      profileName = p.getString('pName')?? "SAIKRUPA CLASSES";
      profileAddr = p.getString('pAddr')?? "Malakapur, Karad";
      profilePhone = p.getString('pPhone')?? "90220022XX";
      profileImageBase64 = p.getString('pImg');
    });
    String? d = p.getString('students_pro');
    if (d!= null) {
      List l = jsonDecode(d);
      setState(() { students = l.map((e) => Student.fromJson(e)).toList(); });
    }
  }

  Future<void> saveAll() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('pName', profileName);
    await p.setString('pAddr', profileAddr);
    await p.setString('pPhone', profilePhone);
    if (profileImageBase64!= null) await p.setString('pImg', profileImageBase64!);
    await p.setString('students_pro', jsonEncode(students.map((e) => e.toJson()).toList()));
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (img!= null) {
      final bytes = await img.readAsBytes();
      setState(() { profileImageBase64 = base64Encode(bytes); });
      saveAll();
    }
  }

  void editProfile() {
    String n = profileName, a = profileAddr, ph = profilePhone;
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text('Profile Edit'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(onTap: pickImage, child: CircleAvatar(radius: 35, backgroundImage: profileImageBase64!= null? MemoryImage(base64Decode(profileImageBase64!)) : null, child: profileImageBase64 == null? const Icon(Icons.camera_alt) : null)),
        const SizedBox(height: 6),
        TextField(controller: TextEditingController(text: n), decoration: const InputDecoration(labelText: 'Name'), onChanged: (v) => n = v),
        TextField(controller: TextEditingController(text: a), decoration: const InputDecoration(labelText: 'Address'), onChanged: (v) => a = v),
        TextField(controller: TextEditingController(text: ph), decoration: const InputDecoration(labelText: 'Mobile'), onChanged: (v) => ph = v),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')), ElevatedButton(onPressed: () { setState(() { profileName = n; profileAddr = a; profilePhone = ph; }); saveAll(); Navigator.pop(c); }, child: const Text('Save'))],
    ));
  }

  void addStudent() {
    String name = "", phone = "";
    int fee = 500;
    DateTime joinDate = DateTime.now();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text('Navin Vidyarthi'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(decoration: const InputDecoration(labelText: 'Nav'), onChanged: (v) => name = v),
        TextField(decoration: const InputDecoration(labelText: 'Contact'), keyboardType: TextInputType.phone, onChanged: (v) => phone = v),
        TextField(decoration: const InputDecoration(labelText: 'Amount'), controller: TextEditingController(text: "500"), keyboardType: TextInputType.number, onChanged: (v) => fee = int.tryParse(v)?? 500),
        const SizedBox(height: 10),
        Text("Join: ${DateFormat('dd-MM-yyyy').format(joinDate)}"),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
        ElevatedButton(onPressed: () { if (name.isNotEmpty) { setState(() { students.add(Student(name: name, phone: phone, monthlyFee: fee, joiningDate: joinDate, months: List.filled(12, false))); }); saveAll(); Navigator.pop(c); } }, child: const Text('Add')),
      ],
    ));
  }

  void sendReceipt(Student s, int mi) async {
    String fullMsg = "*$profileName*\n*Fee Receipt*\n\nVidhyarthi: ${s.name}\nMahina: ${monthsFull[mi]}\nAmount: Rs.${s.monthlyFee}\nDate: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}\n\nPaid: Rs.${s.paidAmount} | Baki: Rs.${s.balance}";
    final url = Uri.parse("https://wa.me/91${s.phone}?text=${Uri.encodeComponent(fullMsg)}");
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void sendReminder(Student s) async {
    int cm = DateTime.now().month - 1;
    String fullMsg = "Namaskar ${s.name} Palak,\n${monthsFull[cm]} chi fee Rs.${s.monthlyFee} baki aahe.\nBaki: Rs.${s.balance}\n- $profileName";
    final url = Uri.parse("https://wa.me/91${s.phone}?text=${Uri.encodeComponent(fullMsg)}");
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    int totalPaid = students.fold(0, (a, b) => a + b.paidAmount);
    int totalBal = students.fold(0, (a, b) => a + b.balance);
    var filtered = students.where((e) => e.name.toLowerCase().contains(search.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: Text(profileName), backgroundColor: Colors.white, actions: [IconButton(onPressed: editProfile, icon: const Icon(Icons.edit))]),
      body: Column(children: [
        Container(color: Colors.white, padding: const EdgeInsets.all(12), child: Column(children: [
          Row(children: [
            GestureDetector(onTap: editProfile, child: CircleAvatar(radius: 26, backgroundImage: profileImageBase64!= null? MemoryImage(base64Decode(profileImageBase64!)) : null, backgroundColor: Colors.orange.shade100, child: profileImageBase64 == null? Text(profileName[0]) : null)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(profileName, style: const TextStyle(fontWeight: FontWeight.bold)), Text(profileAddr, style: const TextStyle(fontSize: 11, color: Colors.grey)), Text(profilePhone, style: const TextStyle(fontSize: 10))])),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFFFE0B2), borderRadius: BorderRadius.circular(8)), child: Column(children: [Text("${students.length}", style: const TextStyle(fontWeight: FontWeight.bold)), const Text("Students", style: TextStyle(fontSize: 10))]))),
            const SizedBox(width: 6),
            Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFC8E6C9), borderRadius: BorderRadius.circular(8)), child: Column(children: [Text("Rs.$totalPaid", style: const TextStyle(fontWeight: FontWeight.bold)), const Text("Jama", style: TextStyle(fontSize: 10))]))),
            const SizedBox(width: 6),
            Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFFFCDD2), borderRadius: BorderRadius.circular(8)), child: Column(children: [Text("Rs.$totalBal", style: const TextStyle(fontWeight: FontWeight.bold)), const Text("Baki", style: TextStyle(fontSize: 10))]))),
          ]),
        ])),
        Container(color: Colors.white, padding: const EdgeInsets.all(8), child: TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), onChanged: (v) => setState(() => search = v))),
        Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: SingleChildScrollView(child: Column(children: [
          Container(color: const Color(0xFF1E1E2F), width: 1050, padding: const EdgeInsets.all(10), child: Row(children: [
            const SizedBox(width: 110, child: Text('Nav', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
            const SizedBox(width: 90, child: Text('Contact', style: TextStyle(color: Colors.white, fontSize: 11))),
            const SizedBox(width: 55, child: Text('Fee', style: TextStyle(color: Colors.white, fontSize: 11))),
            const SizedBox(width: 75, child: Text('Join', style: TextStyle(color: Colors.white, fontSize: 11))),
           ...monthsShort.map((m) => Container(width: 34, margin: const EdgeInsets.symmetric(horizontal: 2), child: Center(child: Text(m, style: const TextStyle(color: Colors.white70, fontSize: 12))))),
            const SizedBox(width: 45, child: Text('Rec', style: TextStyle(color: Colors.white, fontSize: 11))),
            const SizedBox(width: 60, child: Text('Rem', style: TextStyle(color: Colors.white, fontSize: 11))),
          ])),
         ...filtered.map((s) {
            int idx = students.indexOf(s);
            return Container(color: Colors.white, width: 1050, margin: const EdgeInsets.only(bottom: 1), padding: const EdgeInsets.all(8), child: Row(children: [
              SizedBox(width: 110, child: Text(s.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
              SizedBox(width: 90, child: Text(s.phone, style: const TextStyle(fontSize: 11))),
              SizedBox(width: 55, child: Text('Rs.${s.monthlyFee}', style: const TextStyle(fontSize: 11))),
              SizedBox(width: 75, child: Text(DateFormat('dd-MM-yy').format(s.joiningDate), style: const TextStyle(fontSize: 10))),
             ...List.generate(12, (mi) {
                bool ok = s.months[mi];
                return GestureDetector(onTap: () { setState(() { students[idx].months[mi] =!students[idx].months[mi]; }); saveAll(); }, child: Container(width: 34, height: 26, margin: const EdgeInsets.symmetric(horizontal: 2), decoration: BoxDecoration(color: ok? Colors.green : Colors.red.shade300, borderRadius: BorderRadius.circular(5)), child: Icon(ok? Icons.check : Icons.close, size: 14, color: Colors.white)));
              }),
              SizedBox(width: 45, child: IconButton(icon: const Icon(Icons.receipt, size: 18, color: Colors.blue), onPressed: () { int last = s.months.lastIndexWhere((e) => e); if (last!= -1) sendReceipt(s, last); })),
              SizedBox(width: 60, child: ElevatedButton(onPressed: () => send
