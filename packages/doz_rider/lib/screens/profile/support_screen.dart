import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:doz_shared/doz_shared.dart';

/// Help & Support screen.
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;

    final faqs = isArabic
        ? [
            _FaqItem(
              question: 'كيف أحجز رحلة؟',
              answer:
                  'افتح التطبيق، اضغط على "إلى أين؟"، أدخل وجهتك، اختر نوع السيارة وحدد سعرك.',
            ),
            _FaqItem(
              question: 'كيف أعرف أن السائق موثوق؟',
              answer:
                  'جميع السائقين مراجعون ومعتمدون. يمكنك الاطلاع على تقييماتهم وعدد رحلاتهم.',
            ),
            _FaqItem(
              question: 'ماذا أفعل إذا نسيت شيئاً في السيارة؟',
              answer:
                  'تواصل مع السائق مباشرة عبر التطبيق أو اتصل بخدمة العملاء.',
            ),
            _FaqItem(
              question: 'كيف أشحن محفظتي؟',
              answer:
                  'اذهب إلى المحفظة واضغط "شحن المحفظة" ثم اختر المبلغ وطريقة الدفع.',
            ),
          ]
        : [
            _FaqItem(
              question: 'How do I book a ride?',
              answer:
                  'Tap "Where to?", enter your destination, select vehicle type and set your price.',
            ),
            _FaqItem(
              question: 'How do I know the driver is trustworthy?',
              answer:
                  'All drivers are verified and approved. You can view their ratings and trip history.',
            ),
            _FaqItem(
              question: 'What if I forgot something in the car?',
              answer:
                  'Contact the driver directly via the app or call our support line.',
            ),
            _FaqItem(
              question: 'How do I top up my wallet?',
              answer:
                  'Go to Wallet, tap "Top Up", select an amount and choose payment method.',
            ),
          ];

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
          isArabic ? 'مساعدة ودعم' : 'Help & Support',
          style: DozTextStyles.sectionTitle(isArabic: isArabic),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Contact options
            DozCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ContactOption(
                    icon: Icons.phone_rounded,
                    label: isArabic ? 'اتصل بنا' : 'Call Us',
                    value: AppConstants.supportPhone,
                    onTap: () async {
                      final uri = Uri.parse(
                          'tel:${AppConstants.supportPhone}');
                      if (await canLaunchUrl(uri)) await launchUrl(uri);
                    },
                  ),
                  Divider(height: 1, color: DozColors.borderDark),
                  _ContactOption(
                    icon: Icons.email_outlined,
                    label: isArabic ? 'راسلنا' : 'Email Us',
                    value: AppConstants.supportEmail,
                    onTap: () async {
                      final uri = Uri.parse(
                          'mailto:${AppConstants.supportEmail}');
                      if (await canLaunchUrl(uri)) await launchUrl(uri);
                    },
                  ),
                  Divider(height: 1, color: DozColors.borderDark),
                  _ContactOption(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: isArabic ? 'دردشة مباشرة' : 'Live Chat',
                    value: isArabic ? 'ابدأ محادثة' : 'Start chat',
                    onTap: () {
                      // TODO: open live chat
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              isArabic ? 'الأسئلة الشائعة' : 'Frequently Asked Questions',
              style: DozTextStyles.sectionTitle(isArabic: isArabic),
            ),
            const SizedBox(height: 12),

            ...faqs.map(
              (faq) => _FaqCard(faq: faq),
            ),

            const SizedBox(height: 24),

            // Links
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () async {
                    final uri = Uri.parse(AppConstants.termsUrl);
                    if (await canLaunchUrl(uri)) await launchUrl(uri);
                  },
                  child: Text(
                    l10n.t('termsAndConditions'),
                    style: DozTextStyles.bodySmall(
                      isArabic: isArabic,
                      color: DozColors.primaryGreen,
                    ),
                  ),
                ),
                Text('·',
                    style: DozTextStyles.bodySmall(isArabic: false,
                        color: DozColors.textMuted)),
                TextButton(
                  onPressed: () async {
                    final uri = Uri.parse(AppConstants.privacyUrl);
                    if (await canLaunchUrl(uri)) await launchUrl(uri);
                  },
                  child: Text(
                    l10n.t('privacyPolicy'),
                    style: DozTextStyles.bodySmall(
                      isArabic: isArabic,
                      color: DozColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ContactOption({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: DozColors.primaryGreenSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: DozColors.primaryGreen, size: 20),
      ),
      title: Text(
        label,
        style: DozTextStyles.bodyMedium(isArabic: isArabic)
            .copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(value, style: DozTextStyles.caption(isArabic: isArabic)),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: DozColors.textMuted, size: 20),
      onTap: onTap,
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}

class _FaqCard extends StatefulWidget {
  final _FaqItem faq;

  const _FaqCard({required this.faq});

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;

    return DozCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.zero,
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.faq.question,
                    style: DozTextStyles.bodyMedium(isArabic: isArabic)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: DozColors.textMuted,
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            Divider(height: 1, color: DozColors.borderDark),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.faq.answer,
                style: DozTextStyles.bodyMedium(
                  isArabic: isArabic,
                  color: DozColors.textMuted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
