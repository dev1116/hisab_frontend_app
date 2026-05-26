import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hisab_app/core/network/api_client.dart';
import 'package:hisab_app/core/theme/app_theme.dart';
import 'package:hisab_app/features/quotations/model/quotation_model.dart';
import 'package:hisab_app/features/quotations/provider/quotation_service.dart';
import 'dart:typed_data';

class EditQuotationScreen extends StatefulWidget {
  final int businessId;
  final QuotationModel quotation;

  const EditQuotationScreen({
    super.key,
    required this.businessId,
    required this.quotation,
  });

  @override
  State<EditQuotationScreen> createState() => _EditQuotationScreenState();
}

class _EditQuotationScreenState extends State<EditQuotationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _desc;
  late final TextEditingController _amount;
  late final TextEditingController _tax;
  late final TextEditingController _total;
  late final TextEditingController _notes;
  late final TextEditingController _customerName;
  late final TextEditingController _address1;
  late final TextEditingController _address2;
  late final TextEditingController _pincode;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late final TextEditingController _country;

  Uint8List? _pdfBytes;
  String? _pdfName;
  DateTime? _validUntil;
  bool _saving = false;
  bool _fetchingPincode = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill existing data
    final q = widget.quotation;
    _title = TextEditingController(text: q.title);
    _desc = TextEditingController(text: q.description ?? '');
    _amount = TextEditingController(text: q.amount.toString());
    _tax = TextEditingController(text: q.taxAmount?.toString() ?? '');
    _total = TextEditingController(text: q.totalAmount.toString());
    _notes = TextEditingController(text: q.notes ?? '');
    _customerName = TextEditingController(text: q.customerName ?? '');
    _address1 = TextEditingController(text: q.addressLine1 ?? '');
    _address2 = TextEditingController(text: q.addressLine2 ?? '');
    _pincode = TextEditingController(text: q.pincode ?? '');
    _city = TextEditingController(text: q.city ?? '');
    _state = TextEditingController(text: q.state ?? '');
    _country = TextEditingController(text: q.country ?? 'India');

    if (q.validUntil != null) {
      _validUntil = DateTime.tryParse(q.validUntil!);
    }

    _amount.addListener(_calcTotal);
    _tax.addListener(_calcTotal);
    _pincode.addListener(() {
      if (_pincode.text.length == 6) _fetchPincodeDetails(_pincode.text);
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _amount.dispose();
    _tax.dispose();
    _total.dispose();
    _notes.dispose();
    _customerName.dispose();
    _address1.dispose();
    _address2.dispose();
    _pincode.dispose();
    _city.dispose();
    _state.dispose();
    _country.dispose();
    super.dispose();
  }

  void _calcTotal() {
    final a = double.tryParse(_amount.text) ?? 0;
    final t = double.tryParse(_tax.text) ?? 0;
    _total.text = (a + t).toStringAsFixed(2);
  }

  Future<void> _pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null) {
      setState(() {
        _pdfBytes = result.files.single.bytes;
        _pdfName = result.files.single.name;
      });
    }
  }

  Future<void> _fetchPincodeDetails(String pincode) async {
    setState(() => _fetchingPincode = true);
    try {
      final response = await ApiClient.dio.get('/utils/pincode/$pincode');
      if (!mounted) return;
      setState(() {
        _city.text = response.data['city'] ?? '';
        _state.text = response.data['state'] ?? '';
      });
    } catch (e) {
      if (mounted) _showSnack('Invalid pincode', isError: true);
    } finally {
      if (mounted) setState(() => _fetchingPincode = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final service = QuotationService();
      await service.reviseQuotation(
        businessId: widget.businessId,
        quotationId: widget.quotation.id,
        data: {
          'customerName': _customerName.text.isEmpty
              ? null
              : _customerName.text,
          'title': _title.text,
          'description': _desc.text.isEmpty ? null : _desc.text,
          'amount': double.parse(_amount.text),
          'taxAmount': double.tryParse(_tax.text),
          'totalAmount': double.parse(_total.text),
          'validUntil': _validUntil?.toIso8601String().split('T').first,
          'notes': _notes.text.isEmpty ? null : _notes.text,
          'addressLine1': _address1.text.isEmpty ? null : _address1.text,
          'addressLine2': _address2.text.isEmpty ? null : _address2.text,
          'pincode': _pincode.text.isEmpty ? null : _pincode.text,
          'city': _city.text.isEmpty ? null : _city.text,
          'state': _state.text.isEmpty ? null : _state.text,
          'country': _country.text.isEmpty ? null : _country.text,
        },
        pdfBytes: _pdfBytes,
        pdfName: _pdfName,
      );

      if (!mounted) return;
      _showSnack('Quotation revised — new version created!');
      Navigator.pop(context, true); // true = refresh list
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revise Quotation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimary : AppColors.textDark,
              ),
            ),
            Text(
              '${widget.quotation.quoteNumber} → v${widget.quotation.version + 1}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Version info banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: AppColors.warning.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Current version v${widget.quotation.version} will be archived. A new version will be created.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ── Customer Details ─────────────────────
                  _sectionLabel('Customer Details'),
                  const SizedBox(height: 10),
                  _field(
                    _customerName,
                    'Customer Name',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    _address1,
                    'Address Line 1',
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    _address2,
                    'Address Line 2',
                    icon: Icons.home_outlined,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _pincodeField(isDark)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _field(
                          _city,
                          'City',
                          icon: Icons.location_city_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          _state,
                          'State',
                          icon: Icons.map_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _field(_country, 'Country', icon: Icons.public),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Quotation Details ────────────────────
                  _sectionLabel('Quotation Details'),
                  const SizedBox(height: 10),
                  _field(
                    _title,
                    'Title *',
                    icon: Icons.title,
                    validator: (v) => v!.isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 12),
                  _field(_desc, 'Description', icon: Icons.notes, maxLines: 3),

                  const SizedBox(height: 24),

                  // ── Pricing ──────────────────────────────
                  _sectionLabel('Pricing'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          _amount,
                          'Amount *',
                          icon: Icons.currency_rupee,
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _field(
                          _tax,
                          'Tax Amount',
                          icon: Icons.percent,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Total highlighted
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        ValueListenableBuilder(
                          valueListenable: _total,
                          builder: (_, __, ___) => Text(
                            '₹ ${_total.text.isEmpty ? '0.00' : _total.text}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Additional Info ──────────────────────
                  _sectionLabel('Additional Info'),
                  const SizedBox(height: 10),

                  // Valid Until
                  GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate:
                            _validUntil ??
                            DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (d != null) setState(() => _validUntil = d);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _validUntil != null
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: _validUntil != null
                                ? AppColors.primary
                                : AppColors.textHint,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _validUntil == null
                                ? 'Valid Until (optional)'
                                : 'Valid Until: ${_validUntil!.toIso8601String().split('T').first}',
                            style: TextStyle(
                              color: _validUntil == null
                                  ? AppColors.textHint
                                  : AppColors.primary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _field(
                    _notes,
                    'Notes',
                    icon: Icons.sticky_note_2_outlined,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),

                  // PDF — show existing + option to replace
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface
                          : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _pdfBytes != null
                            ? AppColors.success
                            : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Existing PDF info
                        if (widget.quotation.pdfUrl != null &&
                            _pdfBytes == null)
                          Row(
                            children: [
                              const Icon(
                                Icons.picture_as_pdf_rounded,
                                size: 16,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.quotation.pdfOriginalName ??
                                      'Current PDF',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Text(
                                'Existing',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textHint,
                                ),
                              ),
                            ],
                          ),

                        if (widget.quotation.pdfUrl != null &&
                            _pdfBytes == null)
                          const SizedBox(height: 8),

                        // Replace button
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: _pickPDF,
                            child: Row(
                              children: [
                                Icon(
                                  _pdfBytes != null
                                      ? Icons.check_circle_rounded
                                      : Icons.upload_file_rounded,
                                  size: 16,
                                  color: _pdfBytes != null
                                      ? AppColors.success
                                      : AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _pdfBytes != null
                                      ? _pdfName!
                                      : widget.quotation.pdfUrl != null
                                      ? 'Replace PDF'
                                      : 'Upload PDF (optional)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _pdfBytes != null
                                        ? AppColors.success
                                        : AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),

            // ── Bottom Submit Button ──────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBg : AppColors.lightBg,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save Revision'),
                ),
              ),
            ),
          ],
        ),
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

  Widget _pincodeField(bool isDark) {
    return TextFormField(
      controller: _pincode,
      keyboardType: TextInputType.number,
      maxLength: 6,
      style: TextStyle(
        color: isDark ? AppColors.textPrimary : AppColors.textDark,
      ),
      decoration: InputDecoration(
        labelText: 'Pincode',
        labelStyle: TextStyle(color: AppColors.textHint),
        prefixIcon: Icon(
          Icons.pin_drop_outlined,
          color: AppColors.textHint,
          size: 18,
        ),
        suffixIcon: _fetchingPincode
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
        counterText: '',
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    IconData? icon,
    int maxLines = 1,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: isDark ? AppColors.textPrimary : AppColors.textDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textHint),
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.textHint, size: 18)
            : null,
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
