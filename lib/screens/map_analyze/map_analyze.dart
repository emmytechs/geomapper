import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geo_mapper/models/geo_feature.dart';
import 'package:geo_mapper/models/geo_geometry.dart';
import 'package:geo_mapper/utils/shapefile_handler.dart';
import 'package:latlong2/latlong.dart';
import 'package:geo_mapper/models/map_files_model.dart';

class MapAnalyze extends StatefulWidget {
  const MapAnalyze({super.key, required this.model});

  final MapFilesModel model;

  @override
  State<MapAnalyze> createState() => _MapAnalyzeState();
}

class _MapAnalyzeState extends State<MapAnalyze> {
  final MapController _mapController = MapController();
  List<Polyline> _polylines = [];

  @override
  void initState() {
    super.initState();
    _loadShapefile();
  }

  Future<void> _loadShapefile() async {
    final shapefileHandler = ShapefileHandler();

    try {
      await shapefileHandler.readShapefile(
        widget.model.shpPath!,
        widget.model.dbfPath!,
      );

      final features = shapefileHandler.features;
      _updateMapWithFeatures(features);
    } catch (e) {
      debugPrint('Failed to load shapefile: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load shapefile: $e')));
      }
    }
  }

  void _updateMapWithFeatures(List<GeoFeature> features) {
    final List<Polyline> polylines = [];

    for (var feature in features) {
      // Debugging: print all available attributes
      if (feature.geometry is GeoLineString) {
        final points = (feature.geometry as GeoLineString).points;

        // Optional: Classify type using sourceId or line length
        final type = _classifyLineament(feature);
        final color = _getColorByType(type);

        polylines.add(Polyline(points: points, strokeWidth: 1.0, color: color));
      }
    }

    setState(() {
      _polylines = polylines;

      if (_polylines.isNotEmpty) {
        _mapController.move(_polylines.first.points.first, 10.0);
      }
    });
  }

  String _classifyLineament(GeoFeature feature) {
    final sourceId = feature.properties['sourceId']?.toString() ?? '';

    // You can refine this mapping or apply geometry-based rules
    const idMap = {'620': 'fault', '104': 'fold', '1003': 'joint'};

    return idMap[sourceId] ?? 'unknown';
  }

  Color _getColorByType(String type) {
    switch (type) {
      case 'fault':
        return Colors.red;
      case 'fold':
        return Colors.blue;
      case 'joint':
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 60,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(color: Color(0xffa9a9a9)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.map, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text("GeoMapper", style: TextStyle(color: Colors.white)),
                  ],
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF42a552),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    minimumSize: Size(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text("Upload", style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 13),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFffffff),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    minimumSize: Size(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    "Visualize",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(width: 13),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFffffff),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    minimumSize: Size(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    "Analyze & Export",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(10.0, 8.0),
                      initialZoom: 5.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.opentopomap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.geo_mapper',
                        maxZoom: 27,
                      ),
                      PolylineLayer(polylines: _polylines),
                    ],
                  ),
                ),
                Container(
                  width: 280, // Adjust width as needed
                  color: Colors.grey[200],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "Settings & Options",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      // Add your settings widgets here
                      ListTile(
                        leading: Icon(Icons.layers),
                        title: Text("Layer Control"),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text("About"),
                        onTap: () {},
                      ),
                    ],
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
