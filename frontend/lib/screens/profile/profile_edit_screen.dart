import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '010-1234-0000');
  final _verificationController = TextEditingController(text: '346892');
  final _newPasswordController = TextEditingController(text: 'mypassword');
  final _confirmPasswordController = TextEditingController();

  bool _isPhoneVerified = false;
  bool _isVerificationSent = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _verificationController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('계정'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 전화번호 섹션
              _buildSection(
                '전화번호',
                _buildPhoneNumberField(),
              ),
              const SizedBox(height: 24),

              // 인증번호 섹션
              _buildSection(
                '인증번호',
                _buildVerificationField(),
              ),
              const SizedBox(height: 24),

              // 새 비밀번호 섹션
              _buildSection(
                '새 비밀번호',
                _buildPasswordField(
                  controller: _newPasswordController,
                  isVisible: _isPasswordVisible,
                  onVisibilityChanged: (value) {
                    setState(() {
                      _isPasswordVisible = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 새 비밀번호 확인 섹션
              _buildSection(
                '새 비밀번호 확인',
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  isVisible: _isConfirmPasswordVisible,
                  onVisibilityChanged: (value) {
                    setState(() {
                      _isConfirmPasswordVisible = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),

              // 수정하기 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '수정하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildPhoneNumberField() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
              ],
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: InputBorder.none,
                hintText: '전화번호를 입력하세요',
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _isPhoneVerified ? _resendVerification : _sendVerification,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            side: BorderSide(color: Colors.grey.shade400),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            _isPhoneVerified ? '재전송' : '인증번호 받기',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationField() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextFormField(
              controller: _verificationController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: InputBorder.none,
                hintText: '인증번호를 입력하세요',
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _isPhoneVerified ? null : _verifyCode,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isPhoneVerified ? Colors.grey.shade300 : Colors.white,
            foregroundColor: _isPhoneVerified ? Colors.grey.shade600 : Colors.black87,
            side: BorderSide(color: Colors.grey.shade400),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            _isPhoneVerified ? '인증완료' : '인증하기',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool isVisible,
    required Function(bool) onVisibilityChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: InputBorder.none,
          hintText: '비밀번호를 입력하세요',
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey.shade600,
            ),
            onPressed: () => onVisibilityChanged(!isVisible),
          ),
        ),
      ),
    );
  }

  void _sendVerification() {
    setState(() {
      _isVerificationSent = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('인증번호가 전송되었습니다.')),
    );
  }

  void _resendVerification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('인증번호가 재전송되었습니다.')),
    );
  }

  void _verifyCode() {
    setState(() {
      _isPhoneVerified = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('인증이 완료되었습니다.')),
    );
  }

  void _handleSubmit() {
    // 비밀번호 유효성 검사
    if (_newPasswordController.text.length < 8) {
      _showPasswordAlert();
      return;
    }

    // 비밀번호 확인 검사
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
      );
      return;
    }

    // 확인 다이얼로그 표시
    _showConfirmationDialog();
  }

  void _showPasswordAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Text(
            '비밀번호는 8자 이상이어야 합니다.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('확인'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Text(
            '계정 정보를 수정하시겠습니까?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _submitChanges();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('확인'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _submitChanges() {
    // TODO: 실제 API 호출로 변경
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('계정 정보가 수정되었습니다.')),
    );
    Navigator.of(context).pop();
  }
} 