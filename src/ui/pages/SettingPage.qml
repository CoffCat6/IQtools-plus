// src/ui/pages/SettingPage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root

    required property QtObject theme
    objectName: "SettingPage"

    ColumnLayout {
        anchors.fill: parent
        spacing: root.theme.spacingLG

        SoftCard {
            theme: root.theme
            Layout.fillWidth: true
            Layout.fillHeight: true


            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: root.theme.radiusLG
                color: root.theme.backgroundColor

                
            }
        }
    }
}
