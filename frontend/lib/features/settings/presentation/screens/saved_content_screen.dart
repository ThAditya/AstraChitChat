import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/core/theme/app_colors.dart';
import 'package:chitchat/core/widgets/particle_background.dart';

class SavedContentScreen extends StatefulWidget {
  const SavedContentScreen({super.key});

  @override
  State<SavedContentScreen> createState() => _SavedContentScreenState();
}

class _SavedContentScreenState extends State<SavedContentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _collectionNameController = TextEditingController();

  final List<Map<String, dynamic>> _collections = [
    {'name': 'All', 'icon': Iconsax.grid_1_copy},
    {'name': 'Songs', 'icon': Iconsax.music_copy},
    {'name': 'Travel', 'icon': Iconsax.airplane_copy},
    {'name': 'Gaming', 'icon': Iconsax.game_copy},
    {'name': 'Study', 'icon': Iconsax.book_1_copy},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _collectionNameController.dispose();
    super.dispose();
  }

  void _showCreateCollectionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: GlassmorphicContainer(
              width: double.infinity,
              height: 300.h,
              borderRadius: 30.r,
              blur: 20,
              alignment: Alignment.center,
              border: 1,
              linearGradient: LinearGradient(
                colors: [Colors.black.withValues(alpha: 0.85), Colors.black.withValues(alpha: 0.95)],
              ),
              borderGradient: LinearGradient(
                colors: [AppColors.primaryNeon.withValues(alpha: 0.5), Colors.transparent],
              ),
              child: Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      "Create New Collection",
                      style: GoogleFonts.orbitron(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    TextField(
                      controller: _collectionNameController,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp),
                      decoration: InputDecoration(
                        hintText: "Collection Name (e.g. Travel, Study)",
                        hintStyle: GoogleFonts.inter(color: AppColors.textGrey, fontSize: 13.sp),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.08),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Iconsax.folder_add_copy, color: AppColors.primaryNeon, size: 20.sp),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_collectionNameController.text.trim().isNotEmpty) {
                            setState(() {
                              _collections.add({
                                'name': _collectionNameController.text.trim(),
                                'icon': Iconsax.folder_2_copy,
                              });
                            });
                            _collectionNameController.clear();
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryNeon,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          "CREATE COLLECTION",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w900,
                            fontSize: 13.sp,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const ParticleBackground(),
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: AppColors.background.withValues(alpha: 0.9),
                  elevation: 0,
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  ),
                  title: Text(
                    'Saved Library',
                    style: GoogleFonts.orbitron(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      onPressed: _showCreateCollectionSheet,
                      icon: const Icon(Iconsax.add_square_copy, color: AppColors.primaryNeon),
                    ),
                    SizedBox(width: 8.w),
                  ],
                ),
                SliverToBoxAdapter(
                  child: _buildCollectionsSection(),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    minHeight: 60.h,
                    maxHeight: 60.h,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.95),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withValues(alpha: 0.05),
                            width: 1,
                          ),
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: AppColors.primaryNeon,
                        indicatorWeight: 3,
                        labelColor: Colors.white,
                        unselectedLabelColor: AppColors.textGrey,
                        labelStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: 'Reels'),
                          Tab(text: 'Videos'),
                          Tab(text: 'Audio'),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildSavedReelsGrid(),
                _buildSavedVideosList(),
                _buildSavedAudioList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'COLLECTIONS',
                style: GoogleFonts.orbitron(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNeon.withValues(alpha: 0.8),
                  letterSpacing: 2,
                ),
              ),
              Icon(Iconsax.edit_2_copy, color: AppColors.textGrey, size: 14.sp),
            ],
          ),
        ),
        SizedBox(
          height: 100.h,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            scrollDirection: Axis.horizontal,
            itemCount: _collections.length,
            itemBuilder: (context, index) {
              final collection = _collections[index];
              return Container(
                width: 85.w,
                margin: EdgeInsets.only(right: 12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNeon.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(collection['icon'] as IconData, 
                        color: AppColors.primaryNeon, size: 20.sp),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      collection['name'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
            },
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  Widget _buildSavedReelsGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16.r),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return GlassmorphicContainer(
          width: double.infinity,
          height: double.infinity,
          borderRadius: 20.r,
          blur: 10,
          alignment: Alignment.center,
          border: 1,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white.withValues(alpha: 0.05), Colors.white.withValues(alpha: 0.02)],
          ),
          borderGradient: LinearGradient(
            colors: [Colors.white.withValues(alpha: 0.1), Colors.transparent],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                          'https://picsum.photos/seed/reel_sl_$index/400/700'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 8.r,
                        right: 8.r,
                        child: Icon(Iconsax.archive_tick_copy,
                            color: AppColors.primaryNeon, size: 18.sp),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saved to Gaming',
                      style: GoogleFonts.inter(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNeon,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Modern Gameplay Reel #$index',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '@pro_gamer • Oct ${index + 2}',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildSavedVideosList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 20.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                    child: CachedNetworkImage(
                      imageUrl: 'https://picsum.photos/seed/vvidl_$index/800/450',
                      width: double.infinity,
                      height: 180.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 12.r,
                    right: 12.r,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '10:2$index',
                        style: GoogleFonts.orbitron(
                          fontSize: 10.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundImage: CachedNetworkImageProvider(
                          'https://i.pravatar.cc/150?u=vcl_$index'),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How to Master Flutter UI in 2024 #$index',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Tech Tutorials • Study • 2 days ago',
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Iconsax.archive_tick_copy, color: AppColors.primaryNeon, size: 18.sp),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.05, end: 0);
      },
    );
  }

  Widget _buildSavedAudioList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: 10,
      itemBuilder: (context, index) {
        final songs = [
          'Midnight City', 'Starboy', 'Blinding Lights', 'Nightcall', 
          'After Hours', 'Save Your Tears', 'The Hills', 'Can\'t Feel My Face'
        ];
        final artists = ['M83', 'The Weeknd', 'Kavinsky', 'Daft Punk', 'Lana Del Rey'];
        
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 50.r,
                height: 50.r,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                        'https://picsum.photos/seed/music_l_$index/200'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24.sp),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      songs[index % songs.length],
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      artists[index % artists.length],
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Iconsax.archive_tick_copy, color: AppColors.primaryNeon, size: 18.sp),
                  SizedBox(height: 4.h),
                  Text(
                    '2:45',
                    style: GoogleFonts.orbitron(
                      fontSize: 10.sp,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: (index * 30).ms).slideX(begin: 0.1, end: 0);
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
