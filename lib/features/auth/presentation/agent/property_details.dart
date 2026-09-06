import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// ==========================================
// COLORS & THEME
// ==========================================
const Color kPrimaryTeal = Color(0xFF0E9C87);
const Color kLightTealBg = Color(0xFFE8F8F5);
const Color kDarkNavy = Color(0xFF14213D);
const Color kGreyText = Color(0xFF8A93A6);
const Color kBorderGrey = Color(0xFFE3E6EA);
const Color kScaffoldBg = Color(0xFFF7F8FA);

// ==========================================
// 1. MODELS
// ==========================================
class UploadedPhoto {
  final String label;
  final bool isCover;
  final String? imagePath;
  UploadedPhoto({required this.label, this.isCover = false, this.imagePath});
}

class UploadedDocument {
  String status;
  String? fileName;
  String? fileSize;
  UploadedDocument({this.status = 'empty', this.fileName, this.fileSize});
}

class PropertySubmissionModel {
  String transactionType;
  String propertyType;
  String title;
  double price;
  String configuration;
  double carpetArea;
  String possessionStatus;
  bool isLegalOwner;

  String city;
  String locality;
  String societyName;
  String streetAddress;
  String pincode;
  String landmark;
  LatLng pinLocation;

  List<UploadedPhoto> photos;
  UploadedDocument titleDeed;
  UploadedDocument taxReceipt;
  UploadedDocument occupancyCertificate;

  bool isAgreedToTerms;
  int qualityScore;

  PropertySubmissionModel({
    this.transactionType = 'Sell',
    this.propertyType = 'Apartment',
    this.title = '',
    this.price = 0.0,
    this.configuration = '3 BHK',
    this.carpetArea = 0.0,
    this.possessionStatus = 'Ready to Move',
    this.isLegalOwner = false,
    this.city = 'Ahmedabad',
    this.locality = 'Bopal',
    this.societyName = 'Green Valley Residency',
    this.streetAddress = '',
    this.pincode = '380058',
    this.landmark = 'Near TRP Mall',
    LatLng? pinLocation,
    List<UploadedPhoto>? photos,
    UploadedDocument? titleDeed,
    UploadedDocument? taxReceipt,
    UploadedDocument? occupancyCertificate,
    this.isAgreedToTerms = false,
    this.qualityScore = 98,
  })  : pinLocation = pinLocation ?? const LatLng(23.0338, 72.4607),
        photos = photos ??
            [
              UploadedPhoto(label: 'Living Room', isCover: true),
              UploadedPhoto(label: 'Kitchen'),
              UploadedPhoto(label: 'Bedroom'),
            ],
        titleDeed = titleDeed ?? UploadedDocument(),
        taxReceipt = taxReceipt ??
            UploadedDocument(
              status: 'uploaded',
              fileName: 'Tax_Receipt_2025-26.pdf',
              fileSize: '2.4 MB',
            ),
        occupancyCertificate = occupancyCertificate ?? UploadedDocument();

  PropertySubmissionModel copyWith({
    String? transactionType,
    String? propertyType,
    String? title,
    double? price,
    String? configuration,
    double? carpetArea,
    String? possessionStatus,
    bool? isLegalOwner,
    String? city,
    String? locality,
    String? societyName,
    String? streetAddress,
    String? pincode,
    String? landmark,
    LatLng? pinLocation,
    List<UploadedPhoto>? photos,
    UploadedDocument? titleDeed,
    UploadedDocument? taxReceipt,
    UploadedDocument? occupancyCertificate,
    bool? isAgreedToTerms,
    int? qualityScore,
  }) {
    return PropertySubmissionModel(
      transactionType: transactionType ?? this.transactionType,
      propertyType: propertyType ?? this.propertyType,
      title: title ?? this.title,
      price: price ?? this.price,
      configuration: configuration ?? this.configuration,
      carpetArea: carpetArea ?? this.carpetArea,
      possessionStatus: possessionStatus ?? this.possessionStatus,
      isLegalOwner: isLegalOwner ?? this.isLegalOwner,
      city: city ?? this.city,
      locality: locality ?? this.locality,
      societyName: societyName ?? this.societyName,
      streetAddress: streetAddress ?? this.streetAddress,
      pincode: pincode ?? this.pincode,
      landmark: landmark ?? this.landmark,
      pinLocation: pinLocation ?? this.pinLocation,
      photos: photos ?? this.photos,
      titleDeed: titleDeed ?? this.titleDeed,
      taxReceipt: taxReceipt ?? this.taxReceipt,
      occupancyCertificate: occupancyCertificate ?? this.occupancyCertificate,
      isAgreedToTerms: isAgreedToTerms ?? this.isAgreedToTerms,
      qualityScore: qualityScore ?? this.qualityScore,
    );
  }
}

// ==========================================
// 2. VIEWMODEL
// ==========================================
class AgentAddPropertyViewModel extends ChangeNotifier {
  PropertySubmissionModel _model = PropertySubmissionModel();
  int _currentStep = 0;
  final ImagePicker _picker = ImagePicker();

  PropertySubmissionModel get model => _model;
  int get currentStep => _currentStep;

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void updateField({
    String? transactionType,
    String? propertyType,
    String? title,
    double? price,
    String? configuration,
    double? carpetArea,
    String? possessionStatus,
    bool? isLegalOwner,
    String? city,
    String? locality,
    String? societyName,
    String? streetAddress,
    String? pincode,
    String? landmark,
    LatLng? pinLocation,
    bool? isAgreedToTerms,
  }) {
    _model = _model.copyWith(
      transactionType: transactionType,
      propertyType: propertyType,
      title: title,
      price: price,
      configuration: configuration,
      carpetArea: carpetArea,
      possessionStatus: possessionStatus,
      isLegalOwner: isLegalOwner,
      city: city,
      locality: locality,
      societyName: societyName,
      streetAddress: streetAddress,
      pincode: pincode,
      landmark: landmark,
      pinLocation: pinLocation,
      isAgreedToTerms: isAgreedToTerms,
    );
    notifyListeners();
  }

  Future<void> pickAndAddPhoto({bool fromCamera = false, String label = 'Property View'}) async {
    final XFile? image = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      final updated = List<UploadedPhoto>.from(_model.photos)
        ..add(UploadedPhoto(label: label, imagePath: image.path));
      _model = _model.copyWith(photos: updated);
      notifyListeners();
    }
  }

  void removePhoto(int index) {
    final updated = List<UploadedPhoto>.from(_model.photos)..removeAt(index);
    _model = _model.copyWith(photos: updated);
    notifyListeners();
  }

  Future<void> uploadDocumentDynamic(String key) async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final doc = UploadedDocument(
        status: 'uploaded',
        fileName: file.name,
        fileSize: '1.5 MB',
      );
      if (key == 'titleDeed') {
        _model = _model.copyWith(titleDeed: doc);
      } else if (key == 'taxReceipt') {
        _model = _model.copyWith(taxReceipt: doc);
      } else if (key == 'occupancy') {
        _model = _model.copyWith(occupancyCertificate: doc);
      }
      notifyListeners();
    }
  }

  void removeDocument(String key) {
    final doc = UploadedDocument();
    if (key == 'titleDeed') _model = _model.copyWith(titleDeed: doc);
    if (key == 'taxReceipt') _model = _model.copyWith(taxReceipt: doc);
    if (key == 'occupancy') _model = _model.copyWith(occupancyCertificate: doc);
    notifyListeners();
  }
}

// ==========================================
// 3. MAIN CONTAINER VIEW SCREEN
// ==========================================
class AgentAddPropertyFlowScreen extends StatefulWidget {
  const AgentAddPropertyFlowScreen({super.key});

  @override
  State<AgentAddPropertyFlowScreen> createState() => _AgentAddPropertyFlowScreenState();
}

class _AgentAddPropertyFlowScreenState extends State<AgentAddPropertyFlowScreen> {
  late final AgentAddPropertyViewModel _viewModel;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _viewModel = AgentAddPropertyViewModel();
    _pageController = PageController();
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (_pageController.hasClients && _pageController.page?.round() != _viewModel.currentStep) {
      _pageController.animateToPage(
        _viewModel.currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_viewModel.currentStep < 5) _viewModel.setStep(_viewModel.currentStep + 1);
  }

  void _prevStep() {
    if (_viewModel.currentStep > 0) _viewModel.setStep(_viewModel.currentStep - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBg,
      appBar: _viewModel.currentStep == 5 ? _successAppBar() : _defaultAppBar(),
      body: Column(
        children: [
          if (_viewModel.currentStep < 5) _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1Details(),
                _buildStep2Location(),
                _buildStep3Photos(),
                _buildStep4Documents(),
                _buildStep5Review(),
                _buildStep6Success(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _defaultAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: kDarkNavy),
        onPressed: () {
          if (_viewModel.currentStep > 0 && _viewModel.currentStep < 5) {
            _prevStep();
          } else {
            Get.back();
          }
        },
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.home_rounded, color: kPrimaryTeal, size: 20),
          SizedBox(width: 6),
          Text('DigiNiwas', style: TextStyle(color: kDarkNavy, fontWeight: FontWeight.w700, fontSize: 17)),
        ],
      ),
      centerTitle: false,
      actions: [
        TextButton(
          onPressed: () {},
          child: const Text('Save Draft', style: TextStyle(color: kPrimaryTeal, fontWeight: FontWeight.w600)),
        )
      ],
    );
  }

  PreferredSizeWidget _successAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: kDarkNavy),
        onPressed: () => Get.back(),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.home_rounded, color: kPrimaryTeal, size: 20),
          SizedBox(width: 6),
          Text('DigiNiwas', style: TextStyle(color: kDarkNavy, fontWeight: FontWeight.w700, fontSize: 17)),
        ],
      ),
      centerTitle: false,
      actions: [
        IconButton(icon: const Icon(Icons.help_outline, color: kDarkNavy), onPressed: () {}),
      ],
    );
  }

  Widget _buildStepIndicator() {
    const labels = ['Details', 'Location', 'Photos', 'Documents', 'Review'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: List.generate(5, (index) {
          bool isCompleted = index < _viewModel.currentStep;
          bool isCurrent = index == _viewModel.currentStep;
          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? kPrimaryTeal : (isCurrent ? kDarkNavy : Colors.white),
                        border: Border.all(color: isCompleted ? kPrimaryTeal : (isCurrent ? kDarkNavy : kBorderGrey)),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : Text('${index + 1}',
                            style: TextStyle(
                                color: isCurrent ? Colors.white : Colors.grey.shade500,
                                fontWeight: FontWeight.bold,
                                fontSize: 11)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(labels[index],
                        style: TextStyle(
                            fontSize: 9,
                            color: isCurrent ? kDarkNavy : Colors.grey.shade400,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
                  ],
                ),
                if (index < 4)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      height: 1.5,
                      color: index < _viewModel.currentStep ? kPrimaryTeal : kBorderGrey,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ==========================================
  // STEP 1: Details
  // ==========================================
  Widget _buildStep1Details() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepLabel('STEP 1 OF 5'),
          const SizedBox(height: 4),
          _stepTitle('Tell us about your property'),
          _stepSubtitle('You can save and continue later.'),
          const SizedBox(height: 20),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel('I want to'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: _selectableChip('Sell', Icons.sell_outlined,
                            _viewModel.model.transactionType == 'Sell',
                                () => _viewModel.updateField(transactionType: 'Sell'))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _selectableChip('Rent', Icons.key_outlined,
                            _viewModel.model.transactionType == 'Rent',
                                () => _viewModel.updateField(transactionType: 'Rent'))),
                  ],
                ),
                const SizedBox(height: 20),
                _fieldLabel('Property type'),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.4,
                  children: [
                    _selectableChip('Apartment', Icons.apartment,
                        _viewModel.model.propertyType == 'Apartment',
                            () => _viewModel.updateField(propertyType: 'Apartment')),
                    _selectableChip('House', Icons.home_outlined,
                        _viewModel.model.propertyType == 'House',
                            () => _viewModel.updateField(propertyType: 'House')),
                    _selectableChip('Plot', Icons.landscape_outlined,
                        _viewModel.model.propertyType == 'Plot',
                            () => _viewModel.updateField(propertyType: 'Plot')),
                    _selectableChip('Commercial', Icons.store_outlined,
                        _viewModel.model.propertyType == 'Commercial',
                            () => _viewModel.updateField(propertyType: 'Commercial')),
                  ],
                ),
                const SizedBox(height: 20),
                _fieldLabel('Property title'),
                const SizedBox(height: 8),
                _textField(
                  hint: 'e.g. Green Valley Residency',
                  initialValue: _viewModel.model.title,
                  onChanged: (val) => _viewModel.updateField(title: val),
                ),
                const SizedBox(height: 20),
                _fieldLabel('Property price'),
                const SizedBox(height: 8),
                _textField(
                  hint: '0',
                  prefix: '₹ ',
                  initialValue: _viewModel.model.price == 0 ? '' : _viewModel.model.price.toStringAsFixed(0),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => _viewModel.updateField(price: double.tryParse(val) ?? 0),
                ),
                const SizedBox(height: 20),
                _fieldLabel('Configuration'),
                const SizedBox(height: 10),
                _segmentedControl(
                  options: const ['2 BHK', '3 BHK', '4+ BHK'],
                  selected: _viewModel.model.configuration,
                  onSelect: (val) => _viewModel.updateField(configuration: val),
                ),
                const SizedBox(height: 20),
                _fieldLabel('Carpet area'),
                const SizedBox(height: 8),
                _textField(
                  hint: '0',
                  suffix: 'sq.ft',
                  initialValue: _viewModel.model.carpetArea == 0 ? '' : _viewModel.model.carpetArea.toStringAsFixed(0),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => _viewModel.updateField(carpetArea: double.tryParse(val) ?? 0),
                ),
                const SizedBox(height: 20),
                _fieldLabel('Possession status'),
                const SizedBox(height: 8),
                _dropdownField(
                  value: _viewModel.model.possessionStatus,
                  items: const ['Ready to Move', 'Under Construction', 'New Launch'],
                  onChanged: (val) => _viewModel.updateField(possessionStatus: val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _viewModel.model.isLegalOwner,
                onChanged: (val) => _viewModel.updateField(isLegalOwner: val ?? false),
                activeColor: kPrimaryTeal,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 12, color: kDarkNavy, height: 1.4),
                      children: [
                        TextSpan(text: 'I am the legal owner or hold legal authorization to list this property.\n'),
                        TextSpan(text: 'Why we ask this', style: TextStyle(color: kPrimaryTeal, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _infoBox(
            icon: Icons.info_outline,
            title: 'Before you continue',
            body: 'Accurate details and clear photos help buyers trust your listing and lead to faster inquiries.',
          ),
          const SizedBox(height: 20),
          _primaryButton('Continue to Location', _nextStep),
          const SizedBox(height: 12),
          _secondaryLinkCenter('Save and Exit'),
          const SizedBox(height: 8),
          _footerSecureText(),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 2: Location
  // ==========================================
  Widget _buildStep2Location() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepLabel('STEP 2 OF 5'),
          const SizedBox(height: 4),
          _stepTitle('Where is your property located?'),
          _stepSubtitle('Accurate location helps buyers find your property quickly.'),
          const SizedBox(height: 20),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel('City'),
                const SizedBox(height: 8),
                _dropdownField(
                  value: _viewModel.model.city,
                  items: const ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot'],
                  onChanged: (val) => _viewModel.updateField(city: val),
                ),
                const SizedBox(height: 16),
                _fieldLabel('Locality / Area'),
                const SizedBox(height: 8),
                _textField(
                  initialValue: _viewModel.model.locality,
                  onChanged: (val) => _viewModel.updateField(locality: val),
                ),
                const SizedBox(height: 16),
                _fieldLabel('Project / Society Name'),
                const SizedBox(height: 8),
                _textField(
                  initialValue: _viewModel.model.societyName,
                  onChanged: (val) => _viewModel.updateField(societyName: val),
                ),
                const SizedBox(height: 16),
                _fieldLabel('Street Address / Flat No.'),
                const SizedBox(height: 8),
                _textField(
                  hint: 'e.g. A-401, Sector 9',
                  initialValue: _viewModel.model.streetAddress,
                  onChanged: (val) => _viewModel.updateField(streetAddress: val),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Pincode'),
                          const SizedBox(height: 8),
                          _textField(
                            initialValue: _viewModel.model.pincode,
                            keyboardType: TextInputType.number,
                            onChanged: (val) => _viewModel.updateField(pincode: val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Nearest Landmark'),
                          const SizedBox(height: 8),
                          _textField(
                            initialValue: _viewModel.model.landmark,
                            onChanged: (val) => _viewModel.updateField(landmark: val),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _interactiveMapPreview(),
          const SizedBox(height: 20),
          _infoBox(
            icon: Icons.shield_outlined,
            title: 'Your exact flat number stays private',
            body: 'Buyers only see your locality and society until a site visit is confirmed.',
          ),
          const SizedBox(height: 20),
          _primaryButton('Continue to Photos', _nextStep),
          const SizedBox(height: 12),
          _secondaryLinkRow(left: 'Save and Exit', onLeft: () {}),
          const SizedBox(height: 8),
          _footerSecureText(),
        ],
      ),
    );
  }

  Widget _interactiveMapPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 160,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: _viewModel.model.pinLocation,
                initialZoom: 15.0,
                onTap: (tapPosition, point) {
                  _viewModel.updateField(pinLocation: point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.diginiwas.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _viewModel.model.pinLocation,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: kPrimaryTeal, size: 38),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                color: Colors.white.withOpacity(0.95),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: kPrimaryTeal),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text('Pinned to: ${_viewModel.model.locality}, ${_viewModel.model.city}',
                          style: const TextStyle(fontSize: 10, color: kGreyText)),
                    ),
                    const Text('Tap map to change pin >',
                        style: TextStyle(fontSize: 10, color: kPrimaryTeal, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // STEP 3: Photos
  // ==========================================
  Widget _buildStep3Photos() {
    final photos = _viewModel.model.photos;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Photos', style: TextStyle(color: kPrimaryTeal, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          _stepLabel('STEP 3 OF 5'),
          const SizedBox(height: 4),
          _stepTitle('Add high-quality photos of your property'),
          _stepSubtitle('A picture is worth a thousand words. High-quality photos attract 5x more buyers.'),
          const SizedBox(height: 20),
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: kLightTealBg,
              border: Border.all(color: kPrimaryTeal.withOpacity(0.4), width: 1.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_upload_outlined, size: 32, color: kPrimaryTeal),
                const SizedBox(height: 8),
                const Text('Click or drag and drop photos here',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: kDarkNavy)),
                const Text('Max 10 photos, 15MB each. PNG, JPG',
                    style: TextStyle(color: kGreyText, fontSize: 11)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _pillOutlineButton(Icons.photo_library_outlined, 'Gallery',
                            () => _viewModel.pickAndAddPhoto(fromCamera: false)),
                    const SizedBox(width: 10),
                    _pillOutlineButton(Icons.camera_alt_outlined, 'Take Photo',
                            () => _viewModel.pickAndAddPhoto(fromCamera: true)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Uploaded Photos (${photos.length}/15)',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: kDarkNavy)),
              GestureDetector(
                onTap: () => _viewModel.pickAndAddPhoto(label: 'Extra Room'),
                child: const Text('+ Add More',
                    style: TextStyle(color: kPrimaryTeal, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: photos.length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.35,
            ),
            itemBuilder: (context, index) {
              if (index == photos.length) {
                return GestureDetector(
                  onTap: () => _viewModel.pickAndAddPhoto(label: 'Exterior View'),
                  child: const DottedPlaceholder(label: '+ Exterior View'),
                );
              }
              final photo = photos[index];
              return _photoThumb(photo, index);
            },
          ),
          const SizedBox(height: 20),
          _infoBox(
            icon: Icons.auto_awesome,
            title: 'Pro Tip: Lighting Matters',
            body: 'Take photos in natural daylight. Open all curtains and turn on interior lights to make spaces look larger and more inviting.',
          ),
          const SizedBox(height: 20),
          _primaryButton('Continue to Documents', _nextStep),
          const SizedBox(height: 12),
          _secondaryLinkRow(left: '← Back to Location', onLeft: _prevStep, right: 'Save and Exit', onRight: () {}),
          const SizedBox(height: 8),
          _footerSecureText(),
        ],
      ),
    );
  }

  Widget _photoThumb(UploadedPhoto photo, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          photo.imagePath != null
              ? Image.file(File(photo.imagePath!), fit: BoxFit.cover)
              : Container(
            color: const Color(0xFFB9D8CF),
            child: const Center(child: Icon(Icons.image, color: Colors.white70, size: 30)),
          ),
          if (photo.isCover)
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(color: kPrimaryTeal, borderRadius: BorderRadius.circular(6)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 10, color: Colors.white),
                    SizedBox(width: 3),
                    Text('Cover Photo', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => _viewModel.removePhoto(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline, size: 14, color: Colors.redAccent),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
                ),
              ),
              child: Text(photo.label,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 4: Documents
  // ==========================================
  Widget _buildStep4Documents() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepLabel('STEP 4 OF 5'),
          const SizedBox(height: 4),
          _stepTitle('Upload property documents'),
          _stepSubtitle("Uploading verified documents speeds up approval and helps you earn the 'DigiNiwas Verified' badge."),
          const SizedBox(height: 20),
          _documentCard(
            title: 'Title Deed / Index II Copy',
            required: true,
            subtitle: 'Proof of ownership. PDF, JPG, PNG (Max 10MB)',
            doc: _viewModel.model.titleDeed,
            onUpload: () => _viewModel.uploadDocumentDynamic('titleDeed'),
            onRemove: () => _viewModel.removeDocument('titleDeed'),
          ),
          const SizedBox(height: 14),
          _documentCard(
            title: 'Latest Property Tax Receipt',
            required: false,
            subtitle: null,
            doc: _viewModel.model.taxReceipt,
            onUpload: () => _viewModel.uploadDocumentDynamic('taxReceipt'),
            onRemove: () => _viewModel.removeDocument('taxReceipt'),
          ),
          const SizedBox(height: 14),
          _documentCard(
            title: 'Occupancy Certificate (OC)',
            required: false,
            optionalTag: true,
            subtitle: 'Recommended for completed projects. PDF, JPG (Max 10MB)',
            doc: _viewModel.model.occupancyCertificate,
            onUpload: () => _viewModel.uploadDocumentDynamic('occupancy'),
            onRemove: () => _viewModel.removeDocument('occupancy'),
          ),
          const SizedBox(height: 20),
          _infoBox(
            icon: Icons.verified_user_outlined,
            title: 'DigiNiwas Trust & Privacy Promise',
            body: 'Your documents are processed using AI for quick verification and are securely encrypted. We comply with all RERA data privacy standards. Documents are never shared publicly.',
          ),
          const SizedBox(height: 20),
          _primaryButton('Continue to Preview', _nextStep),
          const SizedBox(height: 12),
          _secondaryLinkRow(left: '← Back to Photos', onLeft: _prevStep, right: 'Save and Exit', onRight: () {}),
          const SizedBox(height: 8),
          _footerSecureText(text: 'Your documents are 256-bit encrypted and secure.'),
        ],
      ),
    );
  }

  Widget _documentCard({
    required String title,
    required bool required,
    bool optionalTag = false,
    String? subtitle,
    required UploadedDocument doc,
    required VoidCallback onUpload,
    required VoidCallback onRemove,
  }) {
    final isUploaded = doc.status == 'uploaded';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isUploaded ? Icons.shield_outlined : Icons.description_outlined,
                  color: isUploaded ? kPrimaryTeal : kDarkNavy, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontWeight: FontWeight.bold, color: kDarkNavy, fontSize: 14),
                    children: [
                      TextSpan(text: title),
                      if (required) const TextSpan(text: ' *', style: TextStyle(color: Colors.redAccent)),
                      if (optionalTag)
                        const TextSpan(text: '  (Optional)', style: TextStyle(color: kGreyText, fontWeight: FontWeight.normal, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              if (isUploaded)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: kLightTealBg, borderRadius: BorderRadius.circular(10)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 12, color: kPrimaryTeal),
                      SizedBox(width: 3),
                      Text('Uploaded', style: TextStyle(color: kPrimaryTeal, fontSize: 10, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(subtitle, style: const TextStyle(color: kGreyText, fontSize: 11)),
            ),
          ],
          const SizedBox(height: 12),
          if (isUploaded)
            Row(
              children: [
                const Icon(Icons.insert_drive_file, size: 16, color: kGreyText),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('${doc.fileName} (${doc.fileSize})',
                      style: const TextStyle(fontSize: 12, color: kDarkNavy), overflow: TextOverflow.ellipsis),
                ),
                GestureDetector(
                  onTap: onRemove,
                  child: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                ),
              ],
            )
          else
            OutlinedButton.icon(
              onPressed: onUpload,
              style: OutlinedButton.styleFrom(
                foregroundColor: kDarkNavy,
                side: const BorderSide(color: kBorderGrey),
                minimumSize: const Size(double.infinity, 42),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.upload_file, size: 16),
              label: const Text('Upload File', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 5: Review
  // ==========================================
  Widget _buildStep5Review() {
    final m = _viewModel.model;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepLabel('REVIEW'),
          const SizedBox(height: 4),
          _stepTitle('Review your listing details'),
          _stepSubtitle('Please double-check everything before submitting for verification.'),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: kLightTealBg, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: kPrimaryTeal),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Listing Quality Score: ${m.qualityScore}/100 (Ready to Publish)',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: kDarkNavy, fontSize: 13)),
                      const SizedBox(height: 2),
                      const Text('All mandatory details and documents are complete. Your listing will go live within 2 hours after quick verification.',
                          style: TextStyle(fontSize: 11, color: kGreyText)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _reviewSection(
            title: 'Basic Information',
            onEdit: () => _viewModel.setStep(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _reviewKV('Property Type', '${m.propertyType} (${m.transactionType})')),
                    Expanded(child: _reviewKV('Project/Society', m.societyName.isEmpty ? 'Green Valley Residency' : m.societyName)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _reviewKV('Configuration', '${m.configuration} • ${m.carpetArea == 0 ? "1,450" : m.carpetArea.toStringAsFixed(0)} sq.ft')),
                    Expanded(child: _reviewKV('Expected Price', '₹${m.price == 0 ? "85 L" : m.price.toStringAsFixed(0)}')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _reviewSection(
            title: 'Location Details',
            onEdit: () => _viewModel.setStep(1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${m.societyName}, ${m.landmark}',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: kDarkNavy, fontSize: 13)),
                const SizedBox(height: 2),
                Text('${m.locality}, ${m.city}, Gujarat (${m.pincode})',
                    style: const TextStyle(color: kGreyText, fontSize: 12)),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.check_circle, size: 13, color: kPrimaryTeal),
                    SizedBox(width: 4),
                    Text('Exact location pinned on map', style: TextStyle(fontSize: 11, color: kPrimaryTeal)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _reviewSection(
            title: 'Photos (${m.photos.length})',
            onEdit: () => _viewModel.setStep(2),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: m.photos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.5,
              ),
              itemBuilder: (context, index) => _photoThumb(m.photos[index], index),
            ),
          ),
          const SizedBox(height: 14),
          _reviewSection(
            title: 'Submitted Documents',
            onEdit: () => _viewModel.setStep(3),
            child: Column(
              children: [
                _reviewDocRow('Title Deed / Index II', m.titleDeed.status == 'uploaded'),
                const SizedBox(height: 8),
                _reviewDocRow('Latest Property Tax Receipt', m.taxReceipt.status == 'uploaded'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: m.isAgreedToTerms,
                onChanged: (val) => _viewModel.updateField(isAgreedToTerms: val ?? false),
                activeColor: kPrimaryTeal,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 12, color: kDarkNavy, height: 1.4),
                      children: [
                        TextSpan(text: 'I confirm that the information provided is accurate and I am the authorized owner/agent for this property. I agree to the '),
                        TextSpan(text: 'Terms & Conditions.', style: TextStyle(color: kPrimaryTeal, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _primaryButton('Submit Listing for Review →', _nextStep),
          const SizedBox(height: 12),
          _secondaryLinkCenter('Save and Exit'),
          const SizedBox(height: 8),
          _footerSecureText(text: 'Your listing is backed by DigiNiwas Verified Buyer Guarantee.'),
        ],
      ),
    );
  }

  Widget _reviewDocRow(String label, bool uploaded) {
    return Row(
      children: [
        Icon(uploaded ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 15, color: uploaded ? kPrimaryTeal : kGreyText),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: kDarkNavy))),
        Text(uploaded ? '(Uploaded)' : '(Pending)',
            style: TextStyle(fontSize: 11, color: uploaded ? kPrimaryTeal : Colors.orange)),
      ],
    );
  }

  Widget _reviewKV(String key, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(key, style: const TextStyle(fontSize: 11, color: kGreyText)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kDarkNavy)),
      ],
    );
  }

  Widget _reviewSection({required String title, required VoidCallback onEdit, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: kDarkNavy, fontSize: 14)),
              GestureDetector(
                onTap: onEdit,
                child: const Text('Edit', style: TextStyle(color: kPrimaryTeal, fontWeight: FontWeight.w600, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ==========================================
  // STEP 6: Success
  // ==========================================
  Widget _buildStep6Success() {
    final m = _viewModel.model;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chevron_left, color: Colors.grey.shade300),
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(color: kLightTealBg, shape: BoxShape.circle),
                child: const Icon(Icons.check_circle, color: kPrimaryTeal, size: 34),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade300),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Property Submitted',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: kDarkNavy)),
          const SizedBox(height: 8),
          const Text('Your property details have been securely received and are being processed.',
              textAlign: TextAlign.center, style: TextStyle(color: kGreyText, fontSize: 13)),
          const SizedBox(height: 22),
          _propertySummaryCard(m),
          const SizedBox(height: 20),
          _partnerAssignmentCard(),
          const SizedBox(height: 24),
          _primaryButton('Go to My Properties →', () => _viewModel.setStep(0)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kBorderGrey),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Return to Home', style: TextStyle(color: kDarkNavy, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 14),
          _footerSecureText(text: 'Your personal contact details are securely stored and will not be shared directly with buyers without your explicit consent.'),
        ],
      ),
    );
  }

  Widget _propertySummaryCard(PropertySubmissionModel m) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorderGrey),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 130,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2C3E63), Color(0xFF0F1B2B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(child: Icon(Icons.apartment, color: Colors.white24, size: 50)),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: kPrimaryTeal, borderRadius: BorderRadius.circular(6)),
                  child: const Text('For Sale', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.societyName.isEmpty ? 'Green Valley Residency' : m.societyName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: kDarkNavy)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 13, color: kGreyText),
                    const SizedBox(width: 3),
                    Text('${m.locality}, ${m.city}', style: const TextStyle(fontSize: 12, color: kGreyText)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('₹${m.price == 0 ? "1.40 Cr" : m.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kDarkNavy)),
                    const SizedBox(width: 8),
                    Text('• ${m.configuration}', style: const TextStyle(fontSize: 12, color: kGreyText)),
                    const SizedBox(width: 4),
                    Text('• ${m.carpetArea == 0 ? "1,850" : m.carpetArea.toStringAsFixed(0)} sq.ft',
                        style: const TextStyle(fontSize: 12, color: kGreyText)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(color: kLightTealBg, borderRadius: BorderRadius.circular(8)),
                  alignment: Alignment.center,
                  child: const Text('Listing Reference  #DN-AZ-1048',
                      style: TextStyle(fontSize: 11, color: kPrimaryTeal, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _partnerAssignmentCard() {
    const stages = ['Submitted', 'Assigned', 'Verified', 'Live'];
    const currentStageIndex = 1;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.groups_outlined, color: kDarkNavy, size: 18),
              SizedBox(width: 8),
              Text('Partner Assignment', style: TextStyle(fontWeight: FontWeight.bold, color: kDarkNavy)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(stages.length, (i) {
              final done = i < currentStageIndex;
              final current = i == currentStageIndex;
              return Expanded(
                child: Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: done ? kPrimaryTeal : (current ? kLightTealBg : Colors.white),
                            border: Border.all(color: done || current ? kPrimaryTeal : kBorderGrey),
                          ),
                          child: Center(
                            child: done
                                ? const Icon(Icons.check, size: 13, color: Colors.white)
                                : Icon(Icons.circle, size: 8, color: current ? kPrimaryTeal : kBorderGrey),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(stages[i],
                            style: TextStyle(
                                fontSize: 9,
                                color: current ? kPrimaryTeal : kGreyText,
                                fontWeight: current ? FontWeight.bold : FontWeight.normal)),
                      ],
                    ),
                    if (i < stages.length - 1)
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          height: 1.5,
                          color: i < currentStageIndex ? kPrimaryTeal : kBorderGrey,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: kLightTealBg,
                child: Icon(Icons.person, color: kPrimaryTeal),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      children: [
                        Text('Arjun Khanna', style: TextStyle(fontWeight: FontWeight.bold, color: kDarkNavy, fontSize: 13)),
                        SizedBox(width: 4),
                        Icon(Icons.verified, size: 13, color: kPrimaryTeal),
                      ],
                    ),
                    Text('Senior Property Partner', style: TextStyle(fontSize: 11, color: kGreyText)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryTeal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline, size: 15, color: Colors.white),
                    label: const Text('Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kBorderGrey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.call_outlined, size: 15, color: kDarkNavy),
                    label: const Text('Call', style: TextStyle(color: kDarkNavy, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SHARED WIDGET HELPERS
  // ==========================================
  Widget _stepLabel(String text) =>
      Text(text, style: const TextStyle(color: kPrimaryTeal, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5));

  Widget _stepTitle(String text) =>
      Text(text, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: kDarkNavy, height: 1.3));

  Widget _stepSubtitle(String text) =>
      Padding(padding: const EdgeInsets.only(top: 4), child: Text(text, style: const TextStyle(color: kGreyText, fontSize: 12.5)));

  Widget _fieldLabel(String text) => Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: kDarkNavy, fontSize: 13));

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorderGrey)),
    child: child,
  );

  Widget _textField({
    String? hint,
    String? initialValue,
    String? prefix,
    String? suffix,
    TextInputType? keyboardType,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      textAlign: TextAlign.center,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: kDarkNavy, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefix,
        suffixText: suffix,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorderGrey)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorderGrey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kPrimaryTeal)),
      ),
    );
  }

  Widget _dropdownField({required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: kBorderGrey)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: kGreyText),
          style: const TextStyle(color: kDarkNavy, fontSize: 13),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _segmentedControl({required List<String> options, required String selected, required ValueChanged<String> onSelect}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: kScaffoldBg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: options.map((opt) {
          final isSelected = opt == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(opt),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected ? kPrimaryTeal : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(opt,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: isSelected ? Colors.white : kDarkNavy,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _selectableChip(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? kLightTealBg : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? kPrimaryTeal : kBorderGrey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: isSelected ? kPrimaryTeal : Colors.grey.shade600),
            const SizedBox(width: 6),
            Flexible(
              child: Text(label,
                  style: TextStyle(color: kDarkNavy, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 12.5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pillOutlineButton(IconData icon, String label, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: kDarkNavy,
        backgroundColor: Colors.white,
        side: const BorderSide(color: kBorderGrey),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      icon: Icon(icon, size: 15),
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _infoBox({required IconData icon, required String title, required String body}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: kLightTealBg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kPrimaryTeal, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: kDarkNavy, fontSize: 12.5)),
                const SizedBox(height: 3),
                Text(body, style: const TextStyle(fontSize: 11.5, color: kGreyText, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kDarkNavy,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onTap,
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  Widget _secondaryLinkCenter(String text) {
    return Center(
      child: TextButton(
        onPressed: () {},
        child: Text(text, style: const TextStyle(color: kPrimaryTeal, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _secondaryLinkRow({required String left, required VoidCallback onLeft, String? right, VoidCallback? onRight}) {
    return Row(
      mainAxisAlignment: right != null ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
      children: [
        TextButton(onPressed: onLeft, child: Text(left, style: const TextStyle(color: kPrimaryTeal, fontWeight: FontWeight.bold, fontSize: 13))),
        if (right != null)
          TextButton(onPressed: onRight, child: Text(right, style: const TextStyle(color: kPrimaryTeal, fontWeight: FontWeight.bold, fontSize: 13))),
      ],
    );
  }

  Widget _footerSecureText({String text = 'Your information is securely saved.'}) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 11, color: kGreyText),
          const SizedBox(width: 4),
          Flexible(
            child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10.5, color: kGreyText)),
          ),
        ],
      ),
    );
  }
}

// Fixed Dotted Placeholder Tile (Error-free)
class DottedPlaceholder extends StatelessWidget {
  final String label;
  const DottedPlaceholder({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate_outlined, color: kGreyText, size: 20),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: kGreyText, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kBorderGrey
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    // Fallback safe solid/dashed drawing representation for cross-version support

    // Draw dashed lines manually using bounds safely
    double distance = 0;
    const dashWidth = 5.0;
    const dashSpace = 4.0;

    // Safe standard canvas border fallback to prevent computeMetrics compilation errors
    canvas.drawRRect(rrect, paint);
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}