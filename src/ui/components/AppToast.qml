// src/ui/components/AppToast.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Popup {
    id: root

    required property QtObject theme
    property string message: ""
    property string type: "info"       // success | warning | error | info
    property int duration: 3000
    property bool autoClose: true

    // Global singleton-like access: root.show(msg, type)
    function show(msg, toastType) {
        if (typeof toastType === "undefined") toastType = "info";
        root.type = toastType;
        root.message = msg;
        root.open();
        if (root.autoClose) {
            closeTimer.restart();
        }
    }

    x: (parent ? parent.width / 2 - width / 2 : 0)
    y: (parent ? parent.height - height - 60 : 0)
    padding: 0
    closePolicy: Popup.NoAutoClose
    modal: false

    Timer {
        id: closeTimer
        interval: root.duration
        onTriggered: root.close()
    }

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
        NumberAnimation { property: "y"; from: root.y + 20; to: root.y; duration: 300; easing.type: Easing.OutCubic }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200 }
        NumberAnimation { property: "y"; from: root.y; to: root.y + 20; duration: 200 }
    }

    background: Rectangle {
        radius: theme.radiusLG
        color: {
            switch (root.type) {
            case "success": return theme.successSoftColor;
            case "warning": return theme.warningSoftColor;
            case "error": return theme.errorSoftColor;
            default: return theme.infoSoftColor;
            }
        }
        border.width: 1
        border.color: {
            switch (root.type) {
            case "success": return theme.successColor;
            case "warning": return theme.warningColor;
            case "error": return theme.errorColor;
            default: return theme.infoColor;
            }
        }
    }

    contentItem: RowLayout {
        spacing: theme.spacingMD
        width: Math.min(400, root.parent ? root.parent.width * 0.6 : 400)

        Text {
            text: {
                switch (root.type) {
                case "success": return "\u2705";
                case "warning": return "\u26A0\uFE0F";
                case "error": return "\u274C";
                default: return "\u2139\uFE0F";
                }
            }
            font.pixelSize: 18
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: root.message
            color: {
                switch (root.type) {
                case "success": return theme.successColor;
                case "warning": return theme.warningColor;
                case "error": return theme.errorColor;
                default: return theme.infoColor;
                }
            }
            font.family: theme.fontFamily
            font.pixelSize: theme.bodySize
            font.weight: theme.fontWeightMedium
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: 320
        }

        Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            radius: theme.radiusSM
            color: "transparent"
            visible: true

            Text {
                anchors.centerIn: parent
                text: "\u2715"
                color: theme.textSecondary
                font.pixelSize: 12
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.close()
            }
        }
    }
}
