// lib/core/models.dart
// Core models for the route tracking app.
// Copy this file to all Flutter projects (edit_routes, driver, dashboard).
//
// GLOSSARY:
//   Waypoint             — a single geographic point on the map (a lat/lng coordinate
//                          the driver passes through or stops at)
//   requiresStop         — flag on a waypoint indicating the driver must physically
//                          stop there — almost always false
//   routeWaypointsList   — the complete flat ordered list of all waypoints for a route:
//                          start → middles → end
//   startWaypoint        — the first waypoint in routeWaypointsList — where the driver
//                          begins (green pin)
//   endWaypoint          — the last waypoint in routeWaypointsList — where the driver
//                          finishes (red pin)
//   middleWaypoints      — all waypoints between start and end — the drive-through
//                          points in between (blue pins)
//   RoutePart            — a chunk of up to 25 waypoints created by the route editor
//                          screen to satisfy Google Directions API limits
//   routeParts           — the full list of RoutePart chunks for a route — created when
//                          the waypoint limit is reached in the route editor so the
//                          driver can continue seamlessly; used by the driver app
//   DriverRoute             — the complete route document for one driver; includes route
//                          name, routeWaypointsList and routeParts — both written by
//                          the editor
//   LiveLocation         — the driver's current real-time GPS position, updated every
//                          5–10 seconds
//   LocationHistoryEntry — a single recorded position ping from a driver — append-only
//                          log used for route log and confirming actual arrival time
//                          and time to reach current waypoint

import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

// ─────────────────────────────────────────────────────────────────────────────
// WAYPOINT
// A single geographic point on the map (a lat/lng coordinate the driver passes
// through or stops at). Almost always a drive-through point — requiresStop is
// false by default and flipped to true only for rare physical stops.
// ─────────────────────────────────────────────────────────────────────────────
class Waypoint {
  final String? id; // MongoDB _id as string
  final double lat;
  final double lng;
  final String? streetName; // human-readable street name
  final String? address; // full address if available
  final int order; // 0-based position in routeWaypointsList
  final bool requiresStop; // almost always false — driver just drives through
  final int estimatedMinutesFromStart; // cumulative minutes from route origin
  final DateTime? estimatedEta; // absolute predicted arrival clock time
  final DateTime?
      actualArrivalTime; // filled by driver app on arrival (if requiresStop)
  final int? delayMinutes; // positive = late, negative = early

  const Waypoint({
    this.id,
    required this.lat,
    required this.lng,
    this.streetName,
    this.address,
    required this.order,
    this.requiresStop = false,
    this.estimatedMinutesFromStart = 0,
    this.estimatedEta,
    this.actualArrivalTime,
    this.delayMinutes,
  });

  LatLng get latLng => LatLng(lat, lng);

  factory Waypoint.fromJson(Map<String, dynamic> json) => Waypoint(
        id: json['id'] as String?,
        lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
        lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
        streetName: json['street_name'] as String?,
        address: json['address'] as String?,
        order: (json['order'] as num?)?.toInt() ?? 0,
        requiresStop: json['requires_stop'] as bool? ?? false,
        estimatedMinutesFromStart:
            (json['estimated_minutes_from_start'] as num?)?.toInt() ?? 0,
        estimatedEta: json['estimated_eta'] != null
            ? DateTime.tryParse(json['estimated_eta'] as String)
            : null,
        actualArrivalTime: json['actual_arrival_time'] != null
            ? DateTime.tryParse(json['actual_arrival_time'] as String)
            : null,
        delayMinutes: (json['delay_minutes'] as num?)?.toInt(),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'lat': lat,
        'lng': lng,
        if (streetName != null) 'street_name': streetName,
        if (address != null) 'address': address,
        'order': order,
        'requires_stop': requiresStop,
        'estimated_minutes_from_start': estimatedMinutesFromStart,
        if (estimatedEta != null)
          'estimated_eta': estimatedEta!.toUtc().toIso8601String(),
        if (actualArrivalTime != null)
          'actual_arrival_time': actualArrivalTime!.toUtc().toIso8601String(),
        if (delayMinutes != null) 'delay_minutes': delayMinutes,
      };

  Waypoint copyWith({
    String? id,
    double? lat,
    double? lng,
    String? streetName,
    String? address,
    int? order,
    bool? requiresStop,
    int? estimatedMinutesFromStart,
    DateTime? estimatedEta,
    DateTime? actualArrivalTime,
    int? delayMinutes,
  }) =>
      Waypoint(
        id: id ?? this.id,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        streetName: streetName ?? this.streetName,
        address: address ?? this.address,
        order: order ?? this.order,
        requiresStop: requiresStop ?? this.requiresStop,
        estimatedMinutesFromStart:
            estimatedMinutesFromStart ?? this.estimatedMinutesFromStart,
        estimatedEta: estimatedEta ?? this.estimatedEta,
        actualArrivalTime: actualArrivalTime ?? this.actualArrivalTime,
        delayMinutes: delayMinutes ?? this.delayMinutes,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// ROUTE PART
// A chunk of up to 25 waypoints created by the route editor screen to satisfy
// Google Directions API limits. When the limit is reached the editor starts a
// new RoutePart so the driver can continue seamlessly.
// Part 1 is driven first, then part 2, etc.
// ─────────────────────────────────────────────────────────────────────────────
class RoutePart {
  final String? id;
  final int partNumber; // 1-based sequence (1 = first leg)
  final List<Waypoint> waypoints; // up to 25 waypoints for this chunk

  const RoutePart({
    this.id,
    required this.partNumber,
    required this.waypoints,
  });

  factory RoutePart.fromJson(Map<String, dynamic> json) => RoutePart(
        id: json['id'] as String?,
        partNumber: (json['part_number'] as num?)?.toInt() ?? 1,
        waypoints: (json['waypoints'] as List<dynamic>? ?? [])
            .map((e) => Waypoint.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'part_number': partNumber,
        'waypoints': waypoints.map((w) => w.toJson()).toList(),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// APP ROUTE
// The complete route document for one driver. Includes the route name,
// routeWaypointsList (flat ordered list) and routeParts (chunked legs) —
// both written by the route editor.
// Status lifecycle: planned → active → completed
// ─────────────────────────────────────────────────────────────────────────────
class DriverRoute {
  final String? id; // MongoDB _id (assigned on insert)
  final String driverId;
  final String name; // human-readable route name set by the manager
  final DateTime assignedDate;
  final String? notes; // optional dispatcher notes
  final String status; // planned | active | completed
  final List<Waypoint>
      waypoints; // flat source-of-truth list written by the editor
  final List<RoutePart>
      routeParts; // chunked legs (≤25 waypoints each) for Google Directions
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DriverRoute({
    this.id,
    required this.driverId,
    required this.name,
    required this.assignedDate,
    this.notes,
    this.status = 'planned',
    required this.waypoints,
    this.routeParts = const [],
    this.createdAt,
    this.updatedAt,
  });

  // ── routeWaypointsList ────────────────────────────────────────────────────
  // The complete flat ordered list of all waypoints: start → middles → end.

  List<Waypoint> get routeWaypointsList =>
      [...waypoints]..sort((a, b) => a.order.compareTo(b.order));

  // The first waypoint — where the driver begins (green pin).
  Waypoint? get startWaypoint =>
      routeWaypointsList.isNotEmpty ? routeWaypointsList.first : null;

  // The last waypoint — where the driver finishes (red pin).
  Waypoint? get endWaypoint =>
      routeWaypointsList.length > 1 ? routeWaypointsList.last : null;

  // All waypoints between start and end — drive-through points (blue pins).
  List<Waypoint> get middleWaypoints => routeWaypointsList.length > 2
      ? routeWaypointsList.sublist(1, routeWaypointsList.length - 1)
      : [];

  // ── serialisation ─────────────────────────────────────────────────────────

  factory DriverRoute.fromJson(Map<String, dynamic> json) => DriverRoute(
        id: json['id'] as String?,
        driverId: json['driver_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        assignedDate:
            DateTime.tryParse(json['assigned_date'] as String? ?? '') ??
                DateTime.now(),
        notes: json['notes'] as String?,
        status: json['status'] as String? ?? 'planned',
        waypoints: (json['waypoints'] as List<dynamic>? ?? [])
            .map((e) => Waypoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        routeParts: (json['route_parts'] as List<dynamic>? ?? [])
            .map((e) => RoutePart.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'driver_id': driverId,
        'name': name,
        'assigned_date': assignedDate.toUtc().toIso8601String(),
        if (notes != null) 'notes': notes,
        'status': status,
        'waypoints': waypoints.map((w) => w.toJson()).toList(),
        'route_parts': routeParts.map((p) => p.toJson()).toList(),
        if (createdAt != null)
          'created_at': createdAt!.toUtc().toIso8601String(),
        if (updatedAt != null)
          'updated_at': updatedAt!.toUtc().toIso8601String(),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// LIVE LOCATION
// The driver's current real-time GPS position, updated every 5–10 seconds.
// One document per driver in the live_locations collection — always upserted.
// The dashboard subscribes to changes to show drivers moving on the map.
// ─────────────────────────────────────────────────────────────────────────────
class LiveLocation {
  final String driverId;
  final double lat;
  final double lng;
  final String? street;
  final DateTime lastUpdated;
  final bool isActive;
  final int?
      currentStopOrder; // order number of the waypoint the driver is heading to
  final DateTime? nextStopEta;
  final int? deviationMeters; // 0 = on route

  const LiveLocation({
    required this.driverId,
    required this.lat,
    required this.lng,
    this.street,
    required this.lastUpdated,
    this.isActive = true,
    this.currentStopOrder,
    this.nextStopEta,
    this.deviationMeters,
  });

  LatLng get latLng => LatLng(lat, lng);

  factory LiveLocation.fromJson(Map<String, dynamic> json) => LiveLocation(
        driverId: json['driver_id'] as String? ?? '',
        lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
        lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
        street: json['street'] as String?,
        lastUpdated: DateTime.tryParse(json['last_updated'] as String? ?? '') ??
            DateTime.now(),
        isActive: json['is_active'] as bool? ?? true,
        currentStopOrder: (json['current_stop_order'] as num?)?.toInt(),
        nextStopEta: json['next_stop_eta'] != null
            ? DateTime.tryParse(json['next_stop_eta'] as String)
            : null,
        deviationMeters: (json['deviation_meters'] as num?)?.toInt(),
      );

  Map<String, dynamic> toJson() => {
        'driver_id': driverId,
        'lat': lat,
        'lng': lng,
        if (street != null) 'street': street,
        'last_updated': lastUpdated.toUtc().toIso8601String(),
        'is_active': isActive,
        if (currentStopOrder != null) 'current_stop_order': currentStopOrder,
        if (nextStopEta != null)
          'next_stop_eta': nextStopEta!.toUtc().toIso8601String(),
        if (deviationMeters != null) 'deviation_meters': deviationMeters,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCATION HISTORY ENTRY
// A single recorded position ping from a driver — append-only log used for
// route log and confirming actual arrival time and time to reach current waypoint.
// Stored in its own location_history collection (high-write, time-series style).
// ─────────────────────────────────────────────────────────────────────────────
class LocationHistoryEntry {
  final String? id;
  final String driverId;
  final double lat;
  final double lng;
  final String? street;
  final DateTime timestamp;
  final String? routeId;
  final int? stopOrder;
  final bool actualArrival; // true = driver tapped "I've arrived"
  final int? delayMinutes; // positive = late, negative = early

  const LocationHistoryEntry({
    this.id,
    required this.driverId,
    required this.lat,
    required this.lng,
    this.street,
    required this.timestamp,
    this.routeId,
    this.stopOrder,
    this.actualArrival = false,
    this.delayMinutes,
  });

  LatLng get latLng => LatLng(lat, lng);

  factory LocationHistoryEntry.fromJson(Map<String, dynamic> json) =>
      LocationHistoryEntry(
        id: json['id'] as String?,
        driverId: json['driver_id'] as String? ?? '',
        lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
        lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
        street: json['street'] as String?,
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
            DateTime.now(),
        routeId: json['route_id'] as String?,
        stopOrder: (json['stop_order'] as num?)?.toInt(),
        actualArrival: json['actual_arrival'] as bool? ?? false,
        delayMinutes: (json['delay_minutes'] as num?)?.toInt(),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'driver_id': driverId,
        'lat': lat,
        'lng': lng,
        if (street != null) 'street': street,
        'timestamp': timestamp.toUtc().toIso8601String(),
        if (routeId != null) 'route_id': routeId,
        if (stopOrder != null) 'stop_order': stopOrder,
        'actual_arrival': actualArrival,
        if (delayMinutes != null) 'delay_minutes': delayMinutes,
      };
}