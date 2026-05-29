// src/ui/pages/ScreenshotPage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root

    required property QtObject theme
    objectName: "screenshotPage"

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: root.width
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
                Layout.preferredHeight: 300

                ColumnLayout {
                    anchors.fill: parent
                    spacing: root.theme.spacingMD

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

            // 示例截图历史列表
            Text {
                Layout.topMargin: root.theme.spacingMD
                text: qsTr("历史截图")
                color: root.theme.textPrimary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSizeLG
                font.weight: root.theme.fontWeightSemibold
            }

            Repeater {
                model: 10

                delegate: SoftCard {
                    required property int index

                    theme: root.theme
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: root.theme.spacingMD
                        spacing: root.theme.spacingMD

                        // 缩略图占位
                        Rectangle {
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 60
                            radius: root.theme.radiusSM
                            color: root.theme.backgroundColor

                            Text {
                                anchors.centerIn: parent
                                text: "IMG"
                                color: root.theme.textTertiary
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSizeSM
                            }
                        }

                        // 截图信息
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: ["区域截图 - 登录页面", "全屏截图 - 主界面", "延时截图 - 弹窗提示", "区域截图 - 设置页面", "全屏截图 - 仪表盘", "区域截图 - 表单验证", "延时截图 - 加载动画", "全屏截图 - 帮助文档", "区域截图 - 错误提示", "全屏截图 - 最终效果"][index]
                                color: root.theme.textPrimary
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSizeBase
                                font.weight: root.theme.fontWeightMedium
                            }

                            Text {
                                text: ["2024-01-15 14:30", "2024-01-15 13:45", "2024-01-15 12:20", "2024-01-14 16:50", "2024-01-14 15:30", "2024-01-14 14:15", "2024-01-13 11:40", "2024-01-13 10:25", "2024-01-12 09:50", "2024-01-12 08:30"][index]
                                color: root.theme.textSecondary
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSizeSM
                            }
                        }
                    }
                }
            }

            // 底部间距
            Item {
                Layout.preferredHeight: root.theme.spacingMD
            }
        }
    }
}
