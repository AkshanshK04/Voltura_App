import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'view_menu.dart';

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

  /// Optional parent-owned settings. If omitted, ViewSettings() resolves to
  /// the same editor-wide shared instance used by MenuBarWidget.
  final ViewSettings? viewSettings;

  const SchematicSheet({
    super.key,
    this.onCommand,
    this.viewSettings,
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

  SchematicUnit _unit = SchematicUnit.inch;

  // Canonical physical grid spacing is stored in millimetres.
  double _gridMm = 2.54;

  SchematicGridType _gridType = SchematicGridType.grid;

  SchematicHighlightMode _highlightMode =
      SchematicHighlightMode.unhighlight;

  // ==========================================================================
  // SHARED VIEW SETTINGS
  // ==========================================================================

  late ViewSettings _activeViewSettings;

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

  bool _workspaceOpen = false;
  bool _aiOpen = false;

    

  // ==========================================================================
  // CUSTOM PAN
  // ==========================================================================

  int? _panPointer;
  Offset? _panStart;
  Offset? _panStartTranslation;

  bool _panMode = false;

  // Native trackpad gesture state: two-finger pan + pinch zoom.
  bool _trackpadPanZoomActive = false;
  double _trackpadStartScale = 1.0;
  Offset _trackpadStartTranslation = Offset.zero;
  Offset _trackpadFocalPoint = Offset.zero;

  // ==========================================================================
  // LIFECYCLE
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _controller.addListener(_onTransformChanged);

    _activeViewSettings = widget.viewSettings ?? ViewSettings();
    _activeViewSettings.addListener(_onViewSettingsChanged);
    _syncFromViewSettings();
  }

  @override
  void didUpdateWidget(covariant SchematicSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    final nextSettings = widget.viewSettings ?? ViewSettings();

    if (oldWidget.viewSettings != widget.viewSettings) {
      _activeViewSettings.removeListener(_onViewSettingsChanged);
      _activeViewSettings = nextSettings;
      _activeViewSettings.addListener(_onViewSettingsChanged);
      _syncFromViewSettings();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTransformChanged);
    _activeViewSettings.removeListener(_onViewSettingsChanged);
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
    _activeViewSettings.setUnit(
      unit == SchematicUnit.mm ? ViewUnit.mm : ViewUnit.inch,
    );
  }

  // ==========================================================================
  // GRID
  // ==========================================================================

  void _setGridFromInch(double inch) {
    _activeViewSettings.setGridSizeInches(inch);
  }

  void _setGridType(SchematicGridType type) {
    final mapped = switch (type) {
      SchematicGridType.dot => GridType.dot,
      SchematicGridType.grid => GridType.grid,
      SchematicGridType.none => GridType.none,
    };

    _activeViewSettings.setGridType(mapped);
  }

  // ==========================================================================
  // HIGHLIGHT
  // ==========================================================================

  void _setHighlightMode(SchematicHighlightMode mode) {
    final mapped = switch (mode) {
      SchematicHighlightMode.highlight =>
        HighlightNetMode.highlight,
      SchematicHighlightMode.unhighlight =>
        HighlightNetMode.unhighlight,
      SchematicHighlightMode.hoverWire =>
        HighlightNetMode.hoverWire,
    };

    _activeViewSettings.setHighlightNetMode(mapped);
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
  // SHARED VIEW SETTINGS
  // ==========================================================================

  void _syncFromViewSettings() {
    final settings = _activeViewSettings;

    _unit = settings.unit == ViewUnit.mm
        ? SchematicUnit.mm
        : SchematicUnit.inch;

    // Grid size is physically stored in inches and rendered in mm.
    _gridMm = settings.gridSizeInches * 25.4;

    switch (settings.gridType) {
      case GridType.dot:
        _gridType = SchematicGridType.dot;
        break;
      case GridType.grid:
        _gridType = SchematicGridType.grid;
        break;
      case GridType.none:
        _gridType = SchematicGridType.none;
        break;
    }

    switch (settings.highlightNetMode) {
      case HighlightNetMode.highlight:
        _highlightMode = SchematicHighlightMode.highlight;
        break;
      case HighlightNetMode.unhighlight:
        _highlightMode = SchematicHighlightMode.unhighlight;
        break;
      case HighlightNetMode.hoverWire:
        _highlightMode = SchematicHighlightMode.hoverWire;
        break;
    }
  }

  void _onViewSettingsChanged() {
    if (!mounted) {
      _syncFromViewSettings();
      return;
    }

    setState(_syncFromViewSettings);
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
  // Fullscreen is owned by MainShell.
  // The sheet only forwards the command upward.
  widget.onCommand?.call('Full Screen');
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

  void _onPointerPanZoomStart(PointerPanZoomStartEvent event) {
    _trackpadPanZoomActive = true;
    _trackpadStartScale = _scale;
    _trackpadStartTranslation = _translation;
    _trackpadFocalPoint = event.localPosition;

    if (mounted) {
      setState(() {
        _panMode = true;
      });
    }
  }

  void _onPointerPanZoomUpdate(PointerPanZoomUpdateEvent event) {
    if (!_trackpadPanZoomActive) {
      return;
    }

    final targetScale = (_trackpadStartScale * event.scale)
        .clamp(minZoom, maxZoom)
        .toDouble();
    final actualFactor = targetScale / _trackpadStartScale;

    // Pinch zooms around the point between the fingers; two-finger movement
    // is added as a natural canvas pan.
    final newTranslation =
        _trackpadFocalPoint -
        (_trackpadFocalPoint - _trackpadStartTranslation) *
            actualFactor +
        event.pan;

    _controller.value = _makeMatrix(
      targetScale,
      newTranslation,
    );

    _mousePosition = event.localPosition;
    _mouseInside = true;
    _updateMouseWorld();
  }

  void _onPointerPanZoomEnd(PointerPanZoomEndEvent event) {
    _trackpadPanZoomActive = false;

    if (mounted) {
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
                    onPointerPanZoomStart: _onPointerPanZoomStart,
                    onPointerPanZoomUpdate: _onPointerPanZoomUpdate,
                    onPointerPanZoomEnd: _onPointerPanZoomEnd,
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
                                        EdaSchematicSheetPainter(
                                      pixelsPerMm: pixelsPerMm,
                                      gridMm: _gridMm,
                                      gridType: _gridType,
                                    ),
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
                      unit: _unit,
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
                      unit: _unit,
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
              // TRANSPARENT WORKSPACE / AI OVERLAY
              // ===============================================================

              if (_workspaceOpen || _aiOpen)
                Positioned.fill(
                  child: _WorkspaceOverlay(
                    workspaceOpen: _workspaceOpen,
                    aiOpen: _aiOpen,
                    onClose: () {
                      setState(() {
                        _workspaceOpen = false;
                        _aiOpen = false;
                      });
                    },
                    onSheetSelected: (sheetName) {
                      widget.onCommand?.call(
                        'Open Sheet: $sheetName',
                      );
                    },
                  ),
                ),

              // ===============================================================
              // FLOATING WORKSPACE ICON
              // ===============================================================

              Positioned(
                right: 14,
                top: 48,
                child: _FloatingActionIcon(
                  icon: Icons.folder_copy_outlined,
                  tooltip: 'Workspace',
                  active: _workspaceOpen,
                  onTap: () {
                    setState(() {
                      _workspaceOpen = !_workspaceOpen;
                      _aiOpen = false;
                    });
                  },
                ),
              ),

              // ===============================================================
              // FLOATING AI ICON
              // ===============================================================

              Positioned(
                right: 14,
                bottom: 48,
                child: _FloatingActionIcon(
                  icon: Icons.auto_awesome_outlined,
                  tooltip: 'AI',
                  active: _aiOpen,
                  onTap: () {
                    setState(() {
                      _aiOpen = !_aiOpen;
                      _workspaceOpen = false;
                    });
                  },
                ),
              ),

              // ===============================================================
              // TOOLBAR
              // ===============================================================

              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                left: _workspaceOpen || _aiOpen ? 18 : null,
                right: _workspaceOpen || _aiOpen ? null : 64,
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
// FLOATING WORKSPACE / AI ACTION ICON
// ============================================================================

class _FloatingActionIcon extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final bool active;
  final VoidCallback onTap;

  const _FloatingActionIcon({
    required this.icon,
    required this.tooltip,
    required this.active,
    required this.onTap,
  });

  @override
  State<_FloatingActionIcon> createState() =>
      _FloatingActionIconState();
}

class _FloatingActionIconState extends State<_FloatingActionIcon>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final highlighted = widget.active || _hovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: widget.tooltip,
        waitDuration: const Duration(milliseconds: 450),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedScale(
            scale: highlighted ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: widget.active
                    ? Colors.white.withOpacity(0.72)
                    : highlighted
                        ? Colors.white.withOpacity(0.48)
                        : Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.active
                      ? AppColors.signalOrange.withOpacity(0.72)
                      : Colors.white.withOpacity(
                          highlighted ? 0.58 : 0.30,
                        ),
                  width: 0.8,
                ),
                boxShadow: [
                  // Always-on soft glow so the icons remain visible.
                  BoxShadow(
                    color: widget.active
                        ? AppColors.signalOrange.withOpacity(0.42)
                        : const Color(0xFFB9C4CA).withOpacity(0.30),
                    blurRadius: highlighted ? 18 : 10,
                    spreadRadius: highlighted ? 2 : 0,
                  ),
                  if (highlighted)
                    BoxShadow(
                      color: Colors.white.withOpacity(0.32),
                      blurRadius: 8,
                      spreadRadius: -1,
                    ),
                ],
              ),
              child: Icon(
                widget.icon,
                size: highlighted ? 21 : 20,
                color: widget.active
                    ? AppColors.signalOrange
                    : const Color(0xFF465158),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TRANSPARENT OVERLAY
// ============================================================================

class _WorkspaceOverlay extends StatelessWidget {
  final bool workspaceOpen;
  final bool aiOpen;
  final VoidCallback onClose;
  final ValueChanged<String> onSheetSelected;

  const _WorkspaceOverlay({
    required this.workspaceOpen,
    required this.aiOpen,
    required this.onClose,
    required this.onSheetSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fully transparent click-away layer. The schematic remains visible.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onClose,
            child: const SizedBox.expand(),
          ),
        ),

        if (workspaceOpen)
          Positioned(
            top: 12,
            bottom: 12,
            right: 62,
            width: 310,
            child: _WorkspacePanel(
              onClose: onClose,
              onSheetSelected: onSheetSelected,
            ),
          ),

        if (aiOpen)
          Positioned(
            top: 12,
            bottom: 12,
            right: 62,
            width: 350,
            child: _AiPanel(
              onClose: onClose,
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// GLASS PANEL HEADER
// ============================================================================

class _GlassPanelHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onClose;

  const _GlassPanelHeader({
    required this.icon,
    required this.title,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.025),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.12),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFF505B62),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.05,
                color: Color(0xFF303940),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onClose,
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(
                  Icons.close_rounded,
                  size: 17,
                  color: Color(0xFF68737A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// WORKSPACE PANEL
// ============================================================================

class _WorkspacePanel extends StatelessWidget {
  final VoidCallback onClose;
  final ValueChanged<String> onSheetSelected;

  const _WorkspacePanel({
    required this.onClose,
    required this.onSheetSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: 24,
          sigmaY: 24,
        ),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              // Same ultra-light glass opacity as the floating Workspace / AI icons.
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.025),
                  blurRadius: 18,
                  spreadRadius: 0,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.08),
                  blurRadius: 12,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _GlassPanelHeader(
                  icon: Icons.folder_copy_outlined,
                  title: 'WORKSPACE',
                  onClose: onClose,
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 14, 16, 7),
                  child: Text(
                    'PROJECT EXPLORER',
                    style: TextStyle(
                      color: Color(0xFF7B858C),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.15,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 16),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _WorkspaceFolder(
                        title: 'Voltura Project',
                        icon: Icons.folder_special_outlined,
                        initiallyExpanded: true,
                        children: [
                          _WorkspaceFolder(
                            title: 'Schematics',
                            initiallyExpanded: true,
                            children: [
                              _WorkspaceSheet(
                                title: 'Main Schematic',
                                selected: true,
                                onTap: () => onSheetSelected('Main Schematic'),
                              ),
                              _WorkspaceSheet(
                                title: 'Power Supply',
                                onTap: () => onSheetSelected('Power Supply'),
                              ),
                              _WorkspaceSheet(
                                title: 'Controller',
                                onTap: () => onSheetSelected('Controller'),
                              ),
                            ],
                          ),
                          _WorkspaceFolder(
                            title: 'Hardware',
                            children: [
                              _WorkspaceSheet(
                                title: 'PCB Layout',
                                onTap: () => onSheetSelected('PCB Layout'),
                              ),
                              _WorkspaceSheet(
                                title: '3D View',
                                onTap: () => onSheetSelected('3D View'),
                              ),
                            ],
                          ),
                          _WorkspaceFolder(
                            title: 'Libraries',
                            children: [
                              _WorkspaceFolder(
                                title: 'Symbols',
                                children: [
                                  _WorkspaceSheet(
                                    title: 'Passive Components',
                                    onTap: () => onSheetSelected('Passive Components'),
                                  ),
                                  _WorkspaceSheet(
                                    title: 'Connectors',
                                    onTap: () => onSheetSelected('Connectors'),
                                  ),
                                ],
                              ),
                              _WorkspaceFolder(
                                title: 'Footprints',
                                children: [
                                  _WorkspaceSheet(
                                    title: 'Standard Footprints',
                                    onTap: () => onSheetSelected('Standard Footprints'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          _WorkspaceFolder(
                            title: 'Documentation',
                            children: [
                              _WorkspaceSheet(
                                title: 'Project Notes',
                                onTap: () => onSheetSelected('Project Notes'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// AI PANEL
// ============================================================================

class _AiPanel extends StatelessWidget {
  final VoidCallback onClose;

  const _AiPanel({
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: 24,
          sigmaY: 24,
        ),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              // Same ultra-light glass opacity as the floating Workspace / AI icons.
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.025),
                  blurRadius: 18,
                  spreadRadius: 0,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.08),
                  blurRadius: 12,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Column(
              children: [
                _GlassPanelHeader(
                  icon: Icons.auto_awesome_outlined,
                  title: 'AI ASSISTANT',
                  onClose: onClose,
                ),
                const Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 34,
                            color: Color(0xFF7E898F),
                          ),
                          SizedBox(height: 14),
                          Text(
                            'AI workspace',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3B454C),
                            ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            'Your schematic AI tools can appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.5,
                              color: Color(0xFF78838A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// WORKSPACE FOLDER
// ============================================================================

class _WorkspaceFolder extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool initiallyExpanded;
  final List<Widget> children;

  const _WorkspaceFolder({
    required this.title,
    required this.children,
    this.icon = Icons.folder_outlined,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        expansionTileTheme: const ExpansionTileThemeData(
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
        ),
        listTileTheme: const ListTileThemeData(
          dense: true,
          minVerticalPadding: 0,
          visualDensity: VisualDensity.compact,
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.only(left: 10, right: 8),
        childrenPadding: const EdgeInsets.only(left: 12),
        leading: Icon(
          icon,
          size: 17,
          color: const Color(0xFF68747C),
        ),
        iconColor: const Color(0xFF68747C),
        collapsedIconColor: const Color(0xFF68747C),
        title: Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF303940),
            fontWeight: FontWeight.w600,
          ),
        ),
        children: children,
      ),
    );
  }
}

// ============================================================================
// WORKSPACE SHEET
// ============================================================================

class _WorkspaceSheet extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool selected;

  const _WorkspaceSheet({
    required this.title,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8, bottom: 2),
      child: Material(
        color: selected
            ? const Color(0xFFFFE9D9).withOpacity(0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 7,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 15,
                  color: selected
                      ? AppColors.signalOrange
                      : const Color(0xFF7C878E),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: selected
                          ? const Color(0xFF9D4A15)
                          : const Color(0xFF4D585F),
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
  final double pixelsPerMm;
  final double gridMm;
  final SchematicGridType gridType;

  EdaSchematicSheetPainter({
    required this.pixelsPerMm,
    required this.gridMm,
    required this.gridType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final sheet = Rect.fromLTWH(
      _SchematicSheetState.sheetLeft,
      _SchematicSheetState.sheetTop,
      _SchematicSheetState.sheetWidth,
      _SchematicSheetState.sheetHeight,
    );

    _drawSheetShadow(canvas, sheet);
    _drawSheet(canvas, sheet);
    _drawSheetGrid(canvas, sheet);
    _drawFrame(canvas, sheet);
    _drawZones(canvas, sheet);
    _drawTitleBlock(canvas, sheet);
  }

  void _drawSheetShadow(Canvas canvas, Rect sheet) {
    final shadow = Paint()
      ..color = Colors.black.withOpacity(0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    canvas.drawRect(sheet.shift(const Offset(8, 10)), shadow);

    final edgeShadow = Paint()
      ..color = Colors.black.withOpacity(0.055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawRect(sheet.deflate(1), edgeShadow);
  }

  void _drawSheet(Canvas canvas, Rect sheet) {
    // Slight translucency lets the drafting surface feel like a real CAD sheet
    // while keeping the grid crisp and readable.
    canvas.drawRect(
      sheet,
      Paint()..color = Colors.white.withOpacity(0.76),
    );

    // Very subtle inner paper wash.
    canvas.drawRect(
      sheet.deflate(18),
      Paint()..color = const Color(0xFFFDFEFE).withOpacity(0.22),
    );
  }

  void _drawSheetGrid(Canvas canvas, Rect sheet) {
    if (gridType == SchematicGridType.none || gridMm <= 0) {
      return;
    }

    final inner = sheet.deflate(19);
    canvas.save();
    canvas.clipRect(inner);

    // IMPORTANT: this uses the same world origin as EdaInfiniteGridPainter.
    // Therefore the grid inside the sheet stays perfectly locked to the grid
    // outside the sheet while zooming and panning.
    final spacing = pixelsPerMm * gridMm;
    if (!spacing.isFinite || spacing <= 0) {
      canvas.restore();
      return;
    }

    final firstX = (inner.left / spacing).floor() * spacing;
    final firstY = (inner.top / spacing).floor() * spacing;

    if (gridType == SchematicGridType.dot) {
      final dotPaint = Paint()
        ..color = const Color(0xFF879197).withOpacity(0.28)
        ..style = PaintingStyle.fill;

      for (double x = firstX; x <= inner.right; x += spacing) {
        for (double y = firstY; y <= inner.bottom; y += spacing) {
          canvas.drawCircle(Offset(x, y), 0.65, dotPaint);
        }
      }
    } else {
      final minorScreenSpacing = spacing;
      final minorOpacity = minorScreenSpacing < 4
          ? 0.10
          : minorScreenSpacing < 8
              ? 0.17
              : 0.25;

      final minor = Paint()
        ..color = const Color(0xFF879197).withOpacity(minorOpacity)
        ..strokeWidth = minorScreenSpacing < 5 ? 0.45 : 0.65
        ..style = PaintingStyle.stroke;

      for (double x = firstX; x <= inner.right; x += spacing) {
        canvas.drawLine(
          Offset(x, inner.top),
          Offset(x, inner.bottom),
          minor,
        );
      }

      for (double y = firstY; y <= inner.bottom; y += spacing) {
        canvas.drawLine(
          Offset(inner.left, y),
          Offset(inner.right, y),
          minor,
        );
      }

      // Strong drafting lines every 10 grid steps.
      final majorSpacing = spacing * 10;
      if (majorSpacing >= 6) {
        final majorFirstX =
            (inner.left / majorSpacing).floor() * majorSpacing;
        final majorFirstY =
            (inner.top / majorSpacing).floor() * majorSpacing;

        final major = Paint()
          ..color = const Color(0xFF6F7A81).withOpacity(
            majorSpacing < 22 ? 0.24 : 0.36,
          )
          ..strokeWidth = majorSpacing < 22 ? 0.65 : 0.85
          ..style = PaintingStyle.stroke;

        for (double x = majorFirstX; x <= inner.right; x += majorSpacing) {
          canvas.drawLine(
            Offset(x, inner.top),
            Offset(x, inner.bottom),
            major,
          );
        }

        for (double y = majorFirstY; y <= inner.bottom; y += majorSpacing) {
          canvas.drawLine(
            Offset(inner.left, y),
            Offset(inner.right, y),
            major,
          );
        }
      }
    }

    canvas.restore();
  }

  void _drawFrame(Canvas canvas, Rect sheet) {
    final outer = Paint()
      ..color = const Color(0xFF1F2529)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.8;

    final inner = Paint()
      ..color = const Color(0xFF59636A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final technical = Paint()
      ..color = const Color(0xFF9AA3A9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25;

    canvas.drawRect(sheet, outer);
    canvas.drawRect(sheet.deflate(13), inner);
    canvas.drawRect(sheet.deflate(18), technical);

    // Small registration/corner accents make the sheet feel more like a real
    // engineering drawing frame rather than a plain rectangle.
    final accent = Paint()
      ..color = const Color(0xFF30383D)
      ..strokeWidth = 1.35
      ..style = PaintingStyle.stroke;

    const l = 18.0;
    final corners = <List<Offset>>[
      [sheet.topLeft + const Offset(5, l), sheet.topLeft + const Offset(5, 5)],
      [sheet.topLeft + const Offset(5, 5), sheet.topLeft + const Offset(l, 5)],
      [sheet.topRight + const Offset(-l, 5), sheet.topRight + const Offset(-5, 5)],
      [sheet.topRight + const Offset(-5, 5), sheet.topRight + const Offset(-5, l)],
      [sheet.bottomLeft + const Offset(5, -l), sheet.bottomLeft + const Offset(5, -5)],
      [sheet.bottomLeft + const Offset(5, -5), sheet.bottomLeft + const Offset(l, -5)],
      [sheet.bottomRight + const Offset(-l, -5), sheet.bottomRight + const Offset(-5, -5)],
      [sheet.bottomRight + const Offset(-5, -l), sheet.bottomRight + const Offset(-5, -5)],
    ];

    for (final pair in corners) {
      canvas.drawLine(pair[0], pair[1], accent);
    }
  }

  void _drawZones(Canvas canvas, Rect sheet) {
    final frame = sheet.deflate(13);

    final paint = Paint()
      ..color = const Color(0xFF4F5A61)
      ..strokeWidth = 1.0;

    const zoneWidth = 150.0;
    const zoneHeight = 145.0;

    int top = 1;
    for (double x = frame.left + zoneWidth; x < frame.right; x += zoneWidth) {
      canvas.drawLine(
        Offset(x, frame.top),
        Offset(x, frame.top + 20),
        paint,
      );
      _zoneText(canvas, '$top', Offset(x - zoneWidth / 2, frame.top + 4));
      top++;
    }

    int bottom = 1;
    for (double x = frame.left + zoneWidth; x < frame.right; x += zoneWidth) {
      canvas.drawLine(
        Offset(x, frame.bottom - 20),
        Offset(x, frame.bottom),
        paint,
      );
      _zoneText(canvas, '$bottom', Offset(x - zoneWidth / 2, frame.bottom - 18));
      bottom++;
    }

    const letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
    int row = 0;

    for (double y = frame.top + zoneHeight; y < frame.bottom; y += zoneHeight) {
      final index = row.clamp(0, letters.length - 1);
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
        Offset(frame.left + 5, y - zoneHeight / 2 - 5),
      );
      _zoneText(
        canvas,
        label,
        Offset(frame.right - 15, y - zoneHeight / 2 - 5),
      );
      row++;
    }
  }

  void _drawTitleBlock(Canvas canvas, Rect sheet) {
    final frame = sheet.deflate(13);
    const width = 690.0;
    const height = 275.0;

    final block = Rect.fromLTWH(
      frame.right - width,
      frame.bottom - height,
      width,
      height,
    );

    // The title block is intentionally more opaque than the sheet grid so
    // text remains readable without making the whole sheet look solid.
    canvas.drawRect(
      block,
      Paint()..color = Colors.white.withOpacity(0.86),
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

    canvas.drawLine(Offset(block.left, row1), Offset(block.right, row1), line);
    canvas.drawLine(Offset(block.left, row2), Offset(block.right, row2), line);
    canvas.drawLine(Offset(block.left, row3), Offset(block.right, row3), line);

    final col1 = block.left + block.width * 0.52;
    final col2 = block.left + block.width * 0.76;

    canvas.drawLine(Offset(col1, row2), Offset(col1, block.bottom), line);
    canvas.drawLine(Offset(col2, row2), Offset(col2, block.bottom), line);

    _blockText(canvas, 'VOLTURA', Offset(block.left + 18, block.top + 15), fontSize: 28, bold: true);
    _blockText(canvas, 'ENGINEERING DESIGN', Offset(block.left + 19, block.top + 52), fontSize: 13, bold: true);
    _blockText(canvas, 'PROJECT', Offset(block.left + 16, row1 + 12));
    _blockText(canvas, 'MAIN SCHEMATIC', Offset(block.left + 16, row1 + 36), fontSize: 15, bold: true);
    _blockText(canvas, 'SHEET', Offset(block.left + 16, row2 + 12));
    _blockText(canvas, 'A3', Offset(col1 + 14, row2 + 12), fontSize: 15, bold: true);
    _blockText(canvas, 'REV', Offset(col2 + 14, row2 + 12));
    _blockText(canvas, 'DRAWN', Offset(block.left + 16, row3 + 10));
    _blockText(canvas, '01', Offset(col1 + 14, row3 + 10), fontSize: 15, bold: true);
    _blockText(canvas, '1.0', Offset(col2 + 14, row3 + 10), fontSize: 15, bold: true);
  }

  void _zoneText(Canvas canvas, String text, Offset position) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF252B30),
          fontSize: 19,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.15,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout();

    // Clean translucent backing keeps the engineering labels readable
    // without visually hiding the grid underneath.
    final labelRect = Rect.fromCenter(
      center: position + Offset(painter.width / 2, painter.height / 2),
      width: painter.width + 10,
      height: painter.height + 5,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, const Radius.circular(3.5)),
      Paint()..color = Colors.white.withOpacity(0.50),
    );

    painter.paint(canvas, position);
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
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    painter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant EdaSchematicSheetPainter oldDelegate) {
    return oldDelegate.pixelsPerMm != pixelsPerMm ||
        oldDelegate.gridMm != gridMm ||
        oldDelegate.gridType != gridType;
  }
}

// ============================================================================
// HORIZONTAL RULER
// ============================================================================

class EdaHorizontalRulerPainter extends CustomPainter {
  final Matrix4 transform;
  final Offset? mouseWorld;
  final double pixelsPerMm;
  final SchematicUnit unit;

  EdaHorizontalRulerPainter({
    required this.transform,
    required this.mouseWorld,
    required this.pixelsPerMm,
    required this.unit,
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
          _formatUnit(x / pixelsPerMm),
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

  String _formatUnit(double mmValue) {
    final value = unit == SchematicUnit.mm
        ? mmValue
        : mmValue / 25.4;

    if ((value - value.round()).abs() < 0.001) {
      return value.round().toString();
    }

    return unit == SchematicUnit.mm
        ? value.toStringAsFixed(1)
        : value.toStringAsFixed(2);
  }

  @override
  bool shouldRepaint(
    covariant EdaHorizontalRulerPainter oldDelegate,
  ) {
    return oldDelegate.transform != transform ||
        oldDelegate.mouseWorld != mouseWorld ||
        oldDelegate.unit != unit ||
        oldDelegate.pixelsPerMm != pixelsPerMm;
  }
}

// ============================================================================
// VERTICAL RULER
// ============================================================================

class EdaVerticalRulerPainter extends CustomPainter {
  final Matrix4 transform;
  final Offset? mouseWorld;
  final double pixelsPerMm;
  final SchematicUnit unit;

  EdaVerticalRulerPainter({
    required this.transform,
    required this.mouseWorld,
    required this.pixelsPerMm,
    required this.unit,
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
            text: _formatUnit(
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

  String _formatUnit(double mmValue) {
    final value = unit == SchematicUnit.mm
        ? mmValue
        : mmValue / 25.4;

    if ((value - value.round()).abs() < 0.001) {
      return value.round().toString();
    }

    return unit == SchematicUnit.mm
        ? value.toStringAsFixed(1)
        : value.toStringAsFixed(2);
  }

  @override
  bool shouldRepaint(
    covariant EdaVerticalRulerPainter oldDelegate,
  ) {
    return oldDelegate.transform != transform ||
        oldDelegate.mouseWorld != mouseWorld ||
        oldDelegate.unit != unit ||
        oldDelegate.pixelsPerMm != pixelsPerMm;
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
      ..color = color.withOpacity(0.10)
      ..strokeWidth = 4.5;

    final line = Paint()
      ..color = color.withOpacity(0.58)
      ..strokeWidth = 0.9;

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
