// src/ui/components/AppComboBox.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Item {
    id: root

    required property QtObject theme
    property var model: []          // array of strings or objects
    property string displayField: "" // field name if model is list of objects
    property int currentIndex: 0
    property string placeholderText: qsTr("请选择")
    property bool hasError: false
    property real maxPopupHeight: 260
    property alias popup: popup

    signal activated(int index)

    implicitWidth: 180
    implicitHeight: 36

    Accessible.role: Accessible.ComboBox

    Rectangle {
        id: trigger
        anchors.fill: parent
        radius: theme.radiusMD
        color: mouseArea.containsMouse ? theme.hoverOverlay : theme.backgroundColor
        border.width: root.hasError ? 2 : (popup.opened ? 2 : 1)
        border.color: root.hasError ? theme.errorColor
                      : (popup.opened ? theme.primaryColor : theme.dividerColor)

        Behavior on border.color { ColorAnimation { duration: theme.durationShort } }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: theme.spacingMD
            anchors.rightMargin: theme.spacingSM
            spacing: theme.spacingSM

            Text {
                Layout.fillWidth: true
                text: {
                    if (root.model.length === 0) return root.placeholderText;
                    const item = root.model[root.currentIndex];
                    if (typeof item === "string") return item;
                    if (root.displayField && item && item[root.displayField] !== undefined)
                        return item[root.displayField];
                    return String(item);
                }
                color: root.model.length === 0 ? theme.textTertiary : theme.textPrimary
                font.family: theme.fontFamily
                font.pixelSize: theme.bodySize
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                text: "\u25BE"
                font.pixelSize: 14
                color: theme.textSecondary
                rotation: popup.opened ? 180 : 0
                Behavior on rotation { NumberAnimation { duration: theme.durationShort } }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (popup.opened) popup.close();
                else popup.open();
            }
        }
    }

    Popup {
        id: popup
        y: trigger.height + 4
        width: trigger.width
        height: Math.min(listView.contentHeight, root.maxPopupHeight) + theme.spacingMD
        padding: 4
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            radius: theme.radiusMD
            color: theme.elevatedSurfaceColor
            border.width: 1
            border.color: theme.dividerColor
            layer.enabled: true
            layer.effect: null  // plain shadow via layered approach
        }

        contentItem: ListView {
            id: listView
            clip: true
            model: root.model
            spacing: 2

            delegate: Rectangle {
                id: itemDelegate
                required property int index
                required property var modelData
                width: listView.width
                height: 34
                radius: theme.radiusSM
                color: index === root.currentIndex ? theme.primarySoftColor
                       : (hoverArea.containsMouse ? theme.hoverOverlay : "transparent")

                Behavior on color { ColorAnimation { duration: theme.durationShort } }

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: theme.spacingMD
                    anchors.rightMargin: theme.spacingMD
                    verticalAlignment: Text.AlignVCenter
                    text: {
                        const item = itemDelegate.modelData;
                        if (typeof item === "string") return item;
                        if (root.displayField && item && item[displayField] !== undefined)
                            return item[displayField];
                        return String(item);
                    }
                    color: index === root.currentIndex ? theme.primaryColor : theme.textPrimary
                    font.family: theme.fontFamily
                    font.pixelSize: theme.bodySize
                    font.weight: index === root.currentIndex ? theme.fontWeightSemibold : theme.fontWeightNormal
                    elide: Text.ElideRight
                }

                MouseArea {
                    id: hoverArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.currentIndex = index;
                        popup.close();
                        root.activated(index);
                    }
                }
            }
        }
    }
}
