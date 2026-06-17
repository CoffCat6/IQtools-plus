// src/ui/pages/TranslatePage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../theme"

AppPage {
    id: root

    required property QtObject viewModel
    property QtObject toast: null

    objectName: "translatePage"

    AppConfirmDialog {
        id: clearConfirmDialog
        theme: root.theme
        visible: false
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: root.theme.spacingLG

        // Source text card
        SoftCard {
            theme: root.theme
            Layout.fillWidth: true
            Layout.preferredHeight: 320

            Text {
                text: qsTr("源文本")
                color: root.theme.textSecondary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.labelSize
                font.weight: root.theme.labelWeight
            }

            TextArea {
                id: sourceInput
                objectName: "translateSourceInput"

                Layout.fillWidth: true
                Layout.fillHeight: true
                wrapMode: TextArea.Wrap
                selectByMouse: true
                text: root.viewModel.sourceText
                placeholderText: qsTr("输入待翻译文本…")
                color: root.theme.textPrimary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSizeBase

                onTextChanged: {
                    if (activeFocus && text !== root.viewModel.sourceText) {
                        root.viewModel.sourceText = text
                    }
                }

                background: Rectangle {
                    radius: root.theme.radiusMD
                    color: root.theme.backgroundColor
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: root.theme.spacingMD

                AppComboBox {
                    id: fromLanguageBox
                    theme: root.theme
                    Layout.fillWidth: true
                    model: root.viewModel.supportedLanguages
                    currentIndex: Math.max(0, model.indexOf(root.viewModel.fromLanguage))

                    onActivated: function(index) {
                        root.viewModel.fromLanguage = model[index]
                    }
                }

                AppButton {
                    theme: root.theme
                    text: qsTr("⇄")
                    type: "secondary"
                    size: "md"
                    implicitWidth: 44
                    onClicked: root.viewModel.switchLanguages()
                }

                AppComboBox {
                    id: toLanguageBox
                    theme: root.theme
                    Layout.fillWidth: true
                    model: root.viewModel.supportedLanguages.filter(function(item) {
                        return item !== "auto"
                    })

                    Component.onCompleted: {
                        const idx = model.indexOf(root.viewModel.toLanguage)
                        currentIndex = idx >= 0 ? idx : 0
                    }

                    onActivated: function(index) {
                        root.viewModel.toLanguage = model[index]
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: root.theme.spacingMD

                AppComboBox {
                    theme: root.theme
                    Layout.fillWidth: true
                    model: root.viewModel.availableEngines
                    currentIndex: Math.max(0, model.indexOf(root.viewModel.currentEngine))

                    onActivated: function(index) {
                        root.viewModel.currentEngine = model[index]
                    }
                }

                AppButton {
                    theme: root.theme
                    text: qsTr("清空")
                    type: "secondary"
                    size: "md"
                    onClicked: root.viewModel.clear()
                }

                AppButton {
                    objectName: "translateActionButton"
                    theme: root.theme
                    text: root.viewModel.translating ? qsTr("翻译中…") : qsTr("翻译")
                    type: "primary"
                    size: "md"
                    loading: root.viewModel.translating
                    disabled: root.viewModel.translating || sourceInput.text.trim().length === 0
                    fullWidth: true
                    onClicked: root.viewModel.translate()
                }
            }
        }

        // Result text card
        SoftCard {
            theme: root.theme
            Layout.fillWidth: true
            Layout.preferredHeight: 320

            Text {
                text: qsTr("翻译结果")
                color: root.theme.textSecondary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.labelSize
                font.weight: root.theme.labelWeight
            }

            TextArea {
                id: resultArea
                objectName: "translateResultArea"

                Layout.fillWidth: true
                Layout.fillHeight: true
                readOnly: true
                wrapMode: TextArea.Wrap
                selectByMouse: true
                text: root.viewModel.resultText
                color: root.theme.textPrimary
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSizeBase

                background: Rectangle {
                    radius: root.theme.radiusMD
                    color: root.theme.backgroundColor
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: root.theme.spacingMD

                Text {
                    text: qsTr("耗时：%1").arg(root.viewModel.latencyInfo)
                    color: root.theme.textSecondary
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeSM
                }

                Text {
                    text: qsTr("缓存命中率：%1%").arg(Math.round(root.viewModel.cacheHitRate * 100))
                    color: root.theme.textSecondary
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeSM
                }

                Item { Layout.fillWidth: true }

                BusyIndicator {
                    running: root.viewModel.translating
                    visible: running
                    implicitWidth: 20
                    implicitHeight: 20
                }

                AppButton {
                    theme: root.theme
                    text: qsTr("复制结果")
                    type: "secondary"
                    size: "sm"
                    disabled: root.viewModel.resultText.length === 0
                    onClicked: {
                        root.viewModel.copyResult()
                        if (root.toast) root.toast.show(qsTr("翻译结果已复制到剪贴板"), "success")
                    }
                }
            }
        }
    }

    // Status bar
    SoftCard {
        theme: root.theme
        Layout.fillWidth: true
        Layout.preferredHeight: 72

        Text {
            text: root.viewModel.errorMessage.length > 0
                  ? root.viewModel.errorMessage
                  : qsTr("当前为主界面联调阶段，翻译结果由 mock ViewModel 生成。")
            color: root.viewModel.errorMessage.length > 0
                   ? root.theme.errorColor
                   : root.theme.textSecondary
            font.family: root.theme.fontFamily
            font.pixelSize: root.theme.fontSizeBase
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }

    // Translation history
    Text {
        Layout.topMargin: root.theme.spacingMD
        text: qsTr("翻译历史")
        color: root.theme.textPrimary
        font.family: root.theme.fontFamily
        font.pixelSize: root.theme.h3Size
        font.weight: root.theme.h3Weight
    }

    Repeater {
        model: 8

        delegate: AppListItem {
            required property int index

            theme: root.theme
            iconText: ["中→英", "英→中", "中→日", "日→中", "中→韩", "韩→中", "中→法", "法→中"][index]
            title: ["你好世界", "Hello World", "早上好", "おはよう", "谢谢", "감사합니다", "再见", "Au revoir"][index]
            subtitle: ["Hello World", "你好世界", "Good morning", "早上好", "Thank you", "谢谢", "Goodbye", "再见"][index]
            trailingText: ["14:30", "13:45", "12:20", "11:50", "10:30", "09:45", "08:20", "昨天"][index]
        }
    }

    Item { Layout.preferredHeight: root.theme.spacingMD }

    Connections {
        target: root.viewModel

        function onTranslateSucceeded(result) {
            console.log("[TranslatePage] translate succeeded:", result)
            if (root.toast) root.toast.show(qsTr("翻译完成"), "success")
        }

        function onTranslateFailed(reason) {
            console.warn("[TranslatePage] translate failed:", reason)
            if (root.toast) root.toast.show(reason, "error")
        }
    }
}
