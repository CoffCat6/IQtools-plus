// src/ui/pages/ScreenshotPage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root

    required property QtObject theme
    objectName: "screenshotPage"

    ColumnLayout {
        anchors.fill: parent
        spacing: root.theme.spacingLG

        RowLayout {
            Layout.fillWidth: true
            spacing: root.theme.spacingLG

            Repeater {
                model: [
                    qsTr("区域截图"),
                    qsTr("全屏截图"),
                    qsTr("延时截图")
                ]

                delegate: Item {
                    id: actionCard

                    required property string modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: 140

                    SoftCard {
                        anchors.fill: parent
                        theme: root.theme
                        hoverable: true

                        Text {
                            text: actionCard.modelData
                            color: root.theme.textPrimary
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.fontSizeLG
                            font.weight: root.theme.fontWeightSemibold
                        }

                        Text {
                            text: qsTr("后续绑定 ScreenshotViewModel.startCapture(...)")
                            color: root.theme.textSecondary
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.fontSizeSM
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }

        SoftCard {
            theme: root.theme
            Layout.fillWidth: true
            Layout.fillHeight: true

            Text {
                text: qsTr("截图预览 / 历史入口")
                color: root.theme.textPrimary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSizeLG
                font.weight: root.theme.fontWeightSemibold
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: root.theme.radiusLG
                color: root.theme.backgroundColor

                Text {
                    anchors.centerIn: parent
                    text: qsTr("这里预留给截图预览、历史记录和后续标注入口。")
                    color: root.theme.textSecondary
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeBase
                }
            }
        }
    }
}
