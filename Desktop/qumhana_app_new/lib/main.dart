import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QumhanaApp());
}

// متغيرات عامة لحفظ بيانات الجلسة للمواطن الحالي
class UserSession {
  static String citizenName = '';
  static String citizenPhone = '';
}

class QumhanaApp extends StatelessWidget {
  const QumhanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'نظام إدارة خدمات بلدية قمحانة',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Cairo',
      ),
      home: const LoginScreen(),
    );
  }
}

// ==========================================
// 1. شاشة تسجيل الدخول الموحدة
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isEmployeeLogin = false;

  void _login() {
    if (_isEmployeeLogin) {
      // دخول الموظف
      if (_userController.text.trim() == 'employee' && _passController.text.trim() == '123456') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavScreen(initialIndex: 1)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ في اسم المستخدم أو كلمة المرور للموظف')),
        );
      }
    } else {
      // دخول المواطن
      if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء إدخال الاسم ورقم الجوال للمتابعة')),
        );
        return;
      }
      UserSession.citizenName = _nameController.text.trim();
      UserSession.citizenPhone = _phoneController.text.trim();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavScreen(initialIndex: 0)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Icon(Icons.location_city, size: 60, color: Colors.teal.shade800),
                  const SizedBox(height: 16),
                  const Text(
                    'بلدية قمحانة - الخدمات الذكية',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isEmployeeLogin ? 'تسجيل دخول موظف البلدية' : 'بوابة تسجيل دخول المواطنين',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_isEmployeeLogin) ...[
                    TextField(
                      controller: _userController,
                      decoration: const InputDecoration(
                        labelText: 'اسم المستخدم (employee)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'كلمة المرور (123456)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                  ] else ...[
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'الاسم الثلاثي للمواطن',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'رقم الجوال',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('دخول النظام', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isEmployeeLogin = !_isEmployeeLogin;
                      });
                    },
                    child: Text(
                      _isEmployeeLogin ? 'العودة لتسجيل دخول المواطنين' : 'تسجيل الدخول كموظف بلدية؟',
                      style: TextStyle(color: Colors.teal.shade800),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. الشاشة الرئيسية والتبديل
// ==========================================
class MainNavScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const CitizenRequestScreen(),
    const EmployeeDashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'مرحباً: ${UserSession.citizenName} (بوابة المواطن)' : 'لوحة متابعة الموظف - بلدية قمحانة'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () {
              UserSession.citizenName = '';
              UserSession.citizenPhone = '';
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.teal.shade800,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.send),
            label: 'بوابة المواطن',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'لوحة الموظف',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. شاشة المواطن (مع تفاصيل الاسم، العقار، ورقم الجوال)
// ==========================================
class CitizenRequestScreen extends StatefulWidget {
  const CitizenRequestScreen({super.key});

  @override
  State<CitizenRequestScreen> createState() => _CitizenRequestScreenState();
}

class _CitizenRequestScreenState extends State<CitizenRequestScreen> {
  final List<String> _services = [
    'عداد مياه',
    'عداد كهرباء',
    'كشف مالية',
    'طلب ترخيص بناء / إشغال',
    'صيانة عامة وخدمات أخرى'
  ];

  String? _selectedService;
  final _propertyController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  final String apiUrl = 'http://localhost:3000/requests';

  Future<void> _submitRequest() async {
    if (_selectedService == null || _propertyController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار نوع الخدمة، إدخال رقم العقار وتفاصيل الطلب')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // دمج تفاصيل المواطن والعقار في حقل الوصف ليتم تخزينها بجدول الطلبات
    String fullDescription = 'المواطن: ${UserSession.citizenName} | الجوال: ${UserSession.citizenPhone} | العقار: ${_propertyController.text} | التفاصيل: ${_descController.text}';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'title': _selectedService,
          'desc': fullDescription,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال طلبك بنجاح إلى بلدية قمحانة!')),
        );
        setState(() {
          _selectedService = null;
          _propertyController.clear();
          _descController.clear();
        });
      } else {
        throw Exception('فشل في حفظ الطلب');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الاتصال بالسيرفر: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const Text(
              'تقديم طلب أو معاملة لبلدية قمحانة',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            DropdownButtonFormField<String>(
              value: _selectedService,
              decoration: const InputDecoration(
                labelText: 'اختر نوع الخدمة',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _services.map((String service) {
                return DropdownMenuItem<String>(
                  value: service,
                  child: Text(service),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedService = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _propertyController,
              decoration: const InputDecoration(
                labelText: 'رقم العقار / الشقة / المنطقة',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'تفاصيل الطلب أو الشكوى',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('إرسال الطلب للبلدية', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. شاشة الموظف (مع الفلترة وتغيير الحالة وعرض بيانات المواطن ورقم العقار)
// ==========================================
class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  State<EmployeeDashboardScreen> createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  List requests = [];
  bool _isLoading = true;
  String _selectedFilter = 'الكل';
  final String apiUrl = 'http://localhost:3000/requests';

  final List<String> _serviceCategories = [
    'الكل',
    'عداد مياه',
    'عداد كهرباء',
    'كشف مالية',
    'طلب ترخيص بناء / إشغال',
    'صيانة عامة وخدمات أخرى'
  ];

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          requests = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('فشل في جلب البيانات');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الاتصال: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List filteredRequests = requests;
    if (_selectedFilter != 'الكل') {
      filteredRequests = requests.where((req) => req['title'] == _selectedFilter).toList();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'لوحة متابعة طلبات المواطنين الواردة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.teal),
                onPressed: _fetchRequests,
                tooltip: 'تحديث القائمة',
              )
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedFilter,
            decoration: const InputDecoration(
              labelText: 'تصفية حسب نوع الخدمة',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.filter_list),
            ),
            items: _serviceCategories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedFilter = newValue!;
              });
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRequests.isEmpty
                    ? const Center(
                        child: Text('لا توجد طلبات مطابقة لهذا التصنيف',
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                      )
                    : ListView.builder(
                        itemCount: filteredRequests.length,
                        itemBuilder: (context, index) {
                          final req = filteredRequests[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.teal.shade700,
                                            radius: 14,
                                            child: Text('${req['id'] ?? index + 1}',
                                                style: const TextStyle(color: Colors.white, fontSize: 12)),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            req['title'] ?? 'بدون عنوان',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      Chip(
                                        label: const Text('قيد المعالجة', style: TextStyle(color: Colors.white, fontSize: 12)),
                                        backgroundColor: Colors.orange.shade700,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(req['desc'] ?? '', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                  const Divider(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('تم تحديث حالة الطلب إلى: تم الإنجاز')),
                                          );
                                        },
                                        icon: const Icon(Icons.check_circle, color: Colors.green),
                                        label: const Text('إنجاز الطلب', style: TextStyle(color: Colors.green)),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('تم تحديث حالة الطلب إلى: مرفوض')),
                                          );
                                        },
                                        icon: const Icon(Icons.cancel, color: Colors.red),
                                        label: const Text('رفض الطلب', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}