import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectLocationScreen extends StatefulWidget {
  final LatLng? initialPosition;
  final String? initialLabel;
  final String? governorate;

  const SelectLocationScreen({
    super.key,
    this.initialPosition,
    this.initialLabel,
    this.governorate,
  });

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  static const _defaultPosition = LatLng(33.3128, 44.3615); // Baghdad center

  late LatLng _selectedPosition;
  late TextEditingController _labelController;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition ?? _defaultPosition;
    _labelController = TextEditingController(text: widget.initialLabel ?? '');
  }

  @override
  void dispose() {
    _labelController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapTap(LatLng position) {
    setState(() => _selectedPosition = position);
    _mapController?.animateCamera(CameraUpdate.newLatLng(position));
  }

  void _onSave() {
    Navigator.of(context).pop(
      LocationSelectionResult(
        position: _selectedPosition,
        label: _labelController.text.trim().isEmpty
            ? null
            : _labelController.text.trim(),
      ),
    );
  }

  Set<Marker> get _markers => {
        Marker(
          markerId: const MarkerId('selected-location'),
          position: _selectedPosition,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final governorate = widget.governorate;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('حدد الموقع على الخريطة')),
      body: Column(
        children: [
          if (governorate != null) ...[
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.location_city, color: scheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'المحافظة: $governorate',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _selectedPosition,
                  zoom: 14,
                ),
                markers: _markers,
                onTap: _onMapTap,
                onMapCreated: (controller) => _mapController = controller,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                scrollGesturesEnabled: true,
                tiltGesturesEnabled: false,
                rotateGesturesEnabled: false,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الوصف (اختياري)', style: textTheme.labelSmall),
                const SizedBox(height: 8),
                TextField(
                  controller: _labelController,
                  decoration: InputDecoration(
                    hintText: 'مثلاً: قاعة الريان، نفس الموقع المدخل في الخريطة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _onSave,
                        icon: const Icon(Icons.check),
                        label: const Text('حفظ الموقع'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
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
}

class LocationSelectionResult {
  final LatLng position;
  final String? label;

  LocationSelectionResult({
    required this.position,
    this.label,
  });
}
