// src/ui/main.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"
import "pages"
import "theme"

ApplicationWindow {
    id: root

    required property QtObject viewModel

    // Sidebar UI state
    property bool sidebarCollapsed: false

    width: 1440
    height: 920
    minimumWidth: 1160
    minimumHeight: 760
    visible: true
    title: qsTr("IQtools Plus")

    Theme {
        id: theme
        isDark: root.viewModel.darkMode
    }

    color: theme.backgroundColor
    font.family: theme.fontFamily

    background: Rectangle {
        color: theme.backgroundColor

        Behavior on color {
            ColorAnimation {
                duration: theme.durationBase
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: theme.spacingLG
        spacing: theme.spacingLG

        AppSidebar {
            Layout.preferredWidth: root.sidebarCollapsed ? 64 : 260
            Layout.fillHeight: true

            theme: theme
            currentIndex: root.viewModel.currentPageIndex
            collapsed: root.sidebarCollapsed

            onPageSelected: function(pageIndex) {
                root.viewModel.navigateTo(pageIndex)
            }

            onToggleCollapseRequested: {
                root.sidebarCollapsed = !root.sidebarCollapsed
            }

            onThemeToggleRequested: {
                root.viewModel.toggleDarkMode()
            }

            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: theme.durationBase
                    easing.type: Easing.OutCubic
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                spacing: theme.spacingLG

                AppTopBar {
                    Layout.fillWidth: true
                    theme: theme
                    title: root.viewModel.pageTitle
                    subtitle: root.viewModel.pageSubtitle
                }

                SoftCard {
                    theme: theme
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    padding: theme.spacingXL

                    StackLayout {
                        anchors.fill: parent
                        currentIndex: root.viewModel.currentPageIndex

                        HomePage {
                            theme: theme
                            viewModel: root.viewModel.homeViewModel
                        }

                        TranslatePage {
                            theme: theme
                            viewModel: root.viewModel.translateViewModel
                        }

                        ClipboardPage {
                            theme: theme
                            // viewModel: root.viewModel.clipboardViewModel
                        }

                        ScreenshotPage {
                            theme: theme
                        }
                    }
                }
            }
        }
    }
}