import 'package:flutter/material.dart';
import 'package:simulator/screens/home_screen.dart';

class CustomMenu extends StatefulWidget {
  final ThemeMode themeMode;
  final Function(ThemeMode) onThemeChanged;

  const CustomMenu({
    required this.themeMode,
    required this.onThemeChanged,
    super.key,
  });

  @override
  State<CustomMenu> createState() => _CustomMenuState();
}

class _CustomMenuState extends State<CustomMenu> {
  void _toggleTheme() {
    final newThemeMode =
        widget.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    widget.onThemeChanged(newThemeMode);
  }

  @override
  Widget build(BuildContext context) {
    String darkModeLabel =
        widget.themeMode == ThemeMode.dark ? '✓ Dark Mode' : 'Dark Mode';

    return PlatformMenuBar(
      menus: [
        PlatformMenu(
          label: 'F16 Simulator',
          menus: [
            PlatformMenuItemGroup(
              members: [
                if (PlatformProvidedMenuItem.hasMenu(
                    PlatformProvidedMenuItemType.about))
                  const PlatformProvidedMenuItem(
                      type: PlatformProvidedMenuItemType.about),
              ],
            ),
            PlatformMenuItemGroup(
              members: [
                if (PlatformProvidedMenuItem.hasMenu(
                    PlatformProvidedMenuItemType.servicesSubmenu))
                  const PlatformProvidedMenuItem(
                      type: PlatformProvidedMenuItemType.servicesSubmenu),
              ],
            ),
            PlatformMenuItemGroup(
              members: [
                if (PlatformProvidedMenuItem.hasMenu(
                    PlatformProvidedMenuItemType.hide))
                  const PlatformProvidedMenuItem(
                      type: PlatformProvidedMenuItemType.hide),
                if (PlatformProvidedMenuItem.hasMenu(
                    PlatformProvidedMenuItemType.hideOtherApplications))
                  const PlatformProvidedMenuItem(
                      type: PlatformProvidedMenuItemType.hideOtherApplications),
                if (PlatformProvidedMenuItem.hasMenu(
                    PlatformProvidedMenuItemType.showAllApplications))
                  const PlatformProvidedMenuItem(
                      type: PlatformProvidedMenuItemType.showAllApplications),
              ],
            ),
            PlatformMenuItemGroup(members: [
              if (PlatformProvidedMenuItem.hasMenu(
                  PlatformProvidedMenuItemType.quit))
                const PlatformProvidedMenuItem(
                    type: PlatformProvidedMenuItemType.quit),
            ]),
          ],
        ),
        PlatformMenu(
          label: 'View',
          menus: [
            PlatformMenuItemGroup(
              members: [
                if (PlatformProvidedMenuItem.hasMenu(
                    PlatformProvidedMenuItemType.toggleFullScreen))
                  const PlatformProvidedMenuItem(
                      type: PlatformProvidedMenuItemType.toggleFullScreen),
                PlatformMenuItem(
                  label: darkModeLabel,
                  onSelected: () {
                    _toggleTheme(); // Toggle theme mode when Dark Mode is selected.
                  },
                ),
              ],
            ),
          ],
        ),
        PlatformMenu(
          label: 'Window',
          menus: [
            PlatformMenuItemGroup(
              members: [
                if (PlatformProvidedMenuItem.hasMenu(
                    PlatformProvidedMenuItemType.minimizeWindow))
                  const PlatformProvidedMenuItem(
                      type: PlatformProvidedMenuItemType.minimizeWindow),
                if (PlatformProvidedMenuItem.hasMenu(
                    PlatformProvidedMenuItemType.zoomWindow))
                  const PlatformProvidedMenuItem(
                      type: PlatformProvidedMenuItemType.zoomWindow),
              ],
            ),
            PlatformMenuItemGroup(
              members: [
                if (PlatformProvidedMenuItem.hasMenu(
                    PlatformProvidedMenuItemType.arrangeWindowsInFront))
                  const PlatformProvidedMenuItem(
                      type: PlatformProvidedMenuItemType.arrangeWindowsInFront),
              ],
            ),
          ],
        ),
      ],
      child: HomeScreen(),
    );
  }
}
