// src/ui/components/ShortcutCard.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    required property QtObject theme
    property string icon: ""
    property string title: ""
    property string description: ""
    property bool comingSoon: false

    signal clicked()

    implicitHeight: 120
    radius: theme.radiusLG
    color: mouseArea.containsMouse
           ? Qt.rgba(theme.primaryColor.r, theme.primaryColor.g, theme.primaryColor.b, 0.06)
           : theme.surfaceColor

    Behavior on color {
        ColorAnimation { duration: theme.durationShort }
    }

    border.width: comingSoon ? 1 : 0
    border.color: comingSoon ? theme.dividerColor : "transparent"

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (!root.comingSoon) {
                root.clicked()
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.theme.spacingMD
        spacing: root.theme.spacingSM

        // 图标
        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: root.theme.radiusMD
            color: root.comingSoon
                   ? root.theme.backgroundColor
                   : root.theme.primarySoftColor

            Text {
                anchors.centerIn: parent
                text: root.icon
                font.pixelSize: 20
                color: root.comingSoon
                       ? root.theme.textTertiary
                       : root.theme.primaryColor
            }
        }

        // 标题
        Text {
            text: root.title
            color: root.comingSoon
                   ? root.theme.textTertiary
                   : root.theme.textPrimary
            font.family: root.theme.fontFamily
            font.pixelSize: root.theme.fontSizeBase
            font.weight: root.theme.fontWeightSemibold
        }

        // 描述
        Text {
            Layout.fillWidth: true
            text: root.comingSoon
                  ? qsTr("即将上线")
                  : root.description
            color: root.theme.textTertiary
            font.family: root.theme.fontFamily
            font.pixelSize: root.theme.fontSizeSM
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            maximumLineCount: 2
        }
    }
}
