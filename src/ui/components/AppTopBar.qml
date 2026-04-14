// src/ui/components/AppTopBar.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property QtObject theme
    required property string title
    required property string subtitle

    signal themeToggleRequested()

    implicitHeight: 92
    objectName: "appTopBar"

    RowLayout {
        anchors.fill: parent
        spacing: root.theme.spacingLG

        ColumnLayout {
            Layout.fillWidth: true
            spacing: root.theme.spacingXS

            Text {
                text: root.title
                color: root.theme.textPrimary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSize4XL
                font.weight: root.theme.fontWeightBold
            }

            Text {
                text: root.subtitle
                color: root.theme.textSecondary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSizeBase
                elide: Text.ElideRight
            }
        }

        Button {
            id: themeButton
            text: root.theme.isDark ? qsTr("浅色") : qsTr("深色")
            focusPolicy: Qt.TabFocus
            onClicked: root.themeToggleRequested()

            background: Rectangle {
                radius: root.theme.radiusLG
                color: themeButton.hovered ? root.theme.primaryHoverColor : root.theme.primaryColor
            }

            contentItem: Text {
                text: themeButton.text
                color: "#FFFFFF"
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSizeBase
                font.weight: root.theme.fontWeightSemibold
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}