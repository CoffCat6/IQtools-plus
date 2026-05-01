// src/ui/components/AppSidebar.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."

Item {
    id: root

    required property QtObject theme
    required property int currentIndex
    required property bool collapsed

    signal pageSelected(int pageIndex)
    signal toggleCollapseRequested()
    signal themeToggleRequested()

    objectName: "appSidebar"
    implicitWidth: root.collapsed ? 88 : 260

    readonly property var navItems: [
        {
            title: qsTr("首页"),
            badge: qsTr("首")
        },
        {
            title: qsTr("翻译"),
            badge: qsTr("译")
        },
        {
            title: qsTr("剪贴板"),
            badge: qsTr("剪")
        },
        {
            title: qsTr("截图"),
            badge: qsTr("截")
        }
    ]

    Behavior on implicitWidth {
        NumberAnimation {
            duration: root.theme.durationBase
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: root.theme.radiusXL
        color: root.theme.sidebarColor

        Behavior on color {
            ColorAnimation {
                duration: root.theme.durationBase
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.theme.spacingLG
        spacing: root.theme.spacingLG

        ColumnLayout {
            Layout.fillWidth: true
            spacing: root.theme.spacingSM

            Repeater {
                model: root.navItems.length

                delegate: Item {
                    id: navDelegate

                    required property int index
                    readonly property var navItemData: root.navItems[index]

                    Layout.fillWidth: true
                    implicitHeight: navigationItem.implicitHeight

                    NavigationItem {
                        id: navigationItem
                        anchors.fill: parent
                        theme: root.theme
                        title: root.collapsed ? "" : navDelegate.navItemData.title
                        badgeText: navDelegate.navItemData.badge
                        pageIndex: navDelegate.index
                        currentIndex: root.currentIndex

                        onTriggered: function(pageIndex) {
                            root.pageSelected(pageIndex)
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }

        // 主题切换按钮
        Rectangle {
            id: themeToggleButton
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            radius: root.theme.radiusLG
            color: themeToggleMouseArea.containsMouse
                   ? root.theme.surfaceColor : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: root.theme.durationShort
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: root.theme.spacingMD
                anchors.rightMargin: root.theme.spacingMD
                spacing: root.theme.spacingMD

                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: root.theme.radiusMD
                    color: root.theme.surfaceColor

                    Text {
                        anchors.centerIn: parent
                        text: root.theme.isDark ? "☾" : "☀"
                        font.pixelSize: 16
                    }
                }

                Text {
                    visible: !root.collapsed
                    opacity: root.collapsed ? 0.0 : 1.0
                    Layout.fillWidth: true
                    text: root.theme.isDark ? qsTr("浅色模式") : qsTr("深色模式")
                    color: root.theme.textPrimary
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeBase
                    font.weight: root.theme.fontWeightMedium
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter

                    Behavior on opacity {
                        NumberAnimation {
                            duration: root.theme.durationBase
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            MouseArea {
                id: themeToggleMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.themeToggleRequested()
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: root.theme.spacingSM

            // 设置页按钮
            NavigationItem {
                Layout.fillWidth: true
                theme: root.theme
                title: root.collapsed ? "" : qsTr("设置")
                badgeText: qsTr("设")
                pageIndex: 4
                currentIndex: root.currentIndex

                onTriggered: function(pageIndex) {
                    root.pageSelected(pageIndex)
                }
            }

            // 折叠/展开按钮
            NavigationItem {
                Layout.fillWidth: true
                theme: root.theme
                title: root.collapsed ? "" : qsTr("收起侧栏")
                badgeText: root.collapsed ? qsTr("展") : qsTr("收")
                pageIndex: -1
                currentIndex: root.currentIndex

                onTriggered: function() {
                    root.toggleCollapseRequested()
                }
            }
        }
    }
}
