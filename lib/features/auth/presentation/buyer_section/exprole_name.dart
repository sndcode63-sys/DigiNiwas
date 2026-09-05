import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';


class ExproleName extends StatefulWidget {
  const ExproleName({Key? key}) : super(key: key);

  @override
  State<ExproleName> createState() => _ExproleNameState();
}

class _ExproleNameState extends State<ExproleName> {
  bool isLoading = false;
  List<PropertyModel> properties = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchProperties();
  }

  Future<void> fetchProperties() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
      properties = [
        PropertyModel(
          id: '1',
          title: 'Celestial Heights',
          location: 'Bopal, Ahmedabad',
          price: '₹85 L',
          imageUrl: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=600',
          bhk: '2 BHK',
          area: '1,150 sqft',
          possession: 'Ready',
          isVerified: true,
          badgeText: 'MATCHES YOUR BUDGET',
        ),
        PropertyModel(
          id: '2',
          title: 'EcoPark Residences',
          location: 'South Bopal, Ahmedabad',
          price: '₹92 L',
          imageUrl: 'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=600',
          bhk: '2 BHK',
          area: '1,210 sqft',
          possession: 'Dec \'24',
          isVerified: true,
          badgeText: 'GOOD LOCALITY MATCH',
          isCompared: true,
        ),
      ];
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: fetchProperties,
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: _HeaderSection()),
                  const SliverToBoxAdapter(child: _AiSummaryCard()),
                  if (isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF00C896))),
                    )
                  else if (errorMessage.isNotEmpty)
                    SliverFillRemaining(
                      child: Center(child: Text('Error: $errorMessage', style: const TextStyle(color: Colors.red))),
                    )
                  else if (properties.isEmpty)
                      const SliverFillRemaining(
                        child: Center(child: Text('No properties found')),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            return _PropertyCard(
                              property: properties[index],
                              onCompareChanged: (val) {
                                setState(() {
                                  properties[index].isCompared = val ?? false;
                                });
                              },
                            );
                          },
                          childCount: properties.length,
                        ),
                      ),
                  const SliverToBoxAdapter(child: SizedBox(height: 90)),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _CompareFloatingBar(
                count: properties.where((p) => p.isCompared).length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Header Component (Map View Navigation Added) ---
class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Icon(Icons.menu, color: Colors.black87),
              Row(
                children: [
                  Icon(Icons.home_outlined, color: Color(0xFF00C896), size: 22),
                  SizedBox(width: 4),
                  Text('DIGINIWAS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF00C896), letterSpacing: 1.1)),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.favorite_border, color: Colors.black87),
                  SizedBox(width: 12),
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Color(0xFFE2F3F5),
                    child: Text('RS', style: TextStyle(fontSize: 10, color: Color(0xFF00838F), fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.search, color: Colors.grey),
                hintText: '2 BHK in Ahmedabad',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                suffixIcon: Icon(Icons.mic_none, color: Color(0xFF00C896)),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('2,468 Properties Found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A2129))),
          const Text('Available in Ahmedabad, Gujarat', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterButton(Icons.sort, 'Sort', () {}),
                const SizedBox(width: 8),
                _buildFilterButton(Icons.tune, 'Filters', () {}),
                const SizedBox(width: 8),
                // Map View Click Action
                _buildFilterButton(Icons.map_outlined, 'Map View', () {
                  context.push(AppRoutes.mapView);
                }, isPrimary: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(IconData icon, String label, VoidCallback onTap, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF173554) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isPrimary ? Colors.transparent : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isPrimary ? Colors.white : Colors.black87),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, color: isPrimary ? Colors.white : Colors.black87, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// --- AI Summary Card ---
class _AiSummaryCard extends StatelessWidget {
  const _AiSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB5E4E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 16, color: Color(0xFF009688)),
              SizedBox(width: 6),
              Text('Niwas AI Smart Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF00796B))),
            ],
          ),
          SizedBox(height: 6),
          Text('Found highly rated 2 BHKs in Bopal area fitting your budget. They feature modern amenities and high connectivity.', style: TextStyle(fontSize: 11.5, color: Colors.black87, height: 1.3)),
        ],
      ),
    );
  }
}

// --- Property Card Component ---
class _PropertyCard extends StatelessWidget {
  final PropertyModel property;
  final ValueChanged<bool?> onCompareChanged;

  const _PropertyCard({required this.property, required this.onCompareChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  property.imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 160,
                    color: Colors.grey.shade200,
                    child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                  ),
                ),
              ),
              if (property.isVerified)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      children: const [
                        Icon(Icons.verified, size: 12, color: Color(0xFF00C896)),
                        SizedBox(width: 4),
                        Text('Verified', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(property.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(property.price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A2129))),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(property.location, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                if (property.badgeText != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFE2F8F5), borderRadius: BorderRadius.circular(4)),
                    child: Text(property.badgeText!, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF00A87A))),
                  ),
                  const SizedBox(height: 10),
                ],
                const Divider(height: 1, color: Colors.black12),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSpecItem('BHK', property.bhk),
                    _buildSpecItem('Area', property.area),
                    _buildSpecItem('Possession', property.possession),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onCompareChanged(!property.isCompared),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: property.isCompared ? const Color(0xFF00C896) : Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 18,
                              width: 18,
                              child: Checkbox(
                                value: property.isCompared,
                                onChanged: onCompareChanged,
                                activeColor: const Color(0xFF00C896),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('Compare', style: TextStyle(fontSize: 12, color: Colors.black87)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF173554),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        child: const Text('View Details', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }
}

// --- Floating Compare Bar ---
class _CompareFloatingBar extends StatelessWidget {
  final int count;

  const _CompareFloatingBar({required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF26C6DA),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white,
                child: Text('$count', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00ACC1))),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Compare properties', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('Side by side analysis', style: TextStyle(color: Colors.white70, fontSize: 10)),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF00ACC1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: const Text('Compare →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class PropertyModel {
  final String id;
  final String title;
  final String location;
  final String price;
  final String imageUrl;
  final String bhk;
  final String area;
  final String possession;
  final bool isVerified;
  final String? badgeText;
  bool isCompared;

  PropertyModel({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.bhk,
    required this.area,
    required this.possession,
    this.isVerified = false,
    this.badgeText,
    this.isCompared = false,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      price: json['price'] ?? '',
      imageUrl: json['image_url'] ?? '',
      bhk: json['bhk'] ?? '',
      area: json['area'] ?? '',
      possession: json['possession'] ?? '',
      isVerified: json['is_verified'] ?? false,
      badgeText: json['badge_text'],
      isCompared: json['is_compared'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'price': price,
      'image_url': imageUrl,
      'bhk': bhk,
      'area': area,
      'possession': possession,
      'is_verified': isVerified,
      'badge_text': badgeText,
      'is_compared': isCompared,
    };
  }
}



class _MapPinBadge extends StatelessWidget {
  final String price;
  final bool isSelected;
  const _MapPinBadge({required this.price, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF00796B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6)],
        border: Border.all(color: isSelected ? Colors.white : Colors.grey.shade300, width: 1.5),
      ),
      child: Text(price, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }
}

class _MapPropertyCard extends StatelessWidget {
  final String title, location, price, specs, imageUrl;
  final bool isSelected;

  const _MapPropertyCard({
    required this.title,
    required this.location,
    required this.price,
    required this.specs,
    required this.imageUrl,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? const Color(0xFF00A87A) : Colors.grey.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Image.network(imageUrl, height: 115, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF00796B))),
                  ],
                ),
                const SizedBox(height: 2),
                Text(location, style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(specs, style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF173554),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('View Details', style: TextStyle(fontSize: 11, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}