// src/ui/pages/SettingPage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../theme"

AppPage {
    id: root

    required property QtObject viewModel
    property QtObject toast: null
    objectName: "settingPage"

    property int currentCategory: 0

    ListModel {
        id: categoryModel
        ListElement { name: "通用"; icon: "G"; index: 0 }
        ListElement { name: "截图"; icon: "S"; index: 1 }
        ListElement { name: "翻译"; icon: "T"; index: 2 }
        ListElement { name: "剪贴板"; icon: "C"; index: 3 }
        ListElement { name: "高级"; icon: "A"; index: 4 }
        ListElement { name: "关于"; icon: "I"; index: 5 }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 0

        // Left category nav
        Rectangle {
            Layout.preferredWidth: Math.min(200, root.width * 0.22)
            Layout.fillHeight: true
            color: root.theme.sidebarColor
            radius: root.theme.radiusMD

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: root.theme.spacingSM
                spacing: root.theme.spacingXS

                ListView {
                    id: categoryList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: categoryModel
                    spacing: root.theme.spacingXS
                    clip: true

                    delegate: Rectangle {
                        id: categoryItem
                        required property var model

                        width: categoryList.width
                        height: 44
                        radius: root.theme.radiusMD
                        color: root.currentCategory === model.index
                               ? root.theme.primarySoftColor
                               : (hoverArea.containsMouse ? root.theme.surfaceColor : "transparent")

                        Behavior on color {
                            ColorAnimation { duration: root.theme.durationShort }
                        }

                        Rectangle {
                            visible: root.currentCategory === model.index
                            width: 3
                            height: parent.height * 0.4
                            anchors.left: parent.left
                            anchors.leftMargin: root.theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter
                            radius: 1.5
                            color: root.theme.primaryColor
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: root.theme.spacingMD
                            anchors.rightMargin: root.theme.spacingMD
                            spacing: root.theme.spacingMD

                            Rectangle {
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 28
                                radius: root.theme.radiusSM
                                color: root.currentCategory === model.index
                                       ? root.theme.primaryColor
                                       : root.theme.surfaceColor

                                Text {
                                    anchors.centerIn: parent
                                    text: model.icon
                                    color: root.currentCategory === model.index
                                           ? root.theme.textOnPrimary
                                           : root.theme.textSecondary
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.fontSizeSM
                                    font.weight: root.theme.fontWeightBold
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: model.name
                                color: root.currentCategory === model.index
                                       ? root.theme.textPrimary
                                       : root.theme.textSecondary
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSizeBase
                                font.weight: root.currentCategory === model.index
                                             ? root.theme.fontWeightMedium
                                             : root.theme.fontWeightNormal
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: hoverArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.currentCategory = model.index
                        }
                    }
                }
            }
        }

        // Right content area
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"

            ScrollView {
                anchors {
                    fill: parent
                    leftMargin: root.theme.spacingXL
                }
                contentWidth: availableWidth
                clip: true

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                ColumnLayout {
                    width: parent.width
                    spacing: root.theme.spacingXL

                    // ── General ──
                    ColumnLayout {
                        visible: root.currentCategory === 0
                        Layout.fillWidth: true
                        spacing: root.theme.spacingLG

                        Text {
                            text: qsTr("通用设置")
                            color: root.theme.textPrimary
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.h2Size
                            font.weight: root.theme.h2Weight
                        }

                        Rectangle {
                            Layout.fillWidth: true; height: 1; color: root.theme.dividerColor
                        }

                        // Theme settings
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: themeContent.implicitHeight + root.theme.spacingLG * 2
                            color: root.theme.surfaceColor
                            radius: root.theme.radiusLG

                            ColumnLayout {
                                id: themeContent
                                anchors {
                                    left: parent.left; right: parent.right
                                    top: parent.top; margins: root.theme.spacingLG
                                }
                                spacing: root.theme.spacingLG

                                Text {
                                    text: qsTr("外观")
                                    color: root.theme.textPrimary
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.h3Size
                                    font.weight: root.theme.h3Weight
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: root.theme.spacingMD

                                    // Light
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: root.theme.spacingMD

                                        Rectangle {
                                            width: 20; height: 20; radius: 10
                                            border.width: 2
                                            border.color: root.theme.isDark ? root.theme.dividerColor : root.theme.primaryColor
                                            color: "transparent"

                                            Rectangle {
                                                visible: !root.theme.isDark
                                                width: 12; height: 12; radius: 6
                                                anchors.centerIn: parent
                                                color: root.theme.primaryColor
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    root.viewModel.setDarkMode(false)
                                                    if (root.toast) root.toast.show(qsTr("已切换到浅色模式"), "success")
                                                }
                                            }
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: qsTr("浅色模式")
                                            color: root.theme.textSecondary
                                            font.family: root.theme.fontFamily
                                            font.pixelSize: root.theme.fontSizeBase
                                        }
                                    }

                                    // Dark
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: root.theme.spacingMD

                                        Rectangle {
                                            width: 20; height: 20; radius: 10
                                            border.width: 2
                                            border.color: root.theme.isDark ? root.theme.primaryColor : root.theme.dividerColor
                                            color: "transparent"

                                            Rectangle {
                                                visible: root.theme.isDark
                                                width: 12; height: 12; radius: 6
                                                anchors.centerIn: parent
                                                color: root.theme.primaryColor
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    root.viewModel.setDarkMode(true)
                                                    if (root.toast) root.toast.show(qsTr("已切换到暗黑模式"), "success")
                                                }
                                            }
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: qsTr("暗黑模式")
                                            color: root.theme.textSecondary
                                            font.family: root.theme.fontFamily
                                            font.pixelSize: root.theme.fontSizeBase
                                        }
                                    }

                                    // Follow System
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: root.theme.spacingMD

                                        Rectangle {
                                            width: 20; height: 20; radius: 10
                                            border.width: 2
                                            border.color: root.viewModel.followSystemTheme ? root.theme.primaryColor : root.theme.dividerColor
                                            color: "transparent"

                                            Rectangle {
                                                visible: root.viewModel.followSystemTheme
                                                width: 12; height: 12; radius: 6
                                                anchors.centerIn: parent
                                                color: root.theme.primaryColor
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    root.viewModel.setFollowSystemTheme(true)
                                                    if (root.toast) root.toast.show(qsTr("已切换为跟随系统主题"), "success")
                                                }
                                            }
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: qsTr("跟随系统")
                                            color: root.theme.textSecondary
                                            font.family: root.theme.fontFamily
                                            font.pixelSize: root.theme.fontSizeBase
                                        }
                                    }
                                }
                            }
                        }

                        // Language settings
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: langContent.implicitHeight + root.theme.spacingLG * 2
                            color: root.theme.surfaceColor
                            radius: root.theme.radiusLG

                            ColumnLayout {
                                id: langContent
                                anchors {
                                    left: parent.left; right: parent.right
                                    top: parent.top; margins: root.theme.spacingLG
                                }
                                spacing: root.theme.spacingLG

                                Text {
                                    text: qsTr("语言")
                                    color: root.theme.textPrimary
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.h3Size
                                    font.weight: root.theme.h3Weight
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: root.theme.spacingMD

                                    Text {
                                        Layout.fillWidth: true
                                        text: qsTr("语言选择")
                                        color: root.theme.textSecondary
                                        font.family: root.theme.fontFamily
                                        font.pixelSize: root.theme.fontSizeBase
                                    }

                                    AppComboBox {
                                        theme: root.theme
                                        Layout.preferredWidth: 180
                                        model: [qsTr("简体中文"), qsTr("English"), qsTr("日本語"), qsTr("한국어")]
                                        currentIndex: 0
                                        onActivated: function(index) {
                                            if (root.toast) root.toast.show(qsTr("语言设置将在重启后生效"), "info")
                                        }
                                    }
                                }
                            }
                        }

                        Item { Layout.fillHeight: true }
                    }

                    // Placeholder for other categories (simplified)
                    property var placeholderCategories: [1, 2, 3, 4, 5]
                    property var placeholderTitles: [qsTr("截图设置"), qsTr("翻译设置"), qsTr("剪贴板设置"), qsTr("高级设置"), qsTr("关于")]

                    Repeater {
                        model: 5

                        delegate: ColumnLayout {
                            required property int index
                            visible: root.currentCategory === index + 1
                            Layout.fillWidth: true
                            spacing: root.theme.spacingLG

                            Text {
                                text: ["截图设置", "翻译设置", "剪贴板设置", "高级设置", "关于"][index]
                                color: root.theme.textPrimary
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.h2Size
                                font.weight: root.theme.h2Weight
                            }

                            Rectangle {
                                Layout.fillWidth: true; height: 1; color: root.theme.dividerColor
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 100
                                color: root.theme.surfaceColor
                                radius: root.theme.radiusLG

                                Text {
                                    anchors.centerIn: parent
                                    text: ["截图设置", "翻译设置", "剪贴板设置", "高级设置", "关于"]
                                          [index] + qsTr("将在后续实现...")
                                    color: root.theme.textSecondary
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.fontSizeBase
                                }
                            }

                            Item { Layout.fillHeight: true }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }
        }
    }
}
