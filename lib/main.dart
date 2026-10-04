import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'NotoSansDevanagari'),
      home: const HomePage(),
    );
  }
}

// --- MODELS ---
class Student {
  String name; int age; String status; String month; int fee; List<String> paidMonths;
  Student({required this.name, required this.age, required this.status, required this.month, required this.fee, required this.paidMonths});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Student> students = [
    Student(name: 'Vihan Tupe', age: 6, status: 'Fee Pichle', month: 'Sep 2025', fee: 1000, paidMonths: ['J','F','M','A']),
    Student(name: 'Krisha Kirme', age: 10, status: 'Fee Pichle', month: 'Sep 2025', fee: 1200, paidMonths: ['J','F','M']),
    Student(name: 'Anshuman Itape', age: 10, status: 'Fee dayaychi ahe', month: 'Sep 2025', fee: 1000, paidMonths: []),
    Student(name: 'Aaradhya Yadav', age: 8, status: 'Fee Pichle', month: 'Sep 2025', fee: 1000, paidMonths: ['J','F','M','A','M','J','J','A','S']),
    Student(name: 'Samyak Shirke', age: 5, status: 'Fee Pichle', month: 'Sep 2025', fee: 800, paidMonths: ['J','F','M','A','M','J','J','A','S']),
    Student(name: 'Shreya Gadekar', age: 11, status: 'Fee Pichle', month: 'Sep 2025', fee: 800, paidMonths: ['J','F','M','A','M','J','J','A','S','O','N']),
    Student(name: 'Swara Patil', age: 3, status: 'Fee dayaychi ahe', month: 'Sep 2025', fee: 800, paidMonths: ['J']),
    Student(name: 'Swaroop Patil', age: 3, status: 'Fee Pichle', month: 'Sep 2025', fee: 800, paidMonths: ['J','F','M','A','M']),
    Student(name: 'Tejal Patil', age: 25, status: 'Fee dayaychi ahe', month: 'Sep 2025', fee: 1500, paidMonths: ['J','F']),
    Student(name: 'Poorva Patil', age: 20, status: 'Fee Pichle', month: 'Sep 2025', fee: 1500, paidMonths: ['J','F','M','A','M','J','J','A','S','O']),
    Student(name: 'Samskurti', age: 14, status: 'Fee Pichle', month: 'Sep 2025', fee: 1200, paidMonths: ['J','F','M','A','M','J','J','A','S','O']),
    Student(name: 'Swaransh', age: 10, status: 'Fee Pichle', month: 'Sep 2025', fee: 1000, paidMonths: ['J','F','M']),
  ];

  String filter = 'सर्व';
  List<Student> get filteredList {
    if (filter == 'बाकी') return students.where((s) => s.status.contains('dayaychi')).toList();
    if (filter == 'संपलेला') return students.where((s) => s.status.contains('Pichle')).toList();
    return students;
  }

  @override
  Widget build(BuildContext context) {
    int paid = 34100; int balance = 121900;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(children: [
          CircleAvatar(backgroundColor: Colors.orange.shade100, child: const Icon(Icons.school, color: Colors.orange)),
          const SizedBox(width: 8),
          const Text('SAIKRUPA CLASSES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ]),
        actions: [IconButton(onPressed: (){}, icon: const Icon(Icons.add_circle, color: Colors.green)), IconButton(onPressed: (){}, icon: const Icon(Icons.add_box, color: Colors.blue))],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFE040FB)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: Column(children: [
                const SizedBox(height: 15),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)), child: const Text('सप्टेंबर २०२५ वर्ष (Sep 2025)', style: TextStyle(color: Colors.white, fontSize: 12))),
                const SizedBox(height: 10),
                Stack(children: [
                  Container(margin: const EdgeInsets.only(top: 30), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                    child: Column(children: [
                      const SizedBox(height: 30),
                      const Text('SAIKRUPA CLASSES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const Text('प्रा. प्रदीप चव्हाण', style: TextStyle(color: Colors.red)),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        _chip('सेटिंग्स'), const SizedBox(width: 8),
                        _chip('माहिती बदला (Edit Profile)', isGreen: false),
                      ]),
                      const SizedBox(height: 8),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)), child: const Text('+ नवीन विद्यार्थी', style: TextStyle(color: Colors.white))),
                      const SizedBox(height: 8),
                      const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.location_on, size: 14), Text(' कराड, महाराष्ट्र', style: TextStyle(fontSize: 12)), SizedBox(width: 15), Icon(Icons.phone, size: 14), Text(' 9822001122', style: TextStyle(fontSize: 12))]),
                    ]),
                  ),
                  Align(alignment: Alignment.topCenter, child: CircleAvatar(radius: 35, backgroundColor: Colors.white, child: CircleAvatar(radius: 32, backgroundColor: Colors.orange.shade100, child: const Icon(Icons.person, size: 40, color: Colors.brown)))),
                ]),
                const SizedBox(height: 15),
              ]),
            ),
            Padding(padding: const EdgeInsets.all(12), child: Column(children: [
              Row(children: [
                Expanded(child: _dashboardCard('एकूण विद्यार्थी', '12', '(8 शाळा + 4 कॉलेज)', Colors.blue.shade50)),
                const SizedBox(width: 8),
                Expanded(child: _dashboardCard('एकूण जमा (PAID)', '₹34,100', '', Colors.green.shade50, isPaid: true)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _dashboardCard('एकूण बाकी रक्कम (BALANCE)', '₹1,21,900', '', Colors.red.shade50)),
                const SizedBox(width: 8),
                Expanded(child: _dashboardCard('बाकी असलेले विद्यार्थी', '12 विद्यार्थी', 'Whatsapp मेसेज पाठवा', Colors.yellow.shade50, hasBtn: true)),
              ]),
              const SizedBox(height: 12),
              TextField(decoration: InputDecoration(hintText: 'विद्यार्थी शोधा (Search by name, roll no, phone)...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white)),
              const SizedBox(height: 10),
              SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
                _filterBtn('सर्व (12)', 'सर्व'), _filterBtn('बाकी (8)', 'बाकी'), _filterBtn('संपलेला (4)', 'संपलेला'),
              ])),
              const SizedBox(height: 10),
             ...filteredList.asMap().entries.map((e) => _studentCard(e.key + 1, e.value)),
            ])),
          ],
        ),
      ),
    );
  }

  Widget _chip(String t, {bool isGreen = true}) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: isGreen? Colors.grey.shade200 : Colors.blue.shade50, borderRadius: BorderRadius.circular(20)), child: Text(t, style: const TextStyle(fontSize: 10)));
  Widget _dashboardCard(String title, String value, String sub, Color color, {bool isPaid = false, bool hasBtn = false}) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 10)), const SizedBox(height: 4), Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isPaid? 18 : 16, color: hasBtn? Colors.black : Colors.black87)), if(sub.isNotEmpty) Text(sub, style: const TextStyle(fontSize: 9)), if(hasBtn) Container(margin: const EdgeInsets.only(top: 6), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(6)), child: const Text('WhatsApp पाठवा', style: TextStyle(color: Colors.white, fontSize: 10)))]));
  Widget _filterBtn(String label, String val) { bool sel = filter==val; return Padding(padding: const EdgeInsets.only(right: 6), child: ChoiceChip(label: Text(label, style: TextStyle(fontSize: 12, color: sel?Colors.white:Colors.black)), selected: sel, selectedColor: Colors.green, onSelected: (v){ setState(()=> filter=val); })); }
  Widget _studentCard(int index, Student s) {
    List<String> months = ['J','F','M','A','M','J','J','A','S','O','N','D'];
    bool isPending = s.status.contains('dayaychi');
    return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 3)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Text('$index', style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${s.name} | वय ${s.age} (Age ${s.age})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text('नोंदणी क्र. / रोल नं. बंध / ${s.month}', style: const TextStyle(fontSize: 10, color: Colors.grey))])), Column(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: isPending?Colors.orange.shade100:Colors.green.shade100, borderRadius: BorderRadius.circular(10)), child: Text(s.status, style: TextStyle(fontSize: 9, color: isPending?Colors.orange:Colors.green))), const SizedBox(height: 4), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)), child: Text('₹${s.fee}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))] )]),
      const SizedBox(height: 10),
      GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, childAspectRatio: 1.2, crossAxisSpacing: 4, mainAxisSpacing: 4), itemCount: 12, itemBuilder: (c,i){ bool paid = s.paidMonths.contains(months[i]); return Container(decoration: BoxDecoration(color: paid?Colors.green:Colors.red.shade100, borderRadius: BorderRadius.circular(4), border: Border.all(color: paid?Colors.green:Colors.red.shade200)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(months[i], style: TextStyle(fontSize: 10, color: paid?Colors.white:Colors.red, fontWeight: FontWeight.bold)), Text(paid?'✓':'x', style: TextStyle(fontSize: 8, color: paid?Colors.white:Colors.red))])); }),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('जमा (Paid)\n₹${s.paidMonths.length * s.fee}', style: const TextStyle(fontSize: 10)), Text('बाकी (Balance)\n₹${(12 - s.paidMonths.length)*s.fee}', style: const TextStyle(fontSize: 10)), Row(children: [ _smallBtn('पावती', Colors.blue), _smallBtn('माहिती', Colors.orange), _smallBtn('WhatsApp', Colors.green)])]),
    ]));
  }
  Widget _smallBtn(String t, Color c) => Container(margin: const EdgeInsets.only(left: 4), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(15)), child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 10)));
}
