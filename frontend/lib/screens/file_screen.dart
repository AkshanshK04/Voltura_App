import 'package:flutter/material.dart';

import '../../app/app_router.dart';
import '../../theme/app_colors.dart';

class FileScreen extends StatefulWidget {
  const FileScreen({super.key});

  @override
  State<FileScreen> createState() => _FileScreenState();
}

class _FileScreenState extends State<FileScreen> {
  String? expandedSection;

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  void _toggleSection(String section) {
    setState(() {
      expandedSection =
          expandedSection == section ? null : section;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final Color background = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    final Color surface = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final Color text = isDark
        ? AppColors.darkText
        : AppColors.lightText;

    final Color subText = isDark
        ? AppColors.darkSubText
        : AppColors.lightSubText;

    final Color border = isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder;

    return Container(
      color: background,
      child: Row(
        children: [
          _buildSidebar(
            context,
            isDark,
            surface,
            text,
            subText,
            border,
          ),
          Expanded(
            child: _buildMainContent(
              context,
              isDark,
              surface,
              text,
              subText,
              border,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SIDEBAR
  // ============================================================

  Widget _buildSidebar(
    BuildContext context,
    bool isDark,
    Color surface,
    Color text,
    Color subText,
    Color border,
  ) {
    return Container(
      width: 245,
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          right: BorderSide(
            color: border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 22),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.85, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.signalOrange
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.folder_rounded,
                      color: AppColors.signalOrange,
                      size: 21,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'File',
                  style: TextStyle(
                    color: text,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Container(
            height: 1,
            color: border,
          ),

          const SizedBox(height: 12),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              children: [
                _sidebarItem(
                  icon: Icons.add_box_outlined,
                  title: 'New',
                  section: 'New',
                  isDark: isDark,
                  text: text,
                  subText: subText,
                ),
                _sidebarItem(
                  icon: Icons.swap_horiz_rounded,
                  title: 'Migrate Standard',
                  section: 'Migrate Standard',
                  isDark: isDark,
                  text: text,
                  subText: subText,
                ),
                _sidebarItem(
                  icon: Icons.folder_open_outlined,
                  title: 'Open Project',
                  section: 'Open Project',
                  isDark: isDark,
                  text: text,
                  subText: subText,
                ),
                _sidebarItem(
                  icon: Icons.save_outlined,
                  title: 'Save',
                  section: 'Save',
                  isDark: isDark,
                  text: text,
                  subText: subText,
                ),
                _sidebarItem(
                  icon: Icons.save_rounded,
                  title: 'Save All',
                  section: 'Save All',
                  isDark: isDark,
                  text: text,
                  subText: subText,
                ),
                _sidebarItem(
                  icon: Icons.save_as_outlined,
                  title: 'Save As',
                  section: 'Save As',
                  isDark: isDark,
                  text: text,
                  subText: subText,
                ),
                _sidebarItem(
                  icon: Icons.account_tree_outlined,
                  title: 'Version Control',
                  section: 'Version Control',
                  isDark: isDark,
                  text: text,
                  subText: subText,
                ),
                _sidebarItem(
                  icon: Icons.history_rounded,
                  title: 'Historical Records',
                  section: 'Historical Records',
                  isDark: isDark,
                  text: text,
                  subText: subText,
                ),
                _sidebarItem(
                  icon: Icons.backup_outlined,
                  title: 'Projects Backup',
                  section: 'Projects Backup',
                  isDark: isDark,
                  text: text,
                  subText: subText,
                ),
                _sidebarItem(
                  icon: Icons.delete_outline_rounded,
                  title: 'Recycle Bin',
                  section: 'Recycle Bin',
                  isDark: isDark,
                  text: text,
                  subText: subText,
                ),

                const SizedBox(height: 8),

                _sectionLabel('DATA', subText),

                _sidebarItem(
                  icon: Icons.file_upload_outlined,
                  title: 'Import',
                  section: 'Import',
                  isDark: isDark,
                  text: text,
                  subText: subText,
                ),
                _sidebarItem(
                  icon: Icons.file_download_outlined,
                  title: 'Export',
                  section: 'Export',
                  isDark: isDark,
                  text: text,
                  subText: subText,
                ),
                _sidebarItem(
                  icon: Icons.close_rounded,
                  title: 'Close All',
                  section: 'Close All',
                  isDark: isDark,
                  text: text,
                  subText: subText,
                ),

                const SizedBox(height: 8),

                _sectionLabel('PROJECT', subText),

                _sidebarItem(
                  icon: Icons.folder_copy_outlined,
                  title: 'Recent Projects',
                  section: 'Recent Projects',
                  isDark: isDark,
                  text: text,
                  subText: subText,
                ),
                _sidebarItem(
                  icon: Icons.source_outlined,
                  title: 'File Source',
                  section: 'File Source',
                  isDark: isDark,
                  text: text,
                  subText: subText,
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: border,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton.icon(
                onPressed: () {
                  AppRouter.instance.goToSchematic();
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  size: 18,
                ),
                label: const Text(
                  'Back to Schematic',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: text,
                  side: BorderSide(
                    color: border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SIDEBAR ITEM
  // ============================================================

  Widget _sidebarItem({
    required IconData icon,
    required String title,
    required String section,
    required bool isDark,
    required Color text,
    required Color subText,
  }) {
    final bool isSelected = expandedSection == section;
    final bool hasSubOptions = _hasSubOptions(section);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(9),
            onTap: () {
              _toggleSection(section);
            },
            hoverColor: AppColors.slateGray.withOpacity(
              isDark ? 0.12 : 0.08,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.signalOrange.withOpacity(
                        isDark ? 0.12 : 0.08,
                      )
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
                border: Border(
                  left: BorderSide(
                    color: isSelected
                        ? AppColors.signalOrange
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                children: [
                  AnimatedScale(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutBack,
                    scale: isSelected ? 1.08 : 1.0,
                    child: Icon(
                      icon,
                      size: 19,
                      color: isSelected
                          ? AppColors.signalOrange
                          : subText,
                    ),
                  ),

                  const SizedBox(width: 11),

                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      style: TextStyle(
                        color: isSelected
                            ? text
                            : text.withOpacity(0.88),
                        fontSize: 13.5,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      child: Text(title),
                    ),
                  ),

                  if (hasSubOptions)
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      turns: isSelected ? 0.25 : 0,
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: isSelected
                            ? AppColors.signalOrange
                            : subText,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(
    String label,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        13,
        8,
        13,
        6,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.withOpacity(0.65),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  bool _hasSubOptions(String section) {
    return section == 'New' ||
        section == 'Save As' ||
        section == 'Version Control' ||
        section == 'Projects Backup' ||
        section == 'Import' ||
        section == 'Export';
  }

  // ============================================================
  // MAIN CONTENT
  // ============================================================

  Widget _buildMainContent(
    BuildContext context,
    bool isDark,
    Color surface,
    Color text,
    Color subText,
    Color border,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            40,
            30,
            40,
            0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        color: text,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'What would you like to do?',
                      style: TextStyle(
                        color: subText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.12, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: expandedSection == null
                    ? const SizedBox.shrink(
                        key: ValueKey('empty-badge'),
                      )
                    : _currentSectionBadge(
                        expandedSection!,
                        isDark,
                      ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              40,
              0,
              40,
              30,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              reverseDuration:
                  const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final slideAnimation =
                    Tween<Offset>(
                  begin: const Offset(0.025, 0),
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
              child: _buildContentForSection(
                expandedSection,
                isDark,
                surface,
                text,
                subText,
                border,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CURRENT SECTION BADGE
  // ============================================================

  Widget _currentSectionBadge(
    String section,
    bool isDark,
  ) {
    return Container(
      key: ValueKey(section),
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.signalOrange.withOpacity(
          isDark ? 0.12 : 0.09,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.signalOrange.withOpacity(0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.folder_open_rounded,
            size: 15,
            color: AppColors.signalOrange,
          ),
          const SizedBox(width: 7),
          Text(
            section,
            style: const TextStyle(
              color: AppColors.signalOrange,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTENT SWITCH
  // ============================================================

  Widget _buildContentForSection(
    String? section,
    bool isDark,
    Color surface,
    Color text,
    Color subText,
    Color border,
  ) {
    switch (section) {
      case 'New':
        return _buildOptionGroup(
          key: const ValueKey('new-options'),
          title: 'Create New',
          subtitle:
              'Start a new Voltura design or project.',
          icon: Icons.add_box_outlined,
          options: [
            _Option(
              Icons.folder_special_outlined,
              'Project',
            ),
            _Option(
              Icons.developer_board_outlined,
              'Board',
            ),
            _Option(
              Icons.schema_outlined,
              'Schematic',
            ),
            _Option(
              Icons.description_outlined,
              'Page',
            ),
            _Option(
              Icons.developer_board,
              'PCB',
            ),
            _Option(
              Icons.dashboard_outlined,
              'Panel',
            ),
            _Option(
              Icons.memory_outlined,
              'Component',
            ),
            _Option(
              Icons.grid_view_rounded,
              'Footprint',
            ),
            _Option(
              Icons.view_in_ar_outlined,
              '3D Model',
            ),
            _Option(
              Icons.settings_input_component_outlined,
              'Sim Model',
            ),
            _Option(
              Icons.draw_outlined,
              'Drawing',
            ),
            _Option(
              Icons.flag_outlined,
              'Net Flag',
            ),
            _Option(
              Icons.account_tree_outlined,
              'Net Port',
            ),
            _Option(
              Icons.call_split_outlined,
              'Off Page Connector',
            ),
            _Option(
              Icons.block_outlined,
              'Non Electronic Flag',
            ),
            _Option(
              Icons.replay_outlined,
              'Reuse Block',
            ),
            _Option(
              Icons.dashboard_customize_outlined,
              'Panel Lib',
            ),
          ],
          isDark: isDark,
          surface: surface,
          text: text,
          subText: subText,
          border: border,
        );

      case 'Save As':
        return _buildOptionGroup(
          key: const ValueKey('save-as-options'),
          title: 'Save As',
          subtitle:
              'Save your project or document using another name or location.',
          icon: Icons.save_as_outlined,
          options: [
            _Option(
              Icons.folder_outlined,
              'Project Save As',
            ),
            _Option(
              Icons.folder_copy_outlined,
              'Project Save As (Local)',
            ),
            _Option(
              Icons.description_outlined,
              'Document Save As',
            ),
            _Option(
              Icons.description_rounded,
              'Document Save As (Local)',
            ),
            _Option(
              Icons.recycling_outlined,
              'Save As Reuse Block',
            ),
            _Option(
              Icons.archive_outlined,
              'Save As Reuse Block (Local)',
            ),
          ],
          isDark: isDark,
          surface: surface,
          text: text,
          subText: subText,
          border: border,
        );

      case 'Version Control':
        return _buildOptionGroup(
          key: const ValueKey('version-options'),
          title: 'Version Control',
          subtitle:
              'Manage branches, nodes and project versions.',
          icon: Icons.account_tree_outlined,
          options: [
            _Option(
              Icons.call_split_rounded,
              'New Branch',
            ),
            _Option(
              Icons.account_tree_outlined,
              'New Node',
            ),
            _Option(
              Icons.history_rounded,
              'Version Management',
            ),
            _Option(
              Icons.home_work_outlined,
              'Main',
            ),
          ],
          isDark: isDark,
          surface: surface,
          text: text,
          subText: subText,
          border: border,
        );

      case 'Projects Backup':
        return _buildOptionGroup(
          key: const ValueKey('backup-options'),
          title: 'Projects Backup',
          subtitle:
              'Create and manage backups of your projects.',
          icon: Icons.backup_outlined,
          options: [
            _Option(
              Icons.add_circle_outline,
              'New Backup',
            ),
            _Option(
              Icons.manage_history_outlined,
              'Backup Management',
            ),
          ],
          isDark: isDark,
          surface: surface,
          text: text,
          subText: subText,
          border: border,
        );

      case 'Import':
        return _buildOptionGroup(
          key: const ValueKey('import-options'),
          title: 'Import',
          subtitle:
              'Import designs and data from other tools and formats.',
          icon: Icons.file_upload_outlined,
          options: [
            _Option(
              Icons.straighten_outlined,
              'DXF',
            ),
            _Option(
              Icons.image_outlined,
              'Image',
            ),
            _Option(
              Icons.electrical_services_outlined,
              'Voltura',
            ),
            _Option(
              Icons.extension_outlined,
              'EasyEDA Standard',
            ),
            _Option(
              Icons.extension_rounded,
              'EasyEDA Professional',
            ),
            _Option(
              Icons.developer_board_outlined,
              'Allegro / OrCAD',
            ),
            _Option(
              Icons.memory_outlined,
              'Altium Designer',
            ),
            _Option(
              Icons.cable_outlined,
              'Eagle',
            ),
            _Option(
              Icons.developer_board,
              'KiCad',
            ),
            _Option(
              Icons.dashboard_customize_outlined,
              'PADS / PADS PRO',
            ),
            _Option(
              Icons.schema_outlined,
              'Protel',
            ),
            _Option(
              Icons.bolt_outlined,
              'LT Spice',
            ),
          ],
          isDark: isDark,
          surface: surface,
          text: text,
          subText: subText,
          border: border,
        );

      case 'Export':
        return _buildOptionGroup(
          key: const ValueKey('export-options'),
          title: 'Export',
          subtitle:
              'Export your design into common formats and production files.',
          icon: Icons.file_download_outlined,
          options: [
            _Option(
              Icons.receipt_long_outlined,
              'Bill of Materials (BOM)',
            ),
            _Option(
              Icons.straighten_outlined,
              'DXF',
            ),
            _Option(
              Icons.image_outlined,
              'PNG',
            ),
            _Option(
              Icons.picture_as_pdf_outlined,
              'PDF',
            ),
            _Option(
              Icons.image_search_outlined,
              'SVG',
            ),
            _Option(
              Icons.account_tree_outlined,
              'Netlist Files',
            ),
          ],
          isDark: isDark,
          surface: surface,
          text: text,
          subText: subText,
          border: border,
        );

      case 'Migrate Standard':
        return _buildSingleActionContent(
          key: const ValueKey('migrate'),
          Icons.swap_horiz_rounded,
          'Migrate Standard',
          'Migrate your project to the current Voltura standard.',
          isDark,
          surface,
          text,
          subText,
          border,
        );

      case 'Open Project':
        return _buildSingleActionContent(
          key: const ValueKey('open-project'),
          Icons.folder_open_outlined,
          'Open Project',
          'Open an existing Voltura project.',
          isDark,
          surface,
          text,
          subText,
          border,
        );

      case 'Save':
        return _buildSingleActionContent(
          key: const ValueKey('save'),
          Icons.save_outlined,
          'Save',
          'Save the current project.',
          isDark,
          surface,
          text,
          subText,
          border,
        );

      case 'Save All':
        return _buildSingleActionContent(
          key: const ValueKey('save-all'),
          Icons.save_rounded,
          'Save All',
          'Save all currently open documents and projects.',
          isDark,
          surface,
          text,
          subText,
          border,
        );

      case 'Historical Records':
        return _buildSingleActionContent(
          key: const ValueKey('history'),
          Icons.history_rounded,
          'Historical Records',
          'View previous project and document history.',
          isDark,
          surface,
          text,
          subText,
          border,
        );

      case 'Recycle Bin':
        return _buildSingleActionContent(
          key: const ValueKey('recycle'),
          Icons.delete_outline_rounded,
          'Recycle Bin',
          'View and restore deleted project items.',
          isDark,
          surface,
          text,
          subText,
          border,
        );

      case 'Close All':
        return _buildSingleActionContent(
          key: const ValueKey('close-all'),
          Icons.close_rounded,
          'Close All',
          'Close all currently open projects and documents.',
          isDark,
          surface,
          text,
          subText,
          border,
        );

      case 'Recent Projects':
        return _buildSingleActionContent(
          key: const ValueKey('recent-projects'),
          Icons.folder_copy_outlined,
          'Recent Projects',
          'Quickly access projects you recently opened.',
          isDark,
          surface,
          text,
          subText,
          border,
        );

      case 'File Source':
        return _buildSingleActionContent(
          key: const ValueKey('file-source'),
          Icons.source_outlined,
          'File Source',
          'Manage and inspect project file locations.',
          isDark,
          surface,
          text,
          subText,
          border,
        );

      default:
        return _buildWelcomeContent(
          isDark,
          surface,
          text,
          subText,
          border,
        );
    }
  }

  // ============================================================
  // WELCOME
  // ============================================================

  Widget _buildWelcomeContent(
    bool isDark,
    Color surface,
    Color text,
    Color subText,
    Color border,
  ) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 620,
        ),
        padding: const EdgeInsets.all(42),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                isDark ? 0.20 : 0.05,
              ),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.85, end: 1),
              duration: const Duration(milliseconds: 550),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.signalOrange
                      .withOpacity(0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.folder_open_rounded,
                  size: 36,
                  color: AppColors.signalOrange,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'File',
              style: TextStyle(
                color: text,
                fontSize: 25,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage projects, documents, imports, exports and more.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: subText,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 25),
            Text(
              'Select an option from the left panel to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: subText.withOpacity(0.75),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SINGLE ACTION
  // ============================================================

  Widget _buildSingleActionContent(
    IconData icon,
    String title,
    String description,
    bool isDark,
    Color surface,
    Color text,
    Color subText,
    Color border, {
    Key? key,
  }) {
    return Align(
      key: key,
      alignment: Alignment.topLeft,
      child: _actionCard(
        icon,
        title,
        description,
        isDark,
        surface,
        text,
        subText,
        border,
      ),
    );
  }

  // ============================================================
  // OPTION GROUP
  // ============================================================

  Widget _buildOptionGroup({
    Key? key,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<_Option> options,
    required bool isDark,
    required Color surface,
    required Color text,
    required Color subText,
    required Color border,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.88, end: 1),
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.signalOrange.withOpacity(
                    isDark ? 0.12 : 0.08,
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  color: AppColors.signalOrange,
                  size: 21,
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: text,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: subText,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              int columns = 3;

              if (constraints.maxWidth < 850) {
                columns = 2;
              }

              if (constraints.maxWidth < 570) {
                columns = 1;
              }

              return GridView.builder(
                padding: const EdgeInsets.only(
                  bottom: 10,
                ),
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 13,
                  mainAxisSpacing: 13,
                  childAspectRatio: 3.25,
                ),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];

                  return _AnimatedOptionCard(
                    key: ValueKey(option.title),
                    option: option,
                    index: index,
                    isDark: isDark,
                    surface: surface,
                    text: text,
                    subText: subText,
                    border: border,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ACTION CARD
  // ============================================================

  Widget _actionCard(
    IconData icon,
    String title,
    String description,
    bool isDark,
    Color surface,
    Color text,
    Color subText,
    Color border,
  ) {
    return _AnimatedActionCard(
      icon: icon,
      title: title,
      description: description,
      isDark: isDark,
      surface: surface,
      text: text,
      subText: subText,
      border: border,
    );
  }
}

// ================================================================
// ANIMATED OPTION CARD
// ================================================================

class _AnimatedOptionCard extends StatefulWidget {
  final _Option option;
  final int index;
  final bool isDark;
  final Color surface;
  final Color text;
  final Color subText;
  final Color border;

  const _AnimatedOptionCard({
    super.key,
    required this.option,
    required this.index,
    required this.isDark,
    required this.surface,
    required this.text,
    required this.subText,
    required this.border,
  });

  @override
  State<_AnimatedOptionCard> createState() =>
      _AnimatedOptionCardState();
}

class _AnimatedOptionCardState
    extends State<_AnimatedOptionCard> {
  bool hovered = false;
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(
        milliseconds: 260 + (widget.index * 25),
      ),
      curve: Curves.easeOutCubic,
      builder: (context, animation, child) {
        return Opacity(
          opacity: animation,
          child: Transform.translate(
            offset: Offset(
              0,
              8 * (1 - animation),
            ),
            child: child,
          ),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          setState(() {
            hovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            hovered = false;
            pressed = false;
          });
        },
        child: GestureDetector(
          onTapDown: (_) {
            setState(() {
              pressed = true;
            });
          },
          onTapUp: (_) {
            setState(() {
              pressed = false;
            });
          },
          onTapCancel: () {
            setState(() {
              pressed = false;
            });
          },
          child: AnimatedScale(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            scale: pressed
                ? 0.975
                : hovered
                    ? 1.015
                    : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 190),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: hovered
                    ? AppColors.signalOrange.withOpacity(
                        widget.isDark ? 0.055 : 0.025,
                      )
                    : widget.surface,
                borderRadius: BorderRadius.circular(
                  hovered ? 14 : 12,
                ),
                border: Border.all(
                  color: hovered
                      ? AppColors.signalOrange.withOpacity(
                          0.42,
                        )
                      : widget.border,
                  width: hovered ? 1.1 : 1,
                ),
                boxShadow: hovered
                    ? [
                        BoxShadow(
                          color: AppColors.signalOrange
                              .withOpacity(0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration:
                        const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    width: hovered ? 36 : 34,
                    height: hovered ? 36 : 34,
                    decoration: BoxDecoration(
                      color: AppColors.signalOrange
                          .withOpacity(
                        hovered
                            ? 0.14
                            : widget.isDark
                                ? 0.10
                                : 0.07,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AnimatedScale(
                      duration:
                          const Duration(milliseconds: 180),
                      curve: Curves.easeOutBack,
                      scale: hovered ? 1.08 : 1,
                      child: Icon(
                        widget.option.icon,
                        color: AppColors.signalOrange,
                        size: 18,
                      ),
                    ),
                  ),

                  const SizedBox(width: 11),

                  Expanded(
                    child: Text(
                      widget.option.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: widget.text,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  AnimatedSlide(
                    duration:
                        const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    offset: hovered
                        ? const Offset(0.12, 0)
                        : Offset.zero,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: hovered
                          ? AppColors.signalOrange
                          : widget.subText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// ANIMATED ACTION CARD
// ================================================================

class _AnimatedActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isDark;
  final Color surface;
  final Color text;
  final Color subText;
  final Color border;

  const _AnimatedActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isDark,
    required this.surface,
    required this.text,
    required this.subText,
    required this.border,
  });

  @override
  State<_AnimatedActionCard> createState() =>
      _AnimatedActionCardState();
}

class _AnimatedActionCardState
    extends State<_AnimatedActionCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: 390,
        padding: const EdgeInsets.all(22),
        transform: Matrix4.translationValues(
          0,
          hovered ? -3 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: widget.surface,
          borderRadius: BorderRadius.circular(
            hovered ? 17 : 15,
          ),
          border: Border.all(
            color: hovered
                ? AppColors.signalOrange.withOpacity(0.45)
                : widget.border,
          ),
          boxShadow: hovered
              ? [
                  BoxShadow(
                    color: AppColors.signalOrange
                        .withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: hovered ? 51 : 48,
              height: hovered ? 51 : 48,
              decoration: BoxDecoration(
                color: AppColors.signalOrange.withOpacity(
                  hovered ? 0.14 : 0.10,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.icon,
                color: AppColors.signalOrange,
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: widget.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.description,
                    style: TextStyle(
                      color: widget.subText,
                      fontSize: 12,
                      height: 1.4,
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

// ================================================================
// OPTION MODEL
// ================================================================

class _Option {
  final IconData icon;
  final String title;

  const _Option(
    this.icon,
    this.title,
  );
}
