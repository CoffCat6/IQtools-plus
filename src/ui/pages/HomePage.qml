// src/ui/pages/HomePage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root

    required property QtObject theme
    required property QtObject viewModel

    objectName: "homePage"

    ColumnLayout {
        anchors.fill: parent
        spacing: root.theme.spacingLG

        SoftCard {
            theme: root.theme
            Layout.fillWidth: true
            Layout.preferredHeight: 180

            Text {
                text: root.viewModel.welcomeMessage
                color: root.theme.textPrimary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSizeXL
                font.weight: root.theme.fontWeightSemibold
            }

            Text {
                text: qsTr("这是主页，后续会放一些常用功能的快捷入口，以及使用提示与版本信息。")
                color: root.theme.textSecondary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSizeBase
                wrapMode: Text.WordWrap
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: root.theme.spacingLG

            SoftCard {
                theme: root.theme
                Layout.fillWidth: true
                Layout.preferredHeight: 140

                Text {
                    text: qsTr("当前版本")
                    color: root.theme.textSecondary
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeSM
                    font.weight: root.theme.fontWeightSemibold
                }

                Text {
                    text: root.viewModel.appVersion
                    color: root.theme.textPrimary
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeLG
                    font.weight: root.theme.fontWeightSemibold
                }
            }

            SoftCard {
                theme: root.theme
                Layout.fillWidth: true
                Layout.preferredHeight: 140

                Text {
                    text: qsTr("构建信息")
                    color: root.theme.textSecondary
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeSM
                    font.weight: root.theme.fontWeightSemibold
                }

                Text {
                    text: root.viewModel.buildDate
                    color: root.theme.textPrimary
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeLG
                    font.weight: root.theme.fontWeightSemibold
                }
            }
        }
    }
}
