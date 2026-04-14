// src/ui/components/AppSidebar.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."

Item {
    id: root

    required property QtObject theme
    required property int currentIndex

    signal pageSelected(int pageIndex)

    objectName: "appSidebar"
    implicitWidth: 260

    readonly property var navItems: [
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

    Rectangle {
        anchors.fill: parent
        radius: root.theme.radiusXL
        color: root.theme.sidebarColor
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.theme.spacingLG
        spacing: root.theme.spacingLG

        SoftCard {
            theme: root.theme
            highlighted: true
            Layout.fillWidth: true
            implicitHeight: 120

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

        ColumnLayout {
            Layout.fillWidth: true
            spacing: root.theme.spacingSM

            Repeater {
                model: root.navItems

                delegate: NavigationItem {
                    theme: root.theme
                    title: modelData.title
                    badgeText: modelData.badge
                    pageIndex: index
                    currentIndex: root.currentIndex
                    onTriggered: function (pageIndex) {
                        root.pageSelected(pageIndex);
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
            implicitHeight: 112

            Text {
                text: qsTr("当前阶段")
                color: root.theme.textSecondary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSizeSM
                font.weight: root.theme.fontWeightSemibold
            }

            Text {
                text: qsTr("主界面壳层已拆分，下一步可逐页接入 ViewModel。")
                color: root.theme.textPrimary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSizeBase
                wrapMode: Text.WordWrap
            }
        }
    }
}
