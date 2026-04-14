// tests/e2e/tst_main_shell.qml
import QtQuick
import QtTest
import "../../src/ui/theme"
import "../../src/ui/components"

TestCase {
    name: "MainShellBinding"

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
        property string pageTitle: currentPageIndex === 0 ? "翻译" : (currentPageIndex === 1 ? "剪贴板" : "截图")
        property string pageSubtitle: "stub subtitle"
        property QtObject translateViewModel: translateVm

        function navigateTo(pageIndex) {
            currentPageIndex = pageIndex
        }

        function toggleDarkMode() {
            darkMode = !darkMode
        }
    }

    Theme {
        id: theme
        isDark: shellVm.darkMode
    }

    AppSidebar {
        id: sidebar
        width: 260
        height: 600
        theme: theme
        currentIndex: shellVm.currentPageIndex

        onPageSelected: function(pageIndex) {
            shellVm.navigateTo(pageIndex)
        }
    }

    function test_defaultPage() {
        compare(shellVm.currentPageIndex, 0)
        compare(shellVm.pageTitle, "翻译")
    }

    function test_switchPage() {
        shellVm.navigateTo(2)
        compare(shellVm.currentPageIndex, 2)
        compare(shellVm.pageTitle, "截图")
    }

    function test_toggleTheme() {
        compare(shellVm.darkMode, false)
        shellVm.toggleDarkMode()
        compare(shellVm.darkMode, true)
    }
}