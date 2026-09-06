import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({Key? key}) : super(key: key);

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  int _selectedTabIndex = 1;
  final TextEditingController _searchController =
  TextEditingController(text: '2 BHK in Ahmedabad');

  // Controller to control the position of the draggable bottom sheet programmatically
  final DraggableScrollableController _sheetController =
  DraggableScrollableController();

  final LatLng _ahmedabadCenter = const LatLng(23.0225, 72.5714);

  final List<Map<String, dynamic>> _properties = [
    {
      'title': 'Celestial Heights',
      'location': 'Bopal, Ahmedabad',
      'price': '₹85 L',
      'specs': '2 BHK • 1,240 sq.ft',
      'image': 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=600',
      'isVerified': true,
      'isReady': true,
      'isSelected': true,
    },
    {
      'title': 'Green Valley Homes',
      'location': 'South Bopal, Ahmedabad',
      'price': '₹68 L',
      'specs': '2 BHK • 1,100 sq.ft',
      'image': 'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=600',
      'isVerified': true,
      'isReady': false,
      'isSelected': false,
    },
    {
      'title': 'Skyline Heights',
      'location': 'Thaltej, Ahmedabad',
      'price': '₹72 L',
      'specs': '2 BHK • 1,180 sq.ft',
      'image': 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=600',
      'isVerified': false,
      'isReady': true,
      'isSelected': false,
    },
  ];

  // Function to bring the sheet back up smoothly
  void _resetSheetPosition() {
    _sheetController.animateTo(
      0.38, // Initial visible height
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [


            // 1. Map View Background
            FlutterMap(
              options: MapOptions(
                initialCenter: _ahmedabadCenter,
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.diginiwas',
                ),

                MarkerLayer(
                  markers: [
                    Marker(
                      point: const LatLng(23.0338, 72.5850),
                      width: 80,
                      height: 40,
                      child: _buildMapPriceMarker('₹85 L', true),
                    ),
                    Marker(
                      point: const LatLng(23.0100, 72.5500),
                      width: 80,
                      height: 40,
                      child: _buildMapPriceMarker('₹68 L', false),
                    ),
                  ],
                ),
              ],
            ),

            // 2. Foreground UI Overlays (Header, Search, Tabs, and Filter Chips)
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
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
                                  controller: _searchController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Search location or property',
                                    hintStyle: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome,
                                  size: 18,
                                  color: Color(0xFF0F4C3A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Dynamic List / Map Tab Switcher
                        Container(
                          height: 46,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
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
                                      color: _selectedTabIndex == 0
                                          ? const Color(0xFF0F4C3A)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Text(
                                      'List',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: _selectedTabIndex == 0
                                            ? Colors.white
                                            : Colors.grey.shade700,
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
                                      color: _selectedTabIndex == 1
                                          ? const Color(0xFF0F4C3A)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: _selectedTabIndex == 1
                                              ? Colors.white
                                              : Colors.grey.shade700,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Map',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: _selectedTabIndex == 1
                                                ? Colors.white
                                                : Colors.grey.shade700,
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
                        const SizedBox(height: 12),

                        // Filter Chips Row Added Back
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip('Under ₹1 Cr', isDropdown: true),
                              const SizedBox(width: 8),
                              _buildFilterChip('Verified', isGreen: true),
                              const SizedBox(width: 8),
                              _buildFilterChip('Ready to Move'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 3. Draggable Scrollable Bottom Sheet with SafeArea applied inside
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.38,
              minChildSize: 0.0, // Allows bottom sheet to collapse entirely out of view
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
                    top: false, // Ensures safe area applies exclusively to bottom system bar padding
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        // Drag handle bar
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
                              const Text(
                                '12 homes in this area',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.search,
                                    size: 14, color: Color(0xFF0F4C3A)),
                                label: const Text(
                                  'Search this area',
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
                          child: ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _properties.length,
                            itemBuilder: (context, index) {
                              return _buildDetailedPropertyCard(_properties[index]);
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
      // Floating Action Button to restore the bottom sheet back onto the screen
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _resetSheetPosition,
        backgroundColor: const Color(0xFF0F4C3A),
        icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
        label: const Text('Show Properties', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildMapPriceMarker(String price, bool isSelected) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF0F4C3A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.white : const Color(0xFF0F4C3A),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        price,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF0F4C3A),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label,
      {bool isDropdown = false, bool isGreen = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isGreen ? const Color(0xFFE8F5E9) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGreen ? const Color(0xFF81C784) : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (isGreen)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.check_circle, size: 14, color: Color(0xFF2E7D32)),
            ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isGreen ? const Color(0xFF2E7D32) : Colors.black87,
            ),
          ),
          if (isDropdown)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.keyboard_arrow_down, size: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailedPropertyCard(Map<String, dynamic> property) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              property['image'],
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(property['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(property['location'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border, size: 20)),
            ],
          ),
          Text(property['price'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F4C3A))),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(

              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF173554),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('View Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}