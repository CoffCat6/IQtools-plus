// src/ui/components/AppPage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

// Base page template providing standard ScrollView + ColumnLayout skeleton
Item {
    id: root

    required property QtObject theme
    property alias scrollView: scrollView
    property alias contentLayout: contentLayout
    property alias contentWidth: scrollView.contentWidth

    // Override in sub-pages to add content
    default property alias pageContent: contentLayout.data

    ScrollView {
        id: scrollView
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            width: 6
            background: Rectangle {
                color: "transparent"
            }
            contentItem: Rectangle {
                implicitWidth: 6
                radius: 3
                color: root.theme.textTertiary
                opacity: 0.5
            }
        }

        ColumnLayout {
            id: contentLayout
            width: scrollView.availableWidth
            spacing: root.theme.spacingLG
        }
    }
}
