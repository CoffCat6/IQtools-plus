// src/ui/components/SoftCard.qml
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property QtObject theme
    default property alias contentData: contentLayout.data

    property int padding: theme.spacingLG
    property bool hoverable: false
    property bool clickable: false
    property bool highlighted: false

    signal clicked()

    implicitWidth: Math.max(120, contentLayout.implicitWidth + padding * 2)
    implicitHeight: contentLayout.implicitHeight + padding * 2

    property bool hovered: mouseArea.containsMouse
    property real cardOffset: (hoverable || clickable) && hovered ? -2 : 0

    Rectangle {
        id: shadowLayer
        anchors.fill: backgroundRect
        anchors.topMargin: 6
        anchors.leftMargin: 2
        anchors.rightMargin: -2
        anchors.bottomMargin: -6
        radius: backgroundRect.radius + 2
        color: root.theme.shadow((hoverable || clickable) && hovered ? 3 : 2)

        Behavior on color {
            ColorAnimation {
                duration: root.theme.durationBase
            }
        }
    }

    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        y: root.cardOffset
        color: root.highlighted ? root.theme.primarySoftColor : root.theme.surfaceColor
        radius: root.theme.radiusLG

        Behavior on y {
            NumberAnimation {
                duration: root.theme.durationBase
                easing.type: Easing.OutCubic
            }
        }
    }

    ColumnLayout {
        id: contentLayout
        anchors.fill: backgroundRect
        anchors.margins: root.padding
        spacing: root.theme.spacingMD
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.hoverable || root.clickable
        hoverEnabled: root.hoverable || root.clickable
        cursorShape: (root.hoverable || root.clickable) ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (root.clickable) root.clicked()
        }
    }
}
