import 'package:flutter/material.dart';
import 'package:gym_app_flutter/src/providers/user_provider.dart';
import 'package:gym_app_flutter/src/services/api_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:flutter_codice_fiscale/codice_fiscale.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MobileScannerScreen extends StatefulWidget {
  @override
  _MobileScannerScreenState createState() => _MobileScannerScreenState();
}

class _MobileScannerScreenState extends State<MobileScannerScreen> {
  bool _isProcessing = false; // To track login state

  @override
  void initState() {
    super.initState();
    _checkForToken();
  }

  Future<void> _checkForToken() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      // Skip scanner and handle login with the token
      debugPrint('Found saved token: $token');
      _handleLoginWithToken(token);
    } else {
      debugPrint('No saved token found');
    }
  }

  Future<void> _handleLoginWithToken(String token) async {
    setState(() {
      _isProcessing = true; // Disable scanning
    });

    var userProvider = Provider.of<UserProvider>(context, listen: false);
    ApiService apiService = ApiService();

    try {
      debugPrint('Logging in with token: $token');

      var loginResponse = await apiService.getUserProfile(token);
      userProvider.setUser(loginResponse, token);

      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (error) {
      debugPrint('Failed to login with token (handleLoginWithToken): $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to login with token: $error')),
      );
      userProvider.cancelSavedToken();
    } finally {
      setState(() {
        _isProcessing = false; // Re-enable scanning after login attempt
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scansiona retro tessera sanitaria')),
      body: Center(
        child: _isProcessing
            ? const CircularProgressIndicator() // Show a loader while processing
            : MobileScanner(
                onDetect: (barcode) {
                  final String? code = barcode.barcodes.first.rawValue;
                  if (code != null && !_isProcessing) {
                    if (!CodiceFiscale.check(code)) {
                      debugPrint('Invalid fiscal code: $code');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Invalid fiscal code: $code'),
                        ),
                      );
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('QR code detected: $code'),
                      ),
                    );
                    debugPrint('QR code detected: $code');
                    handleLogin(context, code);
                  } else {
                    debugPrint('Failed to scan QR code');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to scan QR code')),
                    );
                  }
                },
              ),
      ),
    );
  }

  Future<void> handleLogin(BuildContext context, String fiscalCode) async {
    ApiService apiService = ApiService();

    setState(() {
      _isProcessing = true; // Disable scanning
    });

    var userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      debugPrint('Logging in with fiscal code: $fiscalCode');

      var loginResponse = await apiService.loginUser(fiscalCode);
      userProvider.setUser(loginResponse.user, loginResponse.token);

      // Save the token for future use
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', loginResponse.token);

      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (error) {
      debugPrint('Failed to login (handleLogin): $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to login: $error')),
      );
      userProvider.cancelSavedToken();
    } finally {
      setState(() {
        _isProcessing = false; // Re-enable scanning after login attempt
      });
    }
  }
}
