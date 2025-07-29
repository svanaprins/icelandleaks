import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/scandal_selector_widget.dart';
import './widgets/timeline_node_widget.dart';
import './widgets/timeline_scrubber_widget.dart';
import './widgets/timeline_search_widget.dart';

class ScandalTimeline extends StatefulWidget {
  const ScandalTimeline({super.key});

  @override
  State<ScandalTimeline> createState() => _ScandalTimelineState();
}

class _ScandalTimelineState extends State<ScandalTimeline>
    with TickerProviderStateMixin {
  late AnimationController _zoomController;
  late Animation<double> _zoomAnimation;

  int _selectedScandalIndex = 0;
  int _currentEventIndex = 0;
  String _searchQuery = '';
  Set<int> _expandedEvents = {};

  final ScrollController _timelineScrollController = ScrollController();
  final TransformationController _transformationController =
      TransformationController();

  // Mock data for Icelandic political scandals
  final List<Map<String, dynamic>> _scandals = [
    {
      "id": 1,
      "name": "Samherji Fishrot",
      "severity": "Critical",
      "year": "2019",
      "description":
          "Major bribery scandal involving Icelandic fishing company Samherji and Namibian officials",
      "events": [
        {
          "id": 1,
          "title": "Initial Leak Discovery",
          "description":
              "Whistleblower documents reveal systematic bribery scheme between Samherji executives and Namibian fishing ministers. Over \$10 million in bribes documented.",
          "date": "15 Nov 2019",
          "severity": "Critical",
          "involvedParties": [
            "Þorsteinn Már Baldvinsson",
            "Bernhard Esau",
            "Sacky Shanghala"
          ],
          "documents": [
            "leaked_emails.pdf",
            "bank_transfers.csv",
            "meeting_records.doc"
          ],
          "type": "Leak"
        },
        {
          "id": 2,
          "title": "Parliamentary Investigation Launched",
          "description":
              "Icelandic Parliament initiates formal investigation into Samherji's operations and potential government knowledge of corrupt practices.",
          "date": "28 Nov 2019",
          "severity": "High",
          "involvedParties": ["Katrín Jakobsdóttir", "Bjarni Benediktsson"],
          "documents": ["parliament_motion.pdf", "investigation_scope.doc"],
          "type": "Investigation"
        },
        {
          "id": 3,
          "title": "CEO Resignation",
          "description":
              "Samherji CEO Þorsteinn Már Baldvinsson resigns amid mounting pressure. Company stock plummets 40% in single trading day.",
          "date": "12 Dec 2019",
          "severity": "High",
          "involvedParties": ["Þorsteinn Már Baldvinsson", "Samherji Board"],
          "documents": ["resignation_letter.pdf", "stock_analysis.xlsx"],
          "type": "Corporate Action"
        },
        {
          "id": 4,
          "title": "International Arrest Warrants",
          "description":
              "Namibian authorities issue international arrest warrants for former ministers. Interpol cooperation requested for asset recovery.",
          "date": "03 Feb 2020",
          "severity": "Critical",
          "involvedParties": ["Bernhard Esau", "Sacky Shanghala", "Interpol"],
          "documents": ["arrest_warrants.pdf", "asset_freeze_orders.doc"],
          "type": "Legal Action"
        },
        {
          "id": 5,
          "title": "Asset Seizure Operations",
          "description":
              "Coordinated asset seizures across multiple jurisdictions. Properties, vehicles, and bank accounts frozen totaling \$15 million.",
          "date": "18 Mar 2020",
          "severity": "Medium",
          "involvedParties": [
            "Financial Intelligence Units",
            "Asset Recovery Teams"
          ],
          "documents": ["seizure_inventory.xlsx", "asset_valuations.pdf"],
          "type": "Asset Recovery"
        }
      ]
    },
    {
      "id": 2,
      "name": "Panama Papers",
      "severity": "High",
      "year": "2016",
      "description":
          "Offshore financial dealings of Icelandic politicians and business leaders exposed",
      "events": [
        {
          "id": 6,
          "title": "Papers Released",
          "description":
              "International Consortium of Investigative Journalists releases Panama Papers, revealing offshore companies linked to Icelandic Prime Minister Sigmundur Davíð Gunnlaugsson.",
          "date": "03 Apr 2016",
          "severity": "Critical",
          "involvedParties": [
            "Sigmundur Davíð Gunnlaugsson",
            "Anna Sigurlaug Pálsdóttir"
          ],
          "documents": ["panama_papers_iceland.pdf", "offshore_companies.xlsx"],
          "type": "Leak"
        },
        {
          "id": 7,
          "title": "Prime Minister Walkout",
          "description":
              "PM Sigmundur Davíð storms out of TV interview when questioned about offshore holdings. Public outrage intensifies across Iceland.",
          "date": "04 Apr 2016",
          "severity": "High",
          "involvedParties": [
            "Sigmundur Davíð Gunnlaugsson",
            "RÚV Journalists"
          ],
          "documents": [
            "interview_transcript.doc",
            "public_reaction_analysis.pdf"
          ],
          "type": "Media Event"
        },
        {
          "id": 8,
          "title": "Mass Protests Begin",
          "description":
              "Thousands gather at Austurvöllur square demanding PM's resignation. Largest political protests in modern Icelandic history.",
          "date": "04 Apr 2016",
          "severity": "High",
          "involvedParties": ["Icelandic Citizens", "Protest Organizers"],
          "documents": ["protest_photos.zip", "crowd_estimates.doc"],
          "type": "Public Response"
        },
        {
          "id": 9,
          "title": "Prime Minister Resigns",
          "description":
              "After days of mounting pressure and coalition partner threats, Sigmundur Davíð Gunnlaugsson announces resignation as Prime Minister.",
          "date": "05 Apr 2016",
          "severity": "Critical",
          "involvedParties": [
            "Sigmundur Davíð Gunnlaugsson",
            "Progressive Party"
          ],
          "documents": ["resignation_speech.pdf", "coalition_statements.doc"],
          "type": "Political Resignation"
        }
      ]
    },
    {
      "id": 3,
      "name": "Banking Crisis",
      "severity": "Critical",
      "year": "2008",
      "description":
          "Collapse of Iceland's three major banks and subsequent prosecutions",
      "events": [
        {
          "id": 10,
          "title": "Kaupthing Bank Collapse",
          "description":
              "Kaupthing, Iceland's largest bank, collapses amid global financial crisis. Government unable to provide bailout due to bank's massive size relative to GDP.",
          "date": "09 Oct 2008",
          "severity": "Critical",
          "involvedParties": ["Hreiðar Már Sigurðsson", "Sigurður Einarsson"],
          "documents": ["bank_collapse_report.pdf", "bailout_analysis.xlsx"],
          "type": "Financial Collapse"
        },
        {
          "id": 11,
          "title": "Criminal Investigations Begin",
          "description":
              "Special Prosecutor's Office launches comprehensive investigation into banking practices. Focus on market manipulation and breach of fiduciary duty.",
          "date": "15 Jan 2009",
          "severity": "High",
          "involvedParties": [
            "Special Prosecutor",
            "Financial Supervisory Authority"
          ],
          "documents": ["investigation_mandate.pdf", "evidence_collection.doc"],
          "type": "Investigation"
        },
        {
          "id": 12,
          "title": "First Banker Convictions",
          "description":
              "Former Kaupthing executives sentenced to prison for market manipulation. Landmark case establishes precedent for banker prosecutions.",
          "date": "12 Dec 2013",
          "severity": "High",
          "involvedParties": [
            "Hreiðar Már Sigurðsson",
            "Sigurður Einarsson",
            "Magnús Guðmundsson"
          ],
          "documents": ["court_verdict.pdf", "sentencing_details.doc"],
          "type": "Legal Conviction"
        }
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _zoomController.dispose();
    _timelineScrollController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredEvents {
    final events = _scandals[_selectedScandalIndex]['events']
        as List<Map<String, dynamic>>;
    if (_searchQuery.isEmpty) return events;

    return events.where((event) {
      final title = (event['title'] as String).toLowerCase();
      final description = (event['description'] as String).toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || description.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshTimeline,
          color: AppTheme.lightTheme.colorScheme.primary,
          child: Stack(
            children: [
              Column(
                children: [
                  // Header with scandal title and controls
                  _buildHeader(),
                  // Scandal selector
                  ScandalSelectorWidget(
                    scandals: _scandals,
                    selectedIndex: _selectedScandalIndex,
                    onScandalSelected: _onScandalSelected,
                  ),
                  // Search widget
                  TimelineSearchWidget(
                    onSearchChanged: _onSearchChanged,
                    onClearSearch: _onClearSearch,
                    currentQuery: _searchQuery,
                  ),
                  // Timeline content
                  Expanded(
                    child: _buildTimelineContent(),
                  ),
                ],
              ),
              // Timeline scrubber
              if (_filteredEvents.isNotEmpty)
                TimelineScrubberWidget(
                  events: _filteredEvents,
                  currentEventIndex: _currentEventIndex,
                  onEventSelected: _onEventSelected,
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTimelineOverview,
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        child: CustomIconWidget(
          iconName: 'map',
          color: AppTheme.lightTheme.colorScheme.onPrimary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final scandal = _scandals[_selectedScandalIndex];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: CustomIconWidget(
                iconName: 'arrow_back',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          // Scandal info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scandal['name'] as String,
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: _getSeverityColor(scandal['severity'] as String)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        scandal['severity'] as String,
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color:
                              _getSeverityColor(scandal['severity'] as String),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '${(scandal['events'] as List).length} events',
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Share button
          GestureDetector(
            onTap: _shareTimeline,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineContent() {
    if (_filteredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              'No events found',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Try adjusting your search terms',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: 0.8,
      maxScale: 3.0,
      onInteractionStart: (details) {
        HapticFeedback.lightImpact();
      },
      child: ListView.builder(
        controller: _timelineScrollController,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        itemCount: _filteredEvents.length,
        itemBuilder: (context, index) {
          final event = _filteredEvents[index];
          final isExpanded = _expandedEvents.contains(event['id'] as int);

          return TimelineNodeWidget(
            event: event,
            isExpanded: isExpanded,
            onTap: () => _toggleEventExpansion(event['id'] as int),
            onLongPress: () => _showEventContextMenu(context, event),
          );
        },
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AppTheme.lightTheme.colorScheme.error;
      case 'high':
        return AppTheme.warningLight;
      case 'medium':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'low':
        return AppTheme.successLight;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  void _onScandalSelected(int index) {
    setState(() {
      _selectedScandalIndex = index;
      _currentEventIndex = 0;
      _expandedEvents.clear();
      _searchQuery = '';
    });
    HapticFeedback.selectionClick();
  }

  void _onEventSelected(int index) {
    setState(() {
      _currentEventIndex = index;
    });

    // Scroll to the selected event
    final itemHeight = 15.h; // Approximate height of each timeline item
    final targetOffset = index * itemHeight;

    _timelineScrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    HapticFeedback.selectionClick();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onClearSearch() {
    setState(() {
      _searchQuery = '';
    });
  }

  void _toggleEventExpansion(int eventId) {
    setState(() {
      if (_expandedEvents.contains(eventId)) {
        _expandedEvents.remove(eventId);
      } else {
        _expandedEvents.add(eventId);
      }
    });
    HapticFeedback.lightImpact();
  }

  void _showEventContextMenu(BuildContext context, Map<String, dynamic> event) {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 30.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                event['title'] as String,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'bookmark_add',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Add to Research'),
              onTap: () {
                Navigator.pop(context);
                _addToResearch(event);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Share Event'),
              onTap: () {
                Navigator.pop(context);
                _shareEvent(event);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'description',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('View Documents'),
              onTap: () {
                Navigator.pop(context);
                _viewDocuments(event);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTimelineOverview() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          height: 60.h,
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              Text(
                'Timeline Overview',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredEvents.length,
                  itemBuilder: (context, index) {
                    final event = _filteredEvents[index];
                    return ListTile(
                      leading: Container(
                        width: 3.w,
                        height: 3.w,
                        decoration: BoxDecoration(
                          color: _getSeverityColor(event['severity'] as String),
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(
                        event['title'] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(event['date'] as String),
                      onTap: () {
                        Navigator.pop(context);
                        _onEventSelected(index);
                      },
                    );
                  },
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshTimeline() async {
    await Future.delayed(const Duration(seconds: 1));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Timeline updated with latest developments')),
    );
  }

  void _shareTimeline() {
    final scandal = _scandals[_selectedScandalIndex];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing ${scandal['name']} timeline')),
    );
  }

  void _addToResearch(Map<String, dynamic> event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${event['title']}" to research collection'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {},
        ),
      ),
    );
  }

  void _shareEvent(Map<String, dynamic> event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing "${event['title']}"')),
    );
  }

  void _viewDocuments(Map<String, dynamic> event) {
    final documents = event['documents'] as List;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Available Documents'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: documents
              .map((doc) => ListTile(
                    leading: CustomIconWidget(
                      iconName: 'description',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                    title: Text(doc as String),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Opening $doc')),
                      );
                    },
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
