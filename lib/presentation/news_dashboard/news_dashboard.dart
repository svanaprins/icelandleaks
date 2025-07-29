import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/news_card_widget.dart';
import './widgets/search_header_widget.dart';
import './widgets/skeleton_card_widget.dart';

class NewsDashboard extends StatefulWidget {
  const NewsDashboard({super.key});

  @override
  State<NewsDashboard> createState() => _NewsDashboardState();
}

class _NewsDashboardState extends State<NewsDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isRefreshing = false;
  int _currentTabIndex = 0;
  List<String> _selectedSources = ['RÚV', 'Stundin', 'DV'];

  // Mock data for news articles
  final List<Map<String, dynamic>> _newsArticles = [
    {
      "id": 1,
      "headline":
          "New Investigation Reveals Offshore Banking Connections in Reykjavik Financial District",
      "summary":
          "Leaked documents show potential tax avoidance schemes involving prominent Icelandic politicians and business leaders.",
      "source": "RÚV",
      "imageUrl":
          "https://images.unsplash.com/photo-1554224155-6726b3ff858f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
      "credibilityRating": 5,
      "isTrending": true,
      "readTime": 8,
      "category": "Financial Corruption"
    },
    {
      "id": 2,
      "headline":
          "Parliament Member Questioned Over Fishrot Scandal Connections",
      "summary":
          "Opposition calls for transparency as new evidence emerges linking current officials to the Samherji bribery case.",
      "source": "Stundin",
      "imageUrl":
          "https://images.unsplash.com/photo-1590736969955-71cc94901144?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "timestamp": DateTime.now().subtract(const Duration(hours: 5)),
      "credibilityRating": 4,
      "isTrending": false,
      "readTime": 6,
      "category": "Political Scandal"
    },
    {
      "id": 3,
      "headline":
          "Whistleblower Protection Laws Under Review Following Anonymous Tips",
      "source": "DV",
      "summary":
          "Government considers strengthening protections after surge in corruption reports from public sector employees.",
      "imageUrl":
          "https://images.unsplash.com/photo-1589829545856-d10d557cf95f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "timestamp": DateTime.now().subtract(const Duration(hours: 8)),
      "credibilityRating": 4,
      "isTrending": true,
      "readTime": 5,
      "category": "Legal Reform"
    },
    {
      "id": 4,
      "headline":
          "Panama Papers Follow-up: Three More Icelandic Officials Under Investigation",
      "summary":
          "Tax authorities expand probe into offshore holdings as public demands accountability from elected representatives.",
      "source": "RÚV",
      "imageUrl":
          "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "timestamp": DateTime.now().subtract(const Duration(hours: 12)),
      "credibilityRating": 5,
      "isTrending": false,
      "readTime": 7,
      "category": "Tax Evasion"
    },
    {
      "id": 5,
      "headline": "Banking Sector Reforms Delayed Amid Lobbying Pressure",
      "summary":
          "Critics argue that financial institutions are using political connections to water down transparency regulations.",
      "source": "Stundin",
      "imageUrl":
          "https://images.unsplash.com/photo-1560472354-b33ff0c44a43?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "timestamp": DateTime.now().subtract(const Duration(days: 1)),
      "credibilityRating": 3,
      "isTrending": false,
      "readTime": 4,
      "category": "Financial Reform"
    },
  ];

  final List<Map<String, dynamic>> _filterSources = [
    {"name": "RÚV", "count": 15, "isSelected": true},
    {"name": "Stundin", "count": 8, "isSelected": true},
    {"name": "DV", "count": 12, "isSelected": true},
    {"name": "Morgunblaðið", "count": 6, "isSelected": false},
    {"name": "Fréttablaðið", "count": 4, "isSelected": false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _scrollController.addListener(_handleScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
      HapticFeedback.selectionClick();
    }
  }

  void _handleScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadMoreData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate loading more data
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    HapticFeedback.mediumImpact();

    // Simulate refresh
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });
  }

  List<Map<String, dynamic>> get _filteredArticles {
    return _newsArticles.where((article) {
      return _selectedSources.contains(article['source']);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            SearchHeaderWidget(
              onSearchTap: _showAdvancedSearch,
              onFilterTap: _showFilterOptions,
            ),
            _buildTabBar(isDark),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildNewsTab(),
                  _buildScandalsTab(),
                  _buildTipsTab(),
                  _buildProfileTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          _currentTabIndex == 0 ? _buildFloatingActionButton(isDark) : null,
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
        unselectedLabelColor: isDark
            ? AppTheme.textMediumEmphasisDark
            : AppTheme.textMediumEmphasisLight,
        indicatorColor: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
        tabs: const [
          Tab(text: 'News'),
          Tab(text: 'Scandals'),
          Tab(text: 'Tips'),
          Tab(text: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNewsTab() {
    return Column(
      children: [
        _buildFilterChips(),
        Expanded(
          child: _filteredArticles.isEmpty
              ? EmptyStateWidget(onSubmitTip: _navigateToTipSubmission)
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _filteredArticles.length + (_isLoading ? 3 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _filteredArticles.length) {
                        return const SkeletonCardWidget();
                      }

                      final article = _filteredArticles[index];
                      return NewsCardWidget(
                        article: article,
                        onTap: () => _navigateToArticle(article),
                        onBookmark: () => _bookmarkArticle(article),
                        onShare: () => _shareArticle(article),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filterSources.length,
        itemBuilder: (context, index) {
          final source = _filterSources[index];
          return FilterChipWidget(
            label: source['name'] as String,
            count: source['count'] as int,
            isSelected: source['isSelected'] as bool,
            onTap: () => _toggleSourceFilter(index),
          );
        },
      ),
    );
  }

  Widget _buildScandalsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'timeline',
            color: AppTheme.primaryLight,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'Scandal Timeline',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Track major political scandals',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textMediumEmphasisLight,
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/scandal-timeline'),
            child: const Text('View Timeline'),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'security',
            color: AppTheme.successLight,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'Anonymous Tips',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Submit tips securely and anonymously',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textMediumEmphasisLight,
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: _navigateToTipSubmission,
            child: const Text('Submit Tip'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'person',
            color: AppTheme.primaryLight,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'User Profile',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Manage your account and preferences',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textMediumEmphasisLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(bool isDark) {
    return FloatingActionButton(
      onPressed: _showAdvancedSearch,
      backgroundColor: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
      child: CustomIconWidget(
        iconName: 'search',
        color: Colors.white,
        size: 24,
      ),
    );
  }

  void _toggleSourceFilter(int index) {
    setState(() {
      _filterSources[index]['isSelected'] =
          !(_filterSources[index]['isSelected'] as bool);

      final sourceName = _filterSources[index]['name'] as String;
      if (_filterSources[index]['isSelected'] as bool) {
        if (!_selectedSources.contains(sourceName)) {
          _selectedSources.add(sourceName);
        }
      } else {
        _selectedSources.remove(sourceName);
      }
    });

    HapticFeedback.selectionClick();
  }

  void _showAdvancedSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 70.h,
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced Search',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 3.h),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search for scandals, politicians, or keywords...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Categories',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: [
                'Financial Corruption',
                'Political Scandal',
                'Tax Evasion',
                'Legal Reform',
                'Banking',
              ]
                  .map((category) => Chip(
                        label: Text(category),
                        onDeleted: () {},
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Sources',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2.h),
            ..._filterSources.map((source) => CheckboxListTile(
                  title: Text(source['name'] as String),
                  subtitle: Text('${source['count']} articles'),
                  value: source['isSelected'] as bool,
                  onChanged: (value) {
                    setState(() {
                      source['isSelected'] = value ?? false;
                      final sourceName = source['name'] as String;
                      if (value == true) {
                        if (!_selectedSources.contains(sourceName)) {
                          _selectedSources.add(sourceName);
                        }
                      } else {
                        _selectedSources.remove(sourceName);
                      }
                    });
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _navigateToArticle(Map<String, dynamic> article) {
    HapticFeedback.lightImpact();
    // Navigate to article detail
  }

  void _bookmarkArticle(Map<String, dynamic> article) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Article bookmarked: ${article['headline']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareArticle(Map<String, dynamic> article) {
    HapticFeedback.selectionClick();
    // Implement share functionality
  }

  void _navigateToTipSubmission() {
    Navigator.pushNamed(context, '/anonymous-tip-submission');
  }
}
