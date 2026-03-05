#include "../Header/applicationresources.h"

#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QStandardPaths>
#include <QResource>

ApplicationResources::ApplicationResources(QObject *parent) : QObject(parent) {
    mAppDataLocation = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    mEncryption = new QAESEncryption(QAESEncryption::AES_256, QAESEncryption::CBC);
    mVaultModel = new VaultModel();
}

ApplicationResources::~ApplicationResources() {
    delete mVaultModel;
}

QJsonDocument ApplicationResources::loadFile(const QString &fileName) {
    QFile file(fileName);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "FAILE TO OPEN THE" << fileName;
        return QJsonDocument();
    }

    QByteArray encryptedData = file.readAll();
    QString decryptedData = mEncryption->decryptData(encryptedData, mEncryption->customHash());
    return QJsonDocument::fromJson(decryptedData.toUtf8());
}

VaultModel *ApplicationResources::vaultModel() const {
    return mVaultModel;
}

int ApplicationResources::radius() const
{
    return mRadius;
}

int ApplicationResources::margin() const
{
    return mMargin;
}

int ApplicationResources::spacing() const
{
    return mSpacing;
}

QColor ApplicationResources::transparent() const
{
    return mTransparent;
}
