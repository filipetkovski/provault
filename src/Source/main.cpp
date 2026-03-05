#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFontDatabase>
#include <QIcon>

#include "../Header/applicationresources.h"

int main(int argc, char *argv[]) {
    QApplication  app(argc, argv);

    ApplicationResources* application = new ApplicationResources();

    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:");
    app.setWindowIcon(QIcon(":/res/Img/pro.jpg"));

    engine.rootContext()->setContextProperty("applicationResources", application);
    engine.rootContext()->setContextProperty("vaultModel", application->vaultModel());

    const QUrl url(QStringLiteral("qrc:/res/Qml/Main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
