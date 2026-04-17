// src/ui/pages/TranslatePage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root

    required property QtObject theme
    required property QtObject viewModel

    objectName: "translatePage"

    ColumnLayout {
        anchors.fill: parent
        spacing: root.theme.spacingLG

        RowLayout {
            Layout.fillWidth: true
            spacing: root.theme.spacingLG

            SoftCard {
                theme: root.theme
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 320

                Text {
                    text: qsTr("源文本")
                    color: root.theme.textSecondary
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeSM
                    font.weight: root.theme.fontWeightSemibold
                }

                TextArea {
                    id: sourceInput
                    objectName: "translateSourceInput"

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    wrapMode: TextArea.Wrap
                    selectByMouse: true
                    text: root.viewModel.sourceText
                    placeholderText: qsTr("输入待翻译文本。下一步这里会直接接真实 TranslateService。")
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

                    ComboBox {
                        id: fromLanguageBox
                        Layout.fillWidth: true
                        model: root.viewModel.supportedLanguages
                        currentIndex: Math.max(0, model.indexOf(root.viewModel.fromLanguage))

                        onActivated: function(index) {
                            root.viewModel.fromLanguage = model[index]
                        }
                    }

                    Button {
                        text: qsTr("⇄")
                        onClicked: root.viewModel.switchLanguages()
                    }

                    ComboBox {
                        id: toLanguageBox
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

                    ComboBox {
                        Layout.fillWidth: true
                        model: root.viewModel.availableEngines
                        currentIndex: Math.max(0, model.indexOf(root.viewModel.currentEngine))

                        onActivated: function(index) {
                            root.viewModel.currentEngine = model[index]
                        }
                    }

                    Button {
                        text: qsTr("清空")
                        onClicked: root.viewModel.clear()
                    }

                    Button {
                        objectName: "translateActionButton"
                        text: root.viewModel.translating ? qsTr("翻译中…") : qsTr("翻译")
                        enabled: !root.viewModel.translating && sourceInput.text.trim().length > 0
                        onClicked: root.viewModel.translate()

                        background: Rectangle {
                            radius: root.theme.radiusLG
                            color: parent.hovered ? root.theme.primaryHoverColor : root.theme.primaryColor
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#FFFFFF"
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.fontSizeBase
                            font.weight: root.theme.fontWeightSemibold
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            SoftCard {
                theme: root.theme
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 320

                Text {
                    text: qsTr("翻译结果")
                    color: root.theme.textSecondary
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeSM
                    font.weight: root.theme.fontWeightSemibold
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

                    Label {
                        text: qsTr("耗时：%1").arg(root.viewModel.latencyInfo)
                        color: root.theme.textSecondary
                    }

                    Label {
                        text: qsTr("缓存命中率：%1%").arg(Math.round(root.viewModel.cacheHitRate * 100))
                        color: root.theme.textSecondary
                    }

                    Item { Layout.fillWidth: true }

                    BusyIndicator {
                        running: root.viewModel.translating
                        visible: running
                    }

                    Button {
                        text: qsTr("复制结果")
                        enabled: root.viewModel.resultText.length > 0
                        onClicked: root.viewModel.copyResult()
                    }
                }
            }
        }

        SoftCard {
            theme: root.theme
            Layout.fillWidth: true
            Layout.preferredHeight: 104

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: root.theme.spacingXS

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
                }
            }
        }
    }

    Connections {
        target: root.viewModel

        function onTranslateSucceeded(result) {
            console.log("[TranslatePage] translate succeeded:", result)
        }

        function onTranslateFailed(reason) {
            console.warn("[TranslatePage] translate failed:", reason)
        }
    }
}
