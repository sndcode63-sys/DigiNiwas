import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import 'my_property_seller.dart';

class AddPropertyFlowScreen extends StatefulWidget {
  const AddPropertyFlowScreen({super.key});

  @override
  State<AddPropertyFlowScreen> createState() => _AddPropertyFlowScreenState();
}

class _AddPropertyFlowScreenState extends State<AddPropertyFlowScreen> {
  int _currentStep = 0; // 0 to 4 for steps 1-5, 5 for success screen

  // Form Data State
  String _listingType = 'Sell';
  String _propertyType = 'Apartment';
  String _title = 'Green Valley Residency';
  String _price = '1.40 Cr';
  String _configuration = '3 BHK';
  String _carpetArea = '1,650';
  String _possessionStatus = 'Ready to Move';

  // Location State
  String _city = 'Ahmedabad';
  String _locality = 'Bopal';
  String _society = 'Green Valley Residency';
  String _streetAddress = 'A-401, Sector 9';
  String _pincode = '380058';
  String _landmark = 'Near TRP Mall';

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
                onPressed: () {},
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
              _textField(_title, (val) => _title = val),
              SizedBox(height: 20.h),
              _label('Property price'),
              SizedBox(height: 8.h),
              _textField(_price, (val) => _price = val, prefix: '₹ '),
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
              _textField(_carpetArea, (val) => _carpetArea = val, suffix: 'sq.ft'),
              SizedBox(height: 20.h),
              _label('Possession status'),
              SizedBox(height: 8.h),
              _dropdownField(_possessionStatus, ['Ready to Move', 'Under Construction'], (val) => setState(() => _possessionStatus = val!)),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        _primaryButton('Continue to Location', () => setState(() => _currentStep = 1)),
        SizedBox(height: 10.h),
        _secondaryButton('Save and Exit', () {}),
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
              _dropdownField(_city, ['Ahmedabad', 'Ambala', 'Delhi', 'Chandigarh'], (val) => setState(() => _city = val!)),
              SizedBox(height: 16.h),
              _label('Locality / Area'),
              SizedBox(height: 8.h),
              _textField(_locality, (val) => _locality = val),
              SizedBox(height: 16.h),
              _label('Project / Society Name'),
              SizedBox(height: 8.h),
              _textField(_society, (val) => _society = val),
              SizedBox(height: 16.h),
              _label('Street Address / Flat No.'),
              SizedBox(height: 8.h),
              _textField(_streetAddress, (val) => _streetAddress = val),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Pincode'),
                        SizedBox(height: 8.h),
                        _textField(_pincode, (val) => _pincode = val),
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
                        _textField(_landmark, (val) => _landmark = val),
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
                    Icon(Icons.map, size: 50.sp, color: Colors.grey.shade400),
                    Positioned(
                      bottom: 10.h,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textPrimary,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                        ),
                        icon: Icon(Icons.my_location, size: 14.sp, color: AppColors.primary),
                        label: Text('Use Current Location', style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.bold)),
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
                            'Pinned to: $_locality, $_city',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text('Change Pin >', style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
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
        _primaryButton('Continue to Photos', () => setState(() => _currentStep = 2)),
        SizedBox(height: 10.h),
        _secondaryButton('Save and Exit', () {}),
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
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, elevation: 0),
                          icon: const Icon(Icons.image, size: 14, color: Colors.white),
                          label: Text('Gallery', style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.white)),
                        ),
                        SizedBox(width: 12.w),
                        OutlinedButton.icon(
                          onPressed: () {},
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
                  Text('Uploaded Photos (4/15)', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text('+ Add More', style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
              SizedBox(height: 12.h),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.4,
                children: [
                  _photoTile('Living Room', true),
                  _photoTile('Kitchen', false),
                  _photoTile('Bedrooms', false),
                  _photoTile('+ Exterior View', false),
                ],
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
        _primaryButton('Continue to Documents', () => setState(() => _currentStep = 3)),
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
                subtitle: 'Proof of ownership. PDF, JPG, PNG (Max 10MB)',
                isUploaded: false,
              ),
              SizedBox(height: 12.h),
              _documentUploadCard(
                title: 'Latest Property Tax Receipt',
                subtitle: 'Tax_Receipt_2025-26.pdf (2.4 MB)',
                isUploaded: true,
              ),
              SizedBox(height: 12.h),
              _documentUploadCard(
                title: 'Occupancy Certificate (OC) (Optional)',
                subtitle: 'Recommended for completed projects. PDF, JPG (Max 10MB)',
                isUploaded: false,
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
        _primaryButton('Continue to Preview', () => setState(() => _currentStep = 4)),
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
                    Text('Listing Quality Score: 98/100 (Ready to Publish)', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Text('All mandatory details and documents are complete. Your listing will go live within 2 hours after quick verification.', style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.textSecondary)),
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
                        Text(_society, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold)),
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
                        Text('$_configuration • $_carpetArea sq.ft.', overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Expected Price', style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.textSecondary)),
                        Text('₹ $_price', overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
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
              Text('$_society, $_landmark\n$_locality, $_city ($_pincode)', style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w500)),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 14.sp, color: AppColors.primary),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text('Exact location pinned on map', overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(value: true, onChanged: (v) {}, activeColor: AppColors.primary),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text('I confirm that the information provided is accurate and I am the authorized owner/agent for this property. I agree to the Terms & Conditions.', style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.textSecondary)),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        _primaryButton('Submit Listing for Review', () => setState(() => _currentStep = 5)),
        SizedBox(height: 10.h),
        _secondaryButton('Save and Exit', () {}),
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
                  Container(
                    height: 120.h,
                    color: Colors.grey.shade300,
                    child: Center(child: Icon(Icons.apartment, size: 50.sp, color: Colors.grey.shade600)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(14.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_society, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                        Text('Modal Town, Ambala', style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.textSecondary)),
                        SizedBox(height: 8.h),
                        Text('₹ $_price  •  $_carpetArea sq. ft.', style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
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
                  Text('Partner Assignment', style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      CircleAvatar(radius: 20.r, backgroundColor: Colors.grey.shade300, child: const Icon(Icons.person)),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Arjun Khanna', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                            Text('Digital Property Partner', style: GoogleFonts.poppins(fontSize: 10.sp, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          icon: const Icon(Icons.chat_bubble_outline, size: 14, color: Colors.white),
                          label: Text('Chat', style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.white)),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.primary)),
                          icon: Icon(Icons.phone_outlined, size: 14, color: AppColors.primary),
                          label: Text('Call', style: GoogleFonts.poppins(fontSize: 11.sp, color: AppColors.primary)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            _primaryButton('Go to My Properties', () {
              Get.offNamed(AppRoutes.myProperties);
            }),            SizedBox(height: 10.h),
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

  Widget _textField(String initialValue, Function(String) onChanged, {String? prefix, String? suffix}) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      decoration: InputDecoration(
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

  Widget _photoTile(String label, bool isCover) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          Center(child: Icon(Icons.image, size: 30.sp, color: Colors.grey.shade400)),
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
            bottom: 8.h,
            left: 8.w,
            child: Text(label, style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.black54)),
          ),
        ],
      ),
    );
  }

  Widget _documentUploadCard({required String title, required String subtitle, required bool isUploaded}) {
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
          if (isUploaded)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(color: const Color(0xFFEAF5F1), borderRadius: BorderRadius.circular(8.r)),
              child: Text('Uploaded', style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
            )
          else
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h)),
              child: Text('Upload File', style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.white)),
            ),
        ],
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0C233B),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        ),
        child: Text(label, style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white)),
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
}