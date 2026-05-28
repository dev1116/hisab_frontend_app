import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../model/quotation_model.dart';
import '../provider/quotation_service.dart';
import 'edit_quotation_screen.dart';

class QuotationDetailScreen extends StatefulWidget {
  final int businessId;
  final QuotationModel quotation;

  const QuotationDetailScreen({
    super.key,
    required this.businessId,
    required this.quotation,
  });

  @override
  State<QuotationDetailScreen> createState() => _QuotationDetailScreenState();
}

class _QuotationDetailScreenState extends State<QuotationDetailScreen> {
  List<QuotationModel> _history = [];
  bool _loadingHistory = true;
  bool _refreshNeeded = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final service = QuotationService();
      final data = await service.getVersionHistory(
        businessId: widget.businessId,
        quotationId: widget.quotation.id,
      );
      if (!mounted) return;
      setState(() {
        _history = data;
        _loadingHistory = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingHistory = false);
    }
  }

  Future<void> _openPdf(String url) async {
    final fullUrl = 'http://localhost:8082$url';
    final uri = Uri.parse(fullUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final q = widget.quotation;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () => Navigator.pop(context, _refreshNeeded),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              q.quoteNumber,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimary : AppColors.textDark,
              ),
            ),
            Text(
              'v${q.version} — ${q.status}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: AppColors.primary,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditQuotationScreen(
                    businessId: widget.businessId,
                    quotation: q,
                  ),
                ),
              );
              if (result == true) {
                _refreshNeeded = true;
                _loadHistory();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Status + Amount Card ───────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusChip(status: q.status, color: q.statusColor),
                    Text(
                      '₹${q.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _InfoChip(
                        label: 'Issue Date',
                        value: q.issueDate,
                        icon: Icons.calendar_today_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (q.validUntil != null)
                      Expanded(
                        child: _InfoChip(
                          label: 'Valid Until',
                          value: q.validUntil!,
                          icon: Icons.event_outlined,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Quotation Details ──────────────────────────────
          _sectionLabel('Quotation Details'),
          const SizedBox(height: 12),
          _DetailCard(
            isDark: isDark,
            children: [
              _DetailRow(label: 'Title', value: q.title),
              if (q.description != null && q.description!.isNotEmpty)
                _DetailRow(label: 'Description', value: q.description!),
              _DetailRow(
                label: 'Amount',
                value: '₹${q.amount.toStringAsFixed(2)}',
              ),
              if (q.taxAmount != null)
                _DetailRow(
                  label: 'Tax',
                  value: '₹${q.taxAmount!.toStringAsFixed(2)}',
                ),
              _DetailRow(
                label: 'Total',
                value: '₹${q.totalAmount.toStringAsFixed(2)}',
                highlight: true,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Customer Details ───────────────────────────────
          if (q.customerName != null) ...[
            _sectionLabel('Customer Details'),
            const SizedBox(height: 12),
            _DetailCard(
              isDark: isDark,
              children: [
                if (q.customerName != null)
                  _DetailRow(label: 'Name', value: q.customerName!),
                if (q.addressLine1 != null && q.addressLine1!.isNotEmpty)
                  _DetailRow(label: 'Address', value: q.addressLine1!),
                if (q.addressLine2 != null && q.addressLine2!.isNotEmpty)
                  _DetailRow(label: '', value: q.addressLine2!),
                if (q.city != null && q.city!.isNotEmpty)
                  _DetailRow(
                    label: 'City / State',
                    value: '${q.city}${q.state != null ? ', ${q.state}' : ''}',
                  ),
                if (q.pincode != null && q.pincode!.isNotEmpty)
                  _DetailRow(label: 'Pincode', value: q.pincode!),
                if (q.country != null && q.country!.isNotEmpty)
                  _DetailRow(label: 'Country', value: q.country!),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // ── Notes ─────────────────────────────────────────
          if (q.notes != null && q.notes!.isNotEmpty) ...[
            _sectionLabel('Notes'),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Text(
                q.notes!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── PDF ────────────────────────────────────────────
          if (q.pdfUrl != null && q.pdfUrl!.isNotEmpty) ...[
            _sectionLabel('Document'),
            const SizedBox(height: 12),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _openPdf(q.pdfUrl!),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: AppColors.error,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              q.pdfOriginalName ?? 'Quotation PDF',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                            const Text(
                              'Tap to open',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.open_in_new_rounded,
                        color: AppColors.error,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── Version History ────────────────────────────────
          _sectionLabel('Version History'),
          const SizedBox(height: 12),

          _loadingHistory
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              : _history.isEmpty
              ? const Text(
                  'No history found',
                  style: TextStyle(color: AppColors.textSecondary),
                )
              : Column(
                  children: _history.map((v) {
                    final isCurrent = v.id == q.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.primary.withValues(alpha: 0.06)
                            : (isDark
                                  ? AppColors.darkSurface
                                  : AppColors.lightSurface),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrent
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Version badge
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? AppColors.primary
                                  : AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'v${v.version}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isCurrent
                                      ? Colors.white
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '₹${v.totalAmount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppColors.textPrimary
                                            : AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _StatusChip(
                                      status: v.status,
                                      color: v.statusColor,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  v.createdAt.substring(0, 10),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Current badge
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Current',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                          // PDF icon
                          if (v.pdfUrl != null && v.pdfUrl!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => _openPdf(v.pdfUrl!),
                                child: const Icon(
                                  Icons.picture_as_pdf_rounded,
                                  color: AppColors.error,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusChip({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _InfoChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;
  const _DetailCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: children
            .asMap()
            .entries
            .map(
              (e) => Column(
                children: [
                  e.value,
                  if (e.key < children.length - 1)
                    Divider(
                      height: 1,
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _DetailRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                color: highlight
                    ? AppColors.primary
                    : (isDark ? AppColors.textPrimary : AppColors.textDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
