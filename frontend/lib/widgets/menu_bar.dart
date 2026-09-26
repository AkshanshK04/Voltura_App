import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'custom_window_bar.dart';

class MenuBarWidget extends StatefulWidget {
  final ValueChanged<String> onMenuChanged;
  final VoidCallback onFullscreenPressed;

  const MenuBarWidget({
    super.key,
    required this.onMenuChanged,
    required this.onFullscreenPressed,
  });

  @override
  State<MenuBarWidget> createState() => _MenuBarWidgetState();
}

class _MenuBarWidgetState extends State<MenuBarWidget> {
  String? hoveredMenu;
  bool arrowHovered = false;

  final List<String> menus = const [
    'File',
    'Edit',
    'View',
    'Place',
    'Tools',
    'Help',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: const BoxDecoration(
        color: Color(0xFF0E4635),
        border: Border(
          top: BorderSide(
            color: Color(0xFF174F40),
            width: 1,
          ),
          bottom: BorderSide(
            color: Color(0xFF708090),
            width: 1,
          ),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ======================================================
          // MENU LINE
          // ======================================================

          Positioned.fill(
            child: Row(
              children: [
                const SizedBox(
                  width: CustomWindowBar.leftAlignment,
                ),

                ...menus.map(
                  (menu) {
                    final bool hovered =
                        hoveredMenu == menu;

                    return MouseRegion(
                      cursor:
                          SystemMouseCursors.click,

                      onEnter: (_) {
                        setState(() {
                          hoveredMenu = menu;
                        });
                      },

                      onExit: (_) {
                        setState(() {
                          hoveredMenu = null;
                        });
                      },

                      child: GestureDetector(
                        onTap: () {
                          widget.onMenuChanged(menu);
                        },

                        child: AnimatedContainer(
                          duration:
                              const Duration(
                            milliseconds: 150,
                          ),
                          curve: Curves.easeOutCubic,

                          height: 28,

                          margin:
                              const EdgeInsets.only(
                            right: 3,
                          ),

                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 13,
                          ),

                          decoration:
                              BoxDecoration(
                            color: hovered
                                ? AppColors.slateGray
                                    .withOpacity(0.32)
                                : Colors.transparent,

                            borderRadius:
                                BorderRadius.circular(3),
                          ),

                          child: Stack(
                            alignment:
                                Alignment.center,

                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(
                                  bottom: 2,
                                ),
                                child: Text(
                                  menu,
                                  style:
                                      const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.5,
                                    fontWeight:
                                        FontWeight.w500,
                                  ),
                                ),
                              ),

                              // --------------------------------
                              // ORANGE HOVER LINE
                              // --------------------------------

                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: TweenAnimationBuilder<
                                    double>(
                                  tween: Tween<double>(
                                    begin: 0,
                                    end: hovered ? 1 : 0,
                                  ),
                                  duration:
                                      const Duration(
                                    milliseconds: 230,
                                  ),
                                  curve:
                                      Curves.easeOutCubic,
                                  builder:
                                      (
                                    context,
                                    value,
                                    child,
                                  ) {
                                    return Align(
                                      alignment:
                                          Alignment.center,
                                      child:
                                          Container(
                                        width:
                                            36 * value,
                                        height: 2,
                                        decoration:
                                            BoxDecoration(
                                          color: AppColors
                                              .signalOrange,
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // ======================================================
          // CENTER FULLSCREEN ARROW
          // ======================================================

          Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,

              onEnter: (_) {
                setState(() {
                  arrowHovered = true;
                });
              },

              onExit: (_) {
                setState(() {
                  arrowHovered = false;
                });
              },

              child: GestureDetector(
                onTap: widget.onFullscreenPressed,

                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: arrowHovered ? 1 : 0,
                  ),
                  duration:
                      const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,

                  builder:
                      (context, value, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        -2 * value,
                      ),
                      child: AnimatedContainer(
                        duration:
                            const Duration(
                          milliseconds: 180,
                        ),
                        width: 38,
                        height: 27,

                        decoration:
                            BoxDecoration(
                          color: Color.lerp(
                            Colors.transparent,
                            AppColors.slateGray
                                .withOpacity(0.80),
                            value,
                          ),

                          borderRadius:
                              BorderRadius.circular(6),

                          border: Border.all(
                            color: Color.lerp(
                              Colors.transparent,
                              AppColors.signalOrange,
                              value,
                            )!,
                            width: 1,
                          ),

                          boxShadow: value > 0
                              ? [
                                  BoxShadow(
                                    color: AppColors
                                        .signalOrange
                                        .withOpacity(
                                      0.16 * value,
                                    ),
                                    blurRadius: 9,
                                    offset:
                                        const Offset(
                                      0,
                                      2,
                                    ),
                                  ),
                                ]
                              : [],
                        ),

                        child: Icon(
                          Icons
                              .keyboard_arrow_up_rounded,
                          size: 23,
                          color: Color.lerp(
                            Colors.white
                                .withOpacity(0.72),
                            Colors.white,
                            value,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
