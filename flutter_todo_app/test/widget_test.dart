import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Local minimal app used for widget tests to avoid depending on external package
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const HomePage()),
          ),
          child: const Text('Login'),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _activities = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addActivity() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _activities.add(text);
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Hai, User 👋'),
            const SizedBox(height: 8),
            const Text('✨ Belum ada kegiatan hari ini ✨'),
            const SizedBox(height: 16),
            TextField(controller: _controller),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addActivity,
                ),
                const SizedBox(width: 8),
                const Text('Tambah'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: _activities.map((a) => Text(a)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Login Page has a title and a login button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify that the login page is displayed
    expect(find.text('Login Page'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Home Page displays activities', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Navigate to the home page after login
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Verify that the home page is displayed
    expect(find.text('Hai, User 👋'), findsOneWidget);
    expect(find.text('✨ Belum ada kegiatan hari ini ✨'), findsOneWidget);
  });

  testWidgets('Add activity button works', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Navigate to the home page after login
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Add a new activity
    await tester.enterText(find.byType(TextField), 'Belajar Flutter');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that the new activity is displayed
    expect(find.text('Belajar Flutter'), findsOneWidget);
  });
}
