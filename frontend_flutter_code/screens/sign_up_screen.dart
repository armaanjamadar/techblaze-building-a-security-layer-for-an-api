import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _profileNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  static const String _signupUrl = 'https://voip-firewire-corps-outline.trycloudflare.com/api/users/new';

  @override
  void dispose() {
    _profileNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isLoading) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse(_signupUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'profile_name': _profileNameController.text.trim(),
          'email': _emailController.text.trim(),
          'user_password': _passwordController.text,
        }),
      );
      _handleApiResponse(response);
    } catch (e) {
      if (!mounted) return;
      _showSnackbar(
        'Unable to connect to the server. Check your internet connection and try again.',
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
    String message;
    try {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data['message'] is String) {
        message = data['message'];
      } else {
        message = 'Request failed (HTTP: ${response.statusCode}).';
      }

      if (data['success'] == true) {
        _showSnackbar(
          'Success: $message',
          isError: false,
        );
      } else if (data['success'] == false) {
        _showSnackbar(
          'Error: $message',
          isError: true,
        );
      }
    } catch (_) {
      _showSnackbar(
        'Unable to process the server response. Please try again.',
        isError: true,
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        title: const Text("Cyber Blogs"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                const Text(
                  "Create Account",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 35),
                const Text(
                  "Profile Name",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _profileNameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  maxLength: 50,
                  decoration: const InputDecoration(
                    hintText: "Enter your profile name",
                    border: OutlineInputBorder(),
                    counterText: "",
                  ),
                  validator: (value) {
                    final profileName = value?.trim() ?? "";
                    if (profileName.isEmpty) {
                      return "Profile name is required";
                    }
                    if (profileName.length < 3) {
                      return "Profile name must be at least 3 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "Email",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  maxLength: 254,
                  decoration: const InputDecoration(
                    hintText: "Enter your email",
                    border: OutlineInputBorder(),
                    counterText: "",
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? "";
                    if (email.isEmpty) {
                      return "Email is required";
                    }
                    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!emailPattern.hasMatch(email)) {
                      return "Enter a valid email address";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "Password",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  maxLength: 128,
                  decoration: InputDecoration(
                    hintText: "Enter your password",
                    border: const OutlineInputBorder(),
                    counterText: "",
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      ),
                      tooltip: _obscurePassword
                        ? "Show password"
                        : "Hide password",
                    ),
                  ),
                  validator: (value) {
                    final password = value ?? "";
                    if (password.isEmpty) {
                      return "Password is required";
                    }
                    if (password.length < 8) {
                      return "Password must be at least 8 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 50),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}