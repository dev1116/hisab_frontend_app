import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../model/invoice_model.dart';
import '../provider/invoice_service.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final int businessId;
  final InvoiceModel invoice;

  const InvoiceDetailScreen({
    super.key,
    required this.businessId,
    required this.invoice,
  });

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  late InvoiceModel _invoice;
  bool _refreshNeeded = false;

  @override
  void initState() {
    super.initState();
    _invoice = widget.invoice;
  }

  Future<void> _openPdf(String url) async {
    final uri = Uri.parse('http://localhost:8082$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
  }

  Future<void> _showPaymentDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Record Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Remaining: ₹${_invoice.remainingAmount.toStringAsFixed(2)}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Payment Amount',
                prefixIcon: const Icon(Icons.currency_rupee, size: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              Navigator.pop(context, amount);
            },
            child: const Text('Record'),
          ),
        ],
      ),
    );

    if (result != null && result > 0) {
      try {
        final updated = await InvoiceService().recordPayment(
          businessId: widget.businessId,
          invoiceId: _invoice.id,
          amount: result,
        );
        setState(() {
          _invoice = updated;
          _refreshNeeded = true;
        });
        _showSnack('Payment recorded!');
      } catch (e) {
        _showSnack('Failed to record payment', isError: true);
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inv = _invoice;

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
              inv.invoiceNumber,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimary : AppColors.textDark,
              ),
            ),
            if (inv.billNumber != null)
              Text(
                'Bill #${inv.billNumber}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        actions: [
          if (inv.status != 'PAID' && inv.status != 'CANCELLED')
            IconButton(
              icon: const Icon(Icons.payments_outlined, size: 20),
              color: AppColors.success,
              onPressed: _showPaymentDialog,
              tooltip: 'Record Payment',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Status + Amount ────────────────────────────
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
                    _StatusChip(status: inv.status, color: inv.statusColor),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${inv.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        if (inv.remainingAmount > 0)
                          Text(
                            'Due: ₹${inv.remainingAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: inv.isOverdue
                                  ? AppColors.error
                                  : AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                // Payment progress
                if (inv.paidAmount > 0) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Paid: ₹${inv.paidAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${((inv.paidAmount / inv.totalAmount) * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: inv.paidAmount / inv.totalAmount,
                      backgroundColor: AppColors.success.withValues(
                        alpha: 0.15,
                      ),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.success,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _InfoChip(
                        label: 'Issue Date',
                        value: inv.issueDate,
                        icon: Icons.calendar_today_outlined,
                      ),
                    ),
                    if (inv.dueDate != null) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InfoChip(
                          label: 'Due Date',
                          value: inv.dueDate!,
                          icon: Icons.event_outlined,
                          color: inv.isOverdue ? AppColors.error : null,
                        ),
                      ),
                    ],
                  ],
                ),

                if (inv.billDate != null) ...[
                  const SizedBox(height: 10),
                  _InfoChip(
                    label: 'Bill Date',
                    value: inv.billDate!,
                    icon: Icons.receipt_outlined,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Record Payment CTA ─────────────────────────
          if (inv.status != 'PAID' && inv.status != 'CANCELLED')
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _showPaymentDialog,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        color: AppColors.success,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Record Payment',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.success,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (inv.status != 'PAID' && inv.status != 'CANCELLED')
            const SizedBox(height: 20),

          // ── Invoice Details ────────────────────────────
          _sectionLabel('Invoice Details'),
          const SizedBox(height: 12),
          _DetailCard(
            isDark: isDark,
            children: [
              _DetailRow(label: 'Title', value: inv.title),
              if (inv.description != null && inv.description!.isNotEmpty)
                _DetailRow(label: 'Description', value: inv.description!),
              _DetailRow(
                label: 'Amount',
                value: '₹${inv.amount.toStringAsFixed(2)}',
              ),
              if (inv.taxAmount != null)
                _DetailRow(
                  label: 'Tax',
                  value: '₹${inv.taxAmount!.toStringAsFixed(2)}',
                ),
              _DetailRow(
                label: 'Total',
                value: '₹${inv.totalAmount.toStringAsFixed(2)}',
                highlight: true,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Customer Details ───────────────────────────
          if (inv.customerName != null) ...[
            _sectionLabel('Customer Details'),
            const SizedBox(height: 12),
            _DetailCard(
              isDark: isDark,
              children: [
                _DetailRow(label: 'Name', value: inv.customerName!),
                if (inv.addressLine1 != null && inv.addressLine1!.isNotEmpty)
                  _DetailRow(label: 'Address', value: inv.addressLine1!),
                if (inv.addressLine2 != null && inv.addressLine2!.isNotEmpty)
                  _DetailRow(label: '', value: inv.addressLine2!),
                if (inv.city != null && inv.city!.isNotEmpty)
                  _DetailRow(
                    label: 'City / State',
                    value:
                        '${inv.city}${inv.state != null ? ', ${inv.state}' : ''}',
                  ),
                if (inv.pincode != null && inv.pincode!.isNotEmpty)
                  _DetailRow(label: 'Pincode', value: inv.pincode!),
                if (inv.country != null && inv.country!.isNotEmpty)
                  _DetailRow(label: 'Country', value: inv.country!),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // ── Notes ──────────────────────────────────────
          if (inv.notes != null && inv.notes!.isNotEmpty) ...[
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
                inv.notes!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── PDF ────────────────────────────────────────
          if (inv.pdfUrl != null && inv.pdfUrl!.isNotEmpty) ...[
            _sectionLabel('Document'),
            const SizedBox(height: 12),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _openPdf(inv.pdfUrl!),
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
                              inv.pdfOriginalName ?? 'Invoice PDF',
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
          ],

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
  final Color? color;
  const _InfoChip({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.06),
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
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: c,
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
