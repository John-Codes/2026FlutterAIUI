// lib/screens/route_editor_screen.dart

import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/dataformat.dart'; // Waypoint, DriverRoute, RoutePart

class RouteEditorScreen extends StatefulWidget {
  final DriverRoute? initialRoute;
  const RouteEditorScreen({super.key, this.initialRoute});

  @override
  State<RouteEditorScreen> createState() => _RouteEditorScreenState();
}

class _RouteEditorScreenState extends State<RouteEditorScreen> {
  GoogleMapController? _mapController;

  // ── marker icons ─────────────────────────────────────────────────────────
  // Assigned in _onMapCreated — the Maps SDK must be fully initialized before
  // BitmapDescriptor.defaultMarkerWithHue() works correctly on Flutter web.
  // Nullable so the markers getter can guard against pre-init access.
  BitmapDescriptor? _iconStart;
  BitmapDescriptor? _iconEnd;
  BitmapDescriptor? _iconWaypoint;

  // ── text controllers & focus ──────────────────────────────────────────────
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final FocusNode _startFocus = FocusNode();
  final FocusNode _endFocus = FocusNode();

  // ── route state ───────────────────────────────────────────────────────────
  Waypoint? _startWaypoint;
  Waypoint? _endWaypoint;
  final List<Waypoint> _middleWaypoints = [];
  Set<Polyline> _polylines = {};

  // Sealed parts when the 25-waypoint limit is hit and the user continues.
  final List<RoutePart> _completedParts = [];

  // Set to true once the health check confirms the FastAPI wrapper is reachable.
  // _updatePolyline and _reverseGeocode are gated on this flag.
  bool _wrapperReady = false;

  static const int _waypointLimit = 25;

  // ── derived ───────────────────────────────────────────────────────────────

  // routeWaypointsList: start → middles → end for the current section.
  List<Waypoint> get _routeWaypointsList => [
        if (_startWaypoint != null) _startWaypoint!,
        ..._middleWaypoints,
        if (_endWaypoint != null) _endWaypoint!,
      ];

  // Route is active only when BOTH waypoints are geocoded AND text fields
  // still match — clearing either field immediately locks the map.
  bool get _startAndEndSet =>
      _startWaypoint != null &&
      _endWaypoint != null &&
      _startController.text.trim().isNotEmpty &&
      _endController.text.trim().isNotEmpty;

  int get _currentPartWaypointCount => _routeWaypointsList.length;

  bool get _atWaypointLimit => _currentPartWaypointCount >= _waypointLimit;

  // ── lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    // Health check — confirms FastAPI wrapper is reachable on startup.
    // Prints status to debug console. If this fails, all /directions and
    // /geocode calls will also fail — check GOOGLE_FASTAPI_WRAPPER_BASEURL
    // in .env and confirm uvicorn is running on port 8008.
    _healthCheck();

    // Invalidate resolved waypoints the moment either field is edited,
    // so the map lock and overlay update instantly.
    _startController.addListener(_onAddressFieldChanged);
    _endController.addListener(_onAddressFieldChanged);

    if (widget.initialRoute != null) {
      _startWaypoint = widget.initialRoute!.startWaypoint;
      _startController.text = _startWaypoint?.streetName ?? '';

      _endWaypoint = widget.initialRoute!.endWaypoint;
      _endController.text = _endWaypoint?.streetName ?? '';

      _middleWaypoints.addAll(widget.initialRoute!.middleWaypoints);
      if (_startAndEndSet) _updatePolyline();
    }
  }

  // Called on every keystroke in either address field.
  // If the user clears or edits a field, null out the resolved waypoint
  // so _startAndEndSet goes false and the map locks immediately.
  void _onAddressFieldChanged() {
    bool changed = false;

    if (_startController.text.trim().isEmpty && _startWaypoint != null) {
      _startWaypoint = null;
      changed = true;
    }
    if (_endController.text.trim().isEmpty && _endWaypoint != null) {
      _endWaypoint = null;
      changed = true;
    }

    if (changed) {
      setState(() {
        _polylines = {};
        // Do NOT clear _middleWaypoints here — user may just be fixing a typo.
        // Waypoints are re-locked by _startAndEndSet going false.
      });
    }
  }

  @override
  void dispose() {
    _startController.removeListener(_onAddressFieldChanged);
    _endController.removeListener(_onAddressFieldChanged);
    _startController.dispose();
    _endController.dispose();
    _startFocus.dispose();
    _endFocus.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // ── marker icon generator ────────────────────────────────────────────────
  // Draws a teardrop-style pin to a dart:ui Canvas, encodes as PNG bytes,
  // and wraps in BitmapDescriptor.fromBytes — the only method that reliably
  // produces colored markers on Flutter web.

  Future<void> _initMarkerIcons() async {
    final start = await _buildPinIcon(const Color(0xFF00C853)); // green
    final end = await _buildPinIcon(const Color(0xFFD50000)); // red
    final waypoint = await _buildPinIcon(const Color(0xFFFF6D00)); // orange
    if (mounted) {
      setState(() {
        _iconStart = start;
        _iconEnd = end;
        _iconWaypoint = waypoint;
      });
    }
  }

  // Draws a filled circle pin (48×48) and returns a BitmapDescriptor.
  Future<BitmapDescriptor> _buildPinIcon(Color color) async {
    const int size = 96;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = color;
    final shadow = Paint()
      ..color = Colors.black38
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // Drop shadow
    canvas.drawCircle(
        const Offset(size / 2 + 2, size / 2 + 3), size / 2.8, shadow);
    // Filled circle
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2.8, paint);
    // White inner dot
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 9,
        Paint()..color = Colors.white);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  // ── health check ─────────────────────────────────────────────────────────

  Future<void> _healthCheck() async {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🔍 RouteEditor: FastAPI wrapper health check');
    debugPrint('   URL  → $_baseUrl/health');
    debugPrint(
        '   ENV  → GOOGLE_FASTAPI_WRAPPER_BASEURL=${dotenv.env['GOOGLE_FASTAPI_WRAPPER_BASEURL'] ?? 'not set — using fallback'}');
    final url = Uri.parse('$_baseUrl/health');
    try {
      final response = await http.get(url).timeout(
            const Duration(seconds: 5),
          );
      if (response.statusCode == 200) {
        debugPrint('✅ FastAPI wrapper reachable');
        debugPrint('   Response: ${response.body}');
        if (mounted) setState(() => _wrapperReady = true);
      } else {
        debugPrint('⚠️  FastAPI wrapper returned ${response.statusCode}');
        debugPrint('   Body: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ FastAPI wrapper UNREACHABLE');
      debugPrint('   Error: $e');
      debugPrint('   Fix 1 → confirm uvicorn is running: python main.py');
      debugPrint(
          '   Fix 2 → confirm port 8008 in .env: GOOGLE_FASTAPI_WRAPPER_BASEURL=http://localhost:8008');
      debugPrint(
          '   Fix 3 → confirm ENV=dev in FastAPI .env (enables wildcard CORS)');
    }
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  // ── API client ───────────────────────────────────────────────────────────
  //
  // Base URL is read from .env:
  //   Dev:  GOOGLE_FASTAPI_WRAPPER_BASEURL=http://localhost:8008
  //   Prod: GOOGLE_FASTAPI_WRAPPER_BASEURL=https://your-prod-domain.com
  //
  // The FastAPI wrapper handles the Google key server-side so no key is
  // ever shipped in the Flutter bundle.

  String get _baseUrl =>
      dotenv.env['GOOGLE_FASTAPI_WRAPPER_BASEURL'] ?? 'http://localhost:8008';

  // GET /geocode?lat=&lng=  →  { "street": "..." }
  // Used to resolve a tapped LatLng into a human-readable street name.
  // Address-string → LatLng (forward geocoding) is handled by the Maps SDK
  // autocomplete widget — wired here as a direct /geocode call for now.
  //
  // NOTE: the FastAPI /geocode endpoint takes lat/lng (reverse geocoding).
  // Forward geocoding (address → lat/lng) requires a separate Geocoding API
  // call or Places Autocomplete — add that when replacing _resolveStartEnd.
  // GET /forward-geocode?address=  →  { "lat", "lng", "formatted_address" }
  // Resolves a free-text address string into lat/lng via the FastAPI wrapper.
  Future<LatLng?> _geocodeAddress(String address) async {
    debugPrint('📍 Forward geocoding: "$address"');
    try {
      final url = Uri.parse('$_baseUrl/forward-geocode')
          .replace(queryParameters: {'address': address});
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final lat = (data['lat'] as num).toDouble();
        final lng = (data['lng'] as num).toDouble();
        final formatted = data['formatted_address'] as String? ?? address;
        debugPrint('📍 Resolved "$address" → $lat, $lng ($formatted)');
        return LatLng(lat, lng);
      }

      debugPrint(
          '📍 Forward geocode failed ${response.statusCode}: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('📍 Forward geocode error: $e');
      return null;
    }
  }

  // GET /geocode?lat=&lng=  →  { "street": "..." }
  // Resolves a tapped map point to a street name for the waypoint label.
  Future<String> _reverseGeocode(LatLng point) async {
    if (!_wrapperReady) {
      debugPrint('⚠️  _reverseGeocode skipped — wrapper not ready.');
      return 'Waypoint';
    }
    try {
      final url = Uri.parse('$_baseUrl/geocode').replace(queryParameters: {
        'lat': point.latitude.toString(),
        'lng': point.longitude.toString(),
      });
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['street'] as String? ?? 'Waypoint';
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
    }
    return 'Waypoint'; // fallback label
  }

  Future<void> _resolveStartEnd() async {
    FocusScope.of(context).unfocus();

    final startText = _startController.text.trim();
    final endText = _endController.text.trim();

    if (startText.isEmpty || endText.isEmpty) {
      _showSnack('Enter both a start and end location.');
      return;
    }

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🚦 Resolving route:');
    debugPrint('   Start → "$startText"');
    debugPrint('   End   → "$endText"');

    final startLatLng = await _geocodeAddress(startText);
    final endLatLng = await _geocodeAddress(endText);

    if (startLatLng == null || endLatLng == null) {
      _showSnack('Could not resolve one or both addresses.');
      debugPrint('❌ Geocoding failed — check /forward-geocode endpoint');
      return;
    }

    debugPrint('🚦 Geocoded:');
    debugPrint(
        '   Start → \${startLatLng.latitude}, \${startLatLng.longitude}');
    debugPrint('   End   → \${endLatLng.latitude}, \${endLatLng.longitude}');

    setState(() {
      _startWaypoint = Waypoint(
        lat: startLatLng.latitude,
        lng: startLatLng.longitude,
        streetName: startText,
        order: 0,
      );
      _endWaypoint = Waypoint(
        lat: endLatLng.latitude,
        lng: endLatLng.longitude,
        streetName: endText,
        order: 999, // reassigned to correct index on save
      );
    });

    await _updatePolyline();
    // Camera is fitted to decoded route points inside _updatePolyline.
    // Do NOT call _fitMapToPoints here with stub coords — it would jump the
    // camera to San Antonio stubs instead of the real route.
  }

  // ── waypoint management ───────────────────────────────────────────────────

  Future<void> _onMapTap(LatLng pos) async {
    // Hard gate — only add waypoints when start & end are both resolved
    if (!_startAndEndSet) return;

    if (_atWaypointLimit) {
      _showWaypointLimitDialog();
      return;
    }

    // Reverse-geocode the tapped point for a meaningful waypoint label
    final street = await _reverseGeocode(pos);

    setState(() {
      _middleWaypoints.add(Waypoint(
        lat: pos.latitude,
        lng: pos.longitude,
        streetName: street,
        order: _middleWaypoints.length + 1,
      ));
    });

    await _updatePolyline();
  }

  Future<void> _deleteWaypoint(int index) async {
    setState(() {
      _middleWaypoints.removeAt(index);
      for (int i = 0; i < _middleWaypoints.length; i++) {
        _middleWaypoints[i] = _middleWaypoints[i].copyWith(order: i + 1);
      }
    });
    await _updatePolyline();
  }

  void _confirmDeleteWaypoint(int index) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove Waypoint ${index + 1}?'),
        content:
            Text(_middleWaypoints[index].streetName ?? 'Waypoint ${index + 1}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              _deleteWaypoint(index);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  // ── polyline ──────────────────────────────────────────────────────────────

  // GET /directions?origin=&destination=&waypoints=
  // Routes through the FastAPI wrapper at _baseUrl — no Google key in Flutter.
  // Called after start/end are resolved and after every waypoint add/remove.
  Future<void> _updatePolyline() async {
    if (!_startAndEndSet) {
      setState(() => _polylines = {});
      return;
    }

    if (!_wrapperReady) {
      debugPrint(
          '⚠️  _updatePolyline skipped — wrapper not ready. Is uvicorn running?');
      _fallbackStraightLine();
      return;
    }

    final origin = '${_startWaypoint!.lat},${_startWaypoint!.lng}';
    final destination = '${_endWaypoint!.lat},${_endWaypoint!.lng}';
    // Prefix each middle waypoint with 'via:' so Google Directions treats
    // them as mandatory pass-through points — the route MUST cross each one
    // in order. Without 'via:' Google can ignore or reorder waypoints.
    final waypoints =
        _middleWaypoints.map((w) => 'via:${w.lat},${w.lng}').join('|');

    final url = Uri.parse('$_baseUrl/directions').replace(
      queryParameters: {
        'origin': origin,
        'destination': destination,
        if (waypoints.isNotEmpty) 'waypoints': waypoints,
      },
    );

    debugPrint('🗺  Directions request → $url');

    try {
      final response = await http.get(url);
      debugPrint('🗺  Directions response → ${response.statusCode}');

      if (response.statusCode == 429) {
        // FastAPI rate-limit hit — admin already notified via Resend
        _showSnack('Route limit reached for today. Try again tomorrow.');
        _fallbackStraightLine();
        return;
      }

      if (response.statusCode != 200) {
        debugPrint('Directions wrapper error: ${response.statusCode}');
        _fallbackStraightLine();
        return;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final status = data['status'] as String? ?? 'UNKNOWN';
      debugPrint('🗺  Directions status: $status');

      if (status != 'OK') {
        debugPrint('🗺  Directions error body: ${response.body}');
        _fallbackStraightLine();
        return;
      }

      final routes = data['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) {
        debugPrint('🗺  Directions: no routes in response');
        _fallbackStraightLine();
        return;
      }

      // Decode overview_polyline into road-following LatLng points
      final encoded = routes[0]['overview_polyline']['points'] as String;
      debugPrint('🗺  Encoded polyline length: ${encoded.length} chars');

      final points = _decodePolyline(encoded);
      debugPrint('🗺  Decoded ${points.length} LatLng points');

      if (points.isEmpty) {
        debugPrint('🗺  Decoded 0 points — fallback');
        _fallbackStraightLine();
        return;
      }

      if (mounted) {
        setState(() {
          _polylines = {
            Polyline(
              polylineId: const PolylineId('route'),
              points: points,
              color: Colors.blue,
              width: 5,
            ),
          };
        });
        // Only fit camera on initial load (no waypoints yet).
        // When adding/removing waypoints the manager is already zoomed in —
        // refitting would jump the camera away from where they are working.
        if (_middleWaypoints.isEmpty) {
          _fitMapToPoints(points);
          debugPrint(
              '🗺  Camera fitted to initial route — ${points.length} points');
        } else {
          debugPrint(
              '🗺  Polyline recalculated — camera unchanged (${points.length} points)');
        }
      }
    } catch (e) {
      debugPrint('Directions exception: $e');
      _fallbackStraightLine();
    }
  }

  // Straight-line fallback — used only when Directions API is unavailable.
  void _fallbackStraightLine() {
    if (!mounted) return;
    setState(() {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: _routeWaypointsList.map((w) => w.latLng).toList(),
          color: Colors.blueGrey,
          width: 3,
          patterns: [PatternItem.dash(12), PatternItem.gap(8)],
        ),
      };
    });
  }

  // Decodes a Google Maps encoded polyline string into LatLng points.
  //
  // Uses multiplication instead of bitwise OR (result += chunk * pow2)
  // to avoid 32-bit integer overflow in Dart web / JS, which corrupts
  // coordinates and produces lines to Africa / the North Pole.
  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    double lat = 0;
    double lng = 0;

    while (index < encoded.length) {
      // Decode one varint — accumulate with multiplication, not bit-shift OR
      double result = 0;
      int shift = 0, b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result +=
            (b & 0x1f) * _pow2(shift); // safe on JS — no 32-bit truncation
        shift += 5;
      } while (b >= 0x20);

      // Zigzag decode: odd result → negative, even → positive
      final iResult = result.toInt();
      final dLat = (iResult & 1) != 0 ? -(iResult >> 1) - 1 : iResult >> 1;
      lat += dLat;

      result = 0;
      shift = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result += (b & 0x1f) * _pow2(shift);
        shift += 5;
      } while (b >= 0x20);

      final iResult2 = result.toInt();
      final dLng = (iResult2 & 1) != 0 ? -(iResult2 >> 1) - 1 : iResult2 >> 1;
      lng += dLng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  // Returns 2^shift as a double — avoids JS integer truncation on large shifts.
  double _pow2(int shift) => shift < 31
      ? (1 << shift).toDouble()
      : (1 << 30).toDouble() * (1 << (shift - 30));

  // ── 25-waypoint limit dialog ──────────────────────────────────────────────

  void _showWaypointLimitDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Waypoint limit reached'),
        content: const Text(
          'This section has reached 25 waypoints.\n\n'
          'Save this section and start a new one to keep adding waypoints, '
          'or save the route as is.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _saveRoute();
            },
            child: const Text('Save As Is'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _sealCurrentPartAndContinue();
            },
            child: const Text('Add New Section'),
          ),
        ],
      ),
    );
  }

  // Seals the current part, carries end → new start, resets for next section.
  void _sealCurrentPartAndContinue() {
    final sealedWaypoints = _routeWaypointsList
        .asMap()
        .entries
        .map((e) => e.value.copyWith(order: e.key))
        .toList();

    setState(() {
      _completedParts.add(RoutePart(
        partNumber: _completedParts.length + 1,
        waypoints: sealedWaypoints,
      ));
      // End of previous section becomes start of next
      _startWaypoint = _endWaypoint?.copyWith(order: 0);
      _startController.text = _startWaypoint?.streetName ?? '';
      _endWaypoint = null;
      _endController.text = '';
      _middleWaypoints.clear();
      _polylines = {};
    });

    _showSnack(
        'Section ${_completedParts.length} saved — set a new end point.');
  }

  // ── save route ────────────────────────────────────────────────────────────

  void _saveRoute() {
    if (!_startAndEndSet) {
      _showSnack('Set a start and end location first.');
      return;
    }

    final finalWaypoints = _routeWaypointsList
        .asMap()
        .entries
        .map((e) => e.value.copyWith(order: e.key))
        .toList();

    final allParts = [
      ..._completedParts,
      RoutePart(
        partNumber: _completedParts.length + 1,
        waypoints: finalWaypoints,
      ),
    ];

    final driverRoute = DriverRoute(
      driverId: '', // TODO: inject from auth / session
      name: 'Route', // TODO: prompt manager to name the route
      assignedDate: DateTime.now(),
      waypoints: finalWaypoints,
      routeParts: allParts,
    );

    debugPrint('Saving DriverRoute: ${allParts.length} part(s), '
        '${finalWaypoints.length} waypoints in final part.');

    // TODO: POST driverRoute.toJson() to FastAPI
    Navigator.pop(context);
  }

  // ── map helpers ───────────────────────────────────────────────────────────

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    // Generate colored marker PNGs via dart:ui Canvas.
    // defaultMarkerWithHue does not work on Flutter web — always returns red.
    _initMarkerIcons();

    if (_routeWaypointsList.isNotEmpty) {
      _fitMapToPoints(_routeWaypointsList.map((w) => w.latLng).toList());
    }
  }

  void _fitMapToPoints(List<LatLng> points) {
    if (points.length < 2 || _mapController == null) return;
    try {
      final swLat =
          points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
      final swLng =
          points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
      final neLat =
          points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
      final neLng =
          points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

      // Guard: identical points would produce a zero-size bounds and crash animateCamera
      if (swLat == neLat && swLng == neLng) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(points.first, 14),
        );
        return;
      }

      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(swLat, swLng),
            northeast: LatLng(neLat, neLng),
          ),
          80,
        ),
      );
    } catch (e) {
      debugPrint('Error fitting map: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── markers ───────────────────────────────────────────────────────────────

  Set<Marker> get _markers {
    // Return empty set until icons are initialized in onMapCreated
    if (_iconStart == null) return {};

    final markers = <Marker>{};

    // startWaypoint — green pin
    if (_startWaypoint != null) {
      markers.add(Marker(
        markerId: const MarkerId('start'),
        position: _startWaypoint!.latLng,
        icon: _iconStart!,
        infoWindow:
            InfoWindow(title: 'Start', snippet: _startWaypoint!.streetName),
      ));
    }

    // middleWaypoints — orange pins, clearly visible on map tiles
    // Tap the marker to open the info window.
    // Tap the info window snippet to confirm deletion.
    for (int i = 0; i < _middleWaypoints.length; i++) {
      final w = _middleWaypoints[i];
      final index = i;
      markers.add(Marker(
        markerId: MarkerId('mid_$i'),
        position: w.latLng,
        icon: _iconWaypoint!,
        infoWindow: InfoWindow(
          title: '${i + 1}  ${w.streetName ?? 'Waypoint ${i + 1}'}',
          snippet: '🗑 Tap here to remove',
          onTap: () => _confirmDeleteWaypoint(index),
        ),
      ));
    }

    // endWaypoint — red pin
    if (_endWaypoint != null) {
      markers.add(Marker(
        markerId: const MarkerId('end'),
        position: _endWaypoint!.latLng,
        icon: _iconEnd!,
        infoWindow: InfoWindow(title: 'End', snippet: _endWaypoint!.streetName),
      ));
    }

    return markers;
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ── Search panel (Google Maps style) ────────────────────────────
          // TODO: hamburger menu icon (leading) → future side drawer for
          //       driver management, route history, settings, etc.
          _SearchPanel(
            startController: _startController,
            endController: _endController,
            startFocus: _startFocus,
            endFocus: _endFocus,
            onSearch: _resolveStartEnd,
          ),

          // ── Map ──────────────────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(29.4241, -98.4936),
                    zoom: 11,
                  ),
                  onMapCreated: _onMapCreated,
                  markers: _markers,
                  polylines: _polylines,
                  onTap: _onMapTap,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                ),

                // Hint overlay — visible until start & end are resolved
                if (!_startAndEndSet)
                  Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Set start & end to begin adding waypoints',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ),
                  ),

                // Waypoint counter badge — top-right, turns red at limit
                if (_startAndEndSet)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '$_currentPartWaypointCount / $_waypointLimit',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _atWaypointLimit ? Colors.red : Colors.black87,
                        ),
                      ),
                    ),
                  ),

                // Save Route button — floating pill, bottom-centre of map
                if (_startAndEndSet)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          elevation: 4,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        icon: const Icon(Icons.save_alt, size: 18),
                        label: Text(
                          _completedParts.isEmpty
                              ? 'Save Route'
                              : 'Save Route  (${_completedParts.length + 1} sections)',
                        ),
                        onPressed: _saveRoute,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Waypoints panel ─────────────────────────────────────────────
          // Fixed height dark panel — map never shrinks as list grows.
          // Tap × in list or map pin info window to remove a waypoint.
          if (_middleWaypoints.isNotEmpty)
            _WaypointList(
              waypoints: _middleWaypoints,
              onDelete: _confirmDeleteWaypoint,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH PANEL
// Google Maps-style card: green dot → start field, dotted line, red dot → end.
// TODO: add hamburger menu IconButton as leading widget when drawer is built.
// ─────────────────────────────────────────────────────────────────────────────
class _SearchPanel extends StatelessWidget {
  final TextEditingController startController;
  final TextEditingController endController;
  final FocusNode startFocus;
  final FocusNode endFocus;
  final VoidCallback onSearch;

  const _SearchPanel({
    required this.startController,
    required this.endController,
    required this.startFocus,
    required this.endFocus,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── future hamburger menu row ──────────────────────────────
              // TODO: replace placeholder with Scaffold.of(context).openDrawer()
              //       once the side drawer (driver list, route history, settings)
              //       is implemented.
              Row(
                children: [
                  Icon(Icons.menu, color: Colors.grey.shade400),
                  const SizedBox(width: 8),
                  Text(
                    'Route Editor',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Start field ────────────────────────────────────────────
              _RouteInputField(
                controller: startController,
                focusNode: startFocus,
                nextFocus: endFocus,
                hintText: 'Starting point',
                dotColor: Colors.green,
              ),

              // Dotted connector line
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Row(
                  children: [
                    _DottedConnector(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Divider(
                        height: 1,
                        color: Colors.grey.shade200,
                      ),
                    ),
                  ],
                ),
              ),

              // ── End field ──────────────────────────────────────────────
              _RouteInputField(
                controller: endController,
                focusNode: endFocus,
                hintText: 'Destination',
                dotColor: Colors.red,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => onSearch(),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: onSearch,
                  child: const Text('Get Route'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ROUTE INPUT FIELD
// Stateful so the clear (×) button reacts to controller changes live.
// ─────────────────────────────────────────────────────────────────────────────
class _RouteInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  final String hintText;
  final Color dotColor;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _RouteInputField({
    required this.controller,
    required this.focusNode,
    this.nextFocus,
    required this.hintText,
    required this.dotColor,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  State<_RouteInputField> createState() => _RouteInputFieldState();
}

class _RouteInputFieldState extends State<_RouteInputField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Coloured dot matching the map pin colour
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: widget.dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            textInputAction: widget.textInputAction,
            onSubmitted:
                widget.onSubmitted ?? (_) => widget.nextFocus?.requestFocus(),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        // Clear button — only visible when field has content
        if (widget.controller.text.isNotEmpty)
          GestureDetector(
            onTap: () => widget.controller.clear(),
            child: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(
                Icons.close,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DOTTED CONNECTOR
// The small vertical dotted line between the start and end fields.
// ─────────────────────────────────────────────────────────────────────────────
class _DottedConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          3,
          (_) => Container(
            width: 2,
            height: 2,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WAYPOINT LIST
// Fixed-height dark panel pinned to the bottom of the screen.
// Height is constant — the map above never shrinks as the list grows.
// Tap × to remove a waypoint (same as tapping the map pin info window).
// ─────────────────────────────────────────────────────────────────────────────
class _WaypointList extends StatelessWidget {
  final List<Waypoint> waypoints;
  final void Function(int index) onDelete;

  const _WaypointList({
    required this.waypoints,
    required this.onDelete,
  });

  // Fixed panel height — map above always stays the same size
  static const double panelHeight = 160;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: panelHeight,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(color: Color(0xFF2C2C2C), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              children: [
                const Icon(
                  Icons.route,
                  size: 14,
                  color: Color(0xFF888888),
                ),
                const SizedBox(width: 6),
                Text(
                  'WAYPOINTS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF888888),
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Text(
                  '${waypoints.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF555555),
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable list ────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              itemCount: waypoints.length,
              itemBuilder: (context, index) {
                final wp = waypoints[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF242424),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      // Order badge
                      Container(
                        width: 32,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2979FF),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            bottomLeft: Radius.circular(6),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Street name
                      Expanded(
                        child: Text(
                          wp.streetName ?? 'Waypoint ${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFCCCCCC),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Delete button
                      GestureDetector(
                        onTap: () => onDelete(index),
                        child: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Color(0xFF555555),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
