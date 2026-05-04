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
    implicitWidth: root.collapsed ? 64 : 260

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
        },
        {
            title: qsTr("设置"),
            badge: qsTr("设")
        }
    ]

    Behavior on implicitWidth {
        NumberAnimation {
            duration: root.theme.durationBase
            easing.type: Easing.OutCubic
        }
    }

    // 背景
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
        anchors.margins: root.collapsed ? root.theme.spacingSM : root.theme.spacingLG
        spacing: root.collapsed ? root.theme.spacingSM : root.theme.spacingLG

        Behavior on anchors.margins {
            NumberAnimation {
                duration: root.theme.durationBase
                easing.type: Easing.OutCubic
            }
        }

        // ── Header ─────────────────────────────────────────────────────
        // 折叠态：纯文字 logo
        Text {
            visible: root.collapsed
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("IQ")
            color: root.theme.textPrimary
            font.family: root.theme.fontFamily
            font.pixelSize: root.theme.fontSizeXL
            font.weight: root.theme.fontWeightBold
        }

        // 展开态：SoftCard 品牌卡
        SoftCard {
            visible: !root.collapsed
            theme: root.theme
            highlighted: true
            Layout.fillWidth: true
            implicitHeight: 120

            Item {
                anchors.fill: parent

                Column {
                    anchors.fill: parent
                    spacing: root.theme.spacingSM

                    Text {
                        text: qsTr("IQtools Plus")
                        color: root.theme.textPrimary
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSize2XL
                        font.weight: root.theme.fontWeightBold
                    }

                    Text {
                        text: qsTr("桌面效率工具箱")
                        color: root.theme.textSecondary
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSizeBase
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }

        // ── Navigation Items ───────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            spacing: root.collapsed ? 2 : root.theme.spacingSM

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
                        title: navDelegate.navItemData.title
                        badgeText: navDelegate.navItemData.badge
                        pageIndex: navDelegate.index
                        currentIndex: root.currentIndex
                        collapsed: root.collapsed

                        onTriggered: function(pageIndex) {
                            root.pageSelected(pageIndex)
                        }
                    }
                }
            }
        }

        // 弹性空间
        Item {
            Layout.fillHeight: true
        }

        // ── 主题切换 ───────────────────────────────────────────────────
        Rectangle {
            id: themeToggleButton
            Layout.fillWidth: true
            Layout.preferredHeight: root.collapsed ? 36 : 44
            Layout.alignment: Qt.AlignHCenter
            width: root.collapsed ? 36 : undefined
            radius: root.collapsed ? 18 : root.theme.radiusLG
            color: themeToggleMouseArea.containsMouse
                   ? root.theme.surfaceColor : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: root.theme.durationShort
                }
            }

            // 折叠态：纯图标居中
            Text {
                visible: root.collapsed
                anchors.centerIn: parent
                text: root.theme.isDark ? "☾" : "☀"
                font.pixelSize: 16
                color: root.theme.textSecondary
            }

            // 展开态：图标 + 文字
            RowLayout {
                visible: !root.collapsed
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
                    Layout.fillWidth: true
                    text: root.theme.isDark ? qsTr("浅色模式") : qsTr("深色模式")
                    color: root.theme.textPrimary
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeBase
                    font.weight: root.theme.fontWeightMedium
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
            }

            MouseArea {
                id: themeToggleMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.themeToggleRequested()
            }

            ToolTip.visible: root.collapsed && themeToggleMouseArea.containsMouse
            ToolTip.text: root.theme.isDark ? qsTr("浅色模式") : qsTr("深色模式")
            ToolTip.delay: 400
        }

        // ── 收起/展开按钮 ──────────────────────────────────────────────
        Rectangle {
            id: collapseButton
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            Layout.alignment: Qt.AlignHCenter
            radius: 18
            color: collapseMouseArea.containsMouse
                   ? root.theme.surfaceColor : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: root.theme.durationShort
                }
            }

            Text {
                anchors.centerIn: parent
                text: root.collapsed ? "›" : "‹"
                color: root.theme.textSecondary
                font.family: root.theme.fontFamily
                font.pixelSize: 18
                font.weight: root.theme.fontWeightSemibold
            }

            MouseArea {
                id: collapseMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.toggleCollapseRequested()
            }

            ToolTip.visible: root.collapsed && collapseMouseArea.containsMouse
            ToolTip.text: qsTr("展开导航")
            ToolTip.delay: 400
        }
    }
}
