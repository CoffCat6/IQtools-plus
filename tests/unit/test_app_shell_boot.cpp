#include <QQuickWindow>
#include <QQmlApplicationEngine>
#include <QVariant>
#include <QtTest/QtTest>

#include "viewmodels/AppShellViewModel.h"

class AppShellBootTest final : public QObject
{
    Q_OBJECT

private slots:
    void shouldLoadMainWindowFromQrc();
};

void AppShellBootTest::shouldLoadMainWindowFromQrc()
{
    Q_INIT_RESOURCE(qml);

    QQmlApplicationEngine engine;
    AppShellViewModel viewModel;

    engine.setInitialProperties({
        {QStringLiteral("viewModel"), QVariant::fromValue(static_cast<QObject*>(&viewModel))}
    });
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    QVERIFY2(!engine.rootObjects().isEmpty(), "main.qml root object should be created");

    auto* window = qobject_cast<QQuickWindow*>(engine.rootObjects().constFirst());
    QVERIFY2(window != nullptr, "root object should be a QQuickWindow");
    QCOMPARE(window->title(), QStringLiteral("IQtools Plus"));
}

QTEST_MAIN(AppShellBootTest)
#include "test_app_shell_boot.moc"
