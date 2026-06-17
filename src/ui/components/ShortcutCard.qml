// src/ui/components/ShortcutCard.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root

    required property QtObject theme
    property string icon: ""
    property string title: ""
    property string description: ""
    property bool comingSoon: false
    property bool clickable: true

    signal clicked()

    implicitHeight: 120
    radius: theme.radiusLG
    color: mouseArea.containsMouse && !root.comingSoon
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
        cursorShape: root.clickable && !root.comingSoon ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (!root.comingSoon && root.clickable) {
                root.clicked()
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: theme.spacingMD
        spacing: theme.spacingSM

        // 图标
        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: theme.radiusMD
            color: root.comingSoon
                   ? theme.backgroundColor
                   : theme.primarySoftColor

            Text {
                anchors.centerIn: parent
                text: root.icon
                font.pixelSize: 20
                color: root.comingSoon
                       ? theme.textTertiary
                       : theme.primaryColor
            }
        }

        // 标题
        Text {
            text: root.title
            color: root.comingSoon
                   ? theme.textTertiary
                   : theme.textPrimary
            font.family: theme.fontFamily
            font.pixelSize: theme.fontSizeBase
            font.weight: theme.fontWeightSemibold
        }

        // 描述
        Text {
            Layout.fillWidth: true
            text: root.comingSoon
                  ? qsTr("即将上线")
                  : root.description
            color: theme.textTertiary
            font.family: theme.fontFamily
            font.pixelSize: theme.fontSizeSM
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            maximumLineCount: 2
        }
    }
}
