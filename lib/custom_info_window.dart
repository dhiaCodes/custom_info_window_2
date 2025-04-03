/// A widget based custom info window for google_maps_flutter package.
library custom_info_window;

import 'dart:io';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Controller to add, update and control the custom info window.
class CustomInfoWindowController {
  /// Add custom [Widget] and [Marker]'s [LatLng] to [CustomInfoWindow] and make it visible.
  Function(Widget, LatLng) addInfoWindow = (child, l) {};

  /// Notifies [CustomInfoWindow] to redraw as per change in position.
  VoidCallback onCameraMove = () {};

  /// Hides [CustomInfoWindow].
  VoidCallback hideInfoWindow = () {};

  /// Shows cached info window.
  VoidCallback showCachedInfoWindow = () {};

  /// Holds [GoogleMapController] for calculating [CustomInfoWindow] position.
  GoogleMapController? googleMapController;

  void dispose() {
    addInfoWindow = (child, l) {};
    onCameraMove = () {};
    hideInfoWindow = () {};
    googleMapController = null;
  }
}

/// A stateful widget responsible to create widget based custom info window.
class CustomInfoWindow extends StatefulWidget {
  /// A [CustomInfoWindowController] to manipulate [CustomInfoWindow] state.
  final CustomInfoWindowController controller;

  /// Callback to notify the change in position of [CustomInfoWindow].
  /// The first parameter is the top margin and the second parameter is the left margin.
  final Function(double, double)? onChange;

  /// Offset to maintain space between [Marker] and [CustomInfoWindow].
  final double offset;

  /// Height of [CustomInfoWindow].
  final double height;

  /// Width of [CustomInfoWindow].
  final double width;

  const CustomInfoWindow({
    required this.controller,
    this.onChange,
    this.offset = 50,
    this.height = 50,
    this.width = 100,
  })  : assert(offset >= 0),
        assert(height >= 0),
        assert(width >= 0);

  @override
  _CustomInfoWindowState createState() => _CustomInfoWindowState();
}

class _CustomInfoWindowState extends State<CustomInfoWindow> {
  bool _showNow = true;
  double _leftMargin = 0;
  double _topMargin = 0;
  Widget? _child;
  LatLng? _latLng;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      Future.microtask(() {
        devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
      });
    } else {
      devicePixelRatio = 1.0;
    }
    widget.controller.addInfoWindow = _addInfoWindow;
    widget.controller.onCameraMove = _onCameraMove;
    widget.controller.hideInfoWindow = _hideInfoWindow;
    widget.controller.showCachedInfoWindow = showCachedInfoWindow;
  }

  late double devicePixelRatio;

  /// Calculate the position on [CustomInfoWindow] and redraw on screen.
  void _updateInfoWindow() async {
    if (_latLng == null ||
        _child == null ||
        widget.controller.googleMapController == null) {
      return;
    }
    ScreenCoordinate screenCoordinate = await widget
        .controller.googleMapController!
        .getScreenCoordinate(_latLng!);

    double left =
        (screenCoordinate.x.toDouble() / devicePixelRatio) - (widget.width / 2);
    double top = (screenCoordinate.y.toDouble() / devicePixelRatio) -
        (widget.offset + widget.height);
    // widget.onChange?.call(top, left);

    if (mounted) {
      setState(() {
        _leftMargin = left;
        _topMargin = top;
      });
    }
  }

  /// Assign the [Widget] and [Marker]'s [LatLng].
  void showCachedInfoWindow() {
    if (mounted) {
      setState(() {
        _showNow = true;
      });
    }
  }

  /// Assign the [Widget] and [Marker]'s [LatLng].
  void _addInfoWindow(Widget child, LatLng latLng) {
    _child = child;
    _latLng = latLng;
    _updateInfoWindow();
  }

  /// Notifies camera movements on [GoogleMap].
  void _onCameraMove() {
    _updateInfoWindow();
  }

  /// Disables [CustomInfoWindow] visibility.
  void _hideInfoWindow() {
    if (mounted) {
      setState(() {
        _showNow = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showNow == false ||
        (_leftMargin == 0 && _topMargin == 0) ||
        _child == null ||
        _latLng == null) {
      return const SizedBox.shrink();
    }
    return Positioned(
      left: _leftMargin,
      top: _topMargin,
      child: SizedBox(
        child: _child,
        height: widget.height,
        width: widget.width,
      ),
    );
  }
}
