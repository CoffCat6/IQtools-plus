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

        SoftCard {
            theme: root.theme
            highlighted: true
            Layout.fillWidth: true
            implicitHeight: root.collapsed ? 88 : 120

            Behavior on implicitHeight {
                NumberAnimation {
                    duration: root.theme.durationBase
                    easing.type: Easing.OutCubic
                }
            }

            Item {
                anchors.fill: parent

                Column {
                    anchors.fill: parent
                    spacing: root.theme.spacingSM

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.collapsed ? qsTr("IQ") : qsTr("IQtools Plus")
                        color: root.theme.textPrimary
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.collapsed
                                        ? root.theme.fontSizeXL
                                        : root.theme.fontSize2XL
                        font.weight: root.theme.fontWeightBold
                    }

                    Text {
                        visible: !root.collapsed
                        opacity: root.collapsed ? 0.0 : 1.0
                        text: qsTr("桌面效率工具箱")
                        color: root.theme.textSecondary
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSizeBase
                        wrapMode: Text.WordWrap

                        Behavior on opacity {
                            NumberAnimation {
                                duration: root.theme.durationBase
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }
        }

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

        SoftCard {
            theme: root.theme
            Layout.fillWidth: true
            implicitHeight: root.collapsed ? 92 : 156

            Behavior on implicitHeight {
                NumberAnimation {
                    duration: root.theme.durationBase
                    easing.type: Easing.OutCubic
                }
            }

            Item {
                anchors.fill: parent

                Column {
                    anchors.fill: parent
                    spacing: root.theme.spacingSM

                    Text {
                        visible: !root.collapsed
                        opacity: root.collapsed ? 0.0 : 1.0
                        text: qsTr("当前阶段")
                        color: root.theme.textSecondary
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSizeSM
                        font.weight: root.theme.fontWeightSemibold

                        Behavior on opacity {
                            NumberAnimation {
                                duration: root.theme.durationBase
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    Text {
                        visible: !root.collapsed
                        opacity: root.collapsed ? 0.0 : 1.0
                        text: qsTr("主界面壳层已拆分，下一步可逐页接入 ViewModel。")
                        color: root.theme.textPrimary
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSizeBase
                        wrapMode: Text.WordWrap

                        Behavior on opacity {
                            NumberAnimation {
                                duration: root.theme.durationBase
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    Button {
                        id: collapseButton

                        anchors.horizontalCenter: parent.horizontalCenter
                        width: root.collapsed ? 40 : parent.width
                        height: 40
                        text: root.collapsed ? ">" : qsTr("收起导航")

                        onClicked: root.toggleCollapseRequested()

                        contentItem: Text {
                            text: collapseButton.text
                            color: root.theme.textPrimary
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.fontSizeBase
                            font.weight: root.theme.fontWeightSemibold
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 20
                            color: collapseButton.down
                                   ? root.theme.primaryLightColor
                                   : root.theme.surfaceColor

                            Behavior on color {
                                ColorAnimation {
                                    duration: root.theme.durationBase
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}