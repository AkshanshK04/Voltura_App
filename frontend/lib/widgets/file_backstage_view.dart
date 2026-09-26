import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class FileBackstageView extends StatefulWidget {
  final VoidCallback onBack;

  const FileBackstageView({
    super.key,
    required this.onBack,
  });

  @override
  State<FileBackstageView> createState() => _FileBackstageViewState();
}

class _FileBackstageViewState extends State<FileBackstageView> {
  int selectedIndex = 0;

  final List<_FileMenuItem> items = const [
    _FileMenuItem(Icons.add_box_outlined, 'New'),
    _FileMenuItem(Icons.swap_horiz_outlined, 'Migrate Standard'),
    _FileMenuItem(Icons.folder_open_outlined, 'Open Project'),
    _FileMenuItem(Icons.save_outlined, 'Save'),
    _FileMenuItem(Icons.save_outlined, 'Save All'),
    _FileMenuItem(Icons.save_as_outlined, 'Save As'),
    _FileMenuItem(Icons.account_tree_outlined, 'Version Control'),
    _FileMenuItem(Icons.history, 'Historical Records'),
    _FileMenuItem(Icons.backup_outlined, 'Projects Backup'),
    _FileMenuItem(Icons.delete_outline, 'Recycle Bin'),
    _FileMenuItem(Icons.file_upload_outlined, 'Import'),
    _FileMenuItem(Icons.file_download_outlined, 'Export'),
    _FileMenuItem(Icons.close, 'Close All'),
    _FileMenuItem(Icons.folder_open_outlined, 'Recent Projects'),
    _FileMenuItem(Icons.source_outlined, 'File Source'),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Row(
        children: [
          // =========================================================
          // LEFT NAVIGATION
          // =========================================================

          SizedBox(
            width: 235,
            child: Container(
              color: const Color(0xFFF4F5F7),
              child: Column(
                children: [
                  _BackButton(
                    onTap: widget.onBack,
                  ),

                  const Divider(
                    height: 1,
                    color: Color(0xFFD9DCE1),
                  ),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      children: [
                        for (int index = 0; index < items.length; index++)
                          _BackstageNavItem(
                            icon: items[index].icon,
                            label: items[index].label,
                            selected: selectedIndex == index,
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                          ),
                      ],
                    ),
                  ),

                  const Divider(
                    height: 1,
                    color: Color(0xFFD9DCE1),
                  ),

                  _BackstageNavItem(
                    icon: Icons.settings_outlined,
                    label: 'Options',
                    selected: selectedIndex == items.length,
                    onTap: () {
                      setState(() {
                        selectedIndex = items.length;
                      });
                    },
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // =========================================================
          // RIGHT CONTENT / SUB-OPTIONS PANE
          // =========================================================

          Expanded(
            child: Container(
              color: Colors.white,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (
                  Widget child,
                  Animation<double> animation,
                ) {
                  final slideAnimation = Tween<Offset>(
                    begin: const Offset(0.018, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  );

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(selectedIndex),
                  child: _buildContent(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // CONTENT
  // ========================================================================

  Widget _buildContent() {
    final String selected = selectedIndex < items.length
        ? items[selectedIndex].label
        : 'Options';

    switch (selected) {
      case 'New':
        return _SubOptionsPane(
          title: 'New',
          subtitle: 'Create a new Voltura design.',
          icon: Icons.add_box_outlined,
          options: const [
            _SubOption(
              Icons.account_tree_outlined,
              'Project',
              'Create a new project',
            ),
            _SubOption(
              Icons.developer_board_outlined,
              'Board',
              'Create a new board',
            ),
            _SubOption(
              Icons.schema_outlined,
              'Schematic',
              'Create a schematic',
            ),
            _SubOption(
              Icons.insert_drive_file_outlined,
              'Page',
              'Create a new page',
            ),
            _SubOption(
              Icons.memory_outlined,
              'PCB',
              'Create a PCB design',
            ),
            _SubOption(
              Icons.dashboard_outlined,
              'Panel',
              'Create a panel',
            ),
            _SubOption(
              Icons.extension_outlined,
              'Component',
              'Create a component',
            ),
            _SubOption(
              Icons.grid_view_outlined,
              'Footprint',
              'Create a footprint',
            ),
            _SubOption(
              Icons.view_in_ar_outlined,
              '3D Model',
              'Create a 3D model',
            ),
            _SubOption(
              Icons.speed_outlined,
              'Sim Model',
              'Create a simulation model',
            ),
            _SubOption(
              Icons.draw_outlined,
              'Drawing',
              'Create a technical drawing',
            ),
            _SubOption(
              Icons.flag_outlined,
              'Net Flag',
              'Create a net flag',
            ),
            _SubOption(
              Icons.input_outlined,
              'Net Port',
              'Create a net port',
            ),
            _SubOption(
              Icons.link_outlined,
              'Off Page Connector',
              'Create an off-page connector',
            ),
            _SubOption(
              Icons.electrical_services_outlined,
              'Non Electronic Flag',
              'Create a non-electronic flag',
            ),
            _SubOption(
              Icons.view_module_outlined,
              'Reuse Block',
              'Create a reusable design block',
            ),
            _SubOption(
              Icons.library_books_outlined,
              'Panel Lib',
              'Create a panel library',
            ),
          ],
        );

      case 'Migrate Standard':
        return const _SimpleContent(
          title: 'Migrate Standard',
          subtitle: 'Migrate the project to another standard.',
          icon: Icons.swap_horiz_outlined,
        );

      case 'Open Project':
        return const _SimpleContent(
          title: 'Open Project',
          subtitle: 'Open an existing Voltura project.',
          icon: Icons.folder_open_outlined,
        );

      case 'Save':
        return const _SimpleContent(
          title: 'Save',
          subtitle: 'Save the current project.',
          icon: Icons.save_outlined,
        );

      case 'Save All':
        return const _SimpleContent(
          title: 'Save All',
          subtitle: 'Save all open documents.',
          icon: Icons.save_outlined,
        );

      case 'Save As':
        return _SubOptionsPane(
          title: 'Save As',
          subtitle: 'Save the project or document using another location or format.',
          icon: Icons.save_as_outlined,
          options: const [
            _SubOption(
              Icons.folder_copy_outlined,
              'Project Save As',
              'Save the project to another location',
            ),
            _SubOption(
              Icons.folder_outlined,
              'Project Save As (Local)',
              'Save a local copy of the project',
            ),
            _SubOption(
              Icons.description_outlined,
              'Document Save As',
              'Save the current document with another name',
            ),
            _SubOption(
              Icons.insert_drive_file_outlined,
              'Document Save As (Local)',
              'Save a local copy of the document',
            ),
            _SubOption(
              Icons.view_module_outlined,
              'Save As Reuse Block',
              'Save the current design as a reusable block',
            ),
            _SubOption(
              Icons.view_module_outlined,
              'Save As Reuse Block (Local)',
              'Save a local reusable block',
            ),
          ],
        );

      case 'Version Control':
        return _SubOptionsPane(
          title: 'Version Control',
          subtitle: 'Manage project versions and revisions.',
          icon: Icons.account_tree_outlined,
          options: const [
            _SubOption(
              Icons.call_split_outlined,
              'New Branch',
              'Create a new project branch',
            ),
            _SubOption(
              Icons.account_tree_outlined,
              'New Node',
              'Create a new version control node',
            ),
            _SubOption(
              Icons.manage_history_outlined,
              'Version Management',
              'Manage project versions and revisions',
            ),
            _SubOption(
              Icons.home_outlined,
              'Main',
              'Open the main project version',
            ),
          ],
        );

      case 'Historical Records':
        return const _SimpleContent(
          title: 'Historical Records',
          subtitle: 'Browse previous project states.',
          icon: Icons.history,
        );

      case 'Projects Backup':
        return _SubOptionsPane(
          title: 'Projects Backup',
          subtitle: 'Create or manage project backups.',
          icon: Icons.backup_outlined,
          options: const [
            _SubOption(
              Icons.add_to_drive_outlined,
              'New Backup',
              'Create a new project backup',
            ),
            _SubOption(
              Icons.settings_backup_restore_outlined,
              'Backup Management',
              'Manage and restore project backups',
            ),
          ],
        );

      case 'Recycle Bin':
        return const _SimpleContent(
          title: 'Recycle Bin',
          subtitle: 'Manage deleted project items.',
          icon: Icons.delete_outline,
        );

      case 'Import':
        return _SubOptionsPane(
          title: 'Import',
          subtitle: 'Import external design files.',
          icon: Icons.file_upload_outlined,
          options: const [
            _SubOption(
              Icons.polyline_outlined,
              'DXF',
              'Import a DXF design file',
            ),
            _SubOption(
              Icons.image_outlined,
              'Image',
              'Import an image into the project',
            ),
            _SubOption(
              Icons.electric_bolt_outlined,
              'Voltura',
              'Import a Voltura project or design',
            ),
            _SubOption(
              Icons.import_contacts_outlined,
              'EasyEDA (Standard)',
              'Import an EasyEDA Standard project',
            ),
            _SubOption(
              Icons.import_contacts_outlined,
              'EasyEDA (Professional)',
              'Import an EasyEDA Professional project',
            ),
            _SubOption(
              Icons.developer_board_outlined,
              'Allegro / OrCAD',
              'Import an Allegro or OrCAD design',
            ),
            _SubOption(
              Icons.developer_board_outlined,
              'Altium Designer',
              'Import an Altium Designer project',
            ),
            _SubOption(
              Icons.memory_outlined,
              'Eagle',
              'Import an Eagle design',
            ),
            _SubOption(
              Icons.memory_outlined,
              'KiCad',
              'Import a KiCad design',
            ),
            _SubOption(
              Icons.developer_board_outlined,
              'PADS / PADS PRO',
              'Import a PADS or PADS PRO design',
            ),
            _SubOption(
              Icons.memory_outlined,
              'Protel',
              'Import a Protel design',
            ),
            _SubOption(
              Icons.bolt_outlined,
              'LT Spice',
              'Import an LTspice simulation design',
            ),
          ],
        );

      case 'Export':
        return _SubOptionsPane(
          title: 'Export',
          subtitle: 'Export your design into another format.',
          icon: Icons.file_download_outlined,
          options: const [
            _SubOption(
              Icons.table_chart_outlined,
              'Bill of Materials (BOM)',
              'Export the project bill of materials',
            ),
            _SubOption(
              Icons.polyline_outlined,
              'DXF',
              'Export the design as DXF',
            ),
            _SubOption(
              Icons.image_outlined,
              'PNG',
              'Export the design as PNG',
            ),
            _SubOption(
              Icons.picture_as_pdf_outlined,
              'PDF',
              'Export the design as PDF',
            ),
            _SubOption(
              Icons.code_outlined,
              'SVG',
              'Export the design as SVG',
            ),
            _SubOption(
              Icons.account_tree_outlined,
              'Netlist Files',
              'Export project netlist files',
            ),
          ],
        );

      case 'Close All':
        return const _SimpleContent(
          title: 'Close All',
          subtitle: 'Close all currently open documents.',
          icon: Icons.close,
        );

      case 'Recent Projects':
        return const _SimpleContent(
          title: 'Recent Projects',
          subtitle: 'Open one of your recently used projects.',
          icon: Icons.folder_open_outlined,
        );

      case 'File Source':
        return const _SimpleContent(
          title: 'File Source',
          subtitle: 'View the source location of the current project.',
          icon: Icons.source_outlined,
        );

      case 'Options':
        return const _SimpleContent(
          title: 'Options',
          subtitle: 'Configure Voltura application settings.',
          icon: Icons.settings_outlined,
        );

      default:
        return const _WelcomeContent();
    }
  }
}

// ============================================================================
// BACK BUTTON
// ============================================================================

class _BackButton extends StatefulWidget {
  final VoidCallback onTap;

  const _BackButton({
    required this.onTap,
  });

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: hovered
                ? AppColors.slateGray.withOpacity(0.10)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              AnimatedSlide(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                offset: hovered
                    ? const Offset(-0.08, 0)
                    : Offset.zero,
                child: Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: hovered
                      ? AppColors.signalOrange
                      : const Color(0xFF444444),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Back',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: hovered
                      ? AppColors.signalOrange
                      : Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// BACKSTAGE NAV ITEM
// ============================================================================

class _BackstageNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BackstageNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_BackstageNavItem> createState() =>
      _BackstageNavItemState();
}

class _BackstageNavItemState extends State<_BackstageNavItem> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool active = hovered || widget.selected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 190),
          curve: Curves.easeOutCubic,
          height: 45,
          margin: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          transform: Matrix4.translationValues(
            hovered ? 2.0 : 0,
            0,
            0,
          ),
          decoration: BoxDecoration(
            color: active
                ? AppColors.slateGray.withOpacity(
                    widget.selected ? 0.15 : 0.075,
                  )
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: hovered
                  ? AppColors.slateGray.withOpacity(0.16)
                  : Colors.transparent,
              width: 0.8,
            ),
            boxShadow: hovered
                ? [
                    BoxShadow(
                      color: AppColors.slateGray.withOpacity(0.07),
                      blurRadius: 7,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Stack(
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 190),
                    curve: Curves.easeOutCubic,
                    width: widget.selected ? 3 : 2,
                    height: widget.selected
                        ? 27
                        : hovered
                            ? 20
                            : 0,
                    decoration: BoxDecoration(
                      color: AppColors.signalOrange,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 190),
                    curve: Curves.easeOutCubic,
                    width: active ? 10 : 0,
                  ),

                  AnimatedScale(
                    duration: const Duration(milliseconds: 190),
                    curve: Curves.easeOutCubic,
                    scale: hovered ? 1.06 : 1.0,
                    child: Icon(
                      widget.icon,
                      size: 19,
                      color: widget.selected
                          ? AppColors.signalOrange
                          : hovered
                              ? const Color(0xFF444444)
                              : const Color(0xFF555A60),
                    ),
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 170),
                      curve: Curves.easeOutCubic,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: widget.selected || hovered
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: widget.selected
                            ? AppColors.signalOrange
                            : const Color(0xFF34383D),
                      ),
                      child: Text(
                        widget.label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),

              Positioned(
                left: 0,
                bottom: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  height: 2,
                  width: hovered || widget.selected ? 100 : 0,
                  decoration: BoxDecoration(
                    color: AppColors.signalOrange,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: hovered
                        ? [
                            BoxShadow(
                              color: AppColors.signalOrange
                                  .withOpacity(0.30),
                              blurRadius: 5,
                            ),
                          ]
                        : [],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SUB OPTIONS PANE
// ============================================================================

class _SubOptionsPane extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<_SubOption> options;

  const _SubOptionsPane({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(46, 36, 46, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.signalOrange.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: AppColors.signalOrange,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF202124),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(
                bottom: 10,
              ),
              itemCount: options.length,
              gridDelegate:
                  const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 280,
                mainAxisExtent: 118,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final option = options[index];

                return _SubOptionCard(
                  option: option,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SUB OPTION DATA
// ============================================================================

class _SubOption {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SubOption(
    this.icon,
    this.title,
    this.subtitle,
  );
}

// ============================================================================
// SUB OPTION CARD
// ============================================================================

class _SubOptionCard extends StatefulWidget {
  final _SubOption option;

  const _SubOptionCard({
    required this.option,
  });

  @override
  State<_SubOptionCard> createState() => _SubOptionCardState();
}

class _SubOptionCardState extends State<_SubOptionCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(
          0,
          hovered ? -3 : 0,
          0,
        ),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: hovered
              ? const Color(0xFFFFF8F2)
              : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hovered
                ? AppColors.signalOrange.withOpacity(0.55)
                : const Color(0xFFE1E4E8),
          ),
          boxShadow: hovered
              ? [
                  BoxShadow(
                    color: AppColors.signalOrange.withOpacity(0.10),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: hovered
                    ? AppColors.signalOrange
                    : const Color(0xFFE9ECEF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.option.icon,
                color: hovered
                    ? Colors.white
                    : AppColors.signalOrange,
                size: 22,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.option.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF202124),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.option.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SIMPLE CONTENT
// ============================================================================

class _SimpleContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SimpleContent({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.signalOrange.withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 38,
                color: AppColors.signalOrange,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w600,
                color: Color(0xFF202124),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// WELCOME CONTENT
// ============================================================================

class _WelcomeContent extends StatelessWidget {
  const _WelcomeContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Select an option from the File menu.',
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF777C82),
        ),
      ),
    );
  }
}

// ============================================================================
// DATA
// ============================================================================

class _FileMenuItem {
  final IconData icon;
  final String label;

  const _FileMenuItem(
    this.icon,
    this.label,
  );
}
