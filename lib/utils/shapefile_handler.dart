import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geo_mapper/models/geo_feature.dart';
import 'package:geo_mapper/models/geo_geometry.dart';
import 'package:latlong2/latlong.dart';

class ShapefileHandler {
  List<GeoFeature> features = [];

  Future<void> readShapefile(String shpPath, String dbfPath) async {
    // Validate file existence
    if (!File(shpPath).existsSync()) {
      throw Exception('SHP file not found at $shpPath');
    }
    if (!File(dbfPath).existsSync()) {
      throw Exception('DBF file not found at $dbfPath');
    }

    // Read the files
    final shpFile = File(shpPath);
    final dbfFile = File(dbfPath);

    final shpBytes = await shpFile.readAsBytes();
    final dbfBytes = await dbfFile.readAsBytes();

    final shpGeometries = _parseShpFile(shpBytes);
    final dbfAttributes = _parseDbfFile(dbfBytes);

    features.clear();
    for (int i = 0; i < shpGeometries.length && i < dbfAttributes.length; i++) {
      features.add(
        GeoFeature(geometry: shpGeometries[i], properties: dbfAttributes[i]),
      );
    }
  }

  List<GeoGeometry> _parseShpFile(Uint8List bytes) {
    final geometries = <GeoGeometry>[];
    final byteData = ByteData.view(bytes.buffer);

    // Skip the header (100 bytes)
    int offset = 100;

    while (offset < bytes.length) {
      // Read record header
      // final recordNumber = byteData.getUint32(offset, Endian.big);
      final contentLength = byteData.getUint32(offset + 4, Endian.big);
      offset += 8;

      // Read shape type
      final shapeType = byteData.getUint32(offset, Endian.little);
      offset += 4;

      switch (shapeType) {
        case 1: // Point
          final x = byteData.getFloat64(offset, Endian.little);
          final y = byteData.getFloat64(offset + 8, Endian.little);
          geometries.add(GeoPoint(LatLng(y, x)));
          offset += 16;
          break;
        case 3: // PolyLine
        case 5: // Polygon
          // Read bounding box
          offset += 32;

          final numParts = byteData.getUint32(offset, Endian.little);
          final numPoints = byteData.getUint32(offset + 4, Endian.little);
          offset += 8;

          // Read parts
          // final parts = List<int>.generate(numParts, (i) {
          //   return byteData.getUint32(offset + (i * 4), Endian.little);
          // });
          offset += numParts * 4;

          // Read points
          final points = List<LatLng>.generate(numPoints, (i) {
            final x = byteData.getFloat64(offset + (i * 16), Endian.little);
            final y = byteData.getFloat64(offset + (i * 16) + 8, Endian.little);
            return LatLng(y, x);
          });
          offset += numPoints * 16;

          if (shapeType == 3) {
            geometries.add(GeoLineString(points));
          } else {
            geometries.add(GeoPolygon(points));
          }
          break;
        default:
          if (kDebugMode) {
            print('Unsupported shape type: $shapeType');
          }
          offset += contentLength * 2 - 4;
      }
    }

    return geometries;
  }

  List<Map<String, dynamic>> _parseDbfFile(Uint8List bytes) {
    final attributes = <Map<String, dynamic>>[];
    final byteData = ByteData.view(bytes.buffer);

    // Parse DBF header
    final numRecords = byteData.getUint32(4, Endian.little);
    final headerLength = byteData.getUint16(8, Endian.little);
    // final recordLength = byteData.getUint16(10, Endian.little);

    // Parse field descriptors
    final fields = <String>[];
    final fieldLengths = <int>[];
    int fieldOffset = 32;
    while (bytes[fieldOffset] != 0x0D) {
      final fieldNameBytes = bytes.sublist(fieldOffset, fieldOffset + 11);
      final fieldName = String.fromCharCodes(fieldNameBytes).trim();
      fields.add(fieldName);
      fieldLengths.add(bytes[fieldOffset + 16]); // field length is at offset 16
      fieldOffset += 32;
    }

    // Parse records
    int offset = headerLength;
    for (int i = 0; i < numRecords; i++) {
      final record = <String, dynamic>{};
      offset++; // Skip the deletion flag
      for (int f = 0; f < fields.length; f++) {
        final field = fields[f];
        final length = fieldLengths[f];
        if (offset + length > bytes.length) {
          break; // Defensive: don't read past end
        }
        final valueBytes = bytes.sublist(offset, offset + length);
        final value = String.fromCharCodes(valueBytes).trim();
        record[field] = value;
        offset += length;
      }
      attributes.add(record);
    }

    return attributes;
  }

  void addFeature(GeoFeature feature) {
    features.add(feature);
  }

  void removeFeature(GeoFeature feature) {
    features.remove(feature);
  }
}
