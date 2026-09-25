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
    _FileMenuItem(Icons.drive_file_move_outline, 'Open Project'),
    _FileMenuItem(Icons.save_outlined, 'Save'),
    _FileMenuItem(Icons.save_as_outlined, 'Save All'),
    _FileMenuItem(Icons.edit_document, 'Save As'),
    _FileMenuItem(Icons.account_tree_outlined, 'Version Control'),
    _FileMenuItem(Icons.history, 'Historical Records'),
    _FileMenuItem(Icons.backup_outlined, 'Projects Backup'),
    _FileMenuItem(Icons.delete_outline, 'Recycle Bin'),
    _FileMenuItem(Icons.file_upload_outlined, 'Import'),
    _FileMenuItem(Icons.file_download_outlined, 'Export'),
    _FileMenuItem(Icons.print_outlined, 'Print'),
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
          // =====================================================
          // LEFT NAVIGATION
          // =====================================================
          Container(
            width: 235,
            color: const Color(0xFFF4F5F7),
            child: Column(
              children: [
                // Back button
                InkWell(
                  onTap: widget.onBack,
                  hoverColor: const Color(0xFFE4E7EB),
                  child: Container(
                    height: 58,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.arrow_back,
                          size: 20,
                          color: Color(0xFF444444),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Divider(
                  height: 1,
                  color: Color(0xFFD9DCE1),
                ),

                // Scrollable navigation
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];

                        return _BackstageNavItem(
                          icon: item.icon,
                          label: item.label,
                          selected: selectedIndex == index,
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),

                // Bottom settings
                const Divider(
                  height: 1,
                  color: Color(0xFFD9DCE1),
                ),

                _BackstageNavItem(
                  icon: Icons.settings_outlined,
                  label: 'Options',
                  selected: false,
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

          // =====================================================
          // RIGHT CONTENT
          // =====================================================
          Expanded(
            child: Container(
              color: Colors.white,
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final String selected = selectedIndex < items.length
        ? items[selectedIndex].label
        : 'Options';

    switch (selected) {
      case 'New':
        return const _NewContent();

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
        return const _SimpleContent(
          title: 'Save As',
          subtitle: 'Save the current project to another location.',
          icon: Icons.save_as_outlined,
        );

      case 'Version Control':
        return const _SimpleContent(
          title: 'Version Control',
          subtitle: 'Manage project versions and revisions.',
          icon: Icons.account_tree_outlined,
        );

      case 'Historical Records':
        return const _SimpleContent(
          title: 'Historical Records',
          subtitle: 'Browse previous project states.',
          icon: Icons.history,
        );

      case 'Projects Backup':
        return const _SimpleContent(
          title: 'Projects Backup',
          subtitle: 'Create or restore project backups.',
          icon: Icons.backup_outlined,
        );

      case 'Recycle Bin':
        return const _SimpleContent(
          title: 'Recycle Bin',
          subtitle: 'Manage deleted project items.',
          icon: Icons.delete_outline,
        );

      case 'Import':
        return const _SimpleContent(
          title: 'Import',
          subtitle: 'Import external design files.',
          icon: Icons.file_upload_outlined,
        );

      case 'Export':
        return const _SimpleContent(
          title: 'Export',
          subtitle: 'Export your design into another format.',
          icon: Icons.file_download_outlined,
        );

      case 'Print':
        return const _SimpleContent(
          title: 'Print',
          subtitle: 'Configure and print the current design.',
          icon: Icons.print_outlined,
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
        return const _NewContent();
    }
  }
}

// ===============================================================
// NEW CONTENT
// ===============================================================

class _NewContent extends StatelessWidget {
  const _NewContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(46, 36, 46, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'New',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              color: Color(0xFF202124),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Create a new Voltura design.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 34),

          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
              childAspectRatio: 1.35,
              children: const [
                _NewCard(
                  icon: Icons.account_tree_outlined,
                  title: 'Project',
                  subtitle: 'Create a new project',
                ),
                _NewCard(
                  icon: Icons.developer_board_outlined,
                  title: 'Board',
                  subtitle: 'Create a new board',
                ),
                _NewCard(
                  icon: Icons.schema_outlined,
                  title: 'Schematic',
                  subtitle: 'Create a schematic',
                ),
                _NewCard(
                  icon: Icons.insert_drive_file_outlined,
                  title: 'Page',
                  subtitle: 'Create a new page',
                ),
                _NewCard(
                  icon: Icons.memory_outlined,
                  title: 'PCB',
                  subtitle: 'Create a PCB design',
                ),
                _NewCard(
                  icon: Icons.dashboard_outlined,
                  title: 'Panel',
                  subtitle: 'Create a panel',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// NEW CARD
// ===============================================================

class _NewCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _NewCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  State<_NewCard> createState() => _NewCardState();
}

class _NewCardState extends State<_NewCard> {
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
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(
          0,
          hovered ? -3 : 0,
          0,
        ),
        padding: const EdgeInsets.all(22),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                widget.icon,
                color: hovered
                    ? Colors.white
                    : AppColors.signalOrange,
                size: 23,
              ),
            ),

            const Spacer(),

            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF202124),
              ),
            ),

            const SizedBox(height: 5),

            Text(
              widget.subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// NAV ITEM
// ===============================================================

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
  State<_BackstageNavItem> createState() => _BackstageNavItemState();
}

class _BackstageNavItemState extends State<_BackstageNavItem> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = hovered || widget.selected;

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
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          height: 45,
          margin: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          decoration: BoxDecoration(
            color: active
                ? AppColors.signalOrange.withOpacity(
                    widget.selected ? 0.14 : 0.07,
                  )
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 19,
                color: widget.selected
                    ? AppColors.signalOrange
                    : const Color(0xFF555A60),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: widget.selected
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: widget.selected
                        ? AppColors.signalOrange
                        : const Color(0xFF34383D),
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

// ===============================================================
// SIMPLE CONTENT
// ===============================================================

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
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w600,
              color: Color(0xFF202124),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// DATA
// ===============================================================

class _FileMenuItem {
  final IconData icon;
  final String label;

  const _FileMenuItem(
    this.icon,
    this.label,
  );
}
