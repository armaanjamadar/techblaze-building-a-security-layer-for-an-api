import 'dart:convert';
import 'package:cyber_blogs/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final String? token;
  const HomeScreen({super.key, required this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _authorizeUrl = 'https://several-walks-nickel-falls.trycloudflare.com/api/users/get_user';

  static const Set<String> _sensitiveKeys = {
    'password',
    'user_password',
    'token',
    'access_token',
    'refresh_token',
    'secret',
    'api_key',
  };

  static const Duration _requestTimeout = Duration(seconds: 5);

  bool _isLoading = false;
  bool _isLoggingOut = false;

  bool _success = false;
  bool _hasResult = false;
  String _message = '';
  Map<String, dynamic> _userData = {};
  List<dynamic> _permissions = [];

  @override
  void initState() {
    super.initState();
    _authorizeUser();
  }

  Future<void> _authorizeUser() async {
    if (_isLoading) {
      return;
    }

    final token = widget.token;
    if (token == null || token.isEmpty) {
      setState(() {
        _hasResult = true;
        _success = false;
        _message = 'No authorization token was provided.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(_authorizeUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'token': token}),
      ).timeout(_requestTimeout);

      _handleApiResponse(response);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasResult = true;
        _success = false;
        _message = 'Unable to connect to the server.';
      });
      _showSnackbar(
        'Unable to connect to the server.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleApiResponse(http.Response response) {
    if (!mounted) return;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      setState(() {
        _hasResult = true;
        _success = false;
        _message = 'Request failed (HTTP: ${response.statusCode}).';
        _userData = {};
        _permissions = [];
      });
      _showSnackbar(_message, isError: true);
      return;
    }

    try {
      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        setState(() {
          _hasResult = true;
          _success = false;
          _message = 'Invalid server response.';
        });
        _showSnackbar(_message, isError: true);
        return;
      }

      final success = data['success'] == true;
      final message = data['message'] is String
          ? data['message'] as String
          : 'Request failed (HTTP: ${response.statusCode}).';
      final rawUserData = data['user_data'];
      final rawPermissions = data['permissions'];

      setState(() {
        _hasResult = true;
        _success = success;
        _message = message;
        _userData = _sanitizeUserData(
          rawUserData is Map<String, dynamic> ? rawUserData : {},
        );
        _permissions = rawPermissions is List ? rawPermissions : [];
      });

      _showSnackbar(
        success ? 'Success: $message' : 'Error: $message',
        isError: !success,
      );
    } on FormatException {
      setState(() {
        _hasResult = true;
        _success = false;
        _message = 'Unable to process the server response.';
      });
      _showSnackbar(_message, isError: true);
    }
  }

  Map<String, dynamic> _sanitizeUserData(Map<String, dynamic> source) {
    final sanitized = <String, dynamic>{};
    for (final entry in source.entries) {
      if (_sensitiveKeys.contains(entry.key.toLowerCase())) {
        continue;
      }
      sanitized[entry.key] = entry.value;
    }
    return sanitized;
  }

  Future<void> _confirmLogout() async {
    if (_isLoggingOut) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _logout();
    }
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    setState(() {
      _userData = {};
      _permissions = [];
      _message = '';
      _success = false;
      _hasResult = false;
      _isLoggingOut = false;
    });

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  void _showSnackbar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  Widget _buildStatusCard() {
    if (!_hasResult) {
      return const SizedBox.shrink();
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(
          _success ? Icons.check_circle : Icons.error,
          color: _success ? Colors.green : Colors.red,
        ),
        title: Text(
          _success ? 'Authorization Successful' : 'Authorization Failed',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_message),
      ),
    );
  }

  Widget _buildUserDataCard() {
    if (_userData.isEmpty) {
      return const SizedBox.shrink();
    }

    final children = <Widget>[
      const Text(
        'User Information',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
    ];

    for (final entry in _userData.entries) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(entry.value?.toString() ?? 'null'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildPermissionsCard() {
    final children = <Widget>[
      const Text(
        'Permissions',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
    ];

    if (_permissions.isEmpty) {
      children.add(
        const Text(
          'No permissions assigned.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    } else {
      for (final permission in _permissions) {
        children.add(
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text(permission.toString()),
          ),
        );
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        title: const Text('Authorization Panel'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _isLoggingOut ? null : _confirmLogout,
            icon: _isLoggingOut
              ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
              : const Icon(Icons.logout),
            tooltip: 'Log Out',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
          onRefresh: _authorizeUser,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatusCard(),
              _buildUserDataCard(),
              _buildPermissionsCard(),
            ],
          ),
        ),
      ),
    );
  }
}