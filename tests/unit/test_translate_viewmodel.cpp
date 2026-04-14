// tests/unit/test_translate_viewmodel.cpp
#include <QtTest/QtTest>
#include <QSignalSpy>

#include "viewmodels/TranslateViewModel.h"

class TranslateViewModelTest final : public QObject
{
    Q_OBJECT

private slots:
    void shouldRejectEmptyText();
    void shouldProduceMockResult();
    void shouldSwitchLanguages();
};

void TranslateViewModelTest::shouldRejectEmptyText()
{
    TranslateViewModel vm;
    QSignalSpy failedSpy(&vm, &TranslateViewModel::translateFailed);

    vm.setSourceText(QString());
    vm.translate();

    QCOMPARE(failedSpy.count(), 1);
    QVERIFY(!vm.errorMessage().isEmpty());
    QCOMPARE(vm.translating(), false);
}

void TranslateViewModelTest::shouldProduceMockResult()
{
    TranslateViewModel vm;
    QSignalSpy successSpy(&vm, &TranslateViewModel::translateSucceeded);

    vm.setSourceText(QStringLiteral("hello world"));
    vm.setFromLanguage(QStringLiteral("en"));
    vm.setToLanguage(QStringLiteral("zh-CN"));
    vm.translate();

    QTRY_COMPARE(successSpy.count(), 1);
    QVERIFY(vm.resultText().contains(QStringLiteral("hello world")));
    QCOMPARE(vm.translating(), false);
    QVERIFY(vm.latencyInfo().contains(QStringLiteral("ms")));
}

void TranslateViewModelTest::shouldSwitchLanguages()
{
    TranslateViewModel vm;
    vm.setFromLanguage(QStringLiteral("en"));
    vm.setToLanguage(QStringLiteral("zh-CN"));

    vm.switchLanguages();

    QCOMPARE(vm.fromLanguage(), QStringLiteral("zh-CN"));
    QCOMPARE(vm.toLanguage(), QStringLiteral("en"));
}

QTEST_MAIN(TranslateViewModelTest)
#include "test_translate_viewmodel.moc"