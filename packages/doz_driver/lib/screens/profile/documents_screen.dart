import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doz_shared/doz_shared.dart';

enum DocumentStatus { notUploaded, pending, approved, rejected }

class _DocumentItem {
  final String key;
  final String arLabel;
  final String enLabel;
  final IconData icon;
  DocumentStatus status;

  _DocumentItem({required this.key, required this.arLabel, required this.enLabel, required this.icon, this.status = DocumentStatus.notUploaded});
}

/// Documents screen for uploading and managing driver documents.
class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final List<_DocumentItem> _documents = [
    _DocumentItem(key: 'license', arLabel: 'رخصة القيادة', enLabel: "Driver's License", icon: Icons.credit_card, status: DocumentStatus.pending),
    _DocumentItem(key: 'id', arLabel: 'بطاقة الهوية', enLabel: 'National ID', icon: Icons.badge_outlined, status: DocumentStatus.approved),
    _DocumentItem(key: 'registration', arLabel: 'استمارة المركبة', enLabel: 'Vehicle Registration', icon: Icons.article_outlined),
    _DocumentItem(key: 'insurance', arLabel: 'وثيقة التأمين', enLabel: 'Insurance', icon: Icons.security),
  ];

  Future<void> _uploadDocument(int index) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    setState(() { _documents[index].status = DocumentStatus.pending; });
    if (mounted) {
      final l = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l.isArabic ? 'تم رفع المستند، في انتظار المراجعة' : 'Document uploaded, pending review'),
        backgroundColor: DozColors.info,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      appBar: AppBar(
        backgroundColor: DozColors.surfaceDark,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: DozColors.textPrimary, size: 20),
        ),
        title: Text(isAr ? 'المستندات' : 'Documents', style: DozTextStyles.sectionTitle(isArabic: isAr)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: DozColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DozColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: DozColors.info, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(
                    isAr ? 'يجب رفع جميع المستندات للحصول على الموافقة' : 'All documents must be uploaded for approval',
                    style: DozTextStyles.bodySmall(isArabic: isAr, color: DozColors.info),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ..._documents.asMap().entries.map((e) {
              final i = e.key;
              final doc = e.value;
              return _DocumentCard(document: doc, isAr: isAr, onUpload: () => _uploadDocument(i));
            }),
          ],
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final _DocumentItem document;
  final bool isAr;
  final VoidCallback onUpload;

  const _DocumentCard({required this.document, required this.isAr, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DozColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusInfo.borderColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: statusInfo.iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(document.icon, color: statusInfo.iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isAr ? document.arLabel : document.enLabel, style: DozTextStyles.labelLarge(isArabic: isAr)),
                Text(statusInfo.label, style: DozTextStyles.caption(isArabic: isAr).copyWith(color: statusInfo.iconColor)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onUpload,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: document.status == DocumentStatus.notUploaded ? DozColors.primaryGreen : DozColors.cardDark,
                borderRadius: BorderRadius.circular(8),
                border: document.status != DocumentStatus.notUploaded ? Border.all(color: DozColors.borderDark) : null,
              ),
              child: Text(
                document.status == DocumentStatus.notUploaded ? (isAr ? 'رفع' : 'Upload') : (isAr ? 'تحديث' : 'Update'),
                style: DozTextStyles.buttonSmall(isArabic: isAr, color: document.status == DocumentStatus.notUploaded ? DozColors.primaryDark : DozColors.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ({String label, Color iconColor, Color iconBg, Color borderColor}) _getStatusInfo() {
    switch (document.status) {
      case DocumentStatus.approved:
        return (label: isAr ? 'تمت الموافقة' : 'Approved', iconColor: DozColors.success, iconBg: DozColors.success.withOpacity(0.1), borderColor: DozColors.success.withOpacity(0.3));
      case DocumentStatus.pending:
        return (label: isAr ? 'قيد المراجعة' : 'Under Review', iconColor: DozColors.warning, iconBg: DozColors.warning.withOpacity(0.1), borderColor: DozColors.warning.withOpacity(0.3));
      case DocumentStatus.rejected:
        return (label: isAr ? 'مرفوض - يرجى إعادة الرفع' : 'Rejected - Please re-upload', iconColor: DozColors.error, iconBg: DozColors.error.withOpacity(0.1), borderColor: DozColors.error.withOpacity(0.3));
      default:
        return (label: isAr ? 'لم يُرفع بعد' : 'Not uploaded', iconColor: DozColors.textMuted, iconBg: DozColors.cardDark, borderColor: DozColors.borderDark);
    }
  }
}
