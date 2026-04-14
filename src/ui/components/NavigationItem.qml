// src/ui/components/NavigationItem.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property QtObject theme
    required property string title
    required property string badgeText
    required property int pageIndex
    required property int currentIndex

    signal triggered(int pageIndex)

    implicitHeight: 56
    focus: true
    Accessible.role: Accessible.Button
    Accessible.name: title

    readonly property bool selected: currentIndex === pageIndex

    Rectangle {
        anchors.fill: parent
        radius: root.theme.radiusLG
        color: root.selected ? root.theme.primarySoftColor : (mouseArea.containsMouse ? root.theme.surfaceColor : "transparent")

        Behavior on color {
            ColorAnimation {
                duration: root.theme.durationShort
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: root.theme.spacingMD
        anchors.rightMargin: root.theme.spacingMD
        spacing: root.theme.spacingMD

        Rectangle {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            radius: root.theme.radiusMD
            color: root.selected ? root.theme.primaryColor : root.theme.surfaceColor

            Text {
                anchors.centerIn: parent
                text: root.badgeText
                color: root.selected ? "#FFFFFF" : root.theme.textSecondary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSizeSM
                font.weight: root.theme.fontWeightBold
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.title
            color: root.selected ? root.theme.primaryColor : root.theme.textPrimary
            font.family: root.theme.fontFamily
            font.pixelSize: root.theme.fontSizeBase
            font.weight: root.selected ? root.theme.fontWeightSemibold : root.theme.fontWeightMedium
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.triggered(root.pageIndex)
    }

    Keys.onReturnPressed: root.triggered(root.pageIndex)
    Keys.onEnterPressed: root.triggered(root.pageIndex)
    Keys.onSpacePressed: root.triggered(root.pageIndex)
}
