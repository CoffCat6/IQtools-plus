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
