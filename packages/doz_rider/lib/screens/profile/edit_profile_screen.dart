import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/auth_provider.dart';

/// Edit profile screen — update name, email, avatar.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _loading = false;

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
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    try {
      await context.read<AuthProvider>().uploadAvatar(file.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: DozColors.error),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().updateProfile(
            name: _nameController.text.trim(),
            email: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
          );
      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: DozColors.error),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      appBar: AppBar(
        backgroundColor: DozColors.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
          color: DozColors.textPrimary,
        ),
        title: Text(
          isArabic ? 'تعديل الملف الشخصي' : 'Edit Profile',
          style: DozTextStyles.sectionTitle(isArabic: isArabic),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: Text(
              l10n.t('save'),
              style: DozTextStyles.bodyMedium(
                isArabic: isArabic,
                color: DozColors.primaryGreen,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: DozColors.darkGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Stack(
                      children: [
                        DozAvatar(
                          imageUrl: user?.avatarUrl,
                          name: user?.name ?? 'User',
                          size: 90,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: _pickAvatar,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: DozColors.primaryGreen,
                                shape: BoxShape.circle,
                                border: Border.all(color: DozColors.primaryDark, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt_rounded,
                                  size: 16, color: DozColors.primaryDark),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  DozTextField(
                    controller: _nameController,
                    label: l10n.t('fullName'),
                    hint: isArabic ? 'أدخل اسمك' : 'Enter your name',
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: DozColors.textMuted),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return isArabic ? 'الاسم مطلوب' : 'Name required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DozTextField(
                    controller: _emailController,
                    label: '${l10n.t('email')} (${l10n.t('optional')})',
                    hint: isArabic ? 'أدخل بريدك الإلكتروني' : 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined, color: DozColors.textMuted),
                  ),
                  const SizedBox(height: 20),
                  DozTextField(
                    label: l10n.t('phone'),
                    controller: TextEditingController(text: DozFormatters.phone(user?.phone ?? '')),
                    readOnly: true,
                    prefixIcon: const Icon(Icons.phone_outlined, color: DozColors.textMuted),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: DozColors.cardDark,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isArabic ? 'لا يمكن تغييره' : 'Read only',
                        style: DozTextStyles.caption(isArabic: isArabic, color: DozColors.textDisabled),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  DozButton(
                    label: l10n.t('save'),
                    onPressed: _loading ? null : _save,
                    loading: _loading,
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
