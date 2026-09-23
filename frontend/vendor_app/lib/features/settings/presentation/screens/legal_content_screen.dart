import 'package:flutter/material.dart';

enum LegalContentType { privacyPolicy, termsOfService }

class LegalContentScreen extends StatelessWidget {
  final LegalContentType type;

  const LegalContentScreen({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final isPrivacy = type == LegalContentType.privacyPolicy;
    final title = isPrivacy ? 'Privacy Policy' : 'Terms & Conditions';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
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
          child: Container(
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
            child: isPrivacy ? _buildPrivacyContent() : _buildTermsContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ALANGA Vendor Privacy Policy',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
        ),
        const SizedBox(height: 4),
        const Text(
          'Effective Date: September 2026 | Version 1.0.2',
          style: TextStyle(fontSize: 12, color: Color(0xFF8B9E94)),
        ),
        const Divider(height: 28),

        _buildSection(
          '1. Overview',
          'Alanga ("we", "our", or "us") is dedicated to safeguarding your privacy. This policy explains how we collect, use, and process information from vendors who use our Vendor Application and seller marketplace services.',
        ),
        _buildSection(
          '2. Information We Collect',
          '• Personal & Business Information: Name, email address, mobile phone number, business address, and store identifiers.\n• Catalogue & Product Details: Product titles, descriptions, pricing, inventory stock counts, and product imagery uploaded by you.\n• Order & Fulfilment Data: Shipping statuses, dispatch dates, customer order numbers, and settlement receipts.\n• Device & App Diagnostics: Operating system version, app performance logs, and error telemetry.',
        ),
        _buildSection(
          '3. How We Use Your Data',
          'We use the gathered information strictly to:\n• Facilitate your merchant account operations and marketplace listings.\n• Process customer orders and provide inventory tracking.\n• Communicate administrative updates, order statuses, and platform security notices.\n• Comply with statutory legal obligations and commercial regulations.',
        ),
        _buildSection(
          '4. In-App Account Deletion (Apple Guideline 5.1.1(v))',
          'Vendors have the absolute right to delete their account at any time directly within the application under Settings > Delete Account. Upon requesting account deletion, all active credentials, tokens, and store data are permanently removed or anonymized from our production systems.',
        ),
        _buildSection(
          '5. Security of Your Data',
          'We utilize industry-standard cryptographic protocols including HTTPS/TLS encryption in transit and AES-256 for sensitive stored tokens. Authentication secrets are stored securely in the device Keychain / Secure Enclave.',
        ),
        _buildSection(
          '6. Contact & Data Protection Officer',
          'For questions or privacy concerns, contact our privacy officer at:\nEmail: privacy@alanga.com\nSupport Portal: https://alanga.com/support\nAddress: Alanga Marketplace Technologies Inc.',
        ),
      ],
    );
  }

  Widget _buildTermsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ALANGA Vendor Terms & Conditions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF11261B)),
        ),
        const SizedBox(height: 4),
        const Text(
          'Effective Date: September 2026 | Version 1.0.2',
          style: TextStyle(fontSize: 12, color: Color(0xFF8B9E94)),
        ),
        const Divider(height: 28),

        _buildSection(
          '1. Acceptance of Terms',
          'By registering and operating as a vendor on the Alanga Vendor platform, you agree to comply with these terms, our marketplace rules, and applicable regional trade laws.',
        ),
        _buildSection(
          '2. Vendor Eligibility & Store Listing',
          'Vendors must supply accurate business and contact details during registration. You represent that all products, brands, and goods listed through your vendor portal comply with regional quality standards and intellectual property rights.',
        ),
        _buildSection(
          '3. Pricing, Orders & Fulfilment',
          'Vendors are solely responsible for ensuring accurate product prices, shipping policies, stock availability, and timely order fulfillment. Cancellations or defective items may impact your vendor rating and marketplace privileges.',
        ),
        _buildSection(
          '4. Account Termination & Deletion',
          'You may terminate your merchant agreement at any time by deleting your account via the mobile application or contacting seller support. Outstanding financial settlements will be processed in accordance with the vendor agreement.',
        ),
        _buildSection(
          '5. Limitation of Liability',
          'Alanga provides the marketplace platform on an "as is" and "as available" basis. We are not liable for incidental or consequential damages resulting from platform downtime, service interruptions, or third-party logistics.',
        ),
        _buildSection(
          '6. Inquiries & Legal Notices',
          'Legal inquiries may be sent to legal@alanga.com or through Alanga Seller Support at support@alanga.com.',
        ),
      ],
    );
  }

  Widget _buildSection(String heading, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF11261B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4C6656),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
