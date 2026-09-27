import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum SchematicUnit {
  inch,
  mm,
}

enum SchematicGridType {
  dot,
  grid,
  none,
}

enum SchematicHighlightMode {
  highlight,
  unhighlight,
  hoverWire,
}

class SchematicSheet extends StatefulWidget {
  final ValueChanged<String>? onCommand;

  const SchematicSheet({
    super.key,
    this.onCommand,
  });

  @override
  State<SchematicSheet> createState() => _SchematicSheetState();
}

class _SchematicSheetState extends State<SchematicSheet> {
  // ==========================================================================
  // SHEET / WORLD
  // ==========================================================================

  static const double sheetWidth = 2400;
  static const double sheetHeight = 1450;

  static const double sheetLeft = 300;
  static const double sheetTop = 180;

  static const double pixelsPerMm = 5;

  static const double minZoom = 0.12;
  static const double maxZoom = 16;

  static const double rulerSize = 30;

  static const double worldWidth = 3000;
  static const double worldHeight = 1900;

  // ==========================================================================
  // VIEW STATE
  // ==========================================================================

  SchematicUnit _unit = SchematicUnit.mm;

  double _gridMm = 1.0;

  SchematicGridType _gridType = SchematicGridType.grid;

  SchematicHighlightMode _highlightMode =
      SchematicHighlightMode.unhighlight;

  // ==========================================================================
  // CONTROLLER
  // ==========================================================================

  final TransformationController _controller =
      TransformationController();

  // ==========================================================================
  // STATE
  // ==========================================================================

  double _zoom = 1;

  Offset _mousePosition = Offset.zero;
  Offset? _mouseWorld;

  bool _mouseInside = false;
  bool _initialised = false;

  bool _fullScreen = false;

  // ==========================================================================
  // CUSTOM PAN
  // ==========================================================================

  int? _panPointer;
  Offset? _panStart;
  Offset? _panStartTranslation;

  bool _panMode = false;

  // ==========================================================================
  // LIFECYCLE
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _controller.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTransformChanged);
    _controller.dispose();

    super.dispose();
  }

  // ==========================================================================
  // TRANSFORM
  // ==========================================================================

  double get _scale {
    final value = _controller.value.getMaxScaleOnAxis();

    if (!value.isFinite || value <= 0) {
      return 1;
    }

    return value;
  }

  Offset get _translation {
    final matrix = _controller.value;

    return Offset(
      matrix.entry(0, 3),
      matrix.entry(1, 3),
    );
  }

  Matrix4 _makeMatrix(
    double scale,
    Offset translation,
  ) {
    return Matrix4.identity()
      ..setEntry(0, 0, scale)
      ..setEntry(1, 1, scale)
      ..setEntry(2, 2, scale)
      ..setEntry(0, 3, translation.dx)
      ..setEntry(1, 3, translation.dy);
  }

  Offset screenToWorld(Offset screen) {
    try {
      final inverse = Matrix4.inverted(_controller.value);

      return MatrixUtils.transformPoint(
        inverse,
        screen,
      );
    } catch (_) {
      return Offset.zero;
    }
  }

  // ==========================================================================
  // VIEW COMMANDS
  // ==========================================================================

  void executeViewCommand(String command) {
    switch (command) {
      case 'Zoom In':
        _zoomIn();
        break;

      case 'Zoom Out':
        _zoomOut();
        break;

      case 'Fit All in Window':
        _fitFromContext();
        break;

      case 'Fit Selection View':
        _fitSelectionView();
        break;

      case 'Fit Area Selection View':
        _fitAreaSelectionView();
        break;

      case 'Full Screen':
        _toggleFullScreen();
        break;

      case 'Unit: Inch':
        _setUnit(SchematicUnit.inch);
        break;

      case 'Unit: mm':
        _setUnit(SchematicUnit.mm);
        break;

      case 'Grid Size: 0.1 inch':
        _setGridFromInch(0.1);
        break;

      case 'Grid Size: 0.05 inch':
        _setGridFromInch(0.05);
        break;

      case 'Grid Size: 0.02 inch':
        _setGridFromInch(0.02);
        break;

      case 'Grid Size: 0.01 inch':
        _setGridFromInch(0.01);
        break;

      case 'Grid Type: Grid Dot':
        _setGridType(SchematicGridType.dot);
        break;

      case 'Grid Type: Grid':
        _setGridType(SchematicGridType.grid);
        break;

      case 'Grid Type: None':
        _setGridType(SchematicGridType.none);
        break;

      case 'Highlight Net: Highlight Net':
        _setHighlightMode(
          SchematicHighlightMode.highlight,
        );
        break;

      case 'Highlight Net: Unhighlight Net':
        _setHighlightMode(
          SchematicHighlightMode.unhighlight,
        );
        break;

      case 'Highlight Net: Highlight Net While Hovering Wire':
        _setHighlightMode(
          SchematicHighlightMode.hoverWire,
        );
        break;
    }

    widget.onCommand?.call(command);
  }

  // ==========================================================================
  // UNIT
  // ==========================================================================

  void _setUnit(SchematicUnit unit) {
    if (_unit == unit) {
      return;
    }

    setState(() {
      _unit = unit;
    });
  }

  // ==========================================================================
  // GRID
  // ==========================================================================

  void _setGridFromInch(double inch) {
    final mm = inch * 25.4;

    setState(() {
      _gridMm = mm;
    });
  }

  void _setGridType(SchematicGridType type) {
    if (_gridType == type) {
      return;
    }

    setState(() {
      _gridType = type;
    });
  }

  // ==========================================================================
  // HIGHLIGHT
  // ==========================================================================

  void _setHighlightMode(SchematicHighlightMode mode) {
    if (_highlightMode == mode) {
      return;
    }

    setState(() {
      _highlightMode = mode;
    });
  }

  // ==========================================================================
  // DISPLAY VALUES
  // ==========================================================================

  String _formatGridValue() {
    if (_unit == SchematicUnit.mm) {
      if ((_gridMm - _gridMm.round()).abs() < 0.0001) {
        return '${_gridMm.round()} mm';
      }

      return '${_gridMm.toStringAsFixed(3)} mm'.replaceFirst(
        RegExp(r'0+ mm$'),
        ' mm',
      );
    }

    final inch = _gridMm / 25.4;

    return '${inch.toStringAsFixed(2)} inch';
  }

  // ==========================================================================
  // TRANSFORM LISTENER
  // ==========================================================================

  void _onTransformChanged() {
    final scale = _scale;

    if ((scale - _zoom).abs() > 0.0001) {
      if (mounted) {
        setState(() {
          _zoom = scale;
        });
      }
    }

    _updateMouseWorld();

    if (mounted) {
      setState(() {});
    }
  }

  // ==========================================================================
  // INITIAL VIEW
  // ==========================================================================

  void _setupInitialView(BoxConstraints constraints) {
    if (_initialised) {
      return;
    }

    if (constraints.maxWidth <= 0 ||
        constraints.maxHeight <= 0) {
      return;
    }

    _initialised = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _fitPage(
        constraints.maxWidth - rulerSize,
        constraints.maxHeight - rulerSize,
      );
    });
  }

  // ==========================================================================
  // FIT
  // ==========================================================================

  void _fitPage(
    double viewportWidth,
    double viewportHeight,
  ) {
    if (viewportWidth <= 0 ||
        viewportHeight <= 0) {
      return;
    }

    const horizontalPadding = 80.0;
    const verticalPadding = 80.0;

    final availableWidth = math.max(
      100,
      viewportWidth - horizontalPadding,
    );

    final availableHeight = math.max(
      100,
      viewportHeight - verticalPadding,
    );

    final scaleX = availableWidth / sheetWidth;
    final scaleY = availableHeight / sheetHeight;

    final scale = math.min(
      scaleX,
      scaleY,
    ).clamp(
      minZoom,
      2.5,
    ).toDouble();

    final x =
        (viewportWidth - sheetWidth * scale) / 2 -
        sheetLeft * scale;

    final y =
        (viewportHeight - sheetHeight * scale) / 2 -
        sheetTop * scale;

    _controller.value = _makeMatrix(
      scale,
      Offset(x, y),
    );
  }

  void _fitFromContext() {
    final renderObject = context.findRenderObject();

    if (renderObject is! RenderBox) {
      return;
    }

    final size = renderObject.size;

    _fitPage(
      size.width - rulerSize,
      size.height - rulerSize,
    );
  }

  void _fitSelectionView() {
    // Hook for actual selection engine.
    // Until selection geometry exists, safely
    // fall back to fitting the complete sheet.
    _fitFromContext();
  }

  void _fitAreaSelectionView() {
    // Hook for actual area-selection engine.
    // Until area geometry exists, safely
    // fall back to fitting the complete sheet.
    _fitFromContext();
  }

  // ==========================================================================
  // FULL SCREEN
  // ==========================================================================

  void _toggleFullScreen() {
    _fullScreen = !_fullScreen;

    // The parent application can listen to this
    // command and control the actual window/fullscreen.
    if (mounted) {
      setState(() {});
    }
  }

  // ==========================================================================
  // ZOOM
  // ==========================================================================

  void _zoomAround(
    Offset focalPoint,
    double factor,
  ) {
    final currentScale = _scale;

    if (currentScale <= 0) {
      return;
    }

    final targetScale = (currentScale * factor)
        .clamp(
          minZoom,
          maxZoom,
        )
        .toDouble();

    final actualFactor = targetScale / currentScale;

    final oldTranslation = _translation;

    final newTranslation =
        focalPoint -
        (focalPoint - oldTranslation) * actualFactor;

    _controller.value = _makeMatrix(
      targetScale,
      newTranslation,
    );
  }

  void _zoomIn() {
    _zoomAround(
      _mouseInside ? _mousePosition : _viewportCenter(),
      1.2,
    );
  }

  void _zoomOut() {
    _zoomAround(
      _mouseInside ? _mousePosition : _viewportCenter(),
      1 / 1.2,
    );
  }

  void _resetZoom() {
    final focal =
        _mouseInside ? _mousePosition : _viewportCenter();

    final currentScale = _scale;

    if (currentScale <= 0) {
      return;
    }

    final factor = 1 / currentScale;

    final oldTranslation = _translation;

    final newTranslation =
        focal -
        (focal - oldTranslation) * factor;

    _controller.value = _makeMatrix(
      1,
      newTranslation,
    );
  }

  Offset _viewportCenter() {
    final renderObject = context.findRenderObject();

    if (renderObject is! RenderBox) {
      return Offset.zero;
    }

    final size = renderObject.size;

    return Offset(
      rulerSize + (size.width - rulerSize) / 2,
      rulerSize + (size.height - rulerSize) / 2,
    );
  }

  // ==========================================================================
  // MOUSE
  // ==========================================================================

  void _onMouseEnter(PointerEnterEvent event) {
    _mouseInside = true;
    _mousePosition = event.localPosition;

    _updateMouseWorld();

    if (mounted) {
      setState(() {});
    }
  }

  void _onMouseHover(PointerHoverEvent event) {
    _mouseInside = true;
    _mousePosition = event.localPosition;

    _updateMouseWorld();

    if (mounted) {
      setState(() {});
    }
  }

  void _onMouseExit(PointerExitEvent event) {
    _mouseInside = false;
    _mouseWorld = null;

    if (mounted) {
      setState(() {});
    }
  }

  void _updateMouseWorld() {
    if (!_mouseInside) {
      return;
    }

    _mouseWorld = screenToWorld(_mousePosition);
  }

  // ==========================================================================
  // PAN
  // ==========================================================================

  void _onPointerDown(PointerDownEvent event) {
    final buttons = event.buttons;

    final middle = (buttons & 4) != 0;
    final right = (buttons & 2) != 0;

    if (!middle && !right) {
      return;
    }

    _panPointer = event.pointer;
    _panStart = event.localPosition;
    _panStartTranslation = _translation;

    _panMode = true;

    if (mounted) {
      setState(() {});
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_panPointer != event.pointer) {
      return;
    }

    if (_panStart == null ||
        _panStartTranslation == null) {
      return;
    }

    final delta = event.localPosition - _panStart!;

    final translation =
        _panStartTranslation! + delta;

    _controller.value = _makeMatrix(
      _scale,
      translation,
    );
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_panPointer != event.pointer) {
      return;
    }

    _clearPan();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (_panPointer != event.pointer) {
      return;
    }

    _clearPan();
  }

  void _clearPan() {
    _panPointer = null;
    _panStart = null;
    _panStartTranslation = null;

    if (_panMode && mounted) {
      setState(() {
        _panMode = false;
      });
    } else {
      _panMode = false;
    }
  }

  // ==========================================================================
  // MOUSE WHEEL / TRACKPAD
  // ==========================================================================

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) {
      return;
    }

    final delta = event.scrollDelta.dy;

    if (delta == 0) {
      return;
    }

    final factor = math.pow(
      1.10,
      -delta / 40,
    ).toDouble();

    _zoomAround(
      _mousePosition,
      factor,
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFD7DCE0),
      child: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          _setupInitialView(constraints);

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // ===============================================================
              // MAIN CANVAS
              // ===============================================================

              Positioned(
                left: rulerSize,
                right: 0,
                top: rulerSize,
                bottom: 0,
                child: MouseRegion(
                  cursor: _panMode
                      ? SystemMouseCursors.grabbing
                      : SystemMouseCursors.precise,
                  onEnter: _onMouseEnter,
                  onHover: _onMouseHover,
                  onExit: _onMouseExit,
                  child: Listener(
                    onPointerDown: _onPointerDown,
                    onPointerMove: _onPointerMove,
                    onPointerUp: _onPointerUp,
                    onPointerCancel: _onPointerCancel,
                    onPointerSignal: _onPointerSignal,
                    child: ClipRect(
                      child: Stack(
                        fit: StackFit.expand,
                        clipBehavior: Clip.hardEdge,
                        children: [
                          // =================================================
                          // GRID
                          // =================================================

                          CustomPaint(
                            painter: EdaInfiniteGridPainter(
                              transform: _controller.value,
                              pixelsPerMm: pixelsPerMm,
                              gridMm: _gridMm,
                              gridType: _gridType,
                            ),
                          ),

                          // =================================================
                          // SHEET
                          // =================================================

                          ClipRect(
                            child: Transform(
                              transform: _controller.value,
                              alignment: Alignment.topLeft,
                              child: RepaintBoundary(
                                child: SizedBox(
                                  width: worldWidth,
                                  height: worldHeight,
                                  child: CustomPaint(
                                    painter:
                                        EdaSchematicSheetPainter(),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // =================================================
                          // CROSSHAIR
                          // =================================================

                          if (_mouseInside)
                            IgnorePointer(
                              child: CustomPaint(
                                painter: EdaCrosshairPainter(
                                  position: _mousePosition,
                                  color: AppColors.signalOrange,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ===============================================================
              // TOP RULER
              // ===============================================================

              Positioned(
                left: rulerSize,
                right: 0,
                top: 0,
                height: rulerSize,
                child: ClipRect(
                  child: CustomPaint(
                    painter: EdaHorizontalRulerPainter(
                      transform: _controller.value,
                      mouseWorld: _mouseWorld,
                      pixelsPerMm: pixelsPerMm,
                    ),
                  ),
                ),
              ),

              // ===============================================================
              // LEFT RULER
              // ===============================================================

              Positioned(
                left: 0,
                top: rulerSize,
                width: rulerSize,
                bottom: 0,
                child: ClipRect(
                  child: CustomPaint(
                    painter: EdaVerticalRulerPainter(
                      transform: _controller.value,
                      mouseWorld: _mouseWorld,
                      pixelsPerMm: pixelsPerMm,
                    ),
                  ),
                ),
              ),

              // ===============================================================
              // RULER CORNER
              // ===============================================================

              Positioned(
                left: 0,
                top: 0,
                width: rulerSize,
                height: rulerSize,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFE7EAEC),
                    border: Border(
                      right: BorderSide(
                        color: Color(0xFFB8BFC4),
                      ),
                      bottom: BorderSide(
                        color: Color(0xFFB8BFC4),
                      ),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add,
                      size: 10,
                      color: Color(0xFF697177),
                    ),
                  ),
                ),
              ),

              // ===============================================================
              // TOOLBAR
              // ===============================================================

              Positioned(
                right: 18,
                top: 50,
                child: _CanvasToolbar(
                  zoom: _zoom,
                  onZoomIn: _zoomIn,
                  onZoomOut: _zoomOut,
                  onFit: _fitFromContext,
                  onResetZoom: _resetZoom,
                ),
              ),

              // ===============================================================
              // STATUS
              // ===============================================================

              Positioned(
                left: 50,
                bottom: 5,
                child: _CanvasStatus(
                  mouseWorld: _mouseWorld,
                  gridMm: _gridMm,
                  unit: _unit,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// INFINITE GRID PAINTER
// ============================================================================

class EdaInfiniteGridPainter extends CustomPainter {
  final Matrix4 transform;
  final double pixelsPerMm;
  final double gridMm;
  final SchematicGridType gridType;

  EdaInfiniteGridPainter({
    required this.transform,
    required this.pixelsPerMm,
    required this.gridMm,
    required this.gridType,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE0E4E7),
    );

    if (gridType == SchematicGridType.none) {
      return;
    }

    final scale = transform.getMaxScaleOnAxis();

    if (scale <= 0 || !scale.isFinite) {
      return;
    }

    final translation = transform.getTranslation();

    final firstWorldX = -translation.x / scale;
    final lastWorldX =
        (size.width - translation.x) / scale;

    final firstWorldY = -translation.y / scale;
    final lastWorldY =
        (size.height - translation.y) / scale;

    // ============================================================
    // SELECTED GRID
    // ============================================================

    final spacing = pixelsPerMm * gridMm;
    final screenSpacing = spacing * scale;

    if (spacing <= 0) {
      return;
    }

    // ============================================================
    // DOT GRID
    // ============================================================

    if (gridType == SchematicGridType.dot) {
      if (screenSpacing < 4 || screenSpacing > 70) {
        return;
      }

      final paint = Paint()
        ..color = const Color(0xFF929BA1).withOpacity(
          screenSpacing < 8 ? 0.40 : 0.55,
        );

      final startX =
          (firstWorldX / spacing).floor() * spacing;

      final startY =
          (firstWorldY / spacing).floor() * spacing;

      final radius = screenSpacing < 8 ? 0.7 : 1.0;

      for (
        double x = startX;
        x <= lastWorldX;
        x += spacing
      ) {
        final sx = x * scale + translation.x;

        for (
          double y = startY;
          y <= lastWorldY;
          y += spacing
        ) {
          final sy = y * scale + translation.y;

          canvas.drawCircle(
            Offset(sx, sy),
            radius,
            paint,
          );
        }
      }

      return;
    }

    // ============================================================
    // NORMAL GRID
    // ============================================================

    if (screenSpacing >= 3 && screenSpacing <= 100) {
      final opacity = screenSpacing < 7
          ? 0.25
          : screenSpacing < 15
              ? 0.35
              : 0.48;

      final paint = Paint()
        ..color = const Color(0xFFB7BEC4).withOpacity(opacity)
        ..strokeWidth = screenSpacing < 8 ? 0.4 : 0.55;

      final startX =
          (firstWorldX / spacing).floor() * spacing;

      final startY =
          (firstWorldY / spacing).floor() * spacing;

      for (
        double x = startX;
        x <= lastWorldX;
        x += spacing
      ) {
        final sx = x * scale + translation.x;

        canvas.drawLine(
          Offset(sx, 0),
          Offset(sx, size.height),
          paint,
        );
      }

      for (
        double y = startY;
        y <= lastWorldY;
        y += spacing
      ) {
        final sy = y * scale + translation.y;

        canvas.drawLine(
          Offset(0, sy),
          Offset(size.width, sy),
          paint,
        );
      }
    }

    // ============================================================
    // MAJOR GRID
    // ============================================================

    final majorWorldSpacing = spacing * 10;
    final majorScreenSpacing =
        majorWorldSpacing * scale;

    if (majorScreenSpacing < 8) {
      return;
    }

    final majorPaint = Paint()
      ..color = const Color(0xFF929BA1).withOpacity(
        majorScreenSpacing < 25 ? 0.34 : 0.50,
      )
      ..strokeWidth =
          majorScreenSpacing < 20 ? 0.6 : 0.85;

    final majorStartX =
        (firstWorldX / majorWorldSpacing).floor() *
        majorWorldSpacing;

    final majorStartY =
        (firstWorldY / majorWorldSpacing).floor() *
        majorWorldSpacing;

    for (
      double x = majorStartX;
      x <= lastWorldX;
      x += majorWorldSpacing
    ) {
      final sx = x * scale + translation.x;

      canvas.drawLine(
        Offset(sx, 0),
        Offset(sx, size.height),
        majorPaint,
      );
    }

    for (
      double y = majorStartY;
      y <= lastWorldY;
      y += majorWorldSpacing
    ) {
      final sy = y * scale + translation.y;

      canvas.drawLine(
        Offset(0, sy),
        Offset(size.width, sy),
        majorPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant EdaInfiniteGridPainter oldDelegate,
  ) {
    return oldDelegate.transform != transform ||
        oldDelegate.pixelsPerMm != pixelsPerMm ||
        oldDelegate.gridMm != gridMm ||
        oldDelegate.gridType != gridType;
  }
}

// ============================================================================
// SHEET PAINTER
// ============================================================================

class EdaSchematicSheetPainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final sheet = Rect.fromLTWH(
      _SchematicSheetState.sheetLeft,
      _SchematicSheetState.sheetTop,
      _SchematicSheetState.sheetWidth,
      _SchematicSheetState.sheetHeight,
    );

    _drawSheetShadow(canvas, sheet);
    _drawSheet(canvas, sheet);
    _drawFrame(canvas, sheet);
    _drawZones(canvas, sheet);
    _drawTitleBlock(canvas, sheet);
  }

  void _drawSheetShadow(
    Canvas canvas,
    Rect sheet,
  ) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.13)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        13,
      );

    canvas.drawRect(
      sheet.shift(const Offset(7, 9)),
      paint,
    );
  }

  void _drawSheet(
    Canvas canvas,
    Rect sheet,
  ) {
    canvas.drawRect(
      sheet,
      Paint()..color = Colors.white,
    );
  }

  void _drawFrame(
    Canvas canvas,
    Rect sheet,
  ) {
    final outer = Paint()
      ..color = const Color(0xFF22282C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final inner = Paint()
      ..color = const Color(0xFF5B6369)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final technical = Paint()
      ..color = const Color(0xFFA1A7AC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.55;

    canvas.drawRect(sheet, outer);
    canvas.drawRect(sheet.deflate(13), inner);
    canvas.drawRect(sheet.deflate(18), technical);
  }

  void _drawZones(
    Canvas canvas,
    Rect sheet,
  ) {
    final frame = sheet.deflate(13);

    final paint = Paint()
      ..color = const Color(0xFF656C72)
      ..strokeWidth = 0.75;

    const zoneWidth = 150.0;
    const zoneHeight = 145.0;

    int top = 1;

    for (
      double x = frame.left + zoneWidth;
      x < frame.right;
      x += zoneWidth
    ) {
      canvas.drawLine(
        Offset(x, frame.top),
        Offset(x, frame.top + 20),
        paint,
      );

      _zoneText(
        canvas,
        '$top',
        Offset(
          x - zoneWidth / 2,
          frame.top + 4,
        ),
      );

      top++;
    }

    int bottom = 1;

    for (
      double x = frame.left + zoneWidth;
      x < frame.right;
      x += zoneWidth
    ) {
      canvas.drawLine(
        Offset(x, frame.bottom - 20),
        Offset(x, frame.bottom),
        paint,
      );

      _zoneText(
        canvas,
        '$bottom',
        Offset(
          x - zoneWidth / 2,
          frame.bottom - 18,
        ),
      );

      bottom++;
    }

    const letters = [
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'G',
      'H',
      'I',
      'J',
    ];

    int row = 0;

    for (
      double y = frame.top + zoneHeight;
      y < frame.bottom;
      y += zoneHeight
    ) {
      final index = row.clamp(
        0,
        letters.length - 1,
      );

      final label = letters[index];

      canvas.drawLine(
        Offset(frame.left, y),
        Offset(frame.left + 20, y),
        paint,
      );

      canvas.drawLine(
        Offset(frame.right - 20, y),
        Offset(frame.right, y),
        paint,
      );

      _zoneText(
        canvas,
        label,
        Offset(
          frame.left + 5,
          y - zoneHeight / 2 - 5,
        ),
      );

      _zoneText(
        canvas,
        label,
        Offset(
          frame.right - 15,
          y - zoneHeight / 2 - 5,
        ),
      );

      row++;
    }
  }

  void _drawTitleBlock(
    Canvas canvas,
    Rect sheet,
  ) {
    final frame = sheet.deflate(13);

    const width = 690.0;
    const height = 275.0;

    final block = Rect.fromLTWH(
      frame.right - width,
      frame.bottom - height,
      width,
      height,
    );

    final border = Paint()
      ..color = const Color(0xFF30363B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final line = Paint()
      ..color = const Color(0xFF737A80)
      ..strokeWidth = 1;

    canvas.drawRect(block, border);

    final row1 = block.top + block.height * 0.30;
    final row2 = block.top + block.height * 0.58;
    final row3 = block.top + block.height * 0.80;

    canvas.drawLine(
      Offset(block.left, row1),
      Offset(block.right, row1),
      line,
    );

    canvas.drawLine(
      Offset(block.left, row2),
      Offset(block.right, row2),
      line,
    );

    canvas.drawLine(
      Offset(block.left, row3),
      Offset(block.right, row3),
      line,
    );

    final col1 = block.left + block.width * 0.52;
    final col2 = block.left + block.width * 0.76;

    canvas.drawLine(
      Offset(col1, row2),
      Offset(col1, block.bottom),
      line,
    );

    canvas.drawLine(
      Offset(col2, row2),
      Offset(col2, block.bottom),
      line,
    );

    _blockText(
      canvas,
      'VOLTURA',
      Offset(
        block.left + 18,
        block.top + 15,
      ),
      fontSize: 28,
      bold: true,
    );

    _blockText(
      canvas,
      'ENGINEERING DESIGN',
      Offset(
        block.left + 19,
        block.top + 52,
      ),
      fontSize: 13,
      bold: true,
    );

    _blockText(
      canvas,
      'PROJECT',
      Offset(
        block.left + 16,
        row1 + 12,
      ),
    );

    _blockText(
      canvas,
      'MAIN SCHEMATIC',
      Offset(
        block.left + 16,
        row1 + 36,
      ),
      fontSize: 15,
      bold: true,
    );

    _blockText(
      canvas,
      'SHEET',
      Offset(
        block.left + 16,
        row2 + 12,
      ),
    );

    _blockText(
      canvas,
      'A3',
      Offset(
        col1 + 14,
        row2 + 12,
      ),
      fontSize: 15,
      bold: true,
    );

    _blockText(
      canvas,
      'REV',
      Offset(
        col2 + 14,
        row2 + 12,
      ),
    );

    _blockText(
      canvas,
      'DRAWN',
      Offset(
        block.left + 16,
        row3 + 10,
      ),
    );

    _blockText(
      canvas,
      '01',
      Offset(
        col1 + 14,
        row3 + 10,
      ),
      fontSize: 15,
      bold: true,
    );

    _blockText(
      canvas,
      '1.0',
      Offset(
        col2 + 14,
        row3 + 10,
      ),
      fontSize: 15,
      bold: true,
    );
  }

  void _zoneText(
    Canvas canvas,
    String text,
    Offset position,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF555B60),
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    painter.layout();

    painter.paint(
      canvas,
      position - Offset(
        painter.width / 2,
        0,
      ),
    );
  }

  void _blockText(
    Canvas canvas,
    String text,
    Offset position, {
    double fontSize = 12,
    bool bold = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: const Color(0xFF30363B),
          fontSize: fontSize,
          fontWeight: bold
              ? FontWeight.w700
              : FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    painter.layout();

    painter.paint(
      canvas,
      position,
    );
  }

  @override
  bool shouldRepaint(
    covariant EdaSchematicSheetPainter oldDelegate,
  ) {
    return false;
  }
}

// ============================================================================
// HORIZONTAL RULER
// ============================================================================

class EdaHorizontalRulerPainter extends CustomPainter {
  final Matrix4 transform;
  final Offset? mouseWorld;
  final double pixelsPerMm;

  EdaHorizontalRulerPainter({
    required this.transform,
    required this.mouseWorld,
    required this.pixelsPerMm,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF1F3F4),
    );

    final scale = transform.getMaxScaleOnAxis();

    if (scale <= 0) {
      return;
    }

    final translation = transform.getTranslation();

    final spacing = _niceWorldSpacing(
      pixelsPerMm,
      scale,
      70,
    );

    final screenSpacing = spacing * scale;

    final firstWorld = -translation.x / scale;

    final lastWorld =
        (size.width - translation.x) / scale;

    final start =
        (firstWorld / spacing).floor() * spacing;

    final tickPaint = Paint()
      ..color = const Color(0xFF697177)
      ..strokeWidth = 1;

    for (
      double x = start;
      x <= lastWorld + spacing;
      x += spacing
    ) {
      final sx = x * scale + translation.x;

      if (sx < -40 || sx > size.width + 40) {
        continue;
      }

      final major = screenSpacing >= 45;
      final height = major ? 15.0 : 7.0;

      canvas.drawLine(
        Offset(
          sx,
          size.height - height,
        ),
        Offset(
          sx,
          size.height,
        ),
        tickPaint,
      );

      if (major) {
        _drawLabel(
          canvas,
          _format(x / pixelsPerMm),
          Offset(
            sx + 4,
            3,
          ),
        );
      }
    }

    if (mouseWorld != null) {
      final sx =
          mouseWorld!.dx * scale + translation.x;

      if (sx >= 0 && sx <= size.width) {
        final paint = Paint()
          ..color = AppColors.signalOrange
          ..strokeWidth = 1.2;

        canvas.drawLine(
          Offset(sx, 0),
          Offset(sx, size.height),
          paint,
        );

        final path = Path()
          ..moveTo(
            sx - 4,
            size.height,
          )
          ..lineTo(
            sx + 4,
            size.height,
          )
          ..lineTo(
            sx,
            size.height - 6,
          )
          ..close();

        canvas.drawPath(
          path,
          Paint()..color = AppColors.signalOrange,
        );
      }
    }

    canvas.drawLine(
      Offset(
        0,
        size.height - 0.5,
      ),
      Offset(
        size.width,
        size.height - 0.5,
      ),
      Paint()
        ..color = const Color(0xFFB5BDC2)
        ..strokeWidth = 1,
    );
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    Offset position,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF596168),
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    painter.layout();
    painter.paint(canvas, position);
  }

  String _format(double value) {
    if ((value - value.round()).abs() < 0.001) {
      return value.round().toString();
    }

    return value.toStringAsFixed(1);
  }

  @override
  bool shouldRepaint(
    covariant EdaHorizontalRulerPainter oldDelegate,
  ) {
    return oldDelegate.transform != transform ||
        oldDelegate.mouseWorld != mouseWorld;
  }
}

// ============================================================================
// VERTICAL RULER
// ============================================================================

class EdaVerticalRulerPainter extends CustomPainter {
  final Matrix4 transform;
  final Offset? mouseWorld;
  final double pixelsPerMm;

  EdaVerticalRulerPainter({
    required this.transform,
    required this.mouseWorld,
    required this.pixelsPerMm,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF1F3F4),
    );

    final scale = transform.getMaxScaleOnAxis();

    if (scale <= 0) {
      return;
    }

    final translation = transform.getTranslation();

    final spacing = _niceWorldSpacing(
      pixelsPerMm,
      scale,
      55,
    );

    final screenSpacing = spacing * scale;

    final firstWorld = -translation.y / scale;

    final lastWorld =
        (size.height - translation.y) / scale;

    final start =
        (firstWorld / spacing).floor() * spacing;

    final paint = Paint()
      ..color = const Color(0xFF697177)
      ..strokeWidth = 1;

    for (
      double y = start;
      y <= lastWorld + spacing;
      y += spacing
    ) {
      final sy = y * scale + translation.y;

      if (sy < -40 || sy > size.height + 40) {
        continue;
      }

      final major = screenSpacing >= 38;
      final width = major ? 15.0 : 7.0;

      canvas.drawLine(
        Offset(
          size.width - width,
          sy,
        ),
        Offset(
          size.width,
          sy,
        ),
        paint,
      );

      if (major) {
        final painter = TextPainter(
          text: TextSpan(
            text: _format(
              y / pixelsPerMm,
            ),
            style: const TextStyle(
              color: Color(0xFF596168),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        painter.layout();

        painter.paint(
          canvas,
          Offset(
            3,
            sy + 3,
          ),
        );
      }
    }

    if (mouseWorld != null) {
      final sy =
          mouseWorld!.dy * scale + translation.y;

      if (sy >= 0 && sy <= size.height) {
        final paint = Paint()
          ..color = AppColors.signalOrange
          ..strokeWidth = 1.2;

        canvas.drawLine(
          Offset(0, sy),
          Offset(size.width, sy),
          paint,
        );

        final path = Path()
          ..moveTo(0, sy)
          ..lineTo(6, sy - 4)
          ..lineTo(6, sy + 4)
          ..close();

        canvas.drawPath(
          path,
          Paint()..color = AppColors.signalOrange,
        );
      }
    }

    canvas.drawLine(
      Offset(
        size.width - 0.5,
        0,
      ),
      Offset(
        size.width - 0.5,
        size.height,
      ),
      Paint()
        ..color = const Color(0xFFB5BDC2)
        ..strokeWidth = 1,
    );
  }

  String _format(double value) {
    if ((value - value.round()).abs() < 0.001) {
      return value.round().toString();
    }

    return value.toStringAsFixed(1);
  }

  @override
  bool shouldRepaint(
    covariant EdaVerticalRulerPainter oldDelegate,
  ) {
    return oldDelegate.transform != transform ||
        oldDelegate.mouseWorld != mouseWorld;
  }
}

// ============================================================================
// RULER HELPER
// ============================================================================

double _niceWorldSpacing(
  double pixelsPerMm,
  double scale,
  double targetPixels,
) {
  final targetWorld =
      targetPixels / math.max(0.001, scale);

  final targetMm = targetWorld / pixelsPerMm;

  if (targetMm <= 0) {
    return pixelsPerMm;
  }

  final exponent = math.pow(
    10,
    (math.log(targetMm) / math.ln10).floor(),
  ).toDouble();

  final normalized = targetMm / exponent;

  double nice;

  if (normalized <= 1) {
    nice = 1;
  } else if (normalized <= 2) {
    nice = 2;
  } else if (normalized <= 5) {
    nice = 5;
  } else {
    nice = 10;
  }

  return nice * exponent * pixelsPerMm;
}

// ============================================================================
// CROSSHAIR
// ============================================================================

class EdaCrosshairPainter extends CustomPainter {
  final Offset position;
  final Color color;

  EdaCrosshairPainter({
    required this.position,
    required this.color,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    if (position.dx < 0 ||
        position.dy < 0 ||
        position.dx > size.width ||
        position.dy > size.height) {
      return;
    }

    final glow = Paint()
      ..color = color.withOpacity(0.05)
      ..strokeWidth = 4;

    final line = Paint()
      ..color = color.withOpacity(0.45)
      ..strokeWidth = 0.8;

    canvas.drawLine(
      Offset(
        0,
        position.dy,
      ),
      Offset(
        size.width,
        position.dy,
      ),
      glow,
    );

    canvas.drawLine(
      Offset(
        0,
        position.dy,
      ),
      Offset(
        size.width,
        position.dy,
      ),
      line,
    );

    canvas.drawLine(
      Offset(
        position.dx,
        0,
      ),
      Offset(
        position.dx,
        size.height,
      ),
      glow,
    );

    canvas.drawLine(
      Offset(
        position.dx,
        0,
      ),
      Offset(
        position.dx,
        size.height,
      ),
      line,
    );

    canvas.drawCircle(
      position,
      3,
      Paint()..color = Colors.white,
    );

    canvas.drawCircle(
      position,
      3,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
  }

  @override
  bool shouldRepaint(
    covariant EdaCrosshairPainter oldDelegate,
  ) {
    return oldDelegate.position != position ||
        oldDelegate.color != color;
  }
}

// ============================================================================
// TOOLBAR
// ============================================================================

class _CanvasToolbar extends StatelessWidget {
  final double zoom;

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onFit;
  final VoidCallback onResetZoom;

  const _CanvasToolbar({
    required this.zoom,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onFit,
    required this.onResetZoom,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFF20262B).withOpacity(0.97),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: const Color(0xFF495158),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ToolIcon(
              icon: Icons.remove_rounded,
              tooltip: 'Zoom out',
              onPressed: onZoomOut,
            ),
            _ZoomLabel(zoom: zoom),
            _ToolIcon(
              icon: Icons.add_rounded,
              tooltip: 'Zoom in',
              onPressed: onZoomIn,
            ),
            const _ToolbarDivider(),
            _ToolIcon(
              icon: Icons.fit_screen_rounded,
              tooltip: 'Fit sheet',
              onPressed: onFit,
            ),
            _ToolIcon(
              icon: Icons.one_x_mobiledata_rounded,
              tooltip: '100% zoom',
              onPressed: onResetZoom,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TOOL ICON
// ============================================================================

class _ToolIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ToolIcon({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(
            icon,
            size: 15,
            color: const Color(0xFFDCE1E4),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TOOLBAR DIVIDER
// ============================================================================

class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 18,
      margin: const EdgeInsets.symmetric(
        horizontal: 2,
      ),
      color: const Color(0xFF4B5359),
    );
  }
}

// ============================================================================
// ZOOM LABEL
// ============================================================================

class _ZoomLabel extends StatelessWidget {
  final double zoom;

  const _ZoomLabel({
    required this.zoom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 48,
      ),
      alignment: Alignment.center,
      child: Text(
        '${(zoom * 100).round()}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ============================================================================
// STATUS
// ============================================================================

class _CanvasStatus extends StatelessWidget {
  final Offset? mouseWorld;
  final double gridMm;
  final SchematicUnit unit;

  const _CanvasStatus({
    required this.mouseWorld,
    required this.gridMm,
    required this.unit,
  });

  String _gridText() {
    if (unit == SchematicUnit.mm) {
      if ((gridMm - gridMm.round()).abs() < 0.0001) {
        return '${gridMm.round()} mm';
      }

      return '${gridMm.toStringAsFixed(3)} mm';
    }

    return '${(gridMm / 25.4).toStringAsFixed(2)} inch';
  }

  @override
  Widget build(BuildContext context) {
    final xMm = mouseWorld == null
        ? null
        : mouseWorld!.dx /
            _SchematicSheetState.pixelsPerMm;

    final yMm = mouseWorld == null
        ? null
        : mouseWorld!.dy /
            _SchematicSheetState.pixelsPerMm;

    final String xValue;
    final String yValue;

    if (xMm == null || yMm == null) {
      xValue = '--';
      yValue = '--';
    } else if (unit == SchematicUnit.mm) {
      xValue = '${xMm.toStringAsFixed(2)} mm';
      yValue = '${yMm.toStringAsFixed(2)} mm';
    } else {
      final xInch = xMm / 25.4;
      final yInch = yMm / 25.4;

      // Fixed:
      // The previous code effectively attempted:
      // double / String
      // because `25.4.toStringAsFixed(3)` was evaluated first.
      xValue = '${xInch.toStringAsFixed(3)} inch';
      yValue = '${yInch.toStringAsFixed(3)} inch';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF20262B).withOpacity(0.96),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF4B535A),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatusItem(
            label: 'X',
            value: xValue,
          ),
          const SizedBox(width: 15),
          _StatusItem(
            label: 'Y',
            value: yValue,
          ),
          const SizedBox(width: 15),
          _StatusItem(
            label: 'GRID',
            value: _gridText(),
          ),
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatusItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8F999F),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
