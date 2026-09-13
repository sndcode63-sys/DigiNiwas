import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../seller/controller/seller_controller.dart';

class AddPropertyFlowScreen extends StatefulWidget {
  const AddPropertyFlowScreen({super.key});

  @override
  State<AddPropertyFlowScreen> createState() => _AddPropertyFlowScreenState();
}

class _AddPropertyFlowScreenState extends State<AddPropertyFlowScreen> {
  int _currentStep = 0; // 0 to 4 for steps 1-5, 5 for success screen

  late final SellerController _controller;
  final ImagePicker _imagePicker = ImagePicker();

  // ---------------------------------------------------------------------
  // STEP 1 — Details
  // ---------------------------------------------------------------------
  String _listingType = 'Sell';
  String _propertyType = 'Apartment';
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  String _configuration = '3 BHK';
  final TextEditingController _carpetAreaCtrl = TextEditingController();
  String _possessionStatus = 'Ready to Move';

  // ---------------------------------------------------------------------
  // STEP 2 — Location
  // ---------------------------------------------------------------------
  final List<String> _cityOptions = [
    'Ahmedabad',
    'Ambala',
    'Delhi',
    'Chandigarh',
    'Mumbai',
    'Pune',
    'Bengaluru',
    'Indore',
  ];
  String _city = 'Ahmedabad';
  final TextEditingController _localityCtrl = TextEditingController();
  final TextEditingController _societyCtrl = TextEditingController();
  final TextEditingController _streetAddressCtrl = TextEditingController();
  final TextEditingController _pincodeCtrl = TextEditingController();
  final TextEditingController _landmarkCtrl = TextEditingController();
  double? _latitude;
  double? _longitude;
  bool _isFetchingLocation = false;

  // ---------------------------------------------------------------------
  // STEP 3 — Photos
  // ---------------------------------------------------------------------
  final List<File> _photos = [];
  static const int _maxPhotos = 15;

  // ---------------------------------------------------------------------
  // STEP 4 — Documents (backend currently exposes a single legal-document
  // slot — `reraCertificate` — on POST /api/newproperties. Title Deed maps
  // to it since it's mandatory; Tax Receipt / OC can be picked for the
  // seller's own records but aren't sent until the API adds dedicated
  // fields for them).
  // ---------------------------------------------------------------------
  File? _titleDeedFile;
  String? _titleDeedName;
  File? _taxReceiptFile;
  String? _taxReceiptName;
  File? _ocFile;
  String? _ocName;

  // ---------------------------------------------------------------------
  // STEP 5 — Review & submit
  // ---------------------------------------------------------------------
  bool _agreeTerms = true;
  Map<String, dynamic>? _createdProperty;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(SellerController(), tag: 'addPropertyFlow');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _descriptionCtrl.dispose();
    _carpetAreaCtrl.dispose();
    _localityCtrl.dispose();
    _societyCtrl.dispose();
    _streetAddressCtrl.dispose();
    _pincodeCtrl.dispose();
    _landmarkCtrl.dispose();
    Get.delete<SellerController>(tag: 'addPropertyFlow');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep == 5) {
      return _buildSuccessScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20.sp),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Get.back();
            }
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Diginiwas',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: TextButton(
                onPressed: _exitFlow,
                child: Text(
                  'Save Draft',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopStepIndicatorBar(),
            SizedBox(height: 20.h),

            // Dynamic Step Body Content
            if (_currentStep == 0) _buildStep1Content(),
            if (_currentStep == 1) _buildStep2Content(),
            if (_currentStep == 2) _buildStep3Content(),
            if (_currentStep == 3) _buildStep4Content(),
            if (_currentStep == 4) _buildStep5Content(),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TOP STEP INDICATOR BAR (Steps 1 to 5)
  // ==========================================
  Widget _buildTopStepIndicatorBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStepDot('1', 'Details', 0),
        _buildStepBarLine(0),
        _buildStepDot('2', 'Location', 1),
        _buildStepBarLine(1),
        _buildStepDot('3', '', 2),
        _buildStepBarLine(2),
        _buildStepDot('4', '', 3),
        _buildStepBarLine(3),
        _buildStepDot('5', 'Preview', 4),
      ],
    );
  }

  Widget _buildStepDot(String number, String label, int stepIndex) {
    bool isCompleted = _currentStep > stepIndex;
    bool isActive = _currentStep == stepIndex;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24.w,
          height: 24.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isActive ? AppColors.primary : Colors.grey.shade300,
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, size: 12.sp, color: Colors.white)
                : Text(
              number,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        if (label.isNotEmpty) ...[
          SizedBox(height: 4.h),
          SizedBox(
            width: 42.w,
            child: Text(
              label,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 8.5.sp,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStepBarLine(int stepIndex) {
    bool isActive = _currentStep > stepIndex;
    return Expanded(
      child: Container(
        height: 2.h,
        color: isActive ? AppColors.primary : Colors.grey.shade300,
        margin: EdgeInsets.symmetric(horizontal: 2.w),
      ),
    );
  }

  // ==========================================
  // STEP 1: DETAILS
  // ==========================================
  Widget _buildStep1Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 1 OF 5', style: _stepHeaderStyle()),
        SizedBox(height: 4.h),
        Text('Tell us about your property', style: _titleStyle()),
        SizedBox(height: 4.h),
        Text('You can save and continue later.', style: _subtitleStyle()),
        SizedBox(height: 20.h),
        Container(
          padding: EdgeInsets.all(18.r),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('I want to'),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(child: _chip('Sell', Icons.local_offer_outlined, _listingType == 'Sell', () => setState(() => _listingType = 'Sell'))),
                  SizedBox(width: 12.w),
                  Expanded(child: _chip('Rent', Icons.vpn_key_outlined, _listingType == 'Rent', () => setState(() => _listingType = 'Rent'))),
                ],
              ),
              SizedBox(height: 20.h),
              _label('Property type'),
              SizedBox(height: 10.h),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.3,
                children: [
                  _chip('Apartment', Icons.apartment_rounded, _propertyType == 'Apartment', () => setState(() => _propertyType = 'Apartment')),
                  _chip('House', Icons.home_outlined, _propertyType == 'House', () => setState(() => _propertyType = 'House')),
                  _chip('Plot', Icons.landscape_outlined, _propertyType == 'Plot', () => setState(() => _propertyType = 'Plot')),
                  _chip('Commercial', Icons.storefront_outlined, _propertyType == 'Commercial', () => setState(() => _propertyType = 'Commercial')),
                ],
              ),
              SizedBox(height: 20.h),
              _label('Property title'),
              SizedBox(height: 8.h),
              _controlledTextField(_titleCtrl, hint: 'e.g. Green Valley Residency'),
              SizedBox(height: 20.h),
              _label('Property price'),
              SizedBox(height: 8.h),
              _controlledTextField(
                _priceCtrl,
                hint: 'e.g. 8500000',
                prefix: '₹ ',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 20.h),
              _label('Description (optional)'),
              SizedBox(height: 8.h),
              _controlledTextField(
                _descriptionCtrl,
                hint: 'A few lines that help buyers picture the property',
                maxLines: 3,
              ),
              SizedBox(height: 20.h),
              _label('Configuration'),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(child: _configChip('2 BHK')),
                  SizedBox(width: 8.w),
                  Expanded(child: _configChip('3 BHK')),
                  SizedBox(width: 8.w),
                  Expanded(child: _configChip('4+ BHK')),
                ],
              ),
              SizedBox(height: 20.h),
              _label('Carpet area'),
              SizedBox(height: 8.h),
              _controlledTextField(
                _carpetAreaCtrl,
                hint: 'e.g. 1650',
                suffix: 'sq.ft',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 20.h),
              _label('Possession status'),
              SizedBox(height: 8.h),
              _dropdownField(_possessionStatus, ['Ready to Move', 'Under Construction'], (val) => setState(() => _possessionStatus = val!)),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        _primaryButton('Continue to Location', _validateStep1AndContinue),
        SizedBox(height: 10.h),
        _secondaryButton('Save and Exit', _exitFlow),
      ],
    );
  }

  // ==========================================
  // STEP 2: LOCATION
  // ==========================================
  Widget _buildStep2Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 2 OF 5', style: _stepHeaderStyle()),
        SizedBox(height: 4.h),
        Text('Where is your property located?', style: _titleStyle()),
        SizedBox(height: 4.h),
        Text('Accurate location helps buyers find your property quickly.', style: _subtitleStyle()),
        SizedBox(height: 20.h),
        Container(
          padding: EdgeInsets.all(18.r),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('City'),
              SizedBox(height: 8.h),
              _dropdownField(_city, _cityOptions, (val) => setState(() => _city = val!)),
              SizedBox(height: 16.h),
              _label('Locality / Area'),
              SizedBox(height: 8.h),
              _controlledTextField(_localityCtrl, hint: 'e.g. Bopal'),
              SizedBox(height: 16.h),
              _label('Project / Society Name'),
              SizedBox(height: 8.h),
              _controlledTextField(_societyCtrl, hint: 'e.g. Green Valley Residency'),
              SizedBox(height: 16.h),
              _label('Street Address / Flat No.'),
              SizedBox(height: 8.h),
              _controlledTextField(_streetAddressCtrl, hint: 'e.g. A-401, Sector 9'),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Pincode'),
                        SizedBox(height: 8.h),
                        _controlledTextField(
                          _pincodeCtrl,
                          hint: 'e.g. 380058',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Nearest Landmark'),
                        SizedBox(height: 8.h),
                        _controlledTextField(_landmarkCtrl, hint: 'e.g. Near TRP Mall'),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Container(
                height: 130.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      _latitude != null ? Icons.location_on : Icons.map,
                      size: 50.sp,
                      color: _latitude != null ? AppColors.primary : Colors.grey.shade400,
                    ),
                    Positioned(
                      bottom: 10.h,
                      child: ElevatedButton.icon(
                        onPressed: _isFetchingLocation ? null : _useCurrentLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textPrimary,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                        ),
                        icon: _isFetchingLocation
                            ? SizedBox(
                          width: 14.sp,
                          height: 14.sp,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        )
                            : Icon(Icons.my_location, size: 14.sp, color: AppColors.primary),
                        label: Text(
                          _isFetchingLocation ? 'Locating...' : 'Use Current Location',
                          style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.location_pin, color: AppColors.primary, size: 14.sp),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            _latitude != null
                                ? 'Pinned to: ${_localityCtrl.text.isEmpty ? _city : _localityCtrl.text}, $_city (${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)})'
                                : 'Pinned to: ${_localityCtrl.text.isEmpty ? "your locality" : _localityCtrl.text}, $_city',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _isFetchingLocation ? null : _useCurrentLocation,
                    child: Text('Change Pin >', style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF5F1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_outline, color: AppColors.primary, size: 18.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your exact flat number stays private', style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Text('Buyers only see your locality and society until a site visit is confirmed.', style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        _primaryButton('Continue to Photos', _validateStep2AndContinue),
        SizedBox(height: 10.h),
        _secondaryButton('Save and Exit', _exitFlow),
      ],
    );
  }

  // ==========================================
  // STEP 3: PHOTOS
  // ==========================================
  Widget _buildStep3Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 3 OF 5', style: _stepHeaderStyle()),
        SizedBox(height: 4.h),
        Text('Add high-quality photos of your property', style: _titleStyle()),
        SizedBox(height: 4.h),
        Text('A picture is worth a thousand words. High-quality photos attract 5x more buyers.', style: _subtitleStyle()),
        SizedBox(height: 20.h),
        Container(
          padding: EdgeInsets.all(20.r),
          decoration: _cardDecoration(),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary.withOpacity(0.4), style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(16.r),
                  color: const Color(0xFFEAF5F1).withOpacity(0.3),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library_outlined, color: AppColors.primary, size: 24.sp),
                        SizedBox(width: 12.w),
                        Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 28.sp),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text('Click or drag and drop photos here', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Text('Max 10 photos, 15MB each. PNG, JPG', style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.textSecondary)),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickFromGallery,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, elevation: 0),
                          icon: const Icon(Icons.image, size: 14, color: Colors.white),
                          label: Text('Gallery', style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.white)),
                        ),
                        SizedBox(width: 12.w),
                        OutlinedButton.icon(
                          onPressed: _pickFromCamera,
                          style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.primary)),
                          icon: Icon(Icons.camera_alt, size: 14, color: AppColors.primary),
                          label: Text('Take Photo', style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Uploaded Photos (${_photos.length}/$_maxPhotos)', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  GestureDetector(
                    onTap: _pickFromGallery,
                    child: Text('+ Add More', style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              if (_photos.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Text(
                    'No photos added yet. Add at least one to continue.',
                    style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textSecondary),
                  ),
                )
              else
                GridView.builder(
                  itemCount: _photos.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: 1.4,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => _photoTile(
                    _photos[index],
                    index == 0,
                        () => setState(() => _photos.removeAt(index)),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(color: const Color(0xFFEAF5F1), borderRadius: BorderRadius.circular(12.r)),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.primary),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pro Tip: Lighting Matters', style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Text('Take photos in natural daylight. Open all curtains and turn on interior lights to make spaces look larger and more inviting.', style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        _primaryButton('Continue to Documents', _validateStep3AndContinue),
        SizedBox(height: 10.h),
        _secondaryButton('Back to Location', () => setState(() => _currentStep = 1)),
      ],
    );
  }

  // ==========================================
  // STEP 4: DOCUMENTS
  // ==========================================
  Widget _buildStep4Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 4 OF 5', style: _stepHeaderStyle()),
        SizedBox(height: 4.h),
        Text('Upload property documents', style: _titleStyle()),
        SizedBox(height: 4.h),
        Text('Uploading verified documents speeds up approval and helps you earn the "Diginiwas Verified" badge.', style: _subtitleStyle()),
        SizedBox(height: 20.h),
        Container(
          padding: EdgeInsets.all(18.r),
          decoration: _cardDecoration(),
          child: Column(
            children: [
              _documentUploadCard(
                title: 'Title Deed / Index II Copy *',
                subtitle: _titleDeedName ?? 'Proof of ownership. PDF, JPG, PNG (Max 10MB)',
                isUploaded: _titleDeedFile != null,
                onUpload: () => _pickDocument(slot: 'titleDeed'),
                onRemove: () => setState(() {
                  _titleDeedFile = null;
                  _titleDeedName = null;
                }),
              ),
              SizedBox(height: 12.h),
              _documentUploadCard(
                title: 'Latest Property Tax Receipt',
                subtitle: _taxReceiptName ?? 'Optional. PDF, JPG, PNG (Max 10MB)',
                isUploaded: _taxReceiptFile != null,
                onUpload: () => _pickDocument(slot: 'taxReceipt'),
                onRemove: () => setState(() {
                  _taxReceiptFile = null;
                  _taxReceiptName = null;
                }),
              ),
              SizedBox(height: 12.h),
              _documentUploadCard(
                title: 'Occupancy Certificate (OC) (Optional)',
                subtitle: _ocName ?? 'Recommended for completed projects. PDF, JPG (Max 10MB)',
                isUploaded: _ocFile != null,
                onUpload: () => _pickDocument(slot: 'oc'),
                onRemove: () => setState(() {
                  _ocFile = null;
                  _ocName = null;
                }),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5F1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified_user, color: AppColors.primary),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DigiNiwas Trust & Privacy Promise', style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          Text('Your documents are processed using AI for quick verification and are securely encrypted. We comply with all RERA data privacy standards. Documents are never shared publicly.', style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        _primaryButton('Continue to Preview', _validateStep4AndContinue),
        SizedBox(height: 10.h),
        _secondaryButton('Back to Photos', () => setState(() => _currentStep = 2)),
      ],
    );
  }

  // ==========================================
  // STEP 5: PREVIEW & SUBMISSION REVIEW
  // ==========================================
  Widget _buildStep5Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text('Review your listing details', style: _titleStyle())),
            Text('Review', style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ],
        ),
        Text('Please double-check everything before submitting for verification.', style: _subtitleStyle()),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF5F1),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            children: [
              Icon(Icons.verified, color: AppColors.primary, size: 28.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Listing Quality Score: $_qualityScore/100 (${_qualityScore >= 80 ? "Ready to Publish" : "Add a bit more detail"})', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Text('Mandatory details and documents are checked before your listing goes live. Verification usually completes within 2 hours.', style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Basic Information', style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text('Edit', style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
              Divider(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Property Type', style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.textSecondary)),
                        Text('$_propertyType ($_listingType)', overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Project / Society', style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.textSecondary)),
                        Text(_societyCtrl.text, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Configuration', style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.textSecondary)),
                        Text('$_configuration • ${_carpetAreaCtrl.text} sq.ft.', overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Expected Price', style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.textSecondary)),
                        Text('₹ ${_priceCtrl.text}', overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Location Details', style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text('Edit', style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
              Divider(height: 20.h),
              Text(
                '${_societyCtrl.text}${_landmarkCtrl.text.isNotEmpty ? ', ${_landmarkCtrl.text}' : ''}\n${_localityCtrl.text}, $_city (${_pincodeCtrl.text})',
                style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    _latitude != null ? Icons.check_circle : Icons.info_outline,
                    size: 14.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      _latitude != null ? 'Exact location pinned on map' : 'Location not pinned — buyers will only see the locality',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Photos & Documents', style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Divider(height: 20.h),
              Text('${_photos.length} photo(s) added', style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w500)),
              SizedBox(height: 4.h),
              Text(
                _titleDeedFile != null ? 'Title Deed uploaded' : 'Title Deed not uploaded yet',
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: _titleDeedFile != null ? AppColors.textPrimary : AppColors.error,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _agreeTerms,
              onChanged: (v) => setState(() => _agreeTerms = v ?? false),
              activeColor: AppColors.primary,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text('I confirm that the information provided is accurate and I am the authorized owner/agent for this property. I agree to the Terms & Conditions.', style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.textSecondary)),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        Obx(() => _primaryButton(
          _controller.isSubmittingProperty.value ? 'Submitting...' : 'Submit Listing for Review',
          _controller.isSubmittingProperty.value ? null : _submitListing,
          loading: _controller.isSubmittingProperty.value,
        )),
        SizedBox(height: 10.h),
        _secondaryButton('Save and Exit', _exitFlow),
      ],
    );
  }

  // ==========================================
  // SUCCESS SCREEN (Property Submitted)
  // ==========================================
  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [IconButton(icon: const Icon(Icons.help_outline), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          children: [
            Text('Property Submitted', style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Text('Your property details have been successfully received and are being processed.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textSecondary)),
            SizedBox(height: 20.h),
            Container(
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                    child: _photos.isNotEmpty
                        ? Image.file(_photos.first, height: 120.h, width: double.infinity, fit: BoxFit.cover)
                        : Container(
                      height: 120.h,
                      color: Colors.grey.shade300,
                      child: Center(child: Icon(Icons.apartment, size: 50.sp, color: Colors.grey.shade600)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(14.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_societyCtrl.text, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                        Text('${_localityCtrl.text}, $_city', style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textSecondary)),
                        SizedBox(height: 8.h),
                        Text('₹ ${_priceCtrl.text}  •  ${_carpetAreaCtrl.text} sq. ft.', style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        if (_referenceId.isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          Text('Reference ID: $_referenceId', style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.textSecondary)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.hourglass_top_rounded, color: AppColors.primary, size: 20.sp),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text('What happens next', style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Our team will verify your documents and photos, then a DigiNiwas partner will be assigned to your listing to help take it live. You can track this status anytime from My Properties.',
                    style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textSecondary, height: 1.4),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            _primaryButton('Go to My Properties', () {
              Get.offNamed(AppRoutes.myProperties);
            }),
            SizedBox(height: 10.h),
            _secondaryButton('Return to Home', () => Get.back()),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // REUSABLE UI HELPERS
  // ==========================================
  TextStyle _stepHeaderStyle() => GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 1.0);
  TextStyle _titleStyle() => GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary);
  TextStyle _subtitleStyle() => GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w500, color: AppColors.textSecondary);

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(20.r),
    boxShadow: [BoxShadow(color: AppColors.textSecondary.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
  );

  Widget _label(String text) => Text(text, style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary));

  Widget _chip(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEAF5F1) : AppColors.surface,
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300, width: isSelected ? 1.5 : 1.0),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18.sp, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w700, color: isSelected ? AppColors.primary : AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _configChip(String title) {
    bool isSelected = _configuration == title;
    return GestureDetector(
      onTap: () => setState(() => _configuration = title),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 11.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEAF5F1) : AppColors.surface,
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300, width: isSelected ? 1.5 : 1.0),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(title, style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w700, color: isSelected ? AppColors.primary : AppColors.textPrimary)),
      ),
    );
  }

  Widget _controlledTextField(
      TextEditingController controller, {
        String? hint,
        String? prefix,
        String? suffix,
        TextInputType? keyboardType,
        int maxLines = 1,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: (_) => setState(() {}),
      style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 12.sp, color: AppColors.textPlaceholder),
        prefixText: prefix,
        suffixText: suffix,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }

  Widget _dropdownField(String value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12.r)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _photoTile(File file, bool isCover, VoidCallback onRemove) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(file, fit: BoxFit.cover),
          if (isCover)
            Positioned(
              top: 8.h,
              left: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6.r)),
                child: Text('Cover Photo', style: GoogleFonts.poppins(fontSize: 8.sp, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          Positioned(
            top: 4.h,
            right: 4.w,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: Icon(Icons.close, size: 14.sp, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentUploadCard({
    required String title,
    required String subtitle,
    required bool isUploaded,
    required VoidCallback onUpload,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.description_outlined, color: AppColors.primary, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(subtitle, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.textSecondary)),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          if (isUploaded) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(color: const Color(0xFFEAF5F1), borderRadius: BorderRadius.circular(8.r)),
              child: Text('Uploaded', style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
            SizedBox(width: 4.w),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.delete_outline, size: 18.sp, color: AppColors.error),
            ),
          ] else
            ElevatedButton(
              onPressed: onUpload,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h)),
              child: Text('Upload File', style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.white)),
            ),
        ],
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback? onPressed, {bool loading = false}) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0C233B),
          disabledBackgroundColor: const Color(0xFF0C233B).withOpacity(0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        ),
        child: loading
            ? SizedBox(
          width: 18.sp,
          height: 18.sp,
          child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : Text(label, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }

  Widget _secondaryButton(String label, VoidCallback onPressed) {
    return Center(
      child: TextButton(
        onPressed: onPressed,
        child: Text(label, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.primary)),
      ),
    );
  }

  // ==========================================
  // VALIDATION — gate each step before advancing
  // ==========================================

  void _validateStep1AndContinue() {
    if (_titleCtrl.text.trim().isEmpty) {
      AppToast.error(context, 'Please enter a property title.');
      return;
    }
    final price = double.tryParse(_priceCtrl.text.trim());
    if (price == null || price <= 0) {
      AppToast.error(context, 'Please enter a valid property price.');
      return;
    }
    final area = double.tryParse(_carpetAreaCtrl.text.trim());
    if (area == null || area <= 0) {
      AppToast.error(context, 'Please enter a valid carpet area.');
      return;
    }
    setState(() => _currentStep = 1);
  }

  void _validateStep2AndContinue() {
    if (_localityCtrl.text.trim().isEmpty) {
      AppToast.error(context, 'Please enter the locality / area.');
      return;
    }
    if (_societyCtrl.text.trim().isEmpty) {
      AppToast.error(context, 'Please enter the project / society name.');
      return;
    }
    if (_streetAddressCtrl.text.trim().isEmpty) {
      AppToast.error(context, 'Please enter the street address / flat no.');
      return;
    }
    if (_pincodeCtrl.text.trim().length != 6) {
      AppToast.error(context, 'Please enter a valid 6-digit pincode.');
      return;
    }
    setState(() => _currentStep = 2);
  }

  void _validateStep3AndContinue() {
    if (_photos.isEmpty) {
      AppToast.error(context, 'Please add at least one photo of the property.');
      return;
    }
    setState(() => _currentStep = 3);
  }

  void _validateStep4AndContinue() {
    if (_titleDeedFile == null) {
      AppToast.error(context, 'Title Deed / Index II Copy is required.');
      return;
    }
    setState(() => _currentStep = 4);
  }

  // ==========================================
  // LOCATION
  // ==========================================

  Future<void> _useCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      final result = await Get.find<LocationService>().getCurrentLocation();
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
        if (result.city.isNotEmpty) {
          if (!_cityOptions.contains(result.city)) _cityOptions.add(result.city);
          _city = result.city;
        }
        if (result.pinCode.isNotEmpty) _pincodeCtrl.text = result.pinCode;
        if (result.address.isNotEmpty && _streetAddressCtrl.text.trim().isEmpty) {
          _streetAddressCtrl.text = result.address;
        }
      });
      if (mounted) AppToast.success(context, 'Location captured successfully.');
    } catch (e) {
      if (mounted) AppToast.error(context, e.toString());
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  // ==========================================
  // PHOTOS
  // ==========================================

  Future<void> _pickFromGallery() async {
    if (_photos.length >= _maxPhotos) {
      AppToast.error(context, 'Maximum $_maxPhotos photos allowed.');
      return;
    }
    final remaining = _maxPhotos - _photos.length;
    try {
      final picked = await _imagePicker.pickMultiImage(imageQuality: 80);
      if (picked.isEmpty) return;
      setState(() => _photos.addAll(picked.take(remaining).map((x) => File(x.path))));
    } catch (e) {
      if (mounted) AppToast.error(context, 'Could not open gallery.');
    }
  }

  Future<void> _pickFromCamera() async {
    if (_photos.length >= _maxPhotos) {
      AppToast.error(context, 'Maximum $_maxPhotos photos allowed.');
      return;
    }
    try {
      final shot = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (shot == null) return;
      setState(() => _photos.add(File(shot.path)));
    } catch (e) {
      if (mounted) AppToast.error(context, 'Could not open camera.');
    }
  }
  //
  // ==========================================
  // DOCUMENTS
  // ==========================================

  // Future<void> _pickDocument({required String slot}) async {
  //   try {
  //     final result = await FilePicker.platform.pickFiles(
  //       type: FileType.custom,
  //       allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
  //     );
  //     if (result == null || result.files.isEmpty) return;
  //     final picked = result.files.single;
  //     if (picked.path == null) return;
  //     final file = File(picked.path!);
  //     setState(() {
  //       switch (slot) {
  //         case 'titleDeed':
  //           _titleDeedFile = file;
  //           _titleDeedName = picked.name;
  //           break;
  //         case 'taxReceipt':
  //           _taxReceiptFile = file;
  //           _taxReceiptName = picked.name;
  //           break;
  //         case 'oc':
  //           _ocFile = file;
  //           _ocName = picked.name;
  //           break;
  //       }
  //     });
  //   } catch (e) {
  //     if (mounted) AppToast.error(context, 'Could not open file picker.');
  //   }
  // }
  Future<void> _pickDocument({required String slot}) async {
    try {
      final ImagePicker picker = ImagePicker();

      // Gallery se image pick karne ke liye
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Optional: image size optimize karne ke liye
      );

      if (picked == null) return;

      final File file = File(picked.path);
      final String fileName = picked.name;

      setState(() {
        switch (slot) {
          case 'titleDeed':
            _titleDeedFile = file;
            _titleDeedName = fileName;
            break;
          case 'taxReceipt':
            _taxReceiptFile = file;
            _taxReceiptName = fileName;
            break;
          case 'oc':
            _ocFile = file;
            _ocName = fileName;
            break;
        }
      });
    } catch (e) {
      if (mounted) {
        AppToast.error(context, 'Could not pick image.');
      }
    }
  }

  // ==========================================
  // DERIVED VALUES
  // ==========================================

  String get _bedroomsValue {
    if (_configuration == '2 BHK') return '2';
    if (_configuration == '3 BHK') return '3';
    return '4';
  }

  int get _qualityScore {
    int score = 40; // base for reaching the review step
    if (_titleCtrl.text.trim().isNotEmpty) score += 10;
    if (double.tryParse(_priceCtrl.text.trim()) != null) score += 10;
    if (_photos.isNotEmpty) score += 15;
    if (_photos.length >= 4) score += 5;
    if (_titleDeedFile != null) score += 15;
    if (_latitude != null) score += 5;
    return score.clamp(0, 100);
  }

  String get _referenceId {
    final data = _createdProperty;
    if (data == null) return '';
    return (data['propertyId'] ?? data['_id'] ?? data['id'] ?? '').toString();
  }

  // ==========================================
  // SUBMIT
  // ==========================================

  Future<void> _submitListing() async {
    if (!_agreeTerms) {
      AppToast.error(context, 'Please accept the Terms & Conditions to continue.');
      return;
    }
    if (_titleDeedFile == null) {
      AppToast.error(context, 'Title Deed / Index II Copy is required.');
      return;
    }

    final area = double.tryParse(_carpetAreaCtrl.text.trim()) ?? 0;
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    final isCommercial = _propertyType == 'Commercial';
    final needsBedrooms = _propertyType == 'Apartment' || _propertyType == 'House';

    final description = _descriptionCtrl.text.trim().isNotEmpty
        ? _descriptionCtrl.text.trim()
        : '$_configuration $_propertyType for $_listingType in ${_societyCtrl.text.trim()}, ${_localityCtrl.text.trim()}.';

    final fields = <String, dynamic>{
      'title': _titleCtrl.text.trim(),
      'transactionType': _listingType == 'Sell' ? 'Sale' : 'Rent',
      'category': isCommercial ? 'Commercial' : 'Residential',
      'status': 'Submitted',
      'propertySize': area,
      'sizeUnit': 'sqft',
      'price': price,
      'projectName': _societyCtrl.text.trim(),
      'description': description,
      'city': _city,
      'locality': _localityCtrl.text.trim(),
      'pinCode': _pincodeCtrl.text.trim(),
      'address': _streetAddressCtrl.text.trim(),
      if (_latitude != null) 'latitude': _latitude,
      if (_longitude != null) 'longitude': _longitude,
      'negotiable': true,
      'superBuiltupArea': area,
      'carpetArea': area,
      if (needsBedrooms) 'bedrooms': _bedroomsValue,
      'propertyType': _propertyType,
      'possessionStatus': _possessionStatus,
      if (_landmarkCtrl.text.trim().isNotEmpty) 'landmark': _landmarkCtrl.text.trim(),
    };

    final result = await _controller.submitNewProperty(
      fields: fields,
      images: _photos,
      reraCertificate: _titleDeedFile,
    );

    if (!mounted) return;

    if (result != null) {
      setState(() {
        _createdProperty = result;
        _currentStep = 5;
      });
    } else {
      final message = _controller.submitPropertyError.value;
      AppToast.error(
        context,
        message.isNotEmpty ? message : 'Could not submit your listing. Please try again.',
      );
    }
  }

  void _exitFlow() {
    Get.back();
  }
}