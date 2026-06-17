// src/ui/components/AppListItem.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root

    required property QtObject theme
    property string iconText: ""         // emoji or short text for type badge
    property string title: ""
    property string subtitle: ""
    property string trailingText: ""     // time, status, etc.
    property bool showCopyButton: false
    property bool highlighted: false     // visually emphasized
    property bool clickable: true

    signal clicked()
    signal copyRequested()

    Layout.fillWidth: true
    implicitHeight: 64
    radius: theme.radiusMD
    color: {
        if (root.highlighted) return theme.primarySoftColor;
        if (mouseArea.containsMouse) return Qt.rgba(theme.primaryColor.r, theme.primaryColor.g, theme.primaryColor.b, 0.06);
        return theme.surfaceColor;
    }

    Behavior on color { ColorAnimation { duration: theme.durationShort } }

    RowLayout {
        anchors.fill: parent
        anchors.margins: theme.spacingMD
        spacing: theme.spacingMD

        // Type badge
        Rectangle {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            radius: theme.radiusSM
            color: root.highlighted ? theme.primaryColor : theme.backgroundColor

            Text {
                anchors.centerIn: parent
                text: root.iconText
                color: root.highlighted ? theme.textOnPrimary : theme.textSecondary
                font.family: theme.fontFamily
                font.pixelSize: theme.labelSize
                font.weight: theme.fontWeightBold
            }
        }

        // Content
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.title
                color: root.highlighted ? theme.primaryColor : theme.textPrimary
                font.family: theme.fontFamily
                font.pixelSize: theme.bodySize
                font.weight: theme.fontWeightMedium
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                visible: root.subtitle.length > 0
                text: root.subtitle
                color: theme.textSecondary
                font.family: theme.fontFamily
                font.pixelSize: theme.bodySmallSize
                elide: Text.ElideRight
            }
        }

        // Trailing text
        Text {
            visible: root.trailingText.length > 0
            text: root.trailingText
            color: theme.textTertiary
            font.family: theme.fontFamily
            font.pixelSize: theme.bodySmallSize
        }

        // Copy button
        Rectangle {
            visible: root.showCopyButton
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            radius: theme.radiusSM
            color: mouseArea.containsMouse ? theme.surfaceColor : theme.backgroundColor

            Text {
                anchors.centerIn: parent
                text: "\uD83D\uDCCB"
                font.pixelSize: 14
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.copyRequested()
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (root.clickable) root.clicked()
        }
    }
}
