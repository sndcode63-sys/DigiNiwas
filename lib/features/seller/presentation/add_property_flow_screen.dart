import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/services/location_service.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_toast.dart';
import '../controllers/seller_controller.dart';

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
  GoogleMapController? _mapController;

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final coords = await StorageService.instance.getLastKnownCoordinates();
      if (coords != null && mounted && _latitude == null) {
        setState(() {
          _latitude = coords.latitude;
          _longitude = coords.longitude;
        });
      }
    });
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
    _mapController?.dispose();
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
        _buildStepDot('1', _currentStep == 0 ? 'Details' : '', 0),
        _buildStepBarLine(0),
        _buildStepDot('2', _currentStep == 1 ? 'Location' : '', 1),
        _buildStepBarLine(1),
        _buildStepDot('3', _currentStep == 2 ? 'Photos' : '', 2),
        _buildStepBarLine(2),
        _buildStepDot('4', _currentStep == 3 ? 'Docs' : '', 3),
        _buildStepBarLine(3),
        _buildStepDot('5', 'Review', 4),
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
          width: 26.w,
          height: 26.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isActive ? const Color(0xFF165A54) : Colors.grey.shade300,
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                : Text(
              number,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        if (label.isNotEmpty) ...[
          SizedBox(height: 4.h),
          SizedBox(
            width: 44.w,
            child: Text(
              label,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                color: isActive ? const Color(0xFF165A54) : const Color(0xFF64748B),
              ),
            ),
          ),
        ] else ...[
          SizedBox(height: 16.h),
        ],
      ],
    );
  }

  Widget _buildStepBarLine(int stepIndex) {
    bool isActive = _currentStep > stepIndex;
    return Expanded(
      child: Container(
        height: 2.5.h,
        color: isActive ? const Color(0xFF165A54) : const Color(0xFFE2E8F0),
        margin: EdgeInsets.only(bottom: 14.h, left: 2.w, right: 2.w),
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
                height: 180.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.grey.shade300, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(_latitude ?? 23.0225, _longitude ?? 72.5714),
                          zoom: 14.5,
                        ),
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        onTap: (latLng) {
                          _onMapTapped(latLng);
                        },
                        markers: {
                          Marker(
                            markerId: const MarkerId('property_pin'),
                            position: LatLng(_latitude ?? 23.0225, _longitude ?? 72.5714),
                            infoWindow: InfoWindow(
                              title: _titleCtrl.text.isNotEmpty ? _titleCtrl.text : 'Property Location',
                              snippet: _localityCtrl.text.isNotEmpty ? _localityCtrl.text : _city,
                            ),
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                          ),
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                      ),
                      Positioned(
                        bottom: 10.h,
                        left: 14.w,
                        right: 14.w,
                        child: ElevatedButton.icon(
                          onPressed: _isFetchingLocation ? null : _useCurrentLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.textPrimary,
                            elevation: 3,
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                          ),
                          icon: _isFetchingLocation
                              ? SizedBox(
                            width: 14.sp,
                            height: 14.sp,
                            child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          )
                              : Icon(Icons.my_location_rounded, size: 16.sp, color: AppColors.primary),
                          label: Text(
                            _isFetchingLocation ? 'Locating...' : 'Use Current Location',
                            style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.location_pin, color: AppColors.primary, size: 15.sp),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            _latitude != null
                                ? 'Pinned: ${_localityCtrl.text.isEmpty ? _city : _localityCtrl.text} (${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)})'
                                : 'Tap on map or click "Use Current Location"',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_latitude != null && _longitude != null && _mapController != null) {
                        _mapController!.animateCamera(
                          CameraUpdate.newLatLngZoom(LatLng(_latitude!, _longitude!), 16.0),
                        );
                      } else {
                        _useCurrentLocation();
                      }
                    },
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
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(16.r),
                  color: const Color(0xFFEAF5F1).withValues(alpha: 0.3),
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
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary)),
                          icon: const Icon(Icons.camera_alt, size: 14, color: AppColors.primary),
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
              const Icon(Icons.lightbulb_outline, color: AppColors.primary),
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
                    const Icon(Icons.verified_user, color: AppColors.primary),
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
        Text(
          'Review your listing details',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F2544),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Please double-check everything before submitting for verification.',
          style: GoogleFonts.poppins(
            fontSize: 11.5.sp,
            color: const Color(0xFF64748B),
          ),
        ),
        SizedBox(height: 16.h),

        // Quality Score Card
        Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF9),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFCCFBEF)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34.w,
                height: 34.h,
                decoration: const BoxDecoration(
                  color: Color(0xFF99F6E4),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(Icons.auto_awesome, color: const Color(0xFF0F766E), size: 18.sp),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Listing Quality Score: ${_qualityScore > 0 ? _qualityScore : 98}/100 (Ready to Publish)',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F766E),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'All mandatory details and documents are complete. Your listing will go live within 2 hours after quick verification.',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5.sp,
                        color: const Color(0xFF475569),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Basic Information Card
        Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Basic Information',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F2544),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _currentStep = 0),
                    child: Text(
                      'Edit',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0D9488),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Property Type',
                          style: GoogleFonts.poppins(fontSize: 10.sp, color: const Color(0xFF64748B)),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '$_propertyType (${_listingType.isNotEmpty ? _listingType : "Sell"})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F2544),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Configuration',
                          style: GoogleFonts.poppins(fontSize: 10.sp, color: const Color(0xFF64748B)),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '$_configuration • ${_carpetAreaCtrl.text.isNotEmpty ? _carpetAreaCtrl.text : "1,450"} sq.ft.',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F2544),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Project/Society',
                          style: GoogleFonts.poppins(fontSize: 10.sp, color: const Color(0xFF64748B)),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _societyCtrl.text.isNotEmpty ? _societyCtrl.text : 'Green Valley Residency',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F2544),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Expected Price',
                          style: GoogleFonts.poppins(fontSize: 10.sp, color: const Color(0xFF64748B)),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '₹${_priceCtrl.text.isNotEmpty ? _priceCtrl.text : "85 L"}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0D9488),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Location Details Card
        Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Location Details',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F2544),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _currentStep = 1),
                    child: Text(
                      'Edit',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0D9488),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                '${_societyCtrl.text.isNotEmpty ? _societyCtrl.text : "Green Valley Residency"}${_landmarkCtrl.text.isNotEmpty ? ", ${_landmarkCtrl.text}" : ", Near TRP Mall"}\n${_localityCtrl.text.isNotEmpty ? _localityCtrl.text : "Bopal"}, $_city, Gujarat (${_pincodeCtrl.text.isNotEmpty ? _pincodeCtrl.text : "380058"})',
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0F2544),
                  height: 1.4,
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF9),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: const Color(0xFFCCFBEF)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 12.sp, color: const Color(0xFF0D9488)),
                    SizedBox(width: 4.w),
                    Text(
                      'Exact location pinned on map',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0D9488),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Photos Card
        Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Photos (${_photos.isNotEmpty ? _photos.length : 4})',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F2544),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _currentStep = 2),
                    child: Text(
                      'Edit',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0D9488),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _buildReviewPhotosGrid(),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Submitted Documents Card
        Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Submitted Documents',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F2544),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _currentStep = 3),
                    child: Text(
                      'Edit',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0D9488),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF9),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFFCCFBEF)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, size: 15.sp, color: const Color(0xFF0D9488)),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Title Deed / Index II (Uploaded)',
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F2544),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF9),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFFCCFBEF)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, size: 15.sp, color: const Color(0xFF0D9488)),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Latest Property Tax Receipt (Uploaded)',
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F2544),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Terms & Conditions Agreement
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24.w,
              height: 24.h,
              child: Checkbox(
                value: _agreeTerms,
                onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                activeColor: const Color(0xFF165A54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: 'I confirm that the information provided is accurate and I am the authorized owner/agent for this property. I agree to the ',
                  style: GoogleFonts.poppins(fontSize: 10.sp, color: const Color(0xFF64748B), height: 1.4),
                  children: [
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0D9488),
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed(AppRoutes.termsOfService),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 18.h),

        // Submit & Exit Buttons
        Obx(() => SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            onPressed: _controller.isSubmittingProperty.value ? null : _submitListing,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF165A54),
              disabledBackgroundColor: const Color(0xFF165A54).withValues(alpha: 0.6),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
            ),
            child: _controller.isSubmittingProperty.value
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Submit Listing for Review',
                        style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.arrow_forward, size: 16.sp, color: Colors.white),
                    ],
                  ),
          ),
        )),
        SizedBox(height: 10.h),
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: OutlinedButton(
            onPressed: _exitFlow,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
            ),
            child: Text(
              'Save and Exit',
              style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF0F2544)),
            ),
          ),
        ),
        SizedBox(height: 14.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 13.sp, color: const Color(0xFF94A3B8)),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                'Your listing is backed by DigiNiwas Verified Buyer Guarantee.',
                style: GoogleFonts.poppins(fontSize: 10.sp, color: const Color(0xFF94A3B8)),
              ),
            ),
          ],
        ),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F2544)),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.home_work_rounded, color: const Color(0xFF165A54), size: 20.sp),
            SizedBox(width: 6.w),
            Text(
              'DigiNiwas',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F2544),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF0F2544)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
        child: Column(
          children: [
            // Centered Checkmark with Glow Effect
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 72.w,
                    height: 72.h,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFEAF5F1),
                    ),
                  ),
                  Container(
                    width: 44.w,
                    height: 44.h,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF165A54),
                    ),
                    child: Icon(Icons.check, color: Colors.white, size: 24.sp),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Property Submitted',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F2544),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Your property details have been securely\nreceived and are being processed.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11.5.sp,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            SizedBox(height: 16.h),

            // Card 1: Property Preview Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                    child: Stack(
                      children: [
                        _photos.isNotEmpty
                            ? Image.file(_photos.first, height: 140.h, width: double.infinity, fit: BoxFit.cover)
                            : Image.network(
                                'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
                                height: 140.h,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                        Positioned(
                          top: 10.h,
                          left: 10.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A8A).withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.sell_outlined, size: 10.sp, color: Colors.white),
                                SizedBox(width: 4.w),
                                Text(
                                  _listingType == 'Rent' ? 'For Rent' : 'For Sale',
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(14.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _societyCtrl.text.isNotEmpty ? _societyCtrl.text : 'Green Valley Residency',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F2544),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '📍 ${_localityCtrl.text.isNotEmpty ? _localityCtrl.text : "Model Town"}, ${_city.isNotEmpty ? _city : "Ambala"}',
                          style: GoogleFonts.poppins(fontSize: 11.sp, color: const Color(0xFF64748B)),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Text(
                              '₹${_priceCtrl.text.isNotEmpty ? _priceCtrl.text : "1.40 Cr"}',
                              style: GoogleFonts.poppins(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F2544),
                              ),
                            ),
                            Text('  •  ', style: TextStyle(color: Colors.grey.shade400)),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                _configuration.isNotEmpty ? _configuration : '3 BHK',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ),
                            Text('  •  ', style: TextStyle(color: Colors.grey.shade400)),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                '${_carpetAreaCtrl.text.isNotEmpty ? _carpetAreaCtrl.text : "1,950"} sq.ft',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Listing Reference',
                                style: GoogleFonts.poppins(fontSize: 11.sp, color: const Color(0xFF64748B)),
                              ),
                              Text(
                                _referenceId.isNotEmpty ? '# $_referenceId' : '# DN-AZ-1048',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF165A54),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),

            // Card 2: Partner Assignment Card
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF5F1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.handshake_outlined, size: 16.sp, color: const Color(0xFF165A54)),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Partner Assignment',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F2544),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  // 4-stage stepper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPartnerStep('Submitted', Icons.check, true, false),
                      _buildPartnerStepLine(true),
                      _buildPartnerStep('Assigned', Icons.person, false, true),
                      _buildPartnerStepLine(false),
                      _buildPartnerStep('Verified', Icons.shield_outlined, false, false),
                      _buildPartnerStepLine(false),
                      _buildPartnerStep('Live', Icons.public, false, false),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  // Partner preview box
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFEEF2F6)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20.r,
                              backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200'),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Arjun Khanna',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F2544),
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Icon(Icons.check_circle, size: 14.sp, color: const Color(0xFF10B981)),
                                    ],
                                  ),
                                  Text(
                                    'Senior Property Partner',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10.5.sp,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 36.h,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Get.snackbar(
                                      'Chat with Partner',
                                      'Connecting to Arjun Khanna on DigiNiwas Chat...',
                                      backgroundColor: const Color(0xFF165A54),
                                      colorText: Colors.white,
                                    );
                                  },
                                  icon: Icon(Icons.chat_bubble_outline, size: 14.sp, color: Colors.white),
                                  label: Text(
                                    'Chat',
                                    style: GoogleFonts.poppins(fontSize: 11.5.sp, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF165A54),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: SizedBox(
                                height: 36.h,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Get.snackbar(
                                      'Call Partner',
                                      'Calling Arjun Khanna (+91 98765 43210)...',
                                      backgroundColor: const Color(0xFF0F2544),
                                      colorText: Colors.white,
                                    );
                                  },
                                  icon: Icon(Icons.phone_outlined, size: 14.sp, color: const Color(0xFF0F2544)),
                                  label: Text(
                                    'Call',
                                    style: GoogleFonts.poppins(fontSize: 11.5.sp, fontWeight: FontWeight.w600, color: const Color(0xFF0F2544)),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {
                  Get.offNamed(AppRoutes.myProperties);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F2544),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Go to My Properties',
                      style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.arrow_forward, size: 16.sp, color: Colors.white),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                ),
                child: Text(
                  'Return to Home',
                  style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF0F2544)),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_outline, size: 14.sp, color: const Color(0xFF94A3B8)),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Your personal contact details are securely stored and will not be shared directly with buyers without your explicit consent.',
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        color: const Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewPhotosGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        childAspectRatio: 1.15,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final hasPhoto = index < _photos.length;
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: hasPhoto
                  ? Image.file(
                      _photos[index],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      index == 0
                          ? 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=500'
                          : index == 1
                              ? 'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=500'
                              : index == 2
                                  ? 'https://images.unsplash.com/photo-1540518614846-7ede433c4550?w=500'
                                  : 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=500',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
            if (index == 0)
              Positioned(
                top: 6.h,
                left: 6.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'Cover',
                    style: GoogleFonts.poppins(
                      fontSize: 8.5.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPartnerStep(String label, IconData icon, bool isCompleted, bool isActive) {
    Color circleColor = isCompleted
        ? const Color(0xFF165A54)
        : isActive
            ? const Color(0xFF99F6E4)
            : const Color(0xFFF1F5F9);
    Color iconColor = isCompleted
        ? Colors.white
        : isActive
            ? const Color(0xFF165A54)
            : const Color(0xFF94A3B8);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24.w,
          height: 24.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: circleColor,
            border: !isCompleted && !isActive ? Border.all(color: const Color(0xFFCBD5E1)) : null,
          ),
          child: Center(
            child: Icon(icon, size: 12.sp, color: iconColor),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9.sp,
            fontWeight: isActive || isCompleted ? FontWeight.w700 : FontWeight.w500,
            color: isActive || isCompleted ? const Color(0xFF0F2544) : const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildPartnerStepLine(bool isDone) {
    return Expanded(
      child: Container(
        height: 2.h,
        color: isDone ? const Color(0xFF165A54) : const Color(0xFFE2E8F0),
        margin: EdgeInsets.only(bottom: 14.h, left: 2.w, right: 2.w),
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
    boxShadow: [BoxShadow(color: AppColors.textSecondary.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
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
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
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
          disabledBackgroundColor: const Color(0xFF0C233B).withValues(alpha: 0.6),
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
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(result.latitude, result.longitude), 15.5),
      );
      if (mounted) AppToast.success(context, 'Location captured successfully.');
    } catch (e) {
      if (mounted) AppToast.error(context, e.toString());
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _onMapTapped(LatLng position) async {
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
    _mapController?.animateCamera(CameraUpdate.newLatLng(position));
    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          if ((p.locality?.isNotEmpty ?? false) && _localityCtrl.text.isEmpty) {
            _localityCtrl.text = p.locality!;
          }
          if ((p.postalCode?.isNotEmpty ?? false) && _pincodeCtrl.text.isEmpty) {
            _pincodeCtrl.text = p.postalCode!;
          }
          final matchedCity = p.locality ?? p.subAdministrativeArea ?? p.administrativeArea;
          if (matchedCity != null && matchedCity.isNotEmpty) {
            if (!_cityOptions.contains(matchedCity)) {
              _cityOptions.add(matchedCity);
            }
            _city = matchedCity;
          }
        });
      }
    } catch (_) {}
  }

  // ==========================================r
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



  Future<void> _pickDocument({required String slot}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result == null || result.files.isEmpty) return;
      final picked = result.files.single;
      if (picked.path == null) return;
      final file = File(picked.path!);
      setState(() {
        switch (slot) {
          case 'titleDeed':
            _titleDeedFile = file;
            _titleDeedName = picked.name;
            break;
          case 'taxReceipt':
            _taxReceiptFile = file;
            _taxReceiptName = picked.name;
            break;
          case 'oc':
            _ocFile = file;
            _ocName = picked.name;
            break;
        }
      });
    } catch (e) {
      if (mounted) AppToast.error(context, 'Could not open file picker.');
    }
  }



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