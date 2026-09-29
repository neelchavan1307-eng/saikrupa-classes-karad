import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  @override Widget build(BuildContext context) {
    return MaterialApp(title: 'Saikrupa Classes', debugShowCheckedModeBanner: false, home: HomePage());
  }
}
class Student {
  String name,std,phone; int monthlyFee; List<bool> months;
  Student({required this.name,required this.std,required this.phone,required this.monthlyFee,required this.months});
  int get paidCount => months.where((m)=>m).length;
  int get paidAmount => paidCount*monthlyFee;
  int get balance => (monthlyFee*12)-paidAmount;
  Map toJson() => {'name':name,'std':std,'phone':phone,'monthlyFee':monthlyFee,'months':months};
  factory Student.fromJson(Map m) => Student(name:m['name'],std:m['std'],phone:m['phone'],monthlyFee:m['monthlyFee'],months:List<bool>.from(m['months']));
}
class HomePage extends StatefulWidget { @override _HomePageState createState()=>_HomePageState(); }
class _HomePageState extends State<HomePage> {
  List<Student> students=[]; String search=""; final months=["J","F","M","A","M","J","J","A","S","O","N","D"];
  @override void initState(){super.initState(); loadData();}
  loadData() async { final p=await SharedPreferences.getInstance(); String? d=p.getString('final'); if(d!=null){ List l=jsonDecode(d); setState(()=>students=l.map((e)=>Student.fromJson(e)).toList()); } }
  saveData() async { final p=await SharedPreferences.getInstance(); p.setString('final', jsonEncode(students.map((e)=>e.toJson()).toList())); }
  void addDialog(){ String n="",s="",ph=""; int f=500;
    showDialog(context:context, builder:(c)=>AlertDialog(title:Text('Navin Vidyarthi'), content:Column(mainAxisSize:MainAxisSize.min, children:[TextField(decoration:InputDecoration(labelText:'Nav'),onChanged:(v)=>n=v), TextField(decoration:InputDecoration(labelText:'Iyatta'),onChanged:(v)=>s=v), TextField(decoration:InputDecoration(labelText:'Mobile'),keyboardType:TextInputType.phone,onChanged:(v)=>ph=v), TextField(decoration:InputDecoration(labelText:'Monthly Fee'),keyboardType:TextInputType.number,controller:TextEditingController(text:"500"),onChanged:(v)=>f=int.tryParse(v)??500)]), actions:[TextButton(onPressed:()=>Navigator.pop(c),child:Text('Cancel')),ElevatedButton(onPressed:(){if(n.isNotEmpty){setState(()=>students.add(Student(name:n,std:s,phone:ph,monthlyFee:f,months:List.filled(12,false))));saveData();Navigator.pop(c);}},child:Text('Add'))]]));
  }
  @override Widget build(BuildContext context){
    int paid=students.fold(0,(a,b)=>a+b.paidAmount); int bal=students.fold(0,(a,b)=>a+b.balance);
    var filtered=students.where((e)=>e.name.toLowerCase().contains(search.toLowerCase())).toList();
    return Scaffold(backgroundColor:Color(0xFFF8F8F8), body:SafeArea(child:SingleChildScrollView(child:Column(children:[
      Container(color:Colors.white,padding:EdgeInsets.all(16),child:Column(children:[
        Row(children:[CircleAvatar(radius:28,backgroundColor:Colors.orange.shade100,child:Text("SC",style:TextStyle(fontWeight:FontWeight.bold,fontSize:22,color:Colors.deepOrange))),SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('SAIKRUPA CLASSES',style:TextStyle(fontWeight:FontWeight.bold,fontSize:18)),Text('Karad - Vidya Vinayen Shobhate',style:TextStyle(fontSize:12,color:Colors.grey)),Text('Malakapur, Karad | 90220022XX',style:TextStyle(fontSize:11))]))]),
        SizedBox(height:14),Row(children:[Expanded(child:Container(padding:EdgeInsets.all(14),decoration:BoxDecoration(color:Color(0xFFFFE0B2),borderRadius:BorderRadius.circular(12)),child:Column(children:[Text("${students.length}",style:TextStyle(fontWeight:FontWeight.bold,fontSize:18)),Text("एकूण विद्यार्थी",style:TextStyle(fontSize:11))]))),SizedBox(width:8),Expanded(child:Container(padding:EdgeInsets.all(14),decoration:BoxDecoration(color:Color(0xFFC8E6C9),borderRadius:BorderRadius.circular(12)),child:Column(children:[Text("Rs.$paid",style:TextStyle(fontWeight:FontWeight.bold,fontSize:18)),Text("एकूण जमा",style:TextStyle(fontSize:11))])))]),
        SizedBox(height:8),Row(children:[Expanded(child:Container(padding:EdgeInsets.all(14),decoration:BoxDecoration(color:Color(0xFFFFCDD2),borderRadius:BorderRadius.circular(12)),child:Column(children:[Text("Rs.$bal",style:TextStyle(fontWeight:FontWeight.bold,fontSize:18)),Text("एकूण बाकी",style:TextStyle(fontSize:11))]))),SizedBox(width:8),Expanded(child:Container(padding:EdgeInsets.all(14),decoration:BoxDecoration(color:Color(0xFFFFF9C4),borderRadius:BorderRadius.circular(12)),child:Column(children:[Text("${students.where((e)=>e.balance>0).length} विद्यार्थी",style:TextStyle(fontWeight:FontWeight.bold,fontSize:16)),Text("फी बाकी",style:TextStyle(fontSize:11))])))]),
      ])),
      Container(color:Colors.white,padding:EdgeInsets.all(10),child:TextField(decoration:InputDecoration(prefixIcon:Icon(Icons.search),hintText:'नावाने शोधा...',border:OutlineInputBorder(borderRadius:BorderRadius.circular(12))),onChanged:(v)=>setState(()=>search=v))),
      SingleChildScrollView(scrollDirection:Axis.horizontal, child:Column(children:[
        Container(color:Color(0xFF1E1E2F),width:700,padding:EdgeInsets.symmetric(vertical:12,horizontal:8),child:Row(children:[SizedBox(width:140,child:Text('नाव',style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold))),...months.map((m)=>Container(width:32,margin:EdgeInsets.symmetric(horizontal:2),child:Center(child:Text(m,style:TextStyle(color:Colors.white70,fontWeight:FontWeight.bold))))),SizedBox(width:60,child:Text('PAID',style:TextStyle(color:Colors.white,fontSize:12))),SizedBox(width:60,child:Text('BAL',style:TextStyle(color:Colors.white,fontSize:12)))])),
       ...filtered.map((s){ int idx=students.indexOf(s); return Container(color:Colors.white,width:700,margin:EdgeInsets.only(bottom:1),padding:EdgeInsets.symmetric(vertical:10,horizontal:8),child:Row(children:[SizedBox(width:140,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(s.name,style:TextStyle(fontWeight:FontWeight.bold,fontSize:13)),Text('${s.std}-Rs.${s.monthlyFee}',style:TextStyle(fontSize:11,color:Colors.grey))])),...List.generate(12,(mi){ bool ok=s.months[mi]; return GestureDetector(onTap:(){setState(()=>students[idx].months[mi]=!students[idx].months[mi]);saveData();}, child:Container(width:32,height:28,margin:EdgeInsets.symmetric(horizontal:2),decoration:BoxDecoration(color:ok?Colors.green:Color(0xFFE57373),borderRadius:BorderRadius.circular(6)),child:Icon(ok?Icons.check:Icons.close,size:16,color:Colors.white)));}),SizedBox(width:60,child:Text('Rs.${s.paidAmount}',style:TextStyle(fontSize:12,color:Colors.green,fontWeight:FontWeight.bold))),SizedBox(width:60,child:Text('Rs.${s.balance}',style:TextStyle(fontSize:12,color:Colors.red,fontWeight:FontWeight.bold))),IconButton(icon:Icon(Icons.delete,size:18),onPressed:(){setState(()=>students.removeAt(idx));saveData();})]));}).toList()
      ]))
    ]))), floatingActionButton:FloatingActionButton.extended(onPressed:addDialog,label:Text('Add Student'),icon:Icon(Icons.add),backgroundColor:Color(0xFFFF5722),foregroundColor:Colors.white));
  }
}
