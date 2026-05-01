// src/ui/components/AppTopBar.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property QtObject theme
    required property string title
    required property string subtitle

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
    }
}