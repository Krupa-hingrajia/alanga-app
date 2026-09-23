import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitTicket() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _submitting = false);
      _subjectController.clear();
      _messageController.clear();

      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 24),
              SizedBox(width: 8),
              Text('Inquiry Submitted', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Thank you for reaching out! Our dedicated vendor partner team will respond to your registered email address within 24 hours.',
            style: TextStyle(fontSize: 13, color: Color(0xFF4C6656), height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3827),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Seller Support',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF11261B),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF11261B), size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Support Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A3827), Color(0xFF28593E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A3827).withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'We are here to help!',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Get in touch with our merchant operations team for catalogue, order, or technical assistance.',
                      style: TextStyle(color: Color(0xFFD1DDD6), fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Contact Channels
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildContactTile(
                      Icons.email_outlined,
                      'Email Support',
                      'support@alanga.com',
                      'Typically responds in 2 hours',
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F2)),
                    _buildContactTile(
                      Icons.phone_in_talk_outlined,
                      'Helpline',
                      '+91 1800 252 642',
                      'Mon - Sat: 9:00 AM - 7:00 PM IST',
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F2)),
                    _buildContactTile(
                      Icons.language_outlined,
                      'Online Help Center',
                      'https://alanga.com/vendor-support',
                      'Guides, tutorials & platform FAQs',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Inquiry Form
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Send an Inquiry',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF11261B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Submit your question and our support team will get back to you.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _subjectController,
                        decoration: InputDecoration(
                          labelText: 'Subject',
                          hintText: 'e.g., Order fulfillment query',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          isDense: true,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Please enter a subject';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _messageController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Message',
                          hintText: 'Describe your issue or question in detail...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Please enter your message';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _submitting ? null : _submitTicket,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A3827),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: _submitting
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('SUBMIT INQUIRY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // FAQs
              const Text(
                'Frequently Asked Questions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
              ),
              const SizedBox(height: 12),
              _buildFaqItem(
                'How do I add new products to my catalogue?',
                'Navigate to the Products tab at the bottom and tap "+ Add Product". Provide product title, brand, category, pricing, and upload images.',
              ),
              _buildFaqItem(
                'How does account deletion work?',
                'Under Settings > Delete Account, you can permanently delete your vendor account. This wipes your session and credentials in compliance with Apple guidelines.',
              ),
              _buildFaqItem(
                'When do I receive customer order notifications?',
                'New orders trigger instant in-app alerts and notifications in the Orders tab for immediate dispatch and management.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactTile(IconData icon, String title, String subtitle, String footnote) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1A3827).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF1A3827), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF11261B))),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF28593E))),
                const SizedBox(height: 2),
                Text(footnote, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF11261B)),
        ),
        iconColor: const Color(0xFF1A3827),
        collapsedIconColor: const Color(0xFF8B9E94),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        children: [
          Text(
            answer,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF4C6656), height: 1.4),
          ),
        ],
      ),
    );
  }
}
