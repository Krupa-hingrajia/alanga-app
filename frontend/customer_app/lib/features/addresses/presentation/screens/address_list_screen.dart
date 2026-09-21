import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../data/models/address_model.dart';
import '../bloc/address_cubit.dart';
import '../bloc/address_state.dart';
import '../widgets/address_card.dart';
import '../widgets/add_edit_address_bottom_sheet.dart';
import '../widgets/address_confirmation_dialog.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AddressCubit>().fetchAddresses();
  }

  void _openAddEditBottomSheet([AddressModel? address]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddEditAddressBottomSheet(address: address),
    );
  }

  Future<void> _handleDeleteAddress(AddressModel address) async {
    final confirmed = await AddressConfirmationDialog.show(
      context,
      title: 'Delete Address?',
      message:
          'Are you sure you want to delete the address for "${address.fullName}"? ${address.isDefault ? "Since this is your default address, another address will be set as default automatically." : ""}',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<AddressCubit>().deleteAddress(address.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Address deleted successfully'),
              backgroundColor: AppColors.primaryGreen,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: AppColors.brandRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleSetDefault(AddressModel address) async {
    try {
      await context.read<AddressCubit>().setDefaultAddress(address.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${address.fullName} is now set as your default delivery address.'),
            backgroundColor: AppColors.primaryGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.brandRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F4),
      appBar: AppBar(
        title: const Text(
          'My Addresses',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF11261B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF11261B)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primaryGreen, size: 24),
            tooltip: 'Add Address',
            onPressed: () => _openAddEditBottomSheet(),
          ),
        ],
      ),
      body: BlocBuilder<AddressCubit, AddressState>(
        builder: (context, state) {
          if (state is AddressLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (state is AddressError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.brandRed),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF4C6656)),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<AddressCubit>().fetchAddresses(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is AddressLoaded) {
            final addresses = state.addresses;

            if (addresses.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.location_off_outlined,
                title: 'No Address Added Yet',
                description: 'Add your delivery address to enjoy fast and hassle-free checkout.',
                buttonText: 'Add Address',
                onButtonPressed: () => _openAddEditBottomSheet(),
              );
            }

            return RefreshIndicator(
              color: AppColors.primaryGreen,
              onRefresh: () => context.read<AddressCubit>().fetchAddresses(),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  return AddressCard(
                    address: address,
                    onEdit: () => _openAddEditBottomSheet(address),
                    onDelete: () => _handleDeleteAddress(address),
                    onSetDefault: !address.isDefault ? () => _handleSetDefault(address) : null,
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.darkGreen.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openAddEditBottomSheet(),
              icon: const Icon(Icons.add_location_alt_outlined, size: 20),
              label: const Text(
                'ADD NEW ADDRESS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
