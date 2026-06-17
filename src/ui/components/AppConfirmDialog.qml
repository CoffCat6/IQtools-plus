// src/ui/components/AppConfirmDialog.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

Popup {
    id: root

    required property QtObject theme
    property string title: qsTr("确认")
    property string message: ""
    property string confirmText: qsTr("确定")
    property string cancelText: qsTr("取消")
    property string type: "confirm"    // confirm | danger | info

    signal confirmed()
    signal cancelled()

    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 0
    width: 420
    height: contentLayout.implicitHeight + theme.spacingLG * 2

    function openDialog(titleText, msg, onConfirm) {
        root.title = titleText;
        root.message = msg;
        root._callback = onConfirm;
        root.open();
    }

    property var _callback: null

    Component.onCompleted: {
        root.confirmed.connect(function() {
            if (root._callback) root._callback();
            root._callback = null;
        });
    }

    x: (parent ? parent.width / 2 - width / 2 : 0)
    y: (parent ? parent.height / 2 - height / 2 : 0)

    background: Rectangle {
        radius: theme.radiusXL
        color: theme.elevatedSurfaceColor
        border.width: 1
        border.color: theme.dividerColor
    }

    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.margins: theme.spacingLG
        spacing: theme.spacingLG

        Text {
            text: root.title
            color: theme.textPrimary
            font.family: theme.fontFamily
            font.pixelSize: theme.h3Size
            font.weight: theme.h3Weight
            Layout.fillWidth: true
        }

        Text {
            text: root.message
            color: theme.textSecondary
            font.family: theme.fontFamily
            font.pixelSize: theme.bodySize
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: theme.spacingMD
            Layout.alignment: Qt.AlignRight

            AppButton {
                theme: root.theme
                text: root.cancelText
                type: "secondary"
                size: "md"
                Layout.preferredWidth: 100
                onClicked: {
                    root.cancelled();
                    root.close();
                }
            }

            AppButton {
                theme: root.theme
                text: root.confirmText
                type: root.type === "danger" ? "danger" : "primary"
                size: "md"
                Layout.preferredWidth: 100
                onClicked: {
                    root.confirmed();
                    root.close();
                }
            }
        }
    }
}
