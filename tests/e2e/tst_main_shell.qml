// tests/e2e/tst_main_shell.qml
import QtQuick
import QtTest

TestCase {
    id: testCase
    name: "MainShellBinding"
    when: windowShown

    QtObject {
        id: homeVm
        property string welcomeMessage: "欢迎使用 IQtools Plus！"
        property string appVersion: "版本 1.0.0"
        property string buildDate: "构建日期: 2024-06-01"
    }

    QtObject {
        id: translateVm
        property string sourceText: ""
        property string resultText: ""
        property bool translating: false
        property string fromLanguage: "auto"
        property string toLanguage: "zh-CN"
        property var supportedLanguages: ["auto", "zh-CN", "en"]
        property string currentEngine: "mock-local"
        property var availableEngines: ["mock-local"]
        property string errorMessage: ""
        property string latencyInfo: "-- ms"
        property real cacheHitRate: 0.0

        function translate() {}
        function clear() {}
        function copyResult() {}
        function switchLanguages() {}
    }

    QtObject {
        id: shellVm
        property int currentPageIndex: 0
        property bool darkMode: false
        property string pageTitle: currentPageIndex === 0 ? "首页"
                                                       : (currentPageIndex === 1 ? "翻译"
                                                       : (currentPageIndex === 2 ? "剪贴板" : "截图"))
        property string pageSubtitle: currentPageIndex === 0 ? "欢迎使用 IQtools Plus！请选择左侧功能导航进入对应页面。"
                                                             : "stub subtitle"
        property QtObject homeViewModel: homeVm
        property QtObject translateViewModel: translateVm

        function navigateTo(pageIndex) {
            currentPageIndex = pageIndex
        }

        function toggleDarkMode() {
            darkMode = !darkMode
        }
    }

    function createWindow() {
        const component = Qt.createComponent("../../src/ui/main.qml")
        compare(component.status, Component.Ready, component.errorString())
        return createTemporaryObject(component, testCase, {
            "viewModel": shellVm
        })
    }

    function test_mainWindowLoads() {
        const window = createWindow()
        verify(window !== null)
        compare(window.title, "IQtools Plus")
        verify(findChild(window, "appSidebar") !== null)
        verify(findChild(window, "homePage") !== null)
    }

    function test_navigationContract() {
        const window = createWindow()
        verify(window !== null)

        shellVm.navigateTo(1)
        compare(shellVm.currentPageIndex, 1)
        compare(shellVm.pageTitle, "翻译")

        shellVm.navigateTo(3)
        compare(shellVm.currentPageIndex, 3)
        compare(shellVm.pageTitle, "截图")
    }

    function test_toggleTheme() {
        compare(shellVm.darkMode, false)
        shellVm.toggleDarkMode()
        compare(shellVm.darkMode, true)
    }
}
