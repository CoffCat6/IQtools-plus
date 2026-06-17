// src/ui/components/AppTextField.qml
import QtQuick
import QtQuick.Controls
import "../theme"

Column {
    id: root

    required property QtObject theme
    property string label: ""
    property string placeholderText: ""
    property string text: ""
    property alias value: textField.text
    property bool hasError: false
    property string errorMessage: ""
    property string helperText: ""
    property bool searchMode: false
    property bool clearable: true
    property bool multiline: false
    property int maxLength: 32767
    property alias readOnly: textField.readOnly
    property alias echoMode: textField.echoMode

    signal textEdited(string newText)
    signal searchSubmitted(string query)

    spacing: theme.spacingXS

    // Label
    Text {
        visible: root.label.length > 0 && !root.searchMode
        text: root.label
        color: root.hasError ? theme.errorColor : theme.textSecondary
        font.family: theme.fontFamily
        font.pixelSize: theme.labelSize
        font.weight: theme.labelWeight
        width: parent.width
    }

    Rectangle {
        id: container
        width: parent.width
        height: root.multiline ? Math.max(80, textArea.implicitHeight + theme.spacingMD * 2)
                               : (root.searchMode ? 40 : 36)
        radius: theme.radiusMD
        color: root.hasError ? theme.errorSoftColor
               : (textField.activeFocus ? theme.surfaceColor : theme.backgroundColor)
        border.width: root.hasError ? 2
                      : (textField.activeFocus ? 2 : 1)
        border.color: root.hasError ? theme.errorColor
                      : (textField.activeFocus ? theme.primaryColor : theme.dividerColor)

        Behavior on border.color { ColorAnimation { duration: theme.durationShort } }
        Behavior on color { ColorAnimation { duration: theme.durationShort } }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: theme.spacingMD
            anchors.rightMargin: theme.spacingSM
            spacing: theme.spacingSM

            // Search icon
            Text {
                visible: root.searchMode
                text: "\uD83D\uDD0D"
                font.pixelSize: 16
                Layout.alignment: Qt.AlignVCenter
            }

            TextInput {
                id: textField
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: TextInput.AlignVCenter
                clip: true
                visible: !root.multiline
                text: root.text
                color: root.hasError ? theme.errorColor : theme.textPrimary
                font.family: theme.fontFamily
                font.pixelSize: theme.bodySize
                echoMode: root.echoMode
                readOnly: root.readOnly
                maximumLength: root.maxLength
                activeFocusOnTab: true

                Text {
                    visible: textField.text.length === 0 && !textField.activeFocus
                    text: root.placeholderText
                    color: theme.textTertiary
                    font: textField.font
                }

                onTextEdited: function(newText) {
                    root.textEdited(newText);
                }
                onAccepted: {
                    if (root.searchMode) root.searchSubmitted(text);
                }
                Keys.onEscapePressed: {
                    textField.text = "";
                    root.textEdited("");
                }
            }

            // Multiline mode
            TextArea.flickable: TextArea {
                id: textArea
                visible: root.multiline
                text: root.text
                color: root.hasError ? theme.errorColor : theme.textPrimary
                font.family: theme.fontFamily
                font.pixelSize: theme.bodySize
                wrapMode: TextEdit.Wrap
                selectByMouse: true
                activeFocusOnTab: true
                maximumLength: root.maxLength

                Text {
                    visible: textArea.text.length === 0 && !textArea.activeFocus
                    text: root.placeholderText
                    color: theme.textTertiary
                    font: textArea.font
                    anchors.fill: parent
                    anchors.margins: 4
                }

                onTextChanged: {
                    root.textEdited(text);
                }
                background: Rectangle {
                    radius: theme.radiusMD
                    color: "transparent"
                }
            }

            // Clear button
            Text {
                visible: root.clearable && textField.text.length > 0 && !root.multiline
                text: "\u2715"
                font.pixelSize: 12
                color: theme.textTertiary
                Layout.alignment: Qt.AlignVCenter

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        textField.text = "";
                        textField.forceActiveFocus();
                        root.textEdited("");
                    }
                }
            }
        }
    }

    // Error / Helper text
    Text {
        visible: root.errorMessage.length > 0 || root.helperText.length > 0
        text: root.hasError ? root.errorMessage : root.helperText
        color: root.hasError ? theme.errorColor : theme.textTertiary
        font.family: theme.fontFamily
        font.pixelSize: theme.captionSize
        font.weight: theme.captionWeight
        width: parent.width
        wrapMode: Text.WordWrap
    }
}
