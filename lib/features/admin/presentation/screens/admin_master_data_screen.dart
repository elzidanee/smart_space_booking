import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'admin_discounts_screen.dart';
import 'admin_members_screen.dart';
import 'admin_spaces_screen.dart';

class AdminMasterDataScreen extends StatefulWidget {
  final int initialTabIndex;

  const AdminMasterDataScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<AdminMasterDataScreen> createState() => _AdminMasterDataScreenState();
}

class _AdminMasterDataScreenState extends State<AdminMasterDataScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface50,
      appBar: AppBar(
        title: const Text('Master Data Hub'),
        backgroundColor: AppColors.surface0,
        elevation: 0,
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          indicatorWeight: 3,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.ink600,
          labelStyle: AppTypography.captionMedium.copyWith(fontWeight: FontWeight.bold),
          unselectedLabelStyle: AppTypography.caption,
          tabs: const [
            Tab(
              icon: Icon(Icons.meeting_room_outlined, size: 20),
              text: 'Space / Ruang',
            ),
            Tab(
              icon: Icon(Icons.people_outline, size: 20),
              text: 'Data Member',
            ),
            Tab(
              icon: Icon(Icons.discount_outlined, size: 20),
              text: 'Kode Promo',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AdminSpacesScreen(),
          AdminMembersScreen(),
          AdminDiscountsScreen(),
        ],
      ),
    );
  }
}
