import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/auth_provider.dart';

/// Edit profile screen for name, email, and avatar.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: DozColors.surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final l = AppLocalizations.of(context);
        final isAr = l.isArabic;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: DozColors.primaryGreen),
                  title: Text(l.t('takePhoto'), style: DozTextStyles.bodyMedium(isArabic: isAr)),
                  onTap: () { Navigator.pop(ctx); _uploadAvatar(ImageSource.camera); },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: DozColors.primaryGreen),
                  title: Text(l.t('chooseFromGallery'), style: DozTextStyles.bodyMedium(isArabic: isAr)),
                  onTap: () { Navigator.pop(ctx); _uploadAvatar(ImageSource.gallery); },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _uploadAvatar(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: source, imageQuality: 80);
      if (file == null) return;
    } catch (_) {}
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await context.read<AuthProvider>().updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
    );
    if (mounted) {
      setState(() => _isLoading = false);
      final l = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.t('profileUpdated')), backgroundColor: DozColors.success));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new, color: DozColors.textPrimary, size: 20)),
        title: Text(l.t('editProfile'), style: DozTextStyles.sectionTitle(isArabic: isAr)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    DozAvatar(imageUrl: auth.user?.avatarUrl, name: auth.user?.name ?? '', size: 88),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        width: 30, height: 30,
                        decoration: const BoxDecoration(color: DozColors.primaryGreen, shape: BoxShape.circle),
                        child: const Icon(Icons.edit, color: DozColors.primaryDark, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: _pickAvatar, child: Text(l.t('changePhoto'), style: DozTextStyles.bodySmall(isArabic: isAr, color: DozColors.primaryGreen))),
              const SizedBox(height: 24),
              _buildLabel(l.t('fullName'), isAr),
              const SizedBox(height: 8),
              DozTextField(controller: _nameController, hint: l.t('enterName'), validator: (v) {
                if (v == null || v.trim().isEmpty) return l.t('required_');
                if (v.trim().length < 2) return l.t('nameTooShort');
                return null;
              }),
              const SizedBox(height: 16),
              _buildLabel('${l.t('email')} (${l.t('optional')})', isAr),
              const SizedBox(height: 8),
              DozTextField(controller: _emailController, hint: 'example@email.com', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 32),
              DozButton(label: l.t('save'), loading: _isLoading, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isAr) {
    return Align(alignment: Alignment.centerLeft, child: Text(text, style: DozTextStyles.labelLarge(isArabic: isAr)));
  }
}
