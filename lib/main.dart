import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const ToDoApp(),
    ),
  );
}

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});

  // konsisten tema biru
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color primaryBlueDark = Color(0xFF0D47A1);
  static const Color backgroundLightBlue = Color(0xFFE8F5FF);

  @override
  Widget build(BuildContext context) {
    final themeProv = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List Activity App',
      themeMode: themeProv.isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: primaryBlue,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ).copyWith(secondary: primaryBlue),
        scaffoldBackgroundColor: backgroundLightBlue,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBlue,
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: primaryBlueDark,
        colorScheme: ColorScheme.dark(
          primary: primaryBlueDark,
          secondary: primaryBlue,
        ),
        scaffoldBackgroundColor: Colors.black,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[850],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryBlueDark,
          centerTitle: true,
          elevation: 0,
        ),
      ),
      initialRoute: '/register', // changed: start app di halaman Register
      routes: {
        '/': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/activity': (_) => const ActivityPage(),
      },
    );
  }
}

/// THEME PROVIDER
class ThemeProvider extends ChangeNotifier {
  bool isDark = false;
  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    isDark = prefs.getBool('isDark') ?? false;
    notifyListeners();
  }

  Future<void> toggle() async {
    isDark = !isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDark);
    notifyListeners();
  }
}

/// --------------------
/// PROVIDER (In-memory list)
/// --------------------
class ActivityProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _activities = [];

  List<Map<String, dynamic>> get activities => _activities;

  // --- CACHE KEYS ---
  static const _kCachedActivities = 'cachedActivities';
  static const _kCacheTimestamp = 'cacheTimestamp';

  // load cached activities (return true if loaded from cache)
  Future<bool> loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kCachedActivities);
    if (list == null || list.isEmpty) return false;

    _activities
      ..clear()
      ..addAll(
        list.map((s) {
          final m = jsonDecode(s) as Map<String, dynamic>;
          // ensure boolean typed
          return {
            'text': m['text']?.toString() ?? '',
            'done': m['done'] == true || m['done'] == 'true',
          };
        }),
      );
    notifyListeners();
    return true;
  }

  Future<void> _saveToCache() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _activities.map((m) => jsonEncode(m)).toList();
    await prefs.setStringList(_kCachedActivities, list);
    await prefs.setString(_kCacheTimestamp, DateTime.now().toIso8601String());
  }

  Future<String?> cacheTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kCacheTimestamp);
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCachedActivities);
    await prefs.remove(_kCacheTimestamp);
  }

  // mutators - keep persisting changes to cache
  void addActivity(String text) {
    _activities.add({'text': text, 'done': false});
    notifyListeners();
    _saveToCache();
  }

  void deleteActivity(int index) {
    _activities.removeAt(index);
    notifyListeners();
    _saveToCache();
  }

  void toggleDone(int index) {
    _activities[index]['done'] = !_activities[index]['done'];
    notifyListeners();
    _saveToCache();
  }

  void clearAll() {
    _activities.clear();
    notifyListeners();
    _saveToCache();
  }
}

/// --------------------
/// REGISTER PAGE
/// --------------------
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _show = false;

  bool isValidEmail(String e) =>
      RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(e.trim());

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Periksa kembali input'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', _emailCtrl.text.trim());
    await prefs.setString('fullName', _nameCtrl.text.trim());
    await prefs.setString('password', _passCtrl.text);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/activity');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Registrasi berhasil, selamat datang ${_nameCtrl.text}'),
        backgroundColor: ToDoApp.primaryBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = ToDoApp.primaryBlue;
    final themeProv = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: primary,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(themeProv.isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => themeProv.toggle(),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap',
                        ),
                        validator: (v) => (v == null || v.trim().length < 3)
                            ? 'Nama minimal 3'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (v) => (v == null || !isValidEmail(v))
                            ? 'Email tidak valid'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: !_show,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _show ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () => setState(() => _show = !_show),
                          ),
                        ),
                        validator: (v) => (v == null || v.length < 6)
                            ? 'Minimal 6 karakter'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _confirmCtrl,
                        obscureText: !_show,
                        decoration: const InputDecoration(
                          labelText: 'Konfirmasi Password',
                        ),
                        validator: (v) => (v != _passCtrl.text)
                            ? 'Password tidak cocok'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _register,
                          child: const Text('Daftar'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/'),
                        child: const Text('Sudah punya akun? Login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// --------------------
/// LOGIN PAGE
/// --------------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _show = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('email');
    final storedPass = prefs.getString('password');
    if (storedEmail == null || storedPass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belum ada akun terdaftar'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_emailCtrl.text.trim() == storedEmail && _passCtrl.text == storedPass) {
      await prefs.setString('lastLogin', _emailCtrl.text.trim());
      if (mounted) Navigator.pushReplacementNamed(context, '/activity');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Login berhasil'),
          backgroundColor: ToDoApp.primaryBlue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email atau password salah'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = ToDoApp.primaryBlue;
    final themeProv = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(themeProv.isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => themeProv.toggle(),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [ToDoApp.primaryBlueDark, ToDoApp.primaryBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 12,
                shadowColor: Colors.black45,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.login,
                                color: primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Email wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: !_show,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _show ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () => setState(() => _show = !_show),
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Password wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _login,
                            child: const Text('Login'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Belum punya akun?'),
                            TextButton(
                              onPressed: () => Navigator.pushReplacementNamed(
                                context,
                                '/register',
                              ),
                              child: const Text('Register'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// --------------------
/// ACTIVITY (HOME) PAGE
/// --------------------
class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final TextEditingController _ctrl = TextEditingController();
  String? _displayName;
  String? _emailUser;
  String? _lastRefreshLabel;

  @override
  void initState() {
    super.initState();
    _loadUser();
    // schedule cache load after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCache());
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _displayName =
          prefs.getString('fullName') ?? prefs.getString('lastLogin');
      _emailUser = prefs.getString('email');
    });
  }

  Future<void> _loadCache() async {
    final prov = Provider.of<ActivityProvider>(context, listen: false);
    final loaded = await prov.loadFromCache();
    final ts = await prov.cacheTimestamp();
    if (ts != null) {
      setState(() {
        _lastRefreshLabel = _formatTs(ts);
      });
    }
    if (loaded) {
      // notify user data came from cache
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data from Cache'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatTs(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      return '${d.year}-${_two(d.month)}-${_two(d.day)} ${_two(d.hour)}:${_two(d.minute)}:${_two(d.second)}';
    } catch (_) {
      return iso;
    }
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  void _add(ActivityProvider prov) {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    prov.addActivity(text);
    _ctrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$text" ditambahkan ✅'),
        backgroundColor: ToDoApp.primaryBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _refreshFromCache() async {
    final prov = Provider.of<ActivityProvider>(context, listen: false);
    final loaded = await prov.loadFromCache();
    final ts = await prov.cacheTimestamp();
    setState(() {
      _lastRefreshLabel = ts == null ? null : _formatTs(ts);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loaded ? 'Refreshed from cache' : 'No cached data'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _doClearCache() async {
    final prov = Provider.of<ActivityProvider>(context, listen: false);
    await prov.clearCache();
    prov.clearAll();
    setState(() {
      _lastRefreshLabel = null;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache cleared'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ActivityProvider>(context);
    final themeProv = Provider.of<ThemeProvider>(context, listen: false);
    final titleName = _displayName ?? _emailUser ?? 'User';

    String initials() {
      final parts = titleName.split(' ');
      final a = parts.isNotEmpty && parts.first.isNotEmpty
          ? parts.first[0]
          : '';
      final b = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
      return (a + b).toUpperCase();
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: ToDoApp.primaryBlueDark,
              child: Text(
                initials(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Hai, $titleName 👋",
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(themeProv.isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => themeProv.toggle(),
          ),
          IconButton(
            tooltip: 'Refresh cache',
            icon: const Icon(Icons.refresh),
            onPressed: _refreshFromCache,
          ),
          IconButton(
            tooltip: 'Clear cache',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear cache?'),
                  content: const Text(
                    'This will clear saved cached activities.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
              if (ok == true) _doClearCache();
            },
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('lastLogin');
              if (mounted) Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [ToDoApp.primaryBlueDark, ToDoApp.primaryBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      // show last refresh/timestamp on top of body
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            if (_lastRefreshLabel != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Last cache refresh: $_lastRefreshLabel',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: InputDecoration(
                      hintText: "Contoh: Belajar Flutter",
                      prefixIcon: const Icon(Icons.task_alt),
                    ),
                    onSubmitted: (_) => _add(prov),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _add(prov),
                    child: const Icon(Icons.add, size: 26),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: prov.activities.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.hourglass_empty,
                            size: 56,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "✨ Belum ada kegiatan hari ini ✨",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: prov.activities.length,
                      itemBuilder: (ctx, i) {
                        final act = prov.activities[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              leading: IconButton(
                                icon: Icon(
                                  act['done']
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: act['done']
                                      ? Colors.green
                                      : ToDoApp.primaryBlue,
                                ),
                                onPressed: () => prov.toggleDone(i),
                              ),
                              title: Text(
                                act['text'],
                                style: TextStyle(
                                  decoration: act['done']
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: act['done']
                                      ? Colors.grey
                                      : Colors.black87,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete_forever,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => prov.deleteActivity(i),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: prov.activities.isNotEmpty
          ? FloatingActionButton(
              child: const Icon(Icons.delete_sweep),
              backgroundColor: ToDoApp.primaryBlue,
              onPressed: () => prov.clearAll(),
              tooltip: 'Clear all',
            )
          : null,
    );
  }
}
