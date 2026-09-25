
import 'package:flutter/material.dart';

void main() => runApp(const ManufacturingApp());

class ManufacturingApp extends StatelessWidget {
  const ManufacturingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ForgeFlow',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

class Job {
  final String po, customer, machine, stage;
  final int progress;
  final String due;

  const Job({
    required this.po,
    required this.customer,
    required this.machine,
    required this.stage,
    required this.progress,
    required this.due,
  });
}

const jobs = [
  Job(po: 'PO-1024', customer: 'ABC Industries', machine: 'M-200', stage: 'Assembly', progress: 72, due: '18 Sep'),
  Job(po: 'PO-1025', customer: 'XYZ Engineering', machine: 'M-450', stage: 'Fabrication', progress: 48, due: '22 Sep'),
  Job(po: 'PO-1026', customer: 'DEF Systems', machine: 'M-120', stage: 'Packing', progress: 92, due: '15 Sep'),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardPage(),
      const JobsPage(),
      const ScanPage(),
      const AlertsPage(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Jobs'),
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
          NavigationDestination(icon: Icon(Icons.notifications_none), selectedIcon: Icon(Icons.notifications), label: 'Alerts'),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good morning', style: TextStyle(color: Colors.black54, fontSize: 14)),
                  SizedBox(height: 3),
                  Text('Production', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFE8EEF9),
              child: Icon(Icons.person_outline, color: Color(0xFF1D4ED8)),
            ),
          ],
        ),
        const SizedBox(height: 22),
        TextField(
          decoration: InputDecoration(
            hintText: 'Search PO, machine or customer',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 18),
        const Row(
          children: [
            StatCard(label: 'Active Jobs', value: '18', icon: Icons.precision_manufacturing_outlined),
            SizedBox(width: 10),
            StatCard(label: 'Delayed', value: '2', icon: Icons.warning_amber_rounded),
          ],
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            StatCard(label: 'In Production', value: '9', icon: Icons.settings_outlined),
            SizedBox(width: 10),
            StatCard(label: 'Ready', value: '4', icon: Icons.check_circle_outline),
          ],
        ),
        const SizedBox(height: 25),
        const SectionTitle(title: 'Active production'),
        const SizedBox(height: 10),
        ...jobs.map((job) => JobCard(job: job)),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const StatCard({super.key, required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: const Color(0xFFEFF4FF), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 21, color: const Color(0xFF2563EB)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) => Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700));
}

class JobCard extends StatelessWidget {
  final Job job;
  const JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobDetailPage(job: job))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.precision_manufacturing_outlined, color: Color(0xFF2563EB)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.po, style: const TextStyle(fontWeight: FontWeight.w800)),
                        Text(job.customer, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                      ],
                    ),
                  ),
                  Text('${job.progress}%', style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 13),
              LinearProgressIndicator(value: job.progress / 100, minHeight: 7, borderRadius: BorderRadius.circular(10)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(job.machine, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text(job.stage, style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 10),
                  Text('Due ${job.due}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JobsPage extends StatelessWidget {
  const JobsPage({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const Text('Production Jobs', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      const Text('Track every machine from PO to dispatch.', style: TextStyle(color: Colors.black54)),
      const SizedBox(height: 18),
      ...jobs.map((job) => JobCard(job: job)),
    ],
  );
}

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150, height: 150,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
            child: const Icon(Icons.qr_code_2, size: 100),
          ),
          const SizedBox(height: 25),
          const Text('Scan machine QR', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Open a machine instantly and update its current production stage.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 25),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Start scanning'),
          ),
        ],
      ),
    ),
  );
}

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: const [
      Text('Alerts', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
      SizedBox(height: 18),
      AlertTile(icon: Icons.warning_amber_rounded, title: 'PO-1025 is delayed', subtitle: 'Fabrication has been in progress for 3 days.'),
      AlertTile(icon: Icons.description_outlined, title: 'GA approval required', subtitle: 'PO-1027 is waiting for design approval.'),
      AlertTile(icon: Icons.local_shipping_outlined, title: 'Ready for dispatch', subtitle: 'PO-1026 has completed packing.'),
    ],
  );
}

class AlertTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const AlertTile({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: CircleAvatar(backgroundColor: const Color(0xFFF1F5F9), child: Icon(icon, color: const Color(0xFF334155))),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
    ),
  );
}

class JobDetailPage extends StatelessWidget {
  final Job job;
  const JobDetailPage({super.key, required this.job});

  static const stages = [
    ('PO Received', true),
    ('GA Preparation', true),
    ('GA Approval', true),
    ('Material Procurement', true),
    ('Machining', true),
    ('Fabrication', true),
    ('Finishing', true),
    ('Assembly', false),
    ('Trials / Testing', false),
    ('Labeling', false),
    ('Packing', false),
    ('Dispatch / Billing', false),
    ('PDIR', false),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(job.po)),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(job.customer, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(job.machine, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('Serial No. SN-2026-1024', style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Production progress', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: job.progress / 100, minHeight: 8, borderRadius: BorderRadius.circular(10)),
              const SizedBox(height: 8),
              Text('${job.progress}% complete'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text('Workflow', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        ...List.generate(stages.length, (i) {
          final stage = stages[i];
          final isCurrent = stage.$1 == job.stage;
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 15,
              backgroundColor: stage.$2 ? const Color(0xFFDCFCE7) : (isCurrent ? const Color(0xFFDBEAFE) : const Color(0xFFE5E7EB)),
              child: Icon(stage.$2 ? Icons.check : (isCurrent ? Icons.play_arrow : Icons.circle_outlined), size: 17,
                color: stage.$2 ? const Color(0xFF15803D) : (isCurrent ? const Color(0xFF2563EB) : Colors.black38)),
            ),
            title: Text(stage.$1, style: TextStyle(fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500)),
            subtitle: isCurrent ? const Text('Current stage • Assembly team') : null,
            trailing: isCurrent ? const Icon(Icons.chevron_right) : null,
          );
        }),
        const SizedBox(height: 15),
        const Text('Quick actions', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.camera_alt_outlined), label: const Text('Photo'))),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.upload_file), label: const Text('Document'))),
          ],
        ),
      ],
    ),
  );
}
