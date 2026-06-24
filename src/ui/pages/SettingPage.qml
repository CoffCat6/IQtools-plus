// src/ui/pages/SettingPage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../theme"

AppPage {
    id: root

    required property QtObject viewModel
    property QtObject toast: null
    objectName: "settingPage"

    property int currentCategory: 0

    ListModel {
        id: categoryModel
        ListElement { name: "通用"; icon: "G"; index: 0 }
        ListElement { name: "截图"; icon: "S"; index: 1 }
        ListElement { name: "翻译"; icon: "T"; index: 2 }
        ListElement { name: "剪贴板"; icon: "C"; index: 3 }
        ListElement { name: "高级"; icon: "A"; index: 4 }
        ListElement { name: "关于"; icon: "I"; index: 5 }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 0

        // Left category nav
        Rectangle {
            Layout.preferredWidth: Math.min(200, root.width * 0.22)
            Layout.fillHeight: true
            color: root.theme.sidebarColor
            radius: root.theme.radiusMD

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: root.theme.spacingSM
                spacing: root.theme.spacingXS

                ListView {
                    id: categoryList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: categoryModel
                    spacing: root.theme.spacingXS
                    clip: true

                    delegate: Rectangle {
                        id: categoryItem
                        required property var model

                        width: categoryList.width
                        height: 44
                        radius: root.theme.radiusMD
                        color: root.currentCategory === model.index
                               ? root.theme.primarySoftColor
                               : (hoverArea.containsMouse ? root.theme.surfaceColor : "transparent")

                        Behavior on color {
                            ColorAnimation { duration: root.theme.durationShort }
                        }

                        Rectangle {
                            visible: root.currentCategory === model.index
                            width: 3
                            height: parent.height * 0.4
                            anchors.left: parent.left
                            anchors.leftMargin: root.theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter
                            radius: 1.5
                            color: root.theme.primaryColor
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: root.theme.spacingMD
                            anchors.rightMargin: root.theme.spacingMD
                            spacing: root.theme.spacingMD

                            Rectangle {
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 28
                                radius: root.theme.radiusSM
                                color: root.currentCategory === model.index
                                       ? root.theme.primaryColor
                                       : root.theme.surfaceColor

                                Text {
                                    anchors.centerIn: parent
                                    text: model.icon
                                    color: root.currentCategory === model.index
                                           ? root.theme.textOnPrimary
                                           : root.theme.textSecondary
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.fontSizeSM
                                    font.weight: root.theme.fontWeightBold
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: model.name
                                color: root.currentCategory === model.index
                                       ? root.theme.textPrimary
                                       : root.theme.textSecondary
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSizeBase
                                font.weight: root.currentCategory === model.index
                                             ? root.theme.fontWeightMedium
                                             : root.theme.fontWeightNormal
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: hoverArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.currentCategory = model.index
                        }
                    }
                }
            }
        }

        // Right content area
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"

            ScrollView {
                anchors {
                    fill: parent
                    leftMargin: root.theme.spacingXL
                }
                contentWidth: availableWidth
                clip: true

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                ColumnLayout {
                    width: parent.width
                    spacing: root.theme.spacingXL

                    // ── General ──
                    ColumnLayout {
                        visible: root.currentCategory === 0
                        Layout.fillWidth: true
                        spacing: root.theme.spacingLG

                        Text {
                            text: qsTr("通用设置")
                            color: root.theme.textPrimary
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.h2Size
                            font.weight: root.theme.h2Weight
                        }

                        Rectangle {
                            Layout.fillWidth: true; height: 1; color: root.theme.dividerColor
                        }

                        // Theme settings
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: themeContent.implicitHeight + root.theme.spacingLG * 2
                            color: root.theme.surfaceColor
                            radius: root.theme.radiusLG

                            ColumnLayout {
                                id: themeContent
                                anchors {
                                    left: parent.left; right: parent.right
                                    top: parent.top; margins: root.theme.spacingLG
                                }
                                spacing: root.theme.spacingLG

                                Text {
                                    text: qsTr("外观")
                                    color: root.theme.textPrimary
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.h3Size
                                    font.weight: root.theme.h3Weight
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: root.theme.spacingMD

                                    // Light
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: root.theme.spacingMD

                                        Rectangle {
                                            width: 20; height: 20; radius: 10
                                            border.width: 2
                                            border.color: root.viewModel.settingViewModel.themeMode === 0 ? root.theme.primaryColor : root.theme.dividerColor
                                            color: "transparent"

                                            Rectangle {
                                                visible: root.viewModel.settingViewModel.themeMode === 0
                                                width: 12; height: 12; radius: 6
                                                anchors.centerIn: parent
                                                color: root.theme.primaryColor
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    root.viewModel.settingViewModel.themeMode = 0
                                                    if (root.toast) root.toast.show(qsTr("已切换到浅色模式"), "success")
                                                }
                                            }
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: qsTr("浅色模式")
                                            color: root.theme.textSecondary
                                            font.family: root.theme.fontFamily
                                            font.pixelSize: root.theme.fontSizeBase
                                        }
                                    }

                                    // Dark
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: root.theme.spacingMD

                                        Rectangle {
                                            width: 20; height: 20; radius: 10
                                            border.width: 2
                                            border.color: root.viewModel.settingViewModel.themeMode === 1 ? root.theme.primaryColor : root.theme.dividerColor
                                            color: "transparent"

                                            Rectangle {
                                                visible: root.viewModel.settingViewModel.themeMode === 1
                                                width: 12; height: 12; radius: 6
                                                anchors.centerIn: parent
                                                color: root.theme.primaryColor
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    root.viewModel.settingViewModel.themeMode = 1
                                                    if (root.toast) root.toast.show(qsTr("已切换到暗黑模式"), "success")
                                                }
                                            }
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: qsTr("暗黑模式")
                                            color: root.theme.textSecondary
                                            font.family: root.theme.fontFamily
                                            font.pixelSize: root.theme.fontSizeBase
                                        }
                                    }

                                    // Follow System
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: root.theme.spacingMD

                                        Rectangle {
                                            width: 20; height: 20; radius: 10
                                            border.width: 2
                                            border.color: root.viewModel.settingViewModel.themeMode === 2 ? root.theme.primaryColor : root.theme.dividerColor
                                            color: "transparent"

                                            Rectangle {
                                                visible: root.viewModel.settingViewModel.themeMode === 2
                                                width: 12; height: 12; radius: 6
                                                anchors.centerIn: parent
                                                color: root.theme.primaryColor
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    root.viewModel.settingViewModel.themeMode = 2
                                                    if (root.toast) root.toast.show(qsTr("已切换为跟随系统主题"), "success")
                                                }
                                            }
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: qsTr("跟随系统")
                                            color: root.theme.textSecondary
                                            font.family: root.theme.fontFamily
                                            font.pixelSize: root.theme.fontSizeBase
                                        }
                                    }
                                }
                            }
                        }

                        // Language settings
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: langContent.implicitHeight + root.theme.spacingLG * 2
                            color: root.theme.surfaceColor
                            radius: root.theme.radiusLG

                            ColumnLayout {
                                id: langContent
                                anchors {
                                    left: parent.left; right: parent.right
                                    top: parent.top; margins: root.theme.spacingLG
                                }
                                spacing: root.theme.spacingLG

                                Text {
                                    text: qsTr("语言")
                                    color: root.theme.textPrimary
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.h3Size
                                    font.weight: root.theme.h3Weight
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: root.theme.spacingMD

                                    Text {
                                        Layout.fillWidth: true
                                        text: qsTr("语言选择")
                                        color: root.theme.textSecondary
                                        font.family: root.theme.fontFamily
                                        font.pixelSize: root.theme.fontSizeBase
                                    }

                                    AppComboBox {
                                        theme: root.theme
                                        Layout.preferredWidth: 180
                                        model: [
                                            { text: qsTr("简体中文"), value: "zh_CN" },
                                            { text: qsTr("English"), value: "en_US" },
                                            { text: qsTr("日本語"), value: "ja_JP" },
                                            { text: qsTr("한국어"), value: "ko_KR" }
                                        ]
                                        displayField: "text"
                                        currentIndex: {
                                            const lang = root.viewModel.settingViewModel.language
                                            for (let i = 0; i < model.length; ++i) {
                                                if (model[i].value === lang) return i
                                            }
                                            return 0
                                        }
                                        onActivated: function(index) {
                                            root.viewModel.settingViewModel.language = model[index].value
                                            if (root.toast) root.toast.show(qsTr("语言设置将在重启后生效"), "info")
                                        }
                                    }
                                }
                            }
                        }

                        Item { Layout.fillHeight: true }
                    }

                    // ── 截图设置 (placeholder) ──
                    ColumnLayout {
                        visible: root.currentCategory === 1
                        Layout.fillWidth: true
                        spacing: root.theme.spacingLG
                        Text {
                            text: qsTr("截图设置")
                            color: root.theme.textPrimary; font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.h2Size; font.weight: root.theme.h2Weight
                        }
                        Rectangle { Layout.fillWidth: true; height: 1; color: root.theme.dividerColor }
                        Rectangle {
                            Layout.fillWidth: true; implicitHeight: 100
                            color: root.theme.surfaceColor; radius: root.theme.radiusLG
                            Text {
                                anchors.centerIn: parent
                                text: qsTr("截图设置将在后续实现...")
                                color: root.theme.textSecondary; font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSizeBase
                            }
                        }
                        Item { Layout.fillHeight: true }
                    }

                    // ── 翻译设置 ──
                    ColumnLayout {
                        visible: root.currentCategory === 2
                        Layout.fillWidth: true
                        spacing: root.theme.spacingLG
                        Text {
                            text: qsTr("翻译设置")
                            color: root.theme.textPrimary; font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.h2Size; font.weight: root.theme.h2Weight
                        }
                        Rectangle { Layout.fillWidth: true; height: 1; color: root.theme.dividerColor }
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: translateContent.implicitHeight + root.theme.spacingLG * 2
                            color: root.theme.surfaceColor; radius: root.theme.radiusLG

                            ColumnLayout {
                                id: translateContent
                                anchors {
                                    left: parent.left; right: parent.right
                                    top: parent.top; margins: root.theme.spacingLG
                                }
                                spacing: root.theme.spacingLG

                                Text {
                                    text: qsTr("翻译引擎")
                                    color: root.theme.textPrimary
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.h3Size
                                    font.weight: root.theme.h3Weight
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: root.theme.spacingMD

                                    Text {
                                        Layout.fillWidth: true
                                        text: qsTr("默认引擎")
                                        color: root.theme.textSecondary
                                        font.family: root.theme.fontFamily
                                        font.pixelSize: root.theme.fontSizeBase
                                    }

                                    AppComboBox {
                                        theme: root.theme
                                        Layout.preferredWidth: 180
                                        model: root.viewModel.settingViewModel.availableEngines
                                        currentIndex: {
                                            const idx = model.indexOf(root.viewModel.settingViewModel.translateEngine)
                                            return idx >= 0 ? idx : 0
                                        }
                                        onActivated: function(index) {
                                            root.viewModel.settingViewModel.translateEngine = model[index]
                                            if (root.toast) root.toast.show(qsTr("默认翻译引擎已更新"), "success")
                                        }
                                    }
                                }
                            }
                        }
                        Item { Layout.fillHeight: true }
                    }

                    // ── 剪贴板设置 (placeholder) ──
                    ColumnLayout {
                        visible: root.currentCategory === 3
                        Layout.fillWidth: true
                        spacing: root.theme.spacingLG
                        Text {
                            text: qsTr("剪贴板设置")
                            color: root.theme.textPrimary; font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.h2Size; font.weight: root.theme.h2Weight
                        }
                        Rectangle { Layout.fillWidth: true; height: 1; color: root.theme.dividerColor }
                        Rectangle {
                            Layout.fillWidth: true; implicitHeight: 100
                            color: root.theme.surfaceColor; radius: root.theme.radiusLG
                            Text {
                                anchors.centerIn: parent
                                text: qsTr("剪贴板设置将在后续实现...")
                                color: root.theme.textSecondary; font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSizeBase
                            }
                        }
                        Item { Layout.fillHeight: true }
                    }

                    // ── 高级设置：日志面板 ──
                    ColumnLayout {
                        visible: root.currentCategory === 4
                        Layout.fillWidth: true
                        spacing: root.theme.spacingLG

                        Text {
                            text: qsTr("高级设置")
                            color: root.theme.textPrimary
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.h2Size
                            font.weight: root.theme.h2Weight
                        }

                        Rectangle { Layout.fillWidth: true; height: 1; color: root.theme.dividerColor }

                        // ── 日志级别控制 ──
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: levelContent.implicitHeight + root.theme.spacingLG * 2
                            color: root.theme.surfaceColor
                            radius: root.theme.radiusLG

                            ColumnLayout {
                                id: levelContent
                                anchors {
                                    left: parent.left; right: parent.right
                                    top: parent.top; margins: root.theme.spacingLG
                                }
                                spacing: root.theme.spacingMD

                                Text {
                                    text: qsTr("日志级别")
                                    color: root.theme.textPrimary
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.h3Size
                                    font.weight: root.theme.h3Weight
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: root.theme.spacingMD

                                    Text {
                                        text: qsTr("控制台")
                                        color: root.theme.textSecondary
                                        font.family: root.theme.fontFamily
                                        font.pixelSize: root.theme.fontSizeBase
                                    }

                                    AppComboBox {
                                        id: consoleLevelCombo
                                        theme: root.theme
                                        Layout.preferredWidth: 140
                                        model: ["Trace", "Debug", "Info", "Warn", "Error", "Critical", "Off"]
                                        currentIndex: root.viewModel.logViewModel.consoleLevel
                                        onActivated: function(idx) {
                                            root.viewModel.logViewModel.consoleLevel = idx
                                            if (root.toast) root.toast.show(qsTr("控制台日志级别已更新"), "success")
                                        }
                                    }

                                    Text {
                                        text: qsTr("文件")
                                        color: root.theme.textSecondary
                                        font.family: root.theme.fontFamily
                                        font.pixelSize: root.theme.fontSizeBase
                                    }

                                    AppComboBox {
                                        id: fileLevelCombo
                                        theme: root.theme
                                        Layout.preferredWidth: 140
                                        model: ["Trace", "Debug", "Info", "Warn", "Error", "Critical", "Off"]
                                        currentIndex: root.viewModel.logViewModel.fileLevel
                                        onActivated: function(idx) {
                                            root.viewModel.logViewModel.fileLevel = idx
                                            if (root.toast) root.toast.show(qsTr("文件日志级别已更新"), "success")
                                        }
                                    }

                                    Item { Layout.fillWidth: true }
                                }

                                Text {
                                    text: qsTr("日志目录: %1").arg(root.viewModel.logViewModel.logDirectory)
                                    color: root.theme.textSecondary
                                    font.family: root.theme.fontFamily
                                    font.pixelSize: root.theme.fontSizeSM
                                    elide: Text.ElideMiddle
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        // ── 实时日志 ──
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: root.theme.surfaceColor
                            radius: root.theme.radiusLG

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: root.theme.spacingLG
                                spacing: root.theme.spacingMD

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: root.theme.spacingMD

                                    Text {
                                        text: qsTr("实时日志")
                                        color: root.theme.textPrimary
                                        font.family: root.theme.fontFamily
                                        font.pixelSize: root.theme.h3Size
                                        font.weight: root.theme.h3Weight
                                    }

                                    Item { Layout.fillWidth: true }

                                    // 过滤级别
                                    Text {
                                        text: qsTr("显示 ≥")
                                        color: root.theme.textSecondary
                                        font.family: root.theme.fontFamily
                                        font.pixelSize: root.theme.fontSizeSM
                                    }

                                    AppComboBox {
                                        id: filterCombo
                                        theme: root.theme
                                        Layout.preferredWidth: 110
                                        model: ["Trace", "Debug", "Info", "Warn", "Error", "Critical"]
                                        currentIndex: root.viewModel.logViewModel.filterLevel
                                        onActivated: function(idx) {
                                            root.viewModel.logViewModel.filterLevel = idx
                                        }
                                    }

                                    // 复制全部
                                    AppButton {
                                        text: qsTr("复制")
                                        theme: root.theme
                                        type: "text"
                                        fullWidth: false
                                        onClicked: {
                                            root.viewModel.logViewModel.copyAll()
                                            if (root.toast) root.toast.show(qsTr("已复制到剪贴板"), "success")
                                        }
                                    }

                                    // 清空
                                    AppButton {
                                        text: qsTr("清空")
                                        theme: root.theme
                                        type: "text"
                                        fullWidth: false
                                        onClicked: root.viewModel.logViewModel.clear()
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true; height: 1; color: root.theme.dividerColor
                                }

                                // 日志列表
                                ListView {
                                    id: logListView
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    clip: true
                                    model: root.viewModel.logViewModel.entries

                                    // 自动滚动到底部
                                    onCountChanged: {
                                        if (logViewAtEnd) {
                                            Qt.callLater(function() {
                                                logListView.positionViewAtEnd()
                                            })
                                        }
                                    }

                                    property bool logViewAtEnd: true
                                    onContentYChanged: {
                                        logViewAtEnd = (contentY + height >= contentHeight - 50)
                                    }

                                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                                    delegate: Rectangle {
                                        id: logDelegate
                                        required property var modelData
                                        required property int index
                                        width: logListView.width
                                        height: logText.implicitHeight + 4
                                        color: "transparent"

                                        Text {
                                            id: logText
                                            anchors {
                                                left: parent.left; right: parent.right
                                                verticalCenter: parent.verticalCenter
                                                margins: root.theme.spacingXS
                                            }
                                            text: modelData.msg || ""
                                            color: {
                                                var lvl = modelData.level || 0
                                                if (lvl >= 4) return "#EF4444"  // error/critical → red
                                                if (lvl >= 3) return "#F59E0B"  // warn → amber
                                                if (lvl >= 2) return root.theme.textPrimary  // info
                                                return root.theme.textSecondary   // debug/trace
                                            }
                                            font.family: "Consolas, 'Courier New', monospace"
                                            font.pixelSize: root.theme.fontSizeSM
                                            wrapMode: Text.NoWrap
                                            elide: Text.ElideRight
                                        }
                                    }

                                    // 空状态
                                    Text {
                                        anchors.centerIn: parent
                                        visible: logListView.count === 0
                                        text: qsTr("暂无日志")
                                        color: root.theme.textSecondary
                                        font.family: root.theme.fontFamily
                                        font.pixelSize: root.theme.fontSizeBase
                                    }
                                }
                            }
                        }
                    }

                    // ── 关于 (placeholder) ──
                    ColumnLayout {
                        visible: root.currentCategory === 5
                        Layout.fillWidth: true
                        spacing: root.theme.spacingLG
                        Text {
                            text: qsTr("关于")
                            color: root.theme.textPrimary; font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.h2Size; font.weight: root.theme.h2Weight
                        }
                        Rectangle { Layout.fillWidth: true; height: 1; color: root.theme.dividerColor }
                        Rectangle {
                            Layout.fillWidth: true; implicitHeight: 100
                            color: root.theme.surfaceColor; radius: root.theme.radiusLG
                            Text {
                                anchors.centerIn: parent
                                text: qsTr("关于将在后续实现...")
                                color: root.theme.textSecondary; font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSizeBase
                            }
                        }
                        Item { Layout.fillHeight: true }
                    }

                    Item { Layout.fillHeight: true }
                }
            }
        }
    }
}
