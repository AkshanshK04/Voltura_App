import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SchematicSheet extends StatefulWidget {
  const SchematicSheet({super.key});

  @override
  State<SchematicSheet> createState() => _SchematicSheetState();
}

class _SchematicSheetState extends State<SchematicSheet> {
  final TransformationController _transformationController =
      TransformationController();

  static const double pixelsPerMm = 5.0;
  static const double gridStepMm = 1.0;
  static const double majorGridStepMm = 10.0;

  static const double rulerHeight = 24.0;

  double _zoom = 1.0;
  double? _mouseX;

  @override
  void initState() {
    super.initState();

    _transformationController.addListener(_onTransformChanged);
  }

  void _onTransformChanged() {
    final scale =
        _transformationController.value.getMaxScaleOnAxis();

    if ((scale - _zoom).abs() > 0.005) {
      setState(() {
        _zoom = scale;
      });
    }
  }

  void _updateMousePosition(PointerHoverEvent event) {
    setState(() {
      _mouseX = event.localPosition.dx;
    });
  }

  void _clearMousePosition(PointerExitEvent event) {
    setState(() {
      _mouseX = null;
    });
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformChanged);
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.pcbBackground,
      child: Stack(
        children: [
          // ========================================================
          // SCHEMATIC GRID
          // ========================================================

          Positioned(
            left: 0,
            top: rulerHeight,
            right: 0,
            bottom: 0,
            child: MouseRegion(
              onHover: _updateMousePosition,
              onExit: _clearMousePosition,
              child: ClipRect(
                child: InteractiveViewer(
                  transformationController:
                      _transformationController,

                  panEnabled: false,
                  scaleEnabled: true,

                  minScale: 0.25,
                  maxScale: 5.0,

                  clipBehavior: Clip.none,

                  child: SizedBox(
                    width: 5000,
                    height: 5000,
                    child: CustomPaint(
                      painter: SchematicGridPainter(
                        pixelsPerMm: pixelsPerMm,
                        gridStepMm: gridStepMm,
                        majorGridStepMm: majorGridStepMm,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ========================================================
          // FITTED ENGINEERING SHEET
          // ========================================================

          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: SchematicFramePainter(),
              ),
            ),
          ),

          // ========================================================
          // HORIZONTAL RULER
          // ========================================================

          Positioned(
            left: 0,
            top: 0,
            right: 0,
            height: rulerHeight,
            child: IgnorePointer(
              child: CustomPaint(
                painter: HorizontalRulerPainter(
                  pixelsPerMm: pixelsPerMm,
                  mouseX: _mouseX,
                ),
                size: Size.infinite,
              ),
            ),
          ),

          // ========================================================
          // ZOOM
          // ========================================================

          Positioned(
            right: 18,
            bottom: 18,
            child: _ZoomIndicator(
              zoom: _zoom,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// GRID
// ============================================================================

class SchematicGridPainter extends CustomPainter {
  final double pixelsPerMm;
  final double gridStepMm;
  final double majorGridStepMm;

  SchematicGridPainter({
    required this.pixelsPerMm,
    required this.gridStepMm,
    required this.majorGridStepMm,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.white;

    canvas.drawRect(
      Offset.zero & size,
      backgroundPaint,
    );

    final minorPaint = Paint()
      ..color = const Color(0xFFE8E8E8)
      ..strokeWidth = 0.7;

    final majorPaint = Paint()
      ..color = const Color(0xFFD0D0D0)
      ..strokeWidth = 1.0;

    final minorSpacing =
        pixelsPerMm * gridStepMm;

    final majorSpacing =
        pixelsPerMm * majorGridStepMm;

    for (
      double x = 0;
      x <= size.width;
      x += minorSpacing
    ) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        minorPaint,
      );
    }

    for (
      double y = 0;
      y <= size.height;
      y += minorSpacing
    ) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        minorPaint,
      );
    }

    for (
      double x = 0;
      x <= size.width;
      x += majorSpacing
    ) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        majorPaint,
      );
    }

    for (
      double y = 0;
      y <= size.height;
      y += majorSpacing
    ) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        majorPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant SchematicGridPainter oldDelegate,
  ) {
    return oldDelegate.pixelsPerMm != pixelsPerMm ||
        oldDelegate.gridStepMm != gridStepMm ||
        oldDelegate.majorGridStepMm != majorGridStepMm;
  }
}

// ============================================================================
// WIDE ENGINEERING SHEET FRAME
// ============================================================================

class SchematicFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // ------------------------------------------------------------
    // AVAILABLE AREA
    // ------------------------------------------------------------

    const double horizontalMargin = 28.0;
    const double verticalMargin = 16.0;

    final availableWidth =
        size.width - horizontalMargin * 2;

    final availableHeight =
        size.height -
        verticalMargin * 2;

    // ------------------------------------------------------------
    // A3 LANDSCAPE STYLE RATIO
    //
    // 420 : 297
    // ------------------------------------------------------------

    const double sheetRatio = 420 / 297;

    double sheetWidth = availableWidth;
    double sheetHeight = sheetWidth / sheetRatio;

    // If height doesn't fit, calculate from height.
    if (sheetHeight > availableHeight) {
      sheetHeight = availableHeight;
      sheetWidth = sheetHeight * sheetRatio;
    }

    // Center sheet in available viewport.
    final sheetLeft =
        (size.width - sheetWidth) / 2;

    final sheetTop =
        verticalMargin +
        (availableHeight - sheetHeight) / 2;

    final Rect sheet = Rect.fromLTWH(
      sheetLeft,
      sheetTop,
      sheetWidth,
      sheetHeight,
    );

    // ------------------------------------------------------------
    // OUTER FRAME
    // ------------------------------------------------------------

    final outerPaint = Paint()
      ..color = const Color(0xFF30363B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(sheet, outerPaint);

    // ------------------------------------------------------------
    // INNER FRAME
    // ------------------------------------------------------------

    final inner = sheet.deflate(6);

    final innerPaint = Paint()
      ..color = const Color(0xFF666666)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawRect(inner, innerPaint);

    // ------------------------------------------------------------
    // ZONES
    // ------------------------------------------------------------

    _drawTopZones(canvas, inner);
    _drawBottomZones(canvas, inner);
    _drawSideZones(canvas, inner);

    // ------------------------------------------------------------
    // TITLE BLOCK
    // ------------------------------------------------------------

    _drawTitleBlock(canvas, inner);
  }

  // ============================================================
  // TOP ZONES
  // ============================================================

  void _drawTopZones(
    Canvas canvas,
    Rect frame,
  ) {
    final paint = Paint()
      ..color = const Color(0xFF707070)
      ..strokeWidth = 0.7;

    const double zoneWidth = 65;

    double x = frame.left + zoneWidth;
    int number = 1;

    while (x < frame.right - zoneWidth) {
      canvas.drawLine(
        Offset(x, frame.top),
        Offset(x, frame.top + 9),
        paint,
      );

      _drawSmallText(
        canvas,
        '$number',
        Offset(
          x - zoneWidth / 2 - 3,
          frame.top + 1,
        ),
      );

      x += zoneWidth;
      number++;
    }
  }

  // ============================================================
  // BOTTOM ZONES
  // ============================================================

  void _drawBottomZones(
    Canvas canvas,
    Rect frame,
  ) {
    final paint = Paint()
      ..color = const Color(0xFF707070)
      ..strokeWidth = 0.7;

    const double zoneWidth = 65;

    double x = frame.left + zoneWidth;
    int number = 1;

    while (x < frame.right - zoneWidth) {
      canvas.drawLine(
        Offset(x, frame.bottom - 9),
        Offset(x, frame.bottom),
        paint,
      );

      _drawSmallText(
        canvas,
        '$number',
        Offset(
          x - zoneWidth / 2 - 3,
          frame.bottom - 8,
        ),
      );

      x += zoneWidth;
      number++;
    }
  }

  // ============================================================
  // LEFT + RIGHT ZONES
  // ============================================================

  void _drawSideZones(
    Canvas canvas,
    Rect frame,
  ) {
    final paint = Paint()
      ..color = const Color(0xFF707070)
      ..strokeWidth = 0.7;

    const double zoneHeight = 55;

    double y = frame.top + zoneHeight;
    int number = 1;

    while (y < frame.bottom - zoneHeight) {
      // LEFT
      canvas.drawLine(
        Offset(frame.left, y),
        Offset(frame.left + 9, y),
        paint,
      );

      _drawSmallText(
        canvas,
        '$number',
        Offset(
          frame.left + 2,
          y - zoneHeight / 2,
        ),
      );

      // RIGHT
      canvas.drawLine(
        Offset(frame.right - 9, y),
        Offset(frame.right, y),
        paint,
      );

      y += zoneHeight;
      number++;
    }
  }

  // ============================================================
  // TITLE BLOCK
  // ============================================================

  void _drawTitleBlock(
    Canvas canvas,
    Rect frame,
  ) {
    // IMPORTANT:
    // Keep this completely INSIDE the sheet.
    final double blockWidth =
        frame.width * 0.30;

    final double blockHeight =
        frame.height * 0.19;

    final Rect block = Rect.fromLTWH(
      frame.right - blockWidth,
      frame.bottom - blockHeight,
      blockWidth,
      blockHeight,
    );

    final borderPaint = Paint()
      ..color = const Color(0xFF404040)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final linePaint = Paint()
      ..color = const Color(0xFF777777)
      ..strokeWidth = 0.7;

    // Main rectangle.
    canvas.drawRect(
      block,
      borderPaint,
    );

    // ----------------------------------------------------------
    // ROWS
    // ----------------------------------------------------------

    final row1 =
        block.top + block.height * 0.28;

    final row2 =
        block.top + block.height * 0.56;

    final row3 =
        block.top + block.height * 0.78;

    canvas.drawLine(
      Offset(block.left, row1),
      Offset(block.right, row1),
      linePaint,
    );

    canvas.drawLine(
      Offset(block.left, row2),
      Offset(block.right, row2),
      linePaint,
    );

    canvas.drawLine(
      Offset(block.left, row3),
      Offset(block.right, row3),
      linePaint,
    );

    // ----------------------------------------------------------
    // COLUMNS
    // ----------------------------------------------------------

    final col1 =
        block.left + block.width * 0.52;

    final col2 =
        block.left + block.width * 0.76;

    canvas.drawLine(
      Offset(col1, row2),
      Offset(col1, block.bottom),
      linePaint,
    );

    canvas.drawLine(
      Offset(col2, row2),
      Offset(col2, block.bottom),
      linePaint,
    );

    // ----------------------------------------------------------
    // TITLE
    // ----------------------------------------------------------

    _drawBlockText(
      canvas,
      'VOLTURA',
      Offset(
        block.left + 9,
        block.top + 7,
      ),
      fontSize: 13,
      bold: true,
    );

    _drawBlockText(
      canvas,
      'SCHEMATIC',
      Offset(
        block.left + 9,
        block.top + 23,
      ),
      fontSize: 8,
      bold: true,
    );

    // ----------------------------------------------------------
    // ROW 2
    // ----------------------------------------------------------

    _drawBlockText(
      canvas,
      'PROJECT',
      Offset(
        block.left + 8,
        row1 + 6,
      ),
    );

    _drawBlockText(
      canvas,
      'MAIN SCHEMATIC',
      Offset(
        block.left + 8,
        row1 + 17,
      ),
      bold: true,
    );

    // ----------------------------------------------------------
    // ROW 3
    // ----------------------------------------------------------

    _drawBlockText(
      canvas,
      'SHEET',
      Offset(
        block.left + 8,
        row2 + 7,
      ),
    );

    _drawBlockText(
      canvas,
      'A3',
      Offset(
        col1 + 7,
        row2 + 7,
      ),
      bold: true,
    );

    _drawBlockText(
      canvas,
      'REV',
      Offset(
        col2 + 7,
        row2 + 7,
      ),
    );

    // ----------------------------------------------------------
    // BOTTOM ROW
    // ----------------------------------------------------------

    _drawBlockText(
      canvas,
      'DRAWN',
      Offset(
        block.left + 8,
        row3 + 6,
      ),
    );

    _drawBlockText(
      canvas,
      '01',
      Offset(
        col1 + 7,
        row3 + 6,
      ),
      bold: true,
    );

    _drawBlockText(
      canvas,
      '1.0',
      Offset(
        col2 + 7,
        row3 + 6,
      ),
      bold: true,
    );
  }

  // ============================================================
  // SMALL TEXT
  // ============================================================

  void _drawSmallText(
    Canvas canvas,
    String text,
    Offset position,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF666666),
          fontSize: 7,
          fontWeight: FontWeight.w500,
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

  // ============================================================
  // TITLE BLOCK TEXT
  // ============================================================

  void _drawBlockText(
    Canvas canvas,
    String text,
    Offset position, {
    double fontSize = 7,
    bool bold = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: const Color(0xFF444444),
          fontSize: fontSize,
          fontWeight:
              bold ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: 0.3,
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
    covariant SchematicFramePainter oldDelegate,
  ) {
    return false;
  }
}

// ============================================================================
// HORIZONTAL RULER
// ============================================================================

class HorizontalRulerPainter extends CustomPainter {
  final double pixelsPerMm;
  final double? mouseX;

  HorizontalRulerPainter({
    required this.pixelsPerMm,
    required this.mouseX,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final backgroundPaint = Paint()
      ..color = Colors.white;

    canvas.drawRect(
      Offset.zero & size,
      backgroundPaint,
    );

    final borderPaint = Paint()
      ..color = const Color(0xFFD0D0D0)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(0, size.height - 0.5),
      Offset(size.width, size.height - 0.5),
      borderPaint,
    );

    final minorTickPaint = Paint()
      ..color = const Color(0xFFAAAAAA)
      ..strokeWidth = 1;

    final majorTickPaint = Paint()
      ..color = const Color(0xFF666666)
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final minorSpacing = pixelsPerMm;
    final majorSpacing = pixelsPerMm * 10;

    for (
      double x = 0;
      x <= size.width;
      x += minorSpacing
    ) {
      final isMajor =
          (x % majorSpacing).abs() < 0.001;

      if (!isMajor) {
        canvas.drawLine(
          Offset(x, size.height - 4),
          Offset(x, size.height),
          minorTickPaint,
        );
      }
    }

    for (
      double x = 0;
      x <= size.width;
      x += majorSpacing
    ) {
      canvas.drawLine(
        Offset(x, size.height - 9),
        Offset(x, size.height),
        majorTickPaint,
      );

      final value =
          (x / pixelsPerMm).round();

      textPainter.text = TextSpan(
        text: '$value',
        style: const TextStyle(
          color: Color(0xFF666666),
          fontSize: 8,
          fontWeight: FontWeight.w500,
        ),
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(x + 3, 2),
      );
    }

    // ==========================================================
    // ORANGE CURSOR POINTER
    // ==========================================================

    if (mouseX != null &&
        mouseX! >= 0 &&
        mouseX! <= size.width) {
      final pointerX = mouseX!;

      final pointerPaint = Paint()
        ..color = AppColors.signalOrange
        ..strokeWidth = 1.5;

      canvas.drawLine(
        Offset(pointerX, 0),
        Offset(pointerX, size.height),
        pointerPaint,
      );

      final trianglePath = Path();

      trianglePath.moveTo(
        pointerX - 4,
        0,
      );

      trianglePath.lineTo(
        pointerX + 4,
        0,
      );

      trianglePath.lineTo(
        pointerX,
        6,
      );

      trianglePath.close();

      canvas.drawPath(
        trianglePath,
        Paint()..color = AppColors.signalOrange,
      );

      final mm =
          pointerX / pixelsPerMm;

      final coordinatePainter = TextPainter(
        text: TextSpan(
          text: '${mm.toStringAsFixed(1)} mm',
          style: TextStyle(
            color: AppColors.signalOrange,
            fontSize: 8,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      coordinatePainter.layout();

      double labelX =
          pointerX -
          coordinatePainter.width / 2;

      labelX = labelX.clamp(
        2.0,
        size.width -
            coordinatePainter.width -
            2.0,
      );

      coordinatePainter.paint(
        canvas,
        Offset(labelX, 1),
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant HorizontalRulerPainter oldDelegate,
  ) {
    return oldDelegate.mouseX != mouseX ||
        oldDelegate.pixelsPerMm != pixelsPerMm;
  }
}

// ============================================================================
// ZOOM INDICATOR
// ============================================================================

class _ZoomIndicator extends StatelessWidget {
  final double zoom;

  const _ZoomIndicator({
    required this.zoom,
  });

  @override
  Widget build(BuildContext context) {
    final percentage =
        (zoom * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFD0D0D0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        '$percentage%',
        style: const TextStyle(
          color: Color(0xFF555555),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
