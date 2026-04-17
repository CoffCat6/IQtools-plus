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
            ColorAnimation { duration: theme.durationBase }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: theme.spacingLG
        spacing: theme.spacingLG

        AppSidebar {
            Layout.preferredWidth: 260
            Layout.fillHeight: true
            theme: theme
            currentIndex: root.viewModel.currentPageIndex

            onPageSelected: function(pageIndex) {
                root.viewModel.navigateTo(pageIndex)
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

                    onThemeToggleRequested: {
                        root.viewModel.toggleDarkMode()
                    }
                }

                SoftCard {
                    theme: theme
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    padding: theme.spacingXL

                    StackLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
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
