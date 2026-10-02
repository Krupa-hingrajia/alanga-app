import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/models/vendor_order_model.dart';

class OrderDocumentGenerator {
  /// Format date to readable string
  static String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  /// 1. Generate Standard 4x6" Shipping Label Document
  static Future<pw.Document> generateShippingLabelDoc(VendorOrderModel order) async {
    final doc = pw.Document();

    final isCod = order.paymentMethod.toUpperCase() == 'COD';
    final customerName = order.address?.fullName.isNotEmpty == true
        ? order.address!.fullName
        : (order.customer?.fullName ?? 'Valued Customer');
    final customerPhone = order.address?.mobileNumber.isNotEmpty == true
        ? order.address!.mobileNumber
        : (order.customer?.phoneNumber ?? 'N/A');
    final formattedAddr = order.address?.formattedAddress ?? 'Address Not Specified';
    final pincode = order.address?.postalCode ?? '';
    final courierName = order.courierName ?? 'ALANGA LOGISTICS';
    final trackingNo = order.trackingNumber ?? order.orderNumber;

    doc.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(100 * PdfPageFormat.mm, 150 * PdfPageFormat.mm, marginAll: 6 * PdfPageFormat.mm),
        build: (pw.Context ctx) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 1.5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Top Header: Marketplace & Courier
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  color: PdfColors.black,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'ALANGA MARKETPLACE',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        courierName.toUpperCase(),
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Order Number & Barcode
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'AWB / ORDER: $trackingNo',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 4),
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.code128(),
                        data: trackingNo,
                        height: 38,
                        drawText: false,
                      ),
                    ],
                  ),
                ),

                pw.Divider(height: 1, thickness: 1, color: PdfColors.black),

                // Payment Badge (COD vs PREPAID)
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  color: isCod ? PdfColors.grey200 : PdfColors.white,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        isCod ? 'CASH ON DELIVERY (COD)' : 'PREPAID',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: isCod ? PdfColors.red900 : PdfColors.green900,
                        ),
                      ),
                      pw.Text(
                        isCod
                            ? 'COLLECT: Rs. ${order.vendorGrandTotal.toStringAsFixed(0)}'
                            : 'DO NOT COLLECT CASH',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.Divider(height: 1, thickness: 1, color: PdfColors.black),

                // SHIP TO (Recipient Details)
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'SHIP TO:',
                          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          customerName,
                          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Phone: $customerPhone',
                          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          formattedAddr,
                          style: const pw.TextStyle(fontSize: 9.5),
                          maxLines: 4,
                        ),
                        pw.Spacer(),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('PIN: $pincode', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                            pw.Text('Date: ${_formatDate(order.createdAt)}', style: const pw.TextStyle(fontSize: 9)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                pw.Divider(height: 1, thickness: 1, color: PdfColors.black),

                // ITEMS SUMMARY
                pw.Container(
                  padding: const pw.EdgeInsets.all(6),
                  color: PdfColors.grey100,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Item Description', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Qty', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.SizedBox(height: 3),
                      ...order.orderItems.map((item) {
                        final vDesc = item.variantName != null ? ' (${item.variantName})' : '';
                        return pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 2),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Expanded(
                                child: pw.Text(
                                  '${item.productName}$vDesc',
                                  style: const pw.TextStyle(fontSize: 8),
                                  maxLines: 1,
                                ),
                              ),
                              pw.Text('x${item.quantity}', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return doc;
  }

  /// Print / Preview Standard 4x6" Shipping Label
  static Future<void> printShippingLabel({
    required BuildContext context,
    required VendorOrderModel order,
  }) async {
    final doc = await generateShippingLabelDoc(order);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Shipping_Label_${order.orderNumber}.pdf',
    );
  }

  /// Share 4x6" Shipping Label PDF via WhatsApp / System Share
  static Future<void> shareShippingLabel({
    required BuildContext context,
    required VendorOrderModel order,
  }) async {
    final doc = await generateShippingLabelDoc(order);
    final bytes = await doc.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Shipping_Label_${order.orderNumber}.pdf',
    );
  }

  /// 2. Generate Standard A4 Tax Invoice Document
  static Future<pw.Document> generateTaxInvoiceDoc(VendorOrderModel order) async {
    final doc = pw.Document();

    final customerName = order.address?.fullName.isNotEmpty == true
        ? order.address!.fullName
        : (order.customer?.fullName ?? 'Valued Customer');
    final customerPhone = order.address?.mobileNumber.isNotEmpty == true
        ? order.address!.mobileNumber
        : (order.customer?.phoneNumber ?? 'N/A');
    final formattedAddr = order.address?.formattedAddress ?? 'Address Not Specified';

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Top Brand & Document Title
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'ALANGA',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('1A3827'),
                        ),
                      ),
                      pw.Text(
                        'Verified Vendor Invoice',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'TAX INVOICE',
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Invoice #: INV-${order.orderNumber}',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Date: ${_formatDate(order.createdAt)}',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 16),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 12),

              // Seller and Buyer Details
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'SOLD BY:',
                          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('Alanga Authorized Seller', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Fulfillment via Alanga Logistics Platform', style: const pw.TextStyle(fontSize: 9.5)),
                        pw.Text('GST Status: Registered Taxable Person', style: const pw.TextStyle(fontSize: 9.5)),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 24),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BILL TO / SHIP TO:',
                          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(customerName, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Phone: $customerPhone', style: const pw.TextStyle(fontSize: 9.5)),
                        pw.Text(formattedAddr, style: const pw.TextStyle(fontSize: 9.5)),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Items Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.8),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(5),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(2.5),
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColor.fromHex('F3F5F4')),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('#', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Item Description', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Rate', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Qty', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Amount', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                      ),
                    ],
                  ),
                  // Table Rows
                  ...order.orderItems.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final item = entry.value;
                    final vDesc = item.variantName != null ? ' - ${item.variantName}' : '';
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('$idx', style: const pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('${item.productName}$vDesc', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
                              if (item.sku != null && item.sku!.isNotEmpty)
                                pw.Text('SKU: ${item.sku}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                            ],
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('Rs. ${item.unitPrice.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.right),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('${item.quantity}', style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.center),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('Rs. ${(item.unitPrice * item.quantity).toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                        ),
                      ],
                    );
                  }),
                ],
              ),

              pw.SizedBox(height: 16),

              // Summary Calculations
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 5,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Payment Mode: ${order.paymentMethod.toUpperCase()}',
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'Payment Status: ${order.paymentStatus.toUpperCase()}',
                            style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey700),
                          ),
                          if (order.trackingNumber != null && order.trackingNumber!.isNotEmpty) ...[
                            pw.SizedBox(height: 3),
                            pw.Text(
                              'Courier / AWB: ${order.courierName ?? "Standard"} - ${order.trackingNumber}',
                              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                    flex: 5,
                    child: pw.Column(
                      children: [
                        _buildInvoiceSummaryRow('Items Subtotal:', 'Rs. ${order.vendorItemsTotal.toStringAsFixed(2)}'),
                        _buildInvoiceSummaryRow('Shipping Charges:', 'Rs. ${order.vendorShippingTotal.toStringAsFixed(2)}'),
                        pw.Divider(thickness: 1, color: PdfColors.grey300),
                        _buildInvoiceSummaryRow(
                          'Total Payable:',
                          'Rs. ${order.vendorGrandTotal.toStringAsFixed(2)}',
                          isBold: true,
                          fontSize: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // Signatory & Legal Footer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'This is a computer generated invoice and does not require physical signature.',
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(
                        width: 120,
                        height: 35,
                        alignment: pw.Alignment.bottomCenter,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 1)),
                        ),
                        child: pw.Text('Authorized Signatory', style: const pw.TextStyle(fontSize: 8)),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('For Alanga Marketplace Seller', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return doc;
  }

  /// Print / Preview Standard A4 Tax Invoice
  static Future<void> printTaxInvoice({
    required BuildContext context,
    required VendorOrderModel order,
  }) async {
    final doc = await generateTaxInvoiceDoc(order);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Tax_Invoice_${order.orderNumber}.pdf',
    );
  }

  /// Share Standard A4 Tax Invoice PDF via WhatsApp / System Share
  static Future<void> shareTaxInvoice({
    required BuildContext context,
    required VendorOrderModel order,
  }) async {
    final doc = await generateTaxInvoiceDoc(order);
    final bytes = await doc.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Tax_Invoice_${order.orderNumber}.pdf',
    );
  }

  static pw.Widget _buildInvoiceSummaryRow(String label, String value, {bool isBold = false, double fontSize = 10}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isBold ? PdfColors.black : PdfColors.grey800,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isBold ? PdfColor.fromHex('1A3827') : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
