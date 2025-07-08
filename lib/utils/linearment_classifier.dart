import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geo_mapper/models/geo_feature.dart';
import 'package:geo_mapper/models/geo_geometry.dart';

/// Classification result with confidence score
class ClassificationResult {
  final String type;
  final double confidence;
  final Map<String, double> metrics;

  ClassificationResult({
    required this.type,
    required this.confidence,
    required this.metrics,
  });
}

class LineamentClassifier {
  /// Classify a lineament based on geometric properties
  static ClassificationResult classifyLineament(GeoFeature feature) {
    if (feature.geometry is! GeoLineString) {
      return ClassificationResult(
        type: 'unknown',
        confidence: 0.0,
        metrics: {},
      );
    }

    final lineString = feature.geometry as GeoLineString;
    final points = lineString.points;

    if (points.length < 2) {
      return ClassificationResult(
        type: 'unknown',
        confidence: 0.0,
        metrics: {},
      );
    }

    // Calculate geometric metrics
    final metrics = _calculateGeometricMetrics(points);

    // Apply classification rules
    final classification = _applyClassificationRules(
      metrics,
      feature.properties,
    );

    return classification;
  }

  /// Calculate comprehensive geometric metrics for lineament analysis
  static Map<String, double> _calculateGeometricMetrics(List<LatLng> points) {
    final metrics = <String, double>{};

    // Basic length calculation
    metrics['length'] = _calculateLength(points);

    // Curvature analysis
    metrics['meanCurvature'] = _calculateMeanCurvature(points);
    metrics['maxCurvature'] = _calculateMaxCurvature(points);
    metrics['curvatureVariation'] = _calculateCurvatureVariation(points);

    // Straightness metrics
    metrics['straightnessIndex'] = _calculateStraightnessIndex(points);
    metrics['sinuosity'] = _calculateSinuosity(points);

    // Orientation analysis
    metrics['generalOrientation'] = _calculateGeneralOrientation(points);
    metrics['orientationVariation'] = _calculateOrientationVariation(points);

    // Fractal dimension (complexity measure)
    metrics['fractalDimension'] = _calculateFractalDimension(points);

    // Roughness measures
    metrics['roughnessIndex'] = _calculateRoughnessIndex(points);

    // Segment analysis
    metrics['segmentLengthVariation'] = _calculateSegmentLengthVariation(
      points,
    );
    metrics['bendingEnergy'] = _calculateBendingEnergy(points);

    // Density and spacing (if applicable)
    metrics['pointDensity'] = points.length / metrics['length']!;

    return metrics;
  }

  /// Apply classification rules based on geological knowledge
  static ClassificationResult _applyClassificationRules(
    Map<String, double> metrics,
    Map<String, dynamic> properties,
  ) {
    double faultScore = 0.0;
    double foldScore = 0.0;
    double jointScore = 0.0;

    // Check for sourceId in properties (existing classification)
    final sourceId = properties['sourceId']?.toString() ?? '';

    // Fault characteristics: Generally straight to slightly curved, high length
    if (metrics['straightnessIndex']! > 0.7) faultScore += 0.3;
    if (metrics['length']! > 1000) {
      faultScore += 0.2; // Faults are typically long
    }
    if (metrics['sinuosity']! < 1.3) faultScore += 0.2;
    if (metrics['curvatureVariation']! < 0.5) faultScore += 0.1;
    if (metrics['orientationVariation']! < 30) {
      faultScore += 0.2; // Relatively consistent orientation
    }

    // Fold characteristics: Curved, sinuous, moderate to high curvature
    if (metrics['meanCurvature']! > 0.1) foldScore += 0.3;
    if (metrics['sinuosity']! > 1.5) foldScore += 0.3;
    if (metrics['curvatureVariation']! > 0.3) foldScore += 0.2;
    if (metrics['bendingEnergy']! > 0.5) foldScore += 0.2;

    // Joint characteristics: Short, straight, consistent orientation
    if (metrics['length']! < 500) {
      jointScore += 0.3; // Joints are typically shorter
    }
    if (metrics['straightnessIndex']! > 0.8) jointScore += 0.3;
    if (metrics['orientationVariation']! < 15) jointScore += 0.2;
    if (metrics['roughnessIndex']! < 0.3) jointScore += 0.2;

    // Consider existing sourceId classification
    if (sourceId == '620') faultScore += 0.4;
    if (sourceId == '104') foldScore += 0.4;
    if (sourceId == '1003') jointScore += 0.4;

    // Determine classification
    String type = 'unknown';
    double confidence = 0.0;

    if (faultScore > foldScore && faultScore > jointScore) {
      type = 'fault';
      confidence = math.min(faultScore, 1.0);
    } else if (foldScore > jointScore) {
      type = 'fold';
      confidence = math.min(foldScore, 1.0);
    } else if (jointScore > 0.3) {
      type = 'joint';
      confidence = math.min(jointScore, 1.0);
    }

    return ClassificationResult(
      type: type,
      confidence: confidence,
      metrics: metrics,
    );
  }

  // Geometric calculation methods
  static double _calculateLength(List<LatLng> points) {
    double totalLength = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      totalLength += _haversineDistance(points[i], points[i + 1]);
    }
    return totalLength;
  }

  static double _calculateMeanCurvature(List<LatLng> points) {
    if (points.length < 3) return 0.0;

    double totalCurvature = 0.0;
    int count = 0;

    for (int i = 1; i < points.length - 1; i++) {
      final curvature = _calculatePointCurvature(
        points[i - 1],
        points[i],
        points[i + 1],
      );
      totalCurvature += curvature;
      count++;
    }

    return count > 0 ? totalCurvature / count : 0.0;
  }

  static double _calculateMaxCurvature(List<LatLng> points) {
    if (points.length < 3) return 0.0;

    double maxCurvature = 0.0;

    for (int i = 1; i < points.length - 1; i++) {
      final curvature = _calculatePointCurvature(
        points[i - 1],
        points[i],
        points[i + 1],
      );
      maxCurvature = math.max(maxCurvature, curvature);
    }

    return maxCurvature;
  }

  static double _calculateCurvatureVariation(List<LatLng> points) {
    if (points.length < 3) return 0.0;

    final curvatures = <double>[];
    for (int i = 1; i < points.length - 1; i++) {
      curvatures.add(
        _calculatePointCurvature(points[i - 1], points[i], points[i + 1]),
      );
    }

    if (curvatures.isEmpty) return 0.0;

    final mean = curvatures.reduce((a, b) => a + b) / curvatures.length;
    final variance =
        curvatures.map((c) => math.pow(c - mean, 2)).reduce((a, b) => a + b) /
        curvatures.length;

    return math.sqrt(variance);
  }

  static double _calculateStraightnessIndex(List<LatLng> points) {
    if (points.length < 2) return 0.0;

    final straightLineDistance = _haversineDistance(points.first, points.last);
    final actualLength = _calculateLength(points);

    return actualLength > 0 ? straightLineDistance / actualLength : 0.0;
  }

  static double _calculateSinuosity(List<LatLng> points) {
    if (points.length < 2) return 1.0;

    final straightLineDistance = _haversineDistance(points.first, points.last);
    final actualLength = _calculateLength(points);

    return straightLineDistance > 0 ? actualLength / straightLineDistance : 1.0;
  }

  static double _calculateGeneralOrientation(List<LatLng> points) {
    if (points.length < 2) return 0.0;

    final start = points.first;
    final end = points.last;

    final deltaLat = end.latitude - start.latitude;
    final deltaLng = end.longitude - start.longitude;

    return math.atan2(deltaLat, deltaLng) * 180 / math.pi;
  }

  static double _calculateOrientationVariation(List<LatLng> points) {
    if (points.length < 3) return 0.0;

    final orientations = <double>[];
    for (int i = 0; i < points.length - 1; i++) {
      final deltaLat = points[i + 1].latitude - points[i].latitude;
      final deltaLng = points[i + 1].longitude - points[i].longitude;
      orientations.add(math.atan2(deltaLat, deltaLng) * 180 / math.pi);
    }

    if (orientations.isEmpty) return 0.0;

    // Calculate circular variance for angles
    double sumSin = 0.0;
    double sumCos = 0.0;

    for (final angle in orientations) {
      final radians = angle * math.pi / 180;
      sumSin += math.sin(radians);
      sumCos += math.cos(radians);
    }

    final meanLength =
        math.sqrt(sumSin * sumSin + sumCos * sumCos) / orientations.length;
    return (1 - meanLength) * 180 / math.pi; // Convert to degrees
  }

  static double _calculateFractalDimension(List<LatLng> points) {
    // Simplified box-counting method
    if (points.length < 4) return 1.0;

    final scales = [1.0, 0.5, 0.25, 0.125];
    final counts = <double>[];

    for (final scale in scales) {
      int count = 0;
      // Simplified counting - in practice, you'd use proper box-counting
      for (int i = 0; i < points.length - 1; i++) {
        final distance = _haversineDistance(points[i], points[i + 1]);
        if (distance > scale) count++;
      }
      counts.add(count.toDouble());
    }

    // Calculate fractal dimension using log-log slope
    if (counts.length < 2) return 1.0;

    double sumLogScale = 0.0;
    double sumLogCount = 0.0;
    double sumLogScaleLogCount = 0.0;
    double sumLogScaleSquared = 0.0;

    for (int i = 0; i < scales.length && i < counts.length; i++) {
      if (counts[i] > 0) {
        final logScale = math.log(scales[i]);
        final logCount = math.log(counts[i]);

        sumLogScale += logScale;
        sumLogCount += logCount;
        sumLogScaleLogCount += logScale * logCount;
        sumLogScaleSquared += logScale * logScale;
      }
    }

    final n = scales.length;
    final denominator = n * sumLogScaleSquared - sumLogScale * sumLogScale;

    if (denominator == 0) return 1.0;

    final slope =
        (n * sumLogScaleLogCount - sumLogScale * sumLogCount) / denominator;
    return 1.0 - slope; // Fractal dimension
  }

  static double _calculateRoughnessIndex(List<LatLng> points) {
    if (points.length < 3) return 0.0;

    double totalDeviation = 0.0;
    final totalLength = _calculateLength(points);

    for (int i = 1; i < points.length - 1; i++) {
      // Calculate perpendicular distance from point to line segment
      final deviation = _perpendicularDistance(
        points[i - 1],
        points[i + 1],
        points[i],
      );
      totalDeviation += deviation;
    }

    return totalLength > 0 ? totalDeviation / totalLength : 0.0;
  }

  static double _calculateSegmentLengthVariation(List<LatLng> points) {
    if (points.length < 3) return 0.0;

    final lengths = <double>[];
    for (int i = 0; i < points.length - 1; i++) {
      lengths.add(_haversineDistance(points[i], points[i + 1]));
    }

    if (lengths.isEmpty) return 0.0;

    final mean = lengths.reduce((a, b) => a + b) / lengths.length;
    final variance =
        lengths.map((l) => math.pow(l - mean, 2)).reduce((a, b) => a + b) /
        lengths.length;

    return mean > 0
        ? math.sqrt(variance) / mean
        : 0.0; // Coefficient of variation
  }

  static double _calculateBendingEnergy(List<LatLng> points) {
    if (points.length < 3) return 0.0;

    double totalEnergy = 0.0;

    for (int i = 1; i < points.length - 1; i++) {
      final curvature = _calculatePointCurvature(
        points[i - 1],
        points[i],
        points[i + 1],
      );
      totalEnergy += curvature * curvature;
    }

    return totalEnergy;
  }

  // Helper methods
  static double _calculatePointCurvature(LatLng p1, LatLng p2, LatLng p3) {
    final a = _haversineDistance(p1, p2);
    final b = _haversineDistance(p2, p3);
    final c = _haversineDistance(p1, p3);

    if (a == 0 || b == 0) return 0.0;

    // Using the formula: curvature = 4 * Area / (a * b * c)
    final s = (a + b + c) / 2;
    final area = math.sqrt(s * (s - a) * (s - b) * (s - c));

    return (4 * area) / (a * b * c);
  }

  static double _haversineDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // Earth's radius in meters

    final lat1Rad = point1.latitude * math.pi / 180;
    final lat2Rad = point2.latitude * math.pi / 180;
    final deltaLatRad = (point2.latitude - point1.latitude) * math.pi / 180;
    final deltaLngRad = (point2.longitude - point1.longitude) * math.pi / 180;

    final a =
        math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLngRad / 2) *
            math.sin(deltaLngRad / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  static double _perpendicularDistance(
    LatLng lineStart,
    LatLng lineEnd,
    LatLng point,
  ) {
    // Calculate perpendicular distance from point to line segment
    final A = point.latitude - lineStart.latitude;
    final B = point.longitude - lineStart.longitude;
    final C = lineEnd.latitude - lineStart.latitude;
    final D = lineEnd.longitude - lineStart.longitude;

    final dot = A * C + B * D;
    final lenSq = C * C + D * D;

    if (lenSq == 0) return math.sqrt(A * A + B * B);

    final param = dot / lenSq;

    double xx, yy;

    if (param < 0) {
      xx = lineStart.latitude;
      yy = lineStart.longitude;
    } else if (param > 1) {
      xx = lineEnd.latitude;
      yy = lineEnd.longitude;
    } else {
      xx = lineStart.latitude + param * C;
      yy = lineStart.longitude + param * D;
    }

    final dx = point.latitude - xx;
    final dy = point.longitude - yy;

    return math.sqrt(dx * dx + dy * dy);
  }

  /// Get color based on classification type and confidence
  static Color getClassificationColor(String type, double confidence) {
    final alpha = (confidence * 255).toInt().clamp(100, 255);

    switch (type) {
      case 'fault':
        return Color.fromARGB(alpha, 255, 0, 0); // Red
      case 'fold':
        return Color.fromARGB(alpha, 0, 0, 255); // Blue
      case 'joint':
        return Color.fromARGB(alpha, 0, 255, 0); // Green
      case 'fracture':
        return Color.fromARGB(alpha, 255, 165, 0); // Orange
      case 'lineation':
        return Color.fromARGB(alpha, 128, 0, 128); // Purple
      default:
        return Color.fromARGB(alpha, 128, 128, 128); // Gray
    }
  }
}
