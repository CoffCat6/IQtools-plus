// src/ui/components/AppCheckbox.qml
import QtQuick
import QtQuick.Controls
import "../theme"

Item {
    id: root

    required property QtObject theme
    property string label: ""
    property bool checked: false
    property bool disabled: false

    signal toggled(bool checked)

    implicitWidth: checkRect.width + (labelText.visible ? labelText.width + theme.spacingSM : 0)
    implicitHeight: Math.max(checkRect.height, labelText.visible ? labelText.height : 20)

    Accessible.role: Accessible.CheckBox
    Accessible.name: label
    Accessible.checked: checked

    Row {
        spacing: theme.spacingSM

        Rectangle {
            id: checkRect
            width: 20
            height: 20
            radius: 4
            color: root.checked ? theme.primaryColor
                   : (mouseArea.containsMouse ? theme.hoverOverlay : theme.backgroundColor)
            border.width: root.checked ? 0 : 2
            border.color: root.disabled ? theme.disabledText : theme.dividerColor

            Behavior on color { ColorAnimation { duration: theme.durationShort } }

            Text {
                anchors.centerIn: parent
                visible: root.checked
                text: "\u2713"
                color: theme.textOnPrimary
                font.pixelSize: 12
                font.weight: Font.Bold
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                enabled: !root.disabled
                cursorShape: root.disabled ? Qt.ForbiddenCursor : Qt.PointingHandCursor
                onClicked: {
                    root.checked = !root.checked;
                    root.toggled(root.checked);
                }
            }
        }

        Text {
            id: labelText
            visible: root.label.length > 0
            text: root.label
            color: root.disabled ? theme.disabledText : theme.textPrimary
            font.family: theme.fontFamily
            font.pixelSize: theme.bodySize
            anchors.verticalCenter: parent.verticalCenter
            MouseArea {
                anchors.fill: parent
                enabled: !root.disabled
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.checked = !root.checked;
                    root.toggled(root.checked);
                }
            }
        }
    }
}
