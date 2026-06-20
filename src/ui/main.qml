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
    // Track previous page index for slide direction
    property int previousPageIndex: 0

    width: 1440
    height: 920
    minimumWidth: 800
    minimumHeight: 600
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
        anchors.margins: {
            if (root.width < theme.bpCompact) return theme.spacingSM;
            return theme.spacingLG;
        }
        spacing: {
            if (root.width < theme.bpCompact) return theme.spacingSM;
            return theme.spacingLG;
        }

        AppSidebar {
            id: sidebar
            Layout.preferredWidth: sidebar.implicitWidth
            Layout.fillHeight: true

            theme: theme
            currentIndex: root.viewModel.currentPageIndex
            collapsed: root.sidebarCollapsed || (root.width < theme.bpCompact)

            onPageSelected: function(pageIndex) {
                root.previousPageIndex = root.viewModel.currentPageIndex
                root.viewModel.navigateTo(pageIndex)
            }

            onToggleCollapseRequested: {
                root.sidebarCollapsed = !root.sidebarCollapsed
            }

            onThemeToggleRequested: {
                root.viewModel.toggleDarkMode()
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
                    padding: {
                        if (root.width < theme.bpCompact) return theme.spacingMD;
                        return theme.spacingXL;
                    }

                    // Page stack with slide transition
                    Item {
                        anchors.fill: parent
                        anchors.margins: {
                            if (root.width < theme.bpCompact) return theme.spacingSM;
                            return theme.spacingMD;
                        }
                        clip: true

                        StackLayout {
                            id: pageStack
                            anchors.fill: parent
                            currentIndex: root.viewModel.currentPageIndex

                            // Slide transition: animate x offset on the active page
                            property real slideOffset: {
                                if (!pageStack.currentItem) return 0;
                                return pageStack.currentItem.visible ? 0 : 80;
                            }

                            // Fade+slide transition when page changes
                            Behavior on currentIndex {
                                id: pageTransition
                                enabled: false  // start disabled, enable after init
                            }

                            Component.onCompleted: {
                                pageTransition.enabled = true;
                            }

                            HomePage {
                                id: homePage
                                theme: theme
                                viewModel: root.viewModel.homeViewModel
                                navigateTo: function(index) {
                                    root.previousPageIndex = root.viewModel.currentPageIndex
                                    // 转换索引：AI助手已移到第二位
                                    var newIndex = index
                                    if (index === 1) newIndex = 1  // 翻译原本是1，现在变成2
                                    else if (index === 2) newIndex = 3  // 剪贴板原本是2，现在变成3
                                    else if (index === 3) newIndex = 4  // 截图原本是3，现在变成4
                                    else if (index === 4) newIndex = 5  // 待办原本是4，现在变成5
                                    root.viewModel.navigateTo(newIndex)
                                }
                                // Fade in/out
                                opacity: pageStack.currentIndex === 0 ? 1 : 0
                                Behavior on opacity {
                                    NumberAnimation { duration: theme.durationLong; easing.type: Easing.OutCubic }
                                }
                            }

                            AIAssistantPage {
                                id: aiAssistantPage
                                theme: theme
                                toast: appToast
                                opacity: pageStack.currentIndex === 1 ? 1 : 0
                                Behavior on opacity {
                                    NumberAnimation { duration: theme.durationLong; easing.type: Easing.OutCubic }
                                }
                            }

                            TranslatePage {
                                id: translatePage
                                theme: theme
                                viewModel: root.viewModel.translateViewModel
                                toast: appToast
                                opacity: pageStack.currentIndex === 2 ? 1 : 0
                                Behavior on opacity {
                                    NumberAnimation { duration: theme.durationLong; easing.type: Easing.OutCubic }
                                }
                            }

                            ClipboardPage {
                                id: clipboardPage
                                theme: theme
                                toast: appToast
                                opacity: pageStack.currentIndex === 3 ? 1 : 0
                                Behavior on opacity {
                                    NumberAnimation { duration: theme.durationLong; easing.type: Easing.OutCubic }
                                }
                            }

                            ScreenshotPage {
                                id: screenshotPage
                                theme: theme
                                toast: appToast
                                opacity: pageStack.currentIndex === 4 ? 1 : 0
                                Behavior on opacity {
                                    NumberAnimation { duration: theme.durationLong; easing.type: Easing.OutCubic }
                                }
                            }

                            TodoPage {
                                id: todoPage
                                theme: theme
                                toast: appToast
                                opacity: pageStack.currentIndex === 5 ? 1 : 0
                                Behavior on opacity {
                                    NumberAnimation { duration: theme.durationLong; easing.type: Easing.OutCubic }
                                }
                            }

                            SettingPage {
                                id: settingPage
                                theme: theme
                                viewModel: root.viewModel
                                toast: appToast
                                opacity: pageStack.currentIndex === 6 ? 1 : 0
                                Behavior on opacity {
                                    NumberAnimation { duration: theme.durationLong; easing.type: Easing.OutCubic }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Global Toast
    AppToast {
        id: appToast
        theme: theme
        parent: root.contentItem
    }

    // Global Confirm Dialog
    AppConfirmDialog {
        id: appConfirmDialog
        theme: theme
        parent: root.contentItem
    }
}