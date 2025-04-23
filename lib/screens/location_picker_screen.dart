import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class LocationPickerScreen extends StatefulWidget {
  final String title;

  const LocationPickerScreen({Key? key, required this.title}) : super(key: key);

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late MapController mapController;
  final TextEditingController searchController = TextEditingController();
  List<SearchInfo> searchResults = [];
  bool isSearching = false;
  bool isMapReady = false;
  GeoPoint? selectedLocation;
  final GeoPoint defaultLocation = GeoPoint(latitude: 36.818970, longitude: 10.165790);
  String? selectedAddress;

  @override
  void initState() {
    super.initState();
    mapController = MapController(
      initPosition: defaultLocation,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMap();
    });
  }

  Future<void> _initializeMap() async {
    try {
      await mapController.enableUserLocation();
      await _getCurrentLocation();
    } catch (e) {
      print("Error initializing map: $e");
      await _goToDefaultLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final userLocation = await mapController.myLocation();
      await mapController.goToLocation(userLocation);
      final address = await addressFromGeoPoint(userLocation);
      setState(() {
        selectedLocation = userLocation;
        selectedAddress = address;
        isMapReady = true;
      });
    } catch (e) {
      print("Error getting current location: $e");
      await _goToDefaultLocation();
    }
  }

  Future<void> _goToDefaultLocation() async {
    try {
      await mapController.goToLocation(defaultLocation);
      final address = await addressFromGeoPoint(defaultLocation);
      setState(() {
        selectedLocation = defaultLocation;
        selectedAddress = address;
        isMapReady = true;
      });
    } catch (e) {
      print("Error going to default location: $e");
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      var results = await addressSuggestion(query);
      setState(() {
        searchResults = results;
        isSearching = false;
      });
    } catch (e) {
      print("Error searching places: $e");
      setState(() {
        searchResults = [];
        isSearching = false;
      });
    }
  }

  Future<void> _handleLocationSelected(GeoPoint point, {String? address}) async {
    try {
      // If address is not provided, get it from the point
      final locationAddress = address ?? await addressFromGeoPoint(point);

      await mapController.goToLocation(point);
      await mapController.setMarker(point);

      setState(() {
        selectedLocation = point;
        selectedAddress = locationAddress;
        searchResults = [];
        searchController.clear();
      });

      if (mounted) {
        Navigator.pop(context, {
          'location': point,
          'address': locationAddress,
        });
      }
    } catch (e) {
      print("Error handling location selection: $e");
    }
  }

  @override
  void dispose() {
    mapController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF1b4242),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search location...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _searchPlaces,
            ),
          ),
          if (searchResults.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(searchResults[index].address.toString()),
                    onTap: () async {
                      try {
                        final point = await searchResults[index].point;
                        if (point != null) {
                          await _handleLocationSelected(
                            point,
                            address: searchResults[index].address.toString(),
                          );
                        }
                      } catch (e) {
                        print("Error selecting search result: $e");
                      }
                    },
                  );
                },
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                OSMFlutter(
                  controller: mapController,
                  osmOption: OSMOption(
                    userTrackingOption: UserTrackingOption(
                      enableTracking: true,
                      unFollowUser: true,
                    ),
                    zoomOption: ZoomOption(
                      initZoom: 15,
                      minZoomLevel: 3,
                      maxZoomLevel: 19,
                      stepZoom: 1.0,
                    ),
                    userLocationMarker: UserLocationMaker(
                      personMarker: MarkerIcon(
                        icon: Icon(
                          Icons.location_history_rounded,
                          color: Colors.blue,
                          size: 48,
                        ),
                      ),
                      directionArrowMarker: MarkerIcon(
                        icon: Icon(
                          Icons.navigation,
                          color: Colors.blue,
                          size: 48,
                        ),
                      ),
                    ),
                    roadConfiguration: RoadOption(
                      roadColor: Colors.blueAccent,
                    ),
                    markerOption: MarkerOption(
                      defaultMarker: MarkerIcon(
                        icon: Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 56,
                        ),
                      ),
                    ),
                  ),
                  onMapIsReady: (ready) {
                    if (ready && !isMapReady) {
                      _initializeMap();
                    }
                  },
                  onGeoPointClicked: (point) async {
                    await _handleLocationSelected(point);
                  },
                  mapIsLoading: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                if (!isMapReady)
                  Container(
                    color: Colors.white,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                if (selectedLocation != null && selectedAddress != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        selectedAddress!,
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
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

Future<String> addressFromGeoPoint(GeoPoint point) async {
  try {
    // Use the built-in address suggestion with coordinates
    final addresses = await addressSuggestion(
      "${point.latitude},${point.longitude}",
    );

    if (addresses.isNotEmpty) {
      // Get the full address string
      String fullAddress = addresses.first.address.toString();

      // Split the address by commas and clean up each part
      List<String> parts = fullAddress.split(',').map((e) => e.trim()).toList();

      // Take the first 3 parts for a cleaner address
      // If there are less than 3 parts, it will take all available parts
      String cleanAddress = parts.take(3).join(', ');

      return cleanAddress;
    }
  } catch (e) {
    print("Error getting address: $e");
  }

  // Fallback to a simple formatted string if everything fails
  return "Location near ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}";
}

extension on MapController {
  enableUserLocation() {}
  setMarker(GeoPoint point) {}
}