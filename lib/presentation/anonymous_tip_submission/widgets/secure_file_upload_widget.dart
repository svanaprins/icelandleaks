
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class SecureFileUploadWidget extends StatefulWidget {
  final List<Map<String, dynamic>> uploadedFiles;
  final Function(Map<String, dynamic>) onFileAdded;
  final Function(int) onFileRemoved;

  const SecureFileUploadWidget({
    Key? key,
    required this.uploadedFiles,
    required this.onFileAdded,
    required this.onFileRemoved,
  }) : super(key: key);

  @override
  State<SecureFileUploadWidget> createState() => _SecureFileUploadWidgetState();
}

class _SecureFileUploadWidgetState extends State<SecureFileUploadWidget> {
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
    } catch (e) {
      // Camera not available, continue without it
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<void> _captureDocument() async {
    if (!await _requestCameraPermission()) return;

    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        await _processFile(photo.path, photo.name, 'image');
      }
    } catch (e) {
      _showErrorMessage('Failed to capture document');
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        await _processFile(image.path, image.name, 'image');
      }
    } catch (e) {
      _showErrorMessage('Failed to select image');
    }
  }

  Future<void> _selectFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );

      if (result != null) {
        for (PlatformFile file in result.files) {
          String? filePath = kIsWeb ? null : file.path;
          await _processFile(
              filePath, file.name, _getFileType(file.extension ?? ''));
        }
      }
    } catch (e) {
      _showErrorMessage('Failed to select files');
    }
  }

  String _getFileType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'document';
      case 'doc':
      case 'docx':
      case 'txt':
        return 'document';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'image';
      default:
        return 'file';
    }
  }

  Future<void> _processFile(
      String? filePath, String fileName, String fileType) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    // Simulate encryption progress
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        _uploadProgress = i / 100;
      });
    }

    final fileData = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': fileName,
      'type': fileType,
      'path': filePath,
      'size': _getRandomFileSize(),
      'encrypted': true,
      'uploadedAt': DateTime.now(),
    };

    widget.onFileAdded(fileData);

    setState(() {
      _isUploading = false;
      _uploadProgress = 0.0;
    });
  }

  String _getRandomFileSize() {
    final sizes = ['1.2 MB', '856 KB', '2.1 MB', '445 KB', '3.7 MB'];
    return sizes[DateTime.now().millisecond % sizes.length];
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
      ),
    );
  }

  Widget _buildUploadZone() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'cloud_upload',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'Secure Document Upload',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'All files are encrypted before upload',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _captureDocument,
                  icon: CustomIconWidget(
                    iconName: 'camera_alt',
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    size: 18,
                  ),
                  label: const Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isUploading ? null : _selectFromGallery,
                  icon: CustomIconWidget(
                    iconName: 'photo_library',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 18,
                  ),
                  label: const Text('Gallery'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _isUploading ? null : _selectFiles,
              icon: CustomIconWidget(
                iconName: 'attach_file',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 18,
              ),
              label: const Text('Browse Files'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadProgress() {
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
                'Encrypting file...',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            '${(_uploadProgress * 100).toInt()}% encrypted',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileList() {
    return Column(
      children: widget.uploadedFiles.map((file) {
        final index = widget.uploadedFiles.indexOf(file);
        return Container(
          margin: EdgeInsets.only(bottom: 1.h),
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.getSuccessColor(true).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: CustomIconWidget(
                  iconName: file['type'] == 'image' ? 'image' : 'description',
                  color: AppTheme.getSuccessColor(true),
                  size: 16,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file['name'],
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'lock',
                          color: AppTheme.getSuccessColor(true),
                          size: 12,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'Encrypted • ${file['size']}',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.getSuccessColor(true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => widget.onFileRemoved(index),
                child: Container(
                  padding: EdgeInsets.all(1.w),
                  child: CustomIconWidget(
                    iconName: 'delete_outline',
                    color: AppTheme.lightTheme.colorScheme.error,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Supporting Evidence',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Upload documents, photos, or other evidence to support your tip',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2.h),
        if (_isUploading) _buildUploadProgress() else _buildUploadZone(),
        if (widget.uploadedFiles.isNotEmpty) ...[
          SizedBox(height: 2.h),
          _buildFileList(),
        ],
      ],
    );
  }
}
