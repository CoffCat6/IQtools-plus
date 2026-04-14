// src/ui/pages/ClipboardPage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root

    required property QtObject theme
    objectName: "clipboardPage"

    ColumnLayout {
        anchors.fill: parent
        spacing: root.theme.spacingLG

        SoftCard {
            theme: root.theme
            Layout.fillWidth: true
            Layout.preferredHeight: 96

            RowLayout {
                spacing: root.theme.spacingMD

                TextField {
                    Layout.fillWidth: true
                    placeholderText: qsTr("搜索剪贴板历史…")

                    background: Rectangle {
                        radius: root.theme.radiusMD
                        color: root.theme.backgroundColor
                    }
                }

                ComboBox {
                    Layout.preferredWidth: 140
                    model: [qsTr("全部"), qsTr("文本"), qsTr("图片"), qsTr("文件")]
                }

                Button {
                    text: qsTr("清空")
                }
            }
        }

        SoftCard {
            theme: root.theme
            Layout.fillWidth: true
            Layout.fillHeight: true

            Text {
                text: qsTr("历史记录")
                color: root.theme.textPrimary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSizeLG
                font.weight: root.theme.fontWeightSemibold
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: root.theme.spacingSM
                model: 6

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 72
                    radius: root.theme.radiusMD
                    color: index === 0 ? root.theme.primarySoftColor : root.theme.backgroundColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: root.theme.spacingMD
                        spacing: root.theme.spacingMD

                        Rectangle {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            radius: root.theme.radiusMD
                            color: root.theme.surfaceColor

                            Text {
                                anchors.centerIn: parent
                                text: index % 2 === 0 ? qsTr("文") : qsTr("图")
                                color: root.theme.textSecondary
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSizeSM
                                font.weight: root.theme.fontWeightBold
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: qsTr("示例剪贴板条目 %1").arg(index + 1)
                                color: root.theme.textPrimary
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSizeBase
                                font.weight: root.theme.fontWeightMedium
                            }

                            Text {
                                text: qsTr("这里将来接 ClipboardListModel.preview / type / timestamp。")
                                color: root.theme.textSecondary
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSizeSM
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }
    }
}