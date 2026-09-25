
import 'package:flutter/material.dart';

void main() => runApp(const ForgeFlowApp());

class ForgeFlowApp extends StatelessWidget {
  const ForgeFlowApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'ForgeFlow',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
      scaffoldBackgroundColor: const Color(0xFFF5F7FB),
    ),
    home: const Shell(),
  );
}

enum Status { done, active, pending, blocked }

class Stage {
  final String name;
  Status status;
  Stage(this.name, this.status);
}

const stageNames = [
  'PO Received','GA Preparation','GA Approval','Material Procurement',
  'Machining','Fabrication','Finishing','Surface Treatment','Assembly',
  'Labeling','Trials / Testing','PDIR','Packing','Invoicing','PO Closed'
];

List<Stage> makeWorkflow(int completed, {int? blocked}) =>
    List.generate(stageNames.length, (i) => Stage(
      stageNames[i],
      blocked == i ? Status.blocked : i < completed ? Status.done : i == completed ? Status.active : Status.pending,
    ));

class Job {
  String po, customer, machine, serial, stage, due, priority, owner;
  int progress;
  List<Stage> workflow;
  List<String> documents;
  Job({
    required this.po, required this.customer, required this.machine,
    required this.serial, required this.stage, required this.progress,
    required this.due, required this.priority, required this.owner,
    required this.workflow, this.documents = const [],
  });
}

final jobs = <Job>[
  Job(po:'PO-1024', customer:'ABC Industries', machine:'M-200', serial:'SN-2026-1024',
    stage:'Assembly', progress:72, due:'30 Sep', priority:'High', owner:'Rahul Patil',
    workflow:makeWorkflow(8), documents:['PO.pdf','GA-Approved.pdf','BOM.xlsx','Trial-01.mp4']),
  Job(po:'PO-1025', customer:'XYZ Engineering', machine:'M-450', serial:'SN-2026-1025',
    stage:'Fabrication', progress:48, due:'04 Oct', priority:'Medium', owner:'Amit Shinde',
    workflow:makeWorkflow(5, blocked:3), documents:['PO.pdf','GA.pdf']),
  Job(po:'PO-1026', customer:'DEF Systems', machine:'M-120', serial:'SN-2026-1026',
    stage:'Packing', progress:92, due:'28 Sep', priority:'High', owner:'Vishal More',
    workflow:makeWorkflow(13), documents:['PO.pdf','PDIR.pdf','Packing-List.pdf']),
  Job(po:'PO-1027', customer:'Nova Automation', machine:'M-310', serial:'SN-2026-1027',
    stage:'GA Approval', progress:19, due:'12 Oct', priority:'Low', owner:'Sneha Kulkarni',
    workflow:makeWorkflow(2), documents:['PO.pdf','GA-v2.pdf']),
];

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(open: openJob),
      JobsPage(open: openJob, add: addJob),
      const AlertsPage(),
      const AnalyticsPage(),
    ];
    return Scaffold(
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon:Icon(Icons.dashboard_outlined),selectedIcon:Icon(Icons.dashboard),label:'Overview'),
          NavigationDestination(icon:Icon(Icons.precision_manufacturing_outlined),selectedIcon:Icon(Icons.precision_manufacturing),label:'Production'),
          NavigationDestination(icon:Icon(Icons.notifications_none),selectedIcon:Icon(Icons.notifications),label:'Alerts'),
          NavigationDestination(icon:Icon(Icons.insights_outlined),selectedIcon:Icon(Icons.insights),label:'Analytics'),
        ],
      ),
      floatingActionButton: tab == 1 ? FloatingActionButton.extended(onPressed:addJob,icon:const Icon(Icons.add),label:const Text('New PO')) : null,
    );
  }
  void openJob(Job j) => Navigator.push(context, MaterialPageRoute(builder: (_) => JobDetailPage(job:j, refresh:() => setState((){}))));
  void addJob() {
    showDialog(context:context,builder:(_) => const AddJobDialog()).then((v) {
      if (v is Job) setState(() => jobs.insert(0,v));
    });
  }
}

class Header extends StatelessWidget {
  const Header({super.key});
  @override Widget build(BuildContext context) => Row(children:[
    const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('Good morning',style:TextStyle(color:Colors.black54,fontSize:14)),
      SizedBox(height:3), Text('ForgeFlow',style:TextStyle(fontSize:29,fontWeight:FontWeight.w800)),
      Text('Machine production control center',style:TextStyle(color:Colors.black54)),
    ])),
    const CircleAvatar(radius:22,backgroundColor:Color(0xFFE7EEFF),child:Text('YM',style:TextStyle(fontWeight:FontWeight.w800,color:Color(0xFF1D4ED8))))
  ]);
}

class Stat extends StatelessWidget {
  final String label,value; final IconData icon;
  const Stat({super.key,required this.label,required this.value,required this.icon});
  @override Widget build(BuildContext context) => Expanded(child:Container(
    padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(18)),
    child:Row(children:[
      Container(padding:const EdgeInsets.all(9),decoration:BoxDecoration(color:const Color(0xFFEFF4FF),borderRadius:BorderRadius.circular(12)),child:Icon(icon,size:20,color:const Color(0xFF2563EB))),
      const SizedBox(width:9),Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(value,style:const TextStyle(fontSize:21,fontWeight:FontWeight.w800)),
        Text(label,style:const TextStyle(fontSize:11,color:Colors.black54))
      ])
    ])
  ));
}

class DashboardPage extends StatelessWidget {
  final void Function(Job) open;
  const DashboardPage({super.key,required this.open});
  @override Widget build(BuildContext context) {
    final delayed=jobs.where((j)=>j.workflow.any((s)=>s.status==Status.blocked)).length;
    final ready=jobs.where((j)=>j.progress>=90).length;
    return ListView(padding:const EdgeInsets.fromLTRB(20,18,20,30),children:[
      const Header(),const SizedBox(height:20),
      TextField(decoration:InputDecoration(hintText:'Search PO, machine or customer',prefixIcon:const Icon(Icons.search),filled:true,fillColor:Colors.white,border:OutlineInputBorder(borderRadius:BorderRadius.circular(16),borderSide:BorderSide.none))),
      const SizedBox(height:18),
      Row(children:[Stat(label:'Active POs',value:jobs.length.toString(),icon:Icons.assignment_outlined),const SizedBox(width:10),Stat(label:'Delayed',value:delayed.toString(),icon:Icons.warning_amber_rounded)]),
      const SizedBox(height:10),
      Row(children:[Stat(label:'In Production',value:jobs.where((j)=>j.progress<90).length.toString(),icon:Icons.settings_outlined),const SizedBox(width:10),Stat(label:'Ready',value:ready.toString(),icon:Icons.local_shipping_outlined)]),
      const SizedBox(height:24),const TitleText('Today\'s attention'),const SizedBox(height:10),
      ...jobs.take(3).map((j)=>JobCard(job:j,onTap:()=>open(j))),
      const SizedBox(height:14),const TitleText('Production pipeline'),const SizedBox(height:10),
      const Pipeline(),
    ]);
  }
}

class TitleText extends StatelessWidget {
  final String text; const TitleText(this.text,{super.key});
  @override Widget build(BuildContext context)=>Text(text,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w800));
}

class Pipeline extends StatelessWidget {
  const Pipeline({super.key});
  @override Widget build(BuildContext context)=>Card(elevation:0,child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[
    pipe('GA & Design','4',Colors.green),pipe('Procurement','3',Colors.orange),pipe('Fabrication','5',Colors.orange),
    pipe('Assembly','2',Colors.orange),pipe('Quality / PDIR','2',Colors.grey),pipe('Dispatch','4',Colors.blue),
  ])));
  Widget pipe(String a,String b,Color c)=>Padding(padding:const EdgeInsets.symmetric(vertical:7),child:Row(children:[
    Container(width:9,height:9,decoration:BoxDecoration(shape:BoxShape.circle,color:c)),const SizedBox(width:12),
    Expanded(child:Text(a,style:const TextStyle(fontWeight:FontWeight.w600))),Text(b,style:const TextStyle(fontWeight:FontWeight.w800)),const SizedBox(width:5),const Text('POs',style:TextStyle(color:Colors.black45,fontSize:12))
  ]));
}

class JobsPage extends StatefulWidget {
  final void Function(Job) open; final VoidCallback add;
  const JobsPage({super.key,required this.open,required this.add});
  @override State<JobsPage> createState()=>_JobsPageState();
}
class _JobsPageState extends State<JobsPage> {
  String filter='All';
  @override Widget build(BuildContext context) {
    final list=filter=='All'?jobs:jobs.where((j)=>j.stage==filter || (filter=='Delayed' && j.workflow.any((s)=>s.status==Status.blocked))).toList();
    return ListView(padding:const EdgeInsets.fromLTRB(20,18,20,100),children:[
      Row(children:[const Expanded(child:Text('Production Jobs',style:TextStyle(fontSize:27,fontWeight:FontWeight.w800))),IconButton(onPressed:widget.add,icon:const Icon(Icons.add_circle_outline))]),
      const Text('One PO = one production job',style:TextStyle(color:Colors.black54)),const SizedBox(height:16),
      SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(children:[
        for(final f in ['All','Assembly','Fabrication','Packing','Delayed'])
          Padding(padding:const EdgeInsets.only(right:8),child:ChoiceChip(label:Text(f),selected:filter==f,onSelected:(_)=>setState(()=>filter=f)))
      ])),const SizedBox(height:14),
      ...list.map((j)=>JobCard(job:j,onTap:()=>widget.open(j)))
    ]);
  }
}

class JobCard extends StatelessWidget {
  final Job job; final VoidCallback onTap;
  const JobCard({super.key,required this.job,required this.onTap});
  @override Widget build(BuildContext context)=>Card(
    elevation:0,margin:const EdgeInsets.only(bottom:10),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18)),
    child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(18),child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[
      Row(children:[const Icon(Icons.precision_manufacturing_outlined,color:Color(0xFF2563EB)),const SizedBox(width:10),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(job.po,style:const TextStyle(fontWeight:FontWeight.w800)),Text(job.customer,style:const TextStyle(color:Colors.black54,fontSize:12))])),
        Priority(job.priority)]),
      const SizedBox(height:13),Row(children:[Expanded(child:ClipRRect(borderRadius:BorderRadius.circular(10),child:LinearProgressIndicator(value:job.progress/100,minHeight:7))),const SizedBox(width:10),Text(job.progress.toString()+'%',style:const TextStyle(fontWeight:FontWeight.w800))]),
      const SizedBox(height:11),Row(children:[Text(job.machine,style:const TextStyle(fontWeight:FontWeight.w600,fontSize:12)),const Spacer(),Text(job.stage,style:const TextStyle(fontSize:12)),const SizedBox(width:9),Text('Due '+job.due,style:const TextStyle(fontSize:12,color:Colors.black54))])
    ])))
  );
}

class Priority extends StatelessWidget {
  final String value; const Priority(this.value,{super.key});
  @override Widget build(BuildContext context){
    final c=value=='High'?Colors.red:value=='Medium'?Colors.orange:Colors.blueGrey;
    return Container(padding:const EdgeInsets.symmetric(horizontal:9,vertical:5),decoration:BoxDecoration(color:c.withAlpha(20),borderRadius:BorderRadius.circular(20)),child:Text(value,style:TextStyle(color:c,fontSize:11,fontWeight:FontWeight.w700)));
  }
}

class JobDetailPage extends StatefulWidget {
  final Job job; final VoidCallback refresh;
  const JobDetailPage({super.key,required this.job,required this.refresh});
  @override State<JobDetailPage> createState()=>_JobDetailState();
}
class _JobDetailState extends State<JobDetailPage> {
  Job get job=>widget.job;
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:Text(job.po),actions:[IconButton(onPressed:showQR,icon:const Icon(Icons.qr_code_2)),IconButton(onPressed:(){},icon:const Icon(Icons.more_vert))]),
    body:ListView(padding:const EdgeInsets.fromLTRB(20,8,20,30),children:[
      Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(job.machine,style:const TextStyle(fontSize:28,fontWeight:FontWeight.w800)),Text(job.customer,style:const TextStyle(color:Colors.black54)),Text(job.serial,style:const TextStyle(color:Colors.black54,fontSize:12))])),Priority(job.priority)]),
      const SizedBox(height:18),ProgressPanel(job),const SizedBox(height:18),const TitleText('Production workflow'),const SizedBox(height:8),
      ...List.generate(job.workflow.length,(i)=>StageTile(stage:job.workflow[i],onTap:()=>advance(i))),
      const SizedBox(height:12),const TitleText('Documents & evidence'),const SizedBox(height:8),
      ...job.documents.map((d)=>Card(elevation:0,child:ListTile(leading:Icon(d.endsWith('.mp4')?Icons.video_file_outlined:Icons.description_outlined),title:Text(d),subtitle:const Text('Uploaded evidence'),trailing:const Icon(Icons.chevron_right)))),
      Row(children:[
        Expanded(child:OutlinedButton.icon(onPressed:()=>message('Photo upload will connect to storage in the backend'),icon:const Icon(Icons.camera_alt_outlined),label:const Text('Photo'))),
        const SizedBox(width:10),Expanded(child:OutlinedButton.icon(onPressed:()=>message('Document picker will connect to storage in the backend'),icon:const Icon(Icons.upload_file),label:const Text('Document')))
      ]),
      const SizedBox(height:18),const TitleText('Dispatch'),const SizedBox(height:8),
      const Card(elevation:0,child:Column(children:[
        ListTile(leading:Icon(Icons.inventory_2_outlined),title:Text('Packing status'),trailing:Text('Pending')),
        Divider(height:1),ListTile(leading:Icon(Icons.receipt_long_outlined),title:Text('Invoice'),trailing:Text('Pending')),
        Divider(height:1),ListTile(leading:Icon(Icons.local_shipping_outlined),title:Text('Vehicle'),trailing:Text('Not assigned')),
      ]))
    ])
  );
  void advance(int i){
    if(job.workflow[i].status==Status.done){message('Stage already completed');return;}
    for(var x=0;x<job.workflow.length;x++){job.workflow[x].status=x<i?Status.done:x==i?Status.active:Status.pending;}
    job.stage=stageNames[i];job.progress=(((i+1)/stageNames.length)*100).round().clamp(1,100);
    setState((){});widget.refresh();message(job.stage+' is now active');
  }
  void message(String s)=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(s)));
  void showQR()=>showDialog(context:context,builder:(_)=>AlertDialog(title:Text(job.machine+' QR'),content:const SizedBox(width:220,height:220,child:Center(child:Icon(Icons.qr_code_2,size:180))),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Close'))]));
}

class ProgressPanel extends StatelessWidget {
  final Job job; const ProgressPanel(this.job,{super.key});
  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(18)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Row(children:[const Expanded(child:Text('Overall production',style:TextStyle(fontWeight:FontWeight.w700))),Text(job.progress.toString()+'%',style:const TextStyle(fontWeight:FontWeight.w800))]),
    const SizedBox(height:12),LinearProgressIndicator(value:job.progress/100,minHeight:9,borderRadius:BorderRadius.circular(10)),const SizedBox(height:10),
    Text('Current stage: '+job.stage,style:const TextStyle(color:Colors.black54)),Text('Owner: '+job.owner,style:const TextStyle(color:Colors.black54))
  ]));
}

class StageTile extends StatelessWidget {
  final Stage stage;final VoidCallback onTap;
  const StageTile({super.key,required this.stage,required this.onTap});
  @override Widget build(BuildContext context){
    final done=stage.status==Status.done,active=stage.status==Status.active,blocked=stage.status==Status.blocked;
    final bg=done?const Color(0xFFDCFCE7):blocked?const Color(0xFFFEE2E2):active?const Color(0xFFDBEAFE):const Color(0xFFE5E7EB);
    final col=done?Colors.green:blocked?Colors.red:active?Colors.blue:Colors.black38;
    return Card(elevation:0,margin:const EdgeInsets.only(bottom:6),child:ListTile(onTap:onTap,leading:CircleAvatar(radius:15,backgroundColor:bg,child:Icon(done?Icons.check:blocked?Icons.priority_high:active?Icons.play_arrow:Icons.circle_outlined,size:16,color:col)),title:Text(stage.name,style:TextStyle(fontWeight:active?FontWeight.w800:FontWeight.w500)),subtitle:Text(done?'Completed':blocked?'Blocked — action required':active?'In progress':'Not started'),trailing:const Icon(Icons.chevron_right,size:20)));
  }
}

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.fromLTRB(20,18,20,30),children:[
    const Text('Alerts',style:TextStyle(fontSize:27,fontWeight:FontWeight.w800)),const Text('Things that need attention',style:TextStyle(color:Colors.black54)),const SizedBox(height:18),
    alert(Icons.warning_amber_rounded,'PO-1025 material blocked','Material Procurement needs an update.',Colors.orange),
    alert(Icons.approval_outlined,'GA approval required','PO-1027 is waiting for design approval.',Colors.blue),
    alert(Icons.local_shipping_outlined,'PO-1026 ready for dispatch','Packing is complete. Assign vehicle and invoice.',Colors.green),
    alert(Icons.timer_outlined,'PO-1024 due soon','Assembly is active with 72% overall progress.',Colors.red),
  ]);
  Widget alert(IconData i,String a,String b,Color c)=>Card(elevation:0,margin:const EdgeInsets.only(bottom:10),child:ListTile(leading:CircleAvatar(backgroundColor:c.withAlpha(20),child:Icon(i,color:c)),title:Text(a,style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text(b),trailing:const Icon(Icons.chevron_right)));
}

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});
  @override Widget build(BuildContext context){
    final avg=(jobs.map((j)=>j.progress).reduce((a,b)=>a+b)/jobs.length).round();
    return ListView(padding:const EdgeInsets.fromLTRB(20,18,20,30),children:[
      const Text('Analytics',style:TextStyle(fontSize:27,fontWeight:FontWeight.w800)),const Text('Production performance snapshot',style:TextStyle(color:Colors.black54)),const SizedBox(height:18),
      Row(children:[Metric('On-time rate','86%',Icons.schedule),const SizedBox(width:10),Metric('Avg. progress',avg.toString()+'%',Icons.trending_up)]),const SizedBox(height:10),
      Row(children:[Metric('Ready to ship',jobs.where((j)=>j.progress>=90).length.toString(),Icons.local_shipping_outlined),const SizedBox(width:10),Metric('Open issues',jobs.where((j)=>j.workflow.any((s)=>s.status==Status.blocked)).length.toString(),Icons.error_outline)]),
      const SizedBox(height:24),const TitleText('Stage throughput'),const SizedBox(height:10),
      Card(elevation:0,child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[
        bar('GA & Design',86),bar('Procurement',71),bar('Fabrication',64),bar('Assembly',52),bar('Testing',38),bar('Dispatch',24)
      ]))),const SizedBox(height:18),const TitleText('Management insight'),const SizedBox(height:8),
      const Card(elevation:0,child:ListTile(leading:Icon(Icons.lightbulb_outline),title:Text('Procurement is the main bottleneck'),subtitle:Text('One active PO is blocked at material procurement. Resolve supplier delays before fabrication capacity is affected.')))
    ]);
  }
  Widget bar(String name,int value)=>Padding(padding:const EdgeInsets.symmetric(vertical:8),child:Row(children:[SizedBox(width:105,child:Text(name,style:const TextStyle(fontSize:12))),Expanded(child:LinearProgressIndicator(value:value/100,minHeight:8,borderRadius:BorderRadius.circular(10))),const SizedBox(width:10),Text(value.toString()+'%',style:const TextStyle(fontSize:12,fontWeight:FontWeight.w700))]));
}

class Metric extends StatelessWidget {
  final String label,value;final IconData icon;
  const Metric(this.label,this.value,this.icon,{super.key});
  @override Widget build(BuildContext context)=>Expanded(child:Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(18)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(icon,color:const Color(0xFF2563EB)),const SizedBox(height:12),Text(value,style:const TextStyle(fontSize:24,fontWeight:FontWeight.w800)),Text(label,style:const TextStyle(fontSize:11,color:Colors.black54))])));
}

class AddJobDialog extends StatefulWidget {
  const AddJobDialog({super.key});
  @override State<AddJobDialog> createState()=>_AddJobState();
}
class _AddJobState extends State<AddJobDialog> {
  final po=TextEditingController(text:'PO-1028'),customer=TextEditingController(),machine=TextEditingController();
  String priority='Medium';
  @override Widget build(BuildContext context)=>AlertDialog(
    title:const Text('Create production job'),
    content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
      TextField(controller:po,decoration:const InputDecoration(labelText:'PO number')),
      TextField(controller:customer,decoration:const InputDecoration(labelText:'Customer')),
      TextField(controller:machine,decoration:const InputDecoration(labelText:'Machine')),
      const SizedBox(height:10),
      DropdownButtonFormField<String>(initialValue:priority,decoration:const InputDecoration(labelText:'Priority'),items:['High','Medium','Low'].map((p)=>DropdownMenuItem(value:p,child:Text(p))).toList(),onChanged:(v)=>setState(()=>priority=v??priority))
    ])),
    actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancel')),FilledButton(onPressed:(){
      if(customer.text.trim().isEmpty||machine.text.trim().isEmpty)return;
      Navigator.pop(context,Job(po:po.text.trim(),customer:customer.text.trim(),machine:machine.text.trim(),serial:'SN-2026-NEW',stage:'PO Received',progress:1,due:'TBD',priority:priority,owner:'Unassigned',workflow:makeWorkflow(0),documents:['PO.pdf']));
    },child:const Text('Create'))]
  );
}
