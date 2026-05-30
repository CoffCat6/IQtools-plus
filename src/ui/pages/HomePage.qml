// src/ui/pages/HomePage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root

    required property QtObject theme
    required property QtObject viewModel
    property var navigateTo: function(index) {}

    objectName: "homePage"

    // 搜索状态
    property string searchQuery: ""

    function matchesQuery(title, description) {
        if (root.searchQuery.length === 0) return true
        const q = root.searchQuery.toLowerCase()
        return title.toLowerCase().includes(q) || description.toLowerCase().includes(q)
    }

    // 是否有搜索结果（根据当前 query 实时计算）
    property bool hasSearchResults: {
        if (searchQuery.length === 0) return true
        return matchesQuery(qsTr("翻译"), qsTr("多引擎翻译、语言切换"))
            || matchesQuery(qsTr("剪贴板"), qsTr("历史记录、搜索过滤"))
            || matchesQuery(qsTr("截图"), qsTr("区域截图、延时截图"))
            || matchesQuery(qsTr("待办"), qsTr("任务管理与工作计划"))
            || matchesQuery(qsTr("计算器"), qsTr("科学计算、单位换算"))
            || matchesQuery(qsTr("颜色拾取"), qsTr("屏幕取色、色值转换"))
            || matchesQuery(qsTr("JSON 工具"), qsTr("格式化、校验、树形预览"))
            || matchesQuery(qsTr("编码转换"), qsTr("Base64、URL 编解码"))
            || matchesQuery(qsTr("密码生成"), qsTr("强度可选、一键复制"))
            || matchesQuery(qsTr("OCR 识别"), qsTr("图片文字识别"))
            || matchesQuery(qsTr("二维码"), qsTr("生成与识别二维码"))
            || matchesQuery(qsTr("Markdown"), qsTr("编写与实时渲染"))
    }

    RowLayout {
        anchors.fill: parent
        spacing: root.theme.spacingLG

        // ── 左侧主内容区 ───────────────────────────────────────────
        ScrollView {
            id: leftScroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            clip: true

            ColumnLayout {
                width: leftScroll.availableWidth
                spacing: root.theme.spacingLG

                // ── 搜索框 ──────────────────────────────────────────────
                SoftCard {
                    theme: root.theme
                    Layout.fillWidth: true
                    Layout.preferredHeight: 72
                    padding: root.theme.spacingSM

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: root.theme.spacingSM

                        Text {
                            text: "\uD83D\uDD0D"
                            font.pixelSize: 18
                        }

                        TextField {
                            id: searchField
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            placeholderText: qsTr("搜索功能、设置、页面…")
                            color: root.theme.textPrimary
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.fontSizeBase

                            background: Rectangle {
                                radius: root.theme.radiusMD
                                color: "transparent"
                            }

                            onTextChanged: {
                                root.searchQuery = text
                            }
                        }

                        // 清空按钮
                        Text {
                            visible: root.searchQuery.length > 0
                            text: "\u2715"
                            font.pixelSize: 14
                            color: root.theme.textTertiary
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    searchField.clear()
                                    searchField.forceActiveFocus()
                                }
                            }
                        }
                    }
                }

                // ── 快捷功能 ─────────────────────────────────────────────
                Text {
                    text: qsTr("快捷功能")
                    color: root.theme.textPrimary
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeLG
                    font.weight: root.theme.fontWeightSemibold
                    visible: root.searchQuery.length === 0 || root.hasSearchResults
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 4
                    columnSpacing: root.theme.spacingMD
                    rowSpacing: root.theme.spacingMD

                    ShortcutCard {
                        theme: root.theme
                        Layout.fillWidth: true
                        icon: "\uD83C\uDF10"
                        title: qsTr("翻译")
                        description: qsTr("多引擎翻译、语言切换")
                        visible: root.matchesQuery(title, description)
                        onClicked: root.navigateTo(1)
                    }
                    ShortcutCard {
                        theme: root.theme
                        Layout.fillWidth: true
                        icon: "\uD83D\uDCCB"
                        title: qsTr("剪贴板")
                        description: qsTr("历史记录、搜索过滤")
                        visible: root.matchesQuery(title, description)
                        onClicked: root.navigateTo(2)
                    }
                    ShortcutCard {
                        theme: root.theme
                        Layout.fillWidth: true
                        icon: "\uD83D\uDCF7"
                        title: qsTr("截图")
                        description: qsTr("区域截图、延时截图")
                        visible: root.matchesQuery(title, description)
                        onClicked: root.navigateTo(3)
                    }
                    ShortcutCard {
                        theme: root.theme
                        Layout.fillWidth: true
                        icon: "\u2713"
                        title: qsTr("待办")
                        description: qsTr("任务管理与工作计划")
                        visible: root.matchesQuery(title, description)
                        onClicked: root.navigateTo(4)
                    }
                }

                // ── 实用工具 ─────────────────────────────────────────────
                Text {
                    text: qsTr("实用工具")
                    color: root.theme.textPrimary
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeLG
                    font.weight: root.theme.fontWeightSemibold
                    visible: root.searchQuery.length === 0 || root.hasSearchResults
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 4
                    columnSpacing: root.theme.spacingMD
                    rowSpacing: root.theme.spacingMD

                    ShortcutCard {
                        theme: root.theme
                        Layout.fillWidth: true
                        icon: "\uD83D\uDD22"
                        title: qsTr("计算器")
                        description: qsTr("科学计算、单位换算")
                        comingSoon: true
                        visible: root.matchesQuery(title, description)
                    }
                    ShortcutCard {
                        theme: root.theme
                        Layout.fillWidth: true
                        icon: "\uD83C\uDFA8"
                        title: qsTr("颜色拾取")
                        description: qsTr("屏幕取色、色值转换")
                        comingSoon: true
                        visible: root.matchesQuery(title, description)
                    }
                    ShortcutCard {
                        theme: root.theme
                        Layout.fillWidth: true
                        icon: "{}"
                        title: qsTr("JSON 工具")
                        description: qsTr("格式化、校验、树形预览")
                        comingSoon: true
                        visible: root.matchesQuery(title, description)
                    }
                    ShortcutCard {
                        theme: root.theme
                        Layout.fillWidth: true
                        icon: "\uD83D\uDD10"
                        title: qsTr("编码转换")
                        description: qsTr("Base64、URL 编解码")
                        comingSoon: true
                        visible: root.matchesQuery(title, description)
                    }
                    ShortcutCard {
                        theme: root.theme
                        Layout.fillWidth: true
                        icon: "\uD83D\uDD11"
                        title: qsTr("密码生成")
                        description: qsTr("强度可选、一键复制")
                        comingSoon: true
                        visible: root.matchesQuery(title, description)
                    }
                    ShortcutCard {
                        theme: root.theme
                        Layout.fillWidth: true
                        icon: "\uD83D\uDCC4"
                        title: qsTr("OCR 识别")
                        description: qsTr("图片文字识别")
                        comingSoon: true
                        visible: root.matchesQuery(title, description)
                    }
                    ShortcutCard {
                        theme: root.theme
                        Layout.fillWidth: true
                        icon: "\u25A6"
                        title: qsTr("二维码")
                        description: qsTr("生成与识别二维码")
                        comingSoon: true
                        visible: root.matchesQuery(title, description)
                    }
                    ShortcutCard {
                        theme: root.theme
                        Layout.fillWidth: true
                        icon: "\uD83D\uDCDD"
                        title: qsTr("Markdown")
                        description: qsTr("编写与实时渲染")
                        comingSoon: true
                        visible: root.matchesQuery(title, description)
                    }
                }

                // ── 搜索无结果提示 ─────────────────────────────────────────
                SoftCard {
                    theme: root.theme
                    Layout.fillWidth: true
                    Layout.preferredHeight: 160
                    visible: root.searchQuery.length > 0 && !root.hasSearchResults

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: root.theme.spacingSM

                        Item { Layout.fillHeight: true }
                        Text {
                            text: "\uD83D\uDD0E"
                            font.pixelSize: 40
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: qsTr('未找到与 "%1" 相关的功能').arg(root.searchQuery)
                            color: root.theme.textSecondary
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.fontSizeLG
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: qsTr("换个关键词试试？")
                            color: root.theme.textTertiary
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.fontSizeBase
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Item { Layout.fillHeight: true }
                    }
                }

                // 底部间距
                Item {
                    Layout.preferredHeight: root.theme.spacingMD
                }
            }
        }

        // ── 右侧信息面板 ───────────────────────────────────────────
        ColumnLayout {
            Layout.preferredWidth: 220
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            spacing: root.theme.spacingMD
            visible: root.searchQuery.length === 0

            // 欢迎语
            SoftCard {
                theme: root.theme
                Layout.fillWidth: true
                Layout.preferredHeight: 80

                Text {
                    text: root.viewModel.welcomeMessage
                    color: root.theme.textPrimary
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeLG
                    font.weight: root.theme.fontWeightBold
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Text {
                    text: qsTr("选择功能开始使用")
                    color: root.theme.textSecondary
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeSM
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            // 当前时间
            SoftCard {
                theme: root.theme
                Layout.fillWidth: true
                Layout.preferredHeight: 100

                Text {
                    text: root.viewModel.currentDate
                    color: root.theme.textSecondary
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeSM
                    font.weight: root.theme.fontWeightSemibold
                }

                Text {
                    text: root.viewModel.currentTime
                    color: root.theme.textPrimary
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSize3XL
                    font.weight: root.theme.fontWeightBold
                }
            }

            // 天气（预留接口）
            SoftCard {
                theme: root.theme
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                hoverable: true

                RowLayout {
                    Layout.fillWidth: true
                    spacing: root.theme.spacingSM

                    Text {
                        text: root.viewModel.weatherIcon
                        font.pixelSize: 24
                    }

                    Text {
                        text: root.viewModel.weatherTemperature
                        color: root.theme.textPrimary
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSize2XL
                        font.weight: root.theme.fontWeightBold
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: root.viewModel.weatherCity
                        color: root.theme.textSecondary
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSizeSM
                    }
                }

                Text {
                    text: root.viewModel.weatherText
                    color: root.theme.textSecondary
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeBase
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.viewModel.refreshWeather(root.viewModel.weatherCity)
                }
            }

            // 版本与统计
            SoftCard {
                theme: root.theme
                Layout.fillWidth: true
                Layout.preferredHeight: 48

                RowLayout {
                    Layout.fillWidth: true
                    spacing: root.theme.spacingSM

                    Text {
                        text: qsTr("v")
                        color: root.theme.textTertiary
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSizeSM
                    }
                    Text {
                        text: root.viewModel.appVersion
                        color: root.theme.textPrimary
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSizeBase
                        font.weight: root.theme.fontWeightSemibold
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: root.viewModel.totalPagesText + " \u00B7 " + root.viewModel.totalToolsText
                        color: root.theme.textTertiary
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSizeSM
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
