
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/anonymous_text_area_widget.dart';
import './widgets/secure_file_upload_widget.dart';
import './widgets/security_header_widget.dart';
import './widgets/security_tips_widget.dart';
import './widgets/tip_category_selector_widget.dart';
import './widgets/tip_preferences_widget.dart';

class AnonymousTipSubmission extends StatefulWidget {
  const AnonymousTipSubmission({Key? key}) : super(key: key);

  @override
  State<AnonymousTipSubmission> createState() => _AnonymousTipSubmissionState();
}

class _AnonymousTipSubmissionState extends State<AnonymousTipSubmission> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final TextEditingController _tipController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isAuthenticated = false;
  bool _isSubmitting = false;
  bool _showVpnRecommendation = true;
  String _selectedCategory = '';
  List<Map<String, dynamic>> _uploadedFiles = [];
  bool _enableTracking = false;
  bool _enableFollowUp = false;
  double _submissionProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _authenticateUser();
  }

  @override
  void dispose() {
    _tipController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _authenticateUser() async {
    try {
      final bool isAvailable = await _localAuth.isDeviceSupported();
      if (!isAvailable) {
        setState(() => _isAuthenticated = true);
        return;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access secure tip submission',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      setState(() => _isAuthenticated = didAuthenticate);

      if (!didAuthenticate) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _isAuthenticated = true);
    }
  }

  void _onCategorySelected(String category) {
    setState(() => _selectedCategory = category);
  }

  void _onFileAdded(Map<String, dynamic> file) {
    setState(() => _uploadedFiles.add(file));
  }

  void _onFileRemoved(int index) {
    setState(() => _uploadedFiles.removeAt(index));
  }

  void _onTrackingChanged(bool value) {
    setState(() => _enableTracking = value);
  }

  void _onFollowUpChanged(bool value) {
    setState(() => _enableFollowUp = value);
  }

  bool _canSubmit() {
    return _selectedCategory.isNotEmpty &&
        _tipController.text.trim().length >= 50 &&
        !_isSubmitting;
  }

  Future<void> _submitTip() async {
    if (!_canSubmit()) return;

    final bool shouldSubmit = await _showSubmissionConfirmation();
    if (!shouldSubmit) return;

    setState(() {
      _isSubmitting = true;
      _submissionProgress = 0.0;
    });

    try {
      // Simulate secure submission process
      for (int i = 0; i <= 100; i += 5) {
        await Future.delayed(const Duration(milliseconds: 150));
        setState(() => _submissionProgress = i / 100);
      }

      await Future.delayed(const Duration(milliseconds: 500));

      final String trackingId = _enableTracking ? _generateTrackingId() : '';

      _showSuccessDialog(trackingId);
    } catch (e) {
      _showErrorDialog();
    } finally {
      setState(() {
        _isSubmitting = false;
        _submissionProgress = 0.0;
      });
    }
  }

  String _generateTrackingId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'IL-${timestamp.toString().substring(8)}-$random';
  }

  Future<bool> _showSubmissionConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                CustomIconWidget(
                  iconName: 'security',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                const Text('Confirm Secure Submission'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your tip will be encrypted and submitted anonymously. This action cannot be undone.',
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Submission Summary:',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                          '• Category: ${_getCategoryTitle(_selectedCategory)}'),
                      Text(
                          '• Text length: ${_tipController.text.length} characters'),
                      Text('• Files attached: ${_uploadedFiles.length}'),
                      if (_enableTracking) const Text('• Tracking enabled'),
                      if (_enableFollowUp) const Text('• Follow-up enabled'),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Submit Securely'),
              ),
            ],
          ),
        ) ??
        false;
  }

  String _getCategoryTitle(String categoryId) {
    switch (categoryId) {
      case 'corruption':
        return 'Government Corruption';
      case 'bribery':
        return 'Bribery & Kickbacks';
      case 'document_leak':
        return 'Document Leak';
      default:
        return 'Unknown';
    }
  }

  void _showSuccessDialog(String trackingId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.getSuccessColor(true),
              size: 24,
            ),
            SizedBox(width: 2.w),
            const Text('Tip Submitted Successfully'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your anonymous tip has been securely submitted and encrypted.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            if (trackingId.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.getSuccessColor(true).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        AppTheme.getSuccessColor(true).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your Tracking ID:',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    SelectableText(
                      trackingId,
                      style: AppTheme.getMonospaceStyle(
                        isLight: true,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Save this ID to track your tip\'s progress',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (trackingId.isNotEmpty)
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: trackingId));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Tracking ID copied to clipboard')),
                );
              },
              child: const Text('Copy ID'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'error',
              color: AppTheme.lightTheme.colorScheme.error,
              size: 24,
            ),
            SizedBox(width: 2.w),
            const Text('Submission Failed'),
          ],
        ),
        content: const Text(
          'Failed to submit your tip. Please check your connection and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_tipController.text.trim().isNotEmpty || _uploadedFiles.isNotEmpty) {
      return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Discard Tip?'),
              content: const Text(
                'You have unsaved changes. Are you sure you want to leave?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Stay'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Discard'),
                ),
              ],
            ),
          ) ??
          false;
    }
    return true;
  }

  Widget _buildSubmissionProgress() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'security',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Encrypting and submitting your tip...',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          LinearProgressIndicator(
            value: _submissionProgress,
            backgroundColor:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            '${(_submissionProgress * 100).toInt()}% complete',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'fingerprint',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 64,
              ),
              SizedBox(height: 2.h),
              Text(
                'Authenticating...',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              SizedBox(height: 1.h),
              Text(
                'Please authenticate to access secure submission',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              SecurityHeaderWidget(
                onDismiss: () => Navigator.of(context).pop(),
                isVpnRecommended: _showVpnRecommendation,
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TipCategorySelectorWidget(
                        selectedCategory: _selectedCategory,
                        onCategorySelected: _onCategorySelected,
                      ),
                      SizedBox(height: 3.h),
                      AnonymousTextAreaWidget(
                        controller: _tipController,
                        maxCharacters: 2000,
                      ),
                      SizedBox(height: 3.h),
                      SecureFileUploadWidget(
                        uploadedFiles: _uploadedFiles,
                        onFileAdded: _onFileAdded,
                        onFileRemoved: _onFileRemoved,
                      ),
                      SizedBox(height: 3.h),
                      TipPreferencesWidget(
                        enableTracking: _enableTracking,
                        enableFollowUp: _enableFollowUp,
                        onTrackingChanged: _onTrackingChanged,
                        onFollowUpChanged: _onFollowUpChanged,
                      ),
                      SizedBox(height: 3.h),
                      const SecurityTipsWidget(),
                      SizedBox(height: 4.h),
                      if (_isSubmitting) _buildSubmissionProgress(),
                      if (_isSubmitting) SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canSubmit() ? _submitTip : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      backgroundColor: _canSubmit()
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.3),
                    ),
                    child: _isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.lightTheme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 2.w),
                              const Text('Submitting Securely...'),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'security',
                                color: _canSubmit()
                                    ? AppTheme.lightTheme.colorScheme.onPrimary
                                    : AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                size: 20,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Submit Securely',
                                style: TextStyle(
                                  color: _canSubmit()
                                      ? AppTheme
                                          .lightTheme.colorScheme.onPrimary
                                      : AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
