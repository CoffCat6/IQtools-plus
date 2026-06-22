// src/ui/pages/AIAssistantPage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../components"
import "../theme"

Item {
    id: root

    required property QtObject theme
    property QtObject toast: null
    property QtObject viewModel: null

    objectName: "aiAssistantPage"

    // 对话数据模型
    ListModel {
        id: conversationModel
    }

    // 上传的文件列表
    ListModel {
        id: uploadedFilesModel
    }

    // 文件选择对话框
    FileDialog {
        id: fileDialog
        onAccepted: {
            // 获取文件路径
            var filePath = selectedFile.toString().replace("file:///", "").replace(/\//g, "\\")
            var fileName = filePath.split("\\").pop()
            // 添加到已上传文件列表
            uploadedFilesModel.append({
                fileName: fileName,
                filePath: filePath,
                fileSize: "1.2 MB",  // 示例，实际需要从后端获取
                uploadTime: new Date().toLocaleTimeString(Qt.locale(), "hh:mm")
            })
            if (root.toast) {
                root.toast.show(qsTr("文件已上传: ") + fileName, "success")
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: root.theme.spacingLG

        // ── 主内容区：对话 + 文件上传 ────────────────────────────────────
        SplitView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            handle: Rectangle {
                implicitWidth: 6
                color: SplitHandle.hovered ? root.theme.primaryColor : "transparent"
                Rectangle {
                    anchors.centerIn: parent
                    width: 2
                    height: 24
                    radius: 1
                    color: SplitHandle.hovered ? "#ffffff" : root.theme.dividerColor
                }
            }

            // ── 左侧：对话区 ──────────────────────────────────────────
            ColumnLayout {
                SplitView.minimumWidth: 800
                Layout.preferredWidth: 1000
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: root.theme.spacingMD

                // 对话历史
                SoftCard {
                    theme: root.theme
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // 对话滚动区域
                    ScrollView {
                        id: conversationScroll
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: root.theme.spacingMD
                        clip: true

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }

                        ColumnLayout {
                            width: conversationScroll.availableWidth
                            spacing: root.theme.spacingMD
                            // 对话消息
                            Repeater {
                                model: conversationModel

                                delegate: ColumnLayout {
                                    required property int index
                                    required property var modelData

                                    Layout.fillWidth: true
                                    spacing: root.theme.spacingSM

                                    // 用户消息 - 右对齐
                                    Rectangle {
                                        visible: modelData.role === "user"
                                        Layout.alignment: Qt.AlignRight
                                        Layout.preferredWidth: Math.min(400, parent.width * 0.7)
                                        Layout.preferredHeight: messageUserText.implicitHeight + root.theme.spacingMD * 2
                                        radius: root.theme.radiusLG
                                        color: root.theme.primaryColor

                                        Text {
                                            id: messageUserText
                                            anchors.fill: parent
                                            anchors.margins: root.theme.spacingMD
                                            text: modelData.content
                                            color: "#ffffff"
                                            font.family: root.theme.fontFamily
                                            font.pixelSize: root.theme.fontSizeBase
                                            wrapMode: Text.WordWrap
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }

                                    // AI 响应 - 左对齐
                                    Rectangle {
                                        visible: modelData.role === "assistant"
                                        Layout.alignment: Qt.AlignLeft
                                        Layout.preferredWidth: Math.min(400, parent.width * 0.7)
                                        Layout.preferredHeight: messageAiText.implicitHeight + root.theme.spacingMD * 2
                                        radius: root.theme.radiusLG
                                        color: root.theme.surfaceColor
                                        border.width: 1
                                        border.color: root.theme.dividerColor

                                        Text {
                                            id: messageAiText
                                            anchors.fill: parent
                                            anchors.margins: root.theme.spacingMD
                                            text: modelData.content
                                            color: root.theme.textPrimary
                                            font.family: root.theme.fontFamily
                                            font.pixelSize: root.theme.fontSizeBase
                                            wrapMode: Text.WordWrap
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }
                            }

                            Item { Layout.preferredHeight: root.theme.spacingMD }
                        }

                        Component.onCompleted: {
                            // 自动滚到底部
                            conversationScroll.ScrollBar.vertical.position = 1
                        }
                    }
                }

                // 输入区域
                SoftCard {
                    theme: root.theme
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    padding: root.theme.spacingMD

                    // 输入框
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: root.theme.radiusMD
                        color: root.theme.backgroundColor
                        border.width: 1
                        border.color: root.theme.primaryColor

                        TextArea {
                            id: messageInput
                            anchors.fill: parent
                            anchors.margins: root.theme.spacingSM
                            placeholderText: qsTr("输入您的问题或指令...")
                            placeholderTextColor: root.theme.textTertiary
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.fontSizeBase
                            color: root.theme.textPrimary
                            wrapMode: TextArea.WordWrap
                            topPadding: 8
                            bottomPadding: 8
                            leftPadding: 8
                            rightPadding: 8
                            background: Rectangle {
                                color: "transparent"
                            }
                        }
                    }

                    // 发送和文件上传按钮
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: root.theme.spacingMD

                        AppButton {
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 36
                            theme: root.theme
                            text: qsTr("📎 上传文件")
                            type: "secondary"
                            onClicked: fileDialog.open()
                        }

                        Item { Layout.fillWidth: true }

                        AppButton {
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 36
                            theme: root.theme
                            text: qsTr("🚀 发送")
                            type: "primary"
                            disabled: messageInput.text.trim().length === 0
                            onClicked: {
                                // 添加用户消息
                                conversationModel.append({
                                    role: "user",
                                    content: messageInput.text,
                                    timestamp: new Date().toLocaleTimeString()
                                })

                                // 模拟 AI 响应（后期接入真实 API）
                                var userMessage = messageInput.text
                                messageInput.text = ""

                                // 延迟显示 AI 响应
                                aiResponseTimer.userMessage = userMessage
                                aiResponseTimer.start()

                                // 自动滚到底部
                                conversationScroll.ScrollBar.vertical.position = 1
                            }
                        }
                    }
                }
            }

            // ── 右侧：文件和信息面板 ────────────────────────────────────
            ColumnLayout {
                SplitView.minimumWidth: 160
                SplitView.maximumWidth: 350
                Layout.preferredWidth: 200
                Layout.fillHeight: true
                spacing: root.theme.spacingMD

                // 已上传的文件
                SoftCard {
                    theme: root.theme
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    padding: root.theme.spacingSM

                    Text {
                        text: qsTr("📁 已上传文件")
                        color: root.theme.textPrimary
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSizeBase
                        font.weight: root.theme.fontWeightBold
                    }

                    // 文件列表
                    ScrollView {
                        visible: uploadedFilesModel.count > 0
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentWidth: availableWidth

                        ColumnLayout {
                            width: parent.width
                            spacing: root.theme.spacingXS

                            Repeater {
                                model: uploadedFilesModel

                                delegate: Rectangle {
                                    required property int index
                                    required property var modelData

                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 48
                                    radius: root.theme.radiusSM
                                    color: root.theme.backgroundColor

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: root.theme.spacingXS
                                        spacing: root.theme.spacingXS

                                        Text {
                                            text: "📄"
                                            font.pixelSize: 14
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 0

                                            Text {
                                                text: modelData.fileName
                                                color: root.theme.textPrimary
                                                font.family: root.theme.fontFamily
                                                font.pixelSize: root.theme.fontSizeXS
                                                font.weight: root.theme.fontWeightSemibold
                                                elide: Text.ElideRight
                                            }

                                            Text {
                                                text: modelData.fileSize + " · " + modelData.uploadTime
                                                color: root.theme.textTertiary
                                                font.family: root.theme.fontFamily
                                                font.pixelSize: root.theme.fontSizeXS - 1
                                            }
                                        }

                                        Text {
                                            text: "×"
                                            color: root.theme.textTertiary
                                            font.pixelSize: 14
                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: uploadedFilesModel.remove(index)
                                            }
                                        }
                                    }
                                }
                            }

                            Item { Layout.preferredHeight: root.theme.spacingXS }
                        }
                    }

                    // 空状态
                    Text {
                        visible: uploadedFilesModel.count === 0
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: qsTr("暂无文件")
                        color: root.theme.textTertiary
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSizeSM
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    // 模拟 AI 响应的定时器
    Timer {
        id: aiResponseTimer
        interval: 1000
        repeat: false

        property string userMessage: ""

        onTriggered: {
            // 模拟 AI 响应
            var responses = [
                qsTr("这是一个很好的问题。让我为您详细解答..."),
                qsTr("根据您上传的文件，我发现了以下几点：1. ... 2. ... 3. ..."),
                qsTr("我建议您考虑以下方案...")
            ]

            var randomResponse = responses[Math.floor(Math.random() * responses.length)]

            conversationModel.append({
                role: "assistant",
                content: randomResponse,
                timestamp: new Date().toLocaleTimeString()
            })

            // 自动滚到底部
            conversationScroll.ScrollBar.vertical.position = 1
        }
    }

    // 自动滚到最新消息
    function scrollToBottom() {
        conversationScroll.ScrollBar.vertical.position = 1
    }
}
