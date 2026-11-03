import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // ===== Controller dasar (dari panduan praktik) =====
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ===== Latihan 1: Controller Nomor Telepon =====
  final _phoneController = TextEditingController();

  // ===== Latihan 2: Controller & state Tanggal Lahir =====
  final _birthDateController = TextEditingController();
  DateTime? _selectedBirthDate;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // ===== Latihan 3: State Jenis Kelamin =====
  String? _selectedGender;

  // ===== Latihan 4: State Checkbox Setuju S&K =====
  bool _agreedToTerms = false;
  bool _showTermsError = false;

  // ===== Latihan 5: State Kekuatan Password =====
  String _passwordStrengthLabel = '';
  double _passwordStrengthValue = 0.0;
  Color _passwordStrengthColor = Colors.grey;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // VALIDASI
  // ---------------------------------------------------------------------

  // Validasi nama
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.trim().length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  // Validasi email
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  // Validasi password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password harus mengandung huruf kapital';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password harus mengandung angka';
    }
    return null;
  }

  // Validasi konfirmasi password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != _passwordController.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  // ===== Latihan 1: Validasi Nomor Telepon =====
  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    final digitsOnlyRegex = RegExp(r'^[0-9]+$');
    if (!digitsOnlyRegex.hasMatch(value.trim())) {
      return 'Nomor telepon hanya boleh berisi angka';
    }
    if (value.trim().length < 10 || value.trim().length > 13) {
      return 'Nomor telepon harus 10-13 digit';
    }
    return null;
  }

  // ===== Latihan 2: Validasi Tanggal Lahir =====
  String? _validateBirthDate(String? value) {
    if (_selectedBirthDate == null) {
      return 'Tanggal lahir wajib dipilih';
    }
    return null;
  }

  // ===== Latihan 3: Validasi Jenis Kelamin (required) =====
  String? _validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Jenis kelamin wajib dipilih';
    }
    return null;
  }

  // ===== Latihan 2: Tampilkan date picker =====
  Future<void> _selectBirthDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text =
            '${picked.day.toString().padLeft(2, '0')}/'
            '${picked.month.toString().padLeft(2, '0')}/'
            '${picked.year}';
      });
    }
  }

  // ===== Latihan 5: Hitung kekuatan password =====
  void _calculatePasswordStrength(String value) {
    String label;
    double strengthValue;
    Color color;

    final hasUpper = value.contains(RegExp(r'[A-Z]'));
    final hasLower = value.contains(RegExp(r'[a-z]'));
    final hasDigit = value.contains(RegExp(r'[0-9]'));
    final hasSymbol = value.contains(RegExp(r'[!@#\$%\^&\*(),.?":{}|<>_\-+=\[\];]'));

    if (value.isEmpty) {
      label = '';
      strengthValue = 0.0;
      color = Colors.grey;
    } else if (value.length < 8) {
      label = 'Lemah';
      strengthValue = 0.33;
      color = Colors.red;
    } else if (value.length >= 8 && hasUpper && hasLower && hasDigit && hasSymbol) {
      label = 'Kuat';
      strengthValue = 1.0;
      color = Colors.green;
    } else if (value.length >= 8 && hasLower && hasDigit) {
      label = 'Sedang';
      strengthValue = 0.66;
      color = Colors.orange;
    } else {
      // >= 8 karakter tapi belum memenuhi kombinasi huruf+angka
      label = 'Lemah';
      strengthValue = 0.33;
      color = Colors.red;
    }

    setState(() {
      _passwordStrengthLabel = label;
      _passwordStrengthValue = strengthValue;
      _passwordStrengthColor = color;
    });
  }

  // Handler submit form
  void _submitForm() {
    // ===== Latihan 4: validasi checkbox di _submitForm() sebelum memproses =====
    setState(() {
      _showTermsError = !_agreedToTerms;
    });

    final isFormValid = _formKey.currentState!.validate();

    if (!isFormValid || !_agreedToTerms) {
      if (!_agreedToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda harus menyetujui syarat & ketentuan'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });
    // Simulasi proses registrasi
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
      // Tampilkan dialog sukses
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Registrasi Berhasil'),
          content: Text(
            'Selamat, ${_nameController.text}!\n'
            'Email: ${_emailController.text}\n'
            'No. Telepon: ${_phoneController.text}\n'
            'Tanggal Lahir: ${_birthDateController.text}\n'
            'Jenis Kelamin: ${_selectedGender ?? '-'}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetForm();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  // Reset form
  void _resetForm() {
    _formKey.currentState!.reset();
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _phoneController.clear();
    _birthDateController.clear();
    setState(() {
      _selectedBirthDate = null;
      _selectedGender = null;
      _agreedToTerms = false;
      _showTermsError = false;
      _passwordStrengthLabel = '';
      _passwordStrengthValue = 0.0;
      _passwordStrengthColor = Colors.grey;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Registrasi'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const SizedBox(height: 16),
                const Icon(
                  Icons.person_add,
                  size: 80,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Buat Akun Baru',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Isi form di bawah ini untuk mendaftar',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Field Nama
                CustomTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap Anda',
                  prefixIcon: Icons.person,
                  validator: _validateName,
                ),

                // Field Email
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Masukkan email Anda',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),

                // ===== Latihan 1: Field Nomor Telepon =====
                CustomTextField(
                  controller: _phoneController,
                  label: 'Nomor Telepon',
                  hint: 'Masukkan nomor telepon (10-13 digit)',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                ),

                // ===== Latihan 2: Field Tanggal Lahir =====
                CustomTextField(
                  controller: _birthDateController,
                  label: 'Tanggal Lahir',
                  hint: 'Pilih tanggal lahir Anda',
                  prefixIcon: Icons.cake,
                  readOnly: true,
                  onTap: _selectBirthDate,
                  validator: _validateBirthDate,
                ),

                // ===== Latihan 3: Dropdown Jenis Kelamin =====
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Jenis Kelamin',
                      prefixIcon: Icon(Icons.wc),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFFAFAFA),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Laki-laki',
                        child: Text('Laki-laki'),
                      ),
                      DropdownMenuItem(
                        value: 'Perempuan',
                        child: Text('Perempuan'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    validator: _validateGender,
                  ),
                ),

                // Field Password
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Minimal 8 karakter, huruf kapital, angka',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    obscureText: _obscurePassword,
                    validator: _validatePassword,
                    // ===== Latihan 5: hitung kekuatan password saat berubah =====
                    onChanged: _calculatePasswordStrength,
                  ),
                ),

                // ===== Latihan 5: Indikator Kekuatan Password =====
                if (_passwordStrengthLabel.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _passwordStrengthValue,
                            minHeight: 6,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _passwordStrengthColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kekuatan Password: $_passwordStrengthLabel',
                          style: TextStyle(
                            fontSize: 12,
                            color: _passwordStrengthColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Field Konfirmasi Password
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password',
                      hintText: 'Ulangi password Anda',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: _validateConfirmPassword,
                  ),
                ),

                // ===== Latihan 4: Checkbox Setuju Syarat & Ketentuan =====
                const SizedBox(height: 8),
                CheckboxListTile(
                  value: _agreedToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreedToTerms = value ?? false;
                      if (_agreedToTerms) {
                        _showTermsError = false;
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Saya menyetujui syarat & ketentuan yang berlaku',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                if (_showTermsError)
                  const Padding(
                    padding: EdgeInsets.only(left: 12.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Anda harus menyetujui syarat & ketentuan',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
                // Tombol Submit
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Daftar',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(height: 12),
                // Tombol Reset
                OutlinedButton(
                  onPressed: _isLoading ? null : _resetForm,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Reset'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}