import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  int _selectedTabIndex = 1;
  final TextEditingController _searchController = TextEditingController();

  // Controller to control the position of the draggable bottom sheet programmatically
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  late LatLng _centerLocation;
  dynamic _exploreData;
  List<dynamic> _markersList = [];
  List<dynamic> _filteredMarkers = [];

  @override
  void initState() {
    super.initState();

    // 🌐 HomeScreen se pass kiya gaya dynamic data receive kar rahe hain
    _exploreData = Get.arguments;

    final mapDetails = _exploreData?.map;

    // Center coordinates set karna (Agar API mein na ho toh default location)
    double lat = mapDetails?.center?.latitude ?? 23.0225;
    double lng = mapDetails?.center?.longitude ?? 72.5714;
    _centerLocation = LatLng(lat, lng);

    // Markers list nikalna
    _markersList = mapDetails?.markers ?? [];
    _filteredMarkers = _markersList;

    // Search query listener
    _searchController.addListener(_filterMarkers);
  }

  void _filterMarkers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMarkers = _markersList.where((m) {
        final name = (m.name ?? '').toLowerCase();
        final type = (m.markerType ?? '').toLowerCase();
        return name.contains(query) || type.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _resetSheetPosition() {
    _sheetController.animateTo(
      0.38,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🗺️ Dynamic Google Maps Markers Generator
    final Set<Marker> googleMarkers = {};
    for (var m in _filteredMarkers) {
      if (m.latitude != null && m.longitude != null) {
        final isProperty = m.markerType == 'PROPERTY';
        googleMarkers.add(
          Marker(
            markerId: MarkerId('${m.latitude}_${m.longitude}'),
            position: LatLng(m.latitude!, m.longitude!),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isProperty ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueAzure,
            ),
            onTap: () {
              _showMarkerDetailSheet(context, m, isProperty);
            },
          ),
        );
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Dynamic Google Map View Background
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _centerLocation,
                zoom: _exploreData?.map?.zoom?.toDouble() ?? 14.0,
              ),
              markers: googleMarkers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),

            // 2. Foreground UI Overlays (Header, Search, Tabs)
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        // App Bar Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Get.back(),
                              icon: const Icon(Icons.arrow_back_ios, size: 20),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                elevation: 2,
                              ),
                            ),
                            const Text(
                              'DigiNiwas',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F4C3A),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.favorite_border, size: 20),
                                  style: IconButton.styleFrom(backgroundColor: Colors.white),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.person_outline, size: 20),
                                  style: IconButton.styleFrom(backgroundColor: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Search Bar
// MapViewScreen ke andar yeh search bar wala code hota hai:
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchController, // 👈 Yeh text controller input ko handle karta hai
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Search nearby place or property',
                                    hintStyle: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                              if (_searchController.text.isNotEmpty)
                                GestureDetector(
                                  onTap: () => _searchController.clear(),
                                  child: const Icon(Icons.clear, size: 18, color: Colors.grey),
                                ),
                            ],
                          ),
                        ),                        const SizedBox(height: 16),

                        // Tab Switcher
                        Container(
                          height: 46,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedTabIndex = 0);
                                    Get.back();
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: _selectedTabIndex == 0 ? const Color(0xFF0F4C3A) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Text(
                                      'List',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: _selectedTabIndex == 0 ? Colors.white : Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedTabIndex = 1),
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: _selectedTabIndex == 1 ? const Color(0xFF0F4C3A) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: _selectedTabIndex == 1 ? Colors.white : Colors.grey.shade700,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Map',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: _selectedTabIndex == 1 ? Colors.white : Colors.grey.shade700,
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
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 3. Draggable Scrollable Bottom Sheet with Dynamic API Data
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.38,
              minChildSize: 0.0,
              maxChildSize: 0.85,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_filteredMarkers.length} places found nearby',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_exploreData?.property?.mapUrl != null)
                                TextButton.icon(
                                  onPressed: () {
                                    final url = _exploreData.property.mapUrl;
                                    if (url != null) launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                  },
                                  icon: const Icon(Icons.directions, size: 14, color: Color(0xFF0F4C3A)),
                                  label: const Text(
                                    'Get Directions',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF0F4C3A),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _filteredMarkers.isEmpty
                              ? const Center(
                            child: Text(
                              'No locations found matching your search.',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          )
                              : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredMarkers.length,
                            itemBuilder: (context, index) {
                              return _buildDynamicMarkerCard(_filteredMarkers[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _resetSheetPosition,
        backgroundColor: const Color(0xFF0F4C3A),
        icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
        label: const Text('Show Places', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // Dynamic Card for API Markers / Places
  Widget _buildDynamicMarkerCard(dynamic marker) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.place, color: Color(0xFF0F4C3A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  marker.name ?? 'Unknown Location',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  'Type: ${marker.markerType ?? 'General'}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              final url = marker.directionsUrl ?? marker.mapUrl;
              if (url != null && url.toString().isNotEmpty) {
                launchUrl(Uri.parse(url.toString()), mode: LaunchMode.externalApplication);
              }
            },
            icon: const Icon(Icons.directions_rounded, color: Color(0xFF0F4C3A)),
          ),
        ],
      ),
    );
  }

  // Marker Tap Modal Sheet
  void _showMarkerDetailSheet(BuildContext context, dynamic marker, bool isProperty) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isProperty ? Icons.home_rounded : Icons.place,
                    color: isProperty ? const Color(0xFF007A5E) : Colors.blue,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      marker.name ?? 'Location',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final url = marker.directionsUrl ?? marker.mapUrl;
                    if (url != null && url.toString().isNotEmpty) {
                      Navigator.of(ctx).pop();
                      launchUrl(Uri.parse(url.toString()), mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.directions_rounded, size: 16, color: Colors.white),
                  label: const Text('Get Directions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4C3A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}