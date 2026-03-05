#include "../Header/vaultmodel.h"

#include <QCryptographicHash>
#include <QCoreApplication>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QFile>
#include <QDir>
#include <QStandardPaths>
#include <QRandomGenerator>
#include <QChar>
#include <QtAlgorithms>
#include <QClipboard>
#include <QGuiApplication>
#include <QMessageBox>
#include <QFileDialog>

VaultModel::VaultModel(QObject *parent) : QAbstractListModel(parent) {
    mAppDataLocation = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);

    QDir dir(mAppDataLocation);
    if (!dir.exists())
        dir.mkpath(".");

    mIsDataModified = false;
    mFailAttempts = 0;
    mEncryption = new QAESEncryption(QAESEncryption::AES_256, QAESEncryption::CBC);
    mTimer = new QTimer(this);
    connect(mTimer, &QTimer::timeout, this, &VaultModel::onTimeout);
    setVaultStatus(VaultStatus::LOCKED);
}

VaultModel::~VaultModel() {
    delete(mTimer);
    delete(mEncryption);
}

QJsonDocument VaultModel::authentication(const QString &key) const {
    if(hasMasterKey()) {
        QFile file(mAppDataLocation + "\encrypted_output.dat");
        if (file.open(QIODevice::ReadOnly)) {
            QByteArray enryptedData = file.readAll();
            file.close();
            QString decryptedData = mEncryption->decryptData(enryptedData, key);
            QJsonDocument jsonDoc = QJsonDocument::fromJson(decryptedData.toUtf8());

            return jsonDoc;
        } else {
            qWarning() << "Vault file can't be open";
        }
    } else {
        qWarning() << "File does not exist.";
    }
    return QJsonDocument();
}

void VaultModel::createKey(const QString &key, const QString &confirmKey) {

    if(key == "" || confirmKey == "") {
        emit incorrectForm("The key can not be empty!");
        return;
    }
    if(key != confirmKey) {
        emit incorrectForm("The keys do not match!");
        return;
    }

    QJsonArray jsonArray; // Create a emty json and encrypt it
    QJsonDocument doc(jsonArray);
    QByteArray value = doc.toJson();
    QByteArray encodeText = mEncryption->encryptData(value,key);

    QFile file(mAppDataLocation + "\encrypted_output.dat");
    if (file.open(QIODevice::WriteOnly)) {
        file.write(encodeText);
        file.close();
    }

    mMasterKey = mEncryption->encryptKey(key);
    setVaultStatus(VaultStatus::UNLOCKED);
    emit keyCreatedSuccessful();
    emit hasMasterKeyChanged();
    qDebug() << "Encrypted file has been created.";

}

void VaultModel::deleteKey(const QString &key) {
    if(key == "") {
        emit incorrectForm("The key can not be empty!");
        return;
    }

    QJsonDocument jsonDoc = authentication(key);
    if(!jsonDoc.isNull()) {
        QFile file(mAppDataLocation + "\encrypted_output.dat");
        if (file.remove()) {
            clearModel();
            setVaultStatus(VaultStatus::LOCKED);
            emit hasMasterKeyChanged();
            emit vaultDeletedSuccessful();
            emit alertTriggered("DELETE SUCCESSFUL");
            qDebug() << "File Deleted Successful";
        } else {
            qWarning() << "Failed to delete the file.";
        }
    } else {
        emit loginFailed("Incorrect master key!");
        qCritical() << "INVALID KEY!";
    }
}

void VaultModel::changeKey(const QString &key, const QString &newKey, const QString &confirmKey) {
    if(key == "" || newKey == "" || confirmKey == "") {
        emit incorrectForm("The key can not be empty!");
        return;
    }

    QJsonDocument jsonDoc = authentication(key);
    if(!jsonDoc.isNull()) {
        if(newKey != confirmKey) {
            emit incorrectForm("The keys do not match!");
            return;
        }

        QFile::remove(mAppDataLocation + "\encrypted_output.dat");
        QFile file(mAppDataLocation + "\encrypted_output.dat");
        if (file.open(QIODevice::ReadWrite)) {
            QByteArray value = jsonDoc.toJson();
            QByteArray encodeText = mEncryption->encryptData(value,newKey);
            file.write(encodeText);
            file.close();
        }

        mMasterKey =  mEncryption->encryptKey(newKey);
        emit alertTriggered("CHANGE SUCCESSFUL");
        emit masterKeyChanged();
        qDebug() << "Master key successfuly changed";

    } else {
        emit incorrectForm("Incorrect master key");
        qCritical() << "INVALID KEY!";
    }
}

void VaultModel::login(const QString &key) {
    if(mFailAttempts >= 5) {
        emit loginFailed("Your vault is lock 5 minutes!");
        qCritical() << "You need to wait 5 minutes";
    } else {
        QJsonDocument jsonDoc = authentication(key);
        if(!jsonDoc.isNull()) {
            QJsonArray array = jsonDoc.array();
            for (const QJsonValue &value : array) {
                QJsonObject userObject = value.toObject();
                beginInsertRows(QModelIndex(), mVaultCredentials.size(),mVaultCredentials.size());
                VaultCredentials vaultCredentials;
                vaultCredentials.localTitle = userObject["title"].toString();
                vaultCredentials.originalTitle = userObject["title"].toString();
                vaultCredentials.originalUsername = userObject["username"].toString();
                vaultCredentials.localUsername = userObject["username"].toString();
                vaultCredentials.localPassword = mEncryption->encryptKey(userObject["password"].toString());
                vaultCredentials.originalPassword = mEncryption->encryptKey(userObject["password"].toString());
                mVaultCredentials.append(vaultCredentials);
                endInsertRows();
            }
            mMasterKey = mEncryption->encryptKey(key);
            mFailAttempts = 0;
            setVaultStatus(VaultStatus::UNLOCKED);
            emit loginSuccessful();
            qDebug() << "Login Successful";
        } else {
            mFailAttempts++;
            if(mFailAttempts >= 5) {
                mTimer->start(300000);
                emit loginFailed("Your vault will be lock 5 minutes!");
                qCritical() << "Vault locked 5 minutes";
            } else {
                emit loginFailed("Incorrect master key!");
                qCritical() << "INVALID KEY!";
            }
        }
    }
}

void VaultModel::exit() {
    clearModel();
    setVaultStatus(VaultStatus::LOCKED);
    qDebug() << "Exit Successful";
}

void VaultModel::lock()
{
    if(isModelChanged())
        saveData();
    clearModel();
    setVaultStatus(VaultStatus::LOCKED);
    qDebug() << "Lock Successful";
    emit lockSuccessful();
}

void VaultModel::copy(const QByteArray &password) {
    QClipboard *clipboard = QGuiApplication::clipboard();
    clipboard->setText(mEncryption->decryptKey(password));
}

QString VaultModel::getUserPassword(const QByteArray &password) {
    return mEncryption->decryptKey(password);
}

void VaultModel::saveData() {
    QString key = mEncryption->decryptKey(mMasterKey);
    QJsonDocument jsonDoc = authentication(key);
    if(!jsonDoc.isNull()) {
        QJsonArray array;
        for(const VaultCredentials &vaultCredentials : mVaultCredentials) {
            QJsonObject  newUserObj;
            newUserObj["title"] = vaultCredentials.localTitle;
            newUserObj["username"] = vaultCredentials.localUsername;
            newUserObj["password"] = mEncryption->decryptKey(vaultCredentials.localPassword);

            array.append(newUserObj);
        }
        jsonDoc = QJsonDocument(array);

        QFile::remove(mAppDataLocation + "\encrypted_output.dat");
        QFile file(mAppDataLocation + "\encrypted_output.dat");
        if (file.open(QIODevice::ReadWrite)) {
            QByteArray value = jsonDoc.toJson();
            QByteArray encodeText = mEncryption->encryptData(value,key);
            file.write(encodeText);
            file.close();
        }

        clearModel();
        emit dataSaved();
        mMasterKey = NULL;
        qDebug() << "Data Saved";
        exit();
    } else {
        qCritical() << "THE ENCRYPTED KET WAS NOT VALID!";
    }
}

void VaultModel::clearModel() {
    beginResetModel();
    mVaultCredentials.clear();
    endResetModel();
    mIsDataModified = false;
    qDebug() << "Model Cleared";
}

void VaultModel::deleteVault() {
    emit deleteVaultStart();
}

bool VaultModel::isModelChanged() {
    if(mIsDataModified)
        return true;

    for(VaultCredentials &vaultCredentials : mVaultCredentials) {
        if(vaultCredentials.isDataChanged())
            return true;
    }

    return false;
}

QString VaultModel::generateStrongPassword() const {
    const int length = 16;
    const QString lowerCase = "abcdefghijklmnopqrstuvwxyz";
    const QString upperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const QString digits = "0123456789";
    const QString specialChars = "!@#$%^&*-_=+.<>?/~";

    QString password;
    for(int i=0; i<2; i++) { // Ensure the password contains at least one of each required type
        password.append(lowerCase[QRandomGenerator::global()->bounded(lowerCase.length())]);
        password.append(upperCase[QRandomGenerator::global()->bounded(upperCase.length())]);
        password.append(digits[QRandomGenerator::global()->bounded(digits.length())]);
        password.append(specialChars[QRandomGenerator::global()->bounded(specialChars.length())]);
    }

    QString allChars = lowerCase + upperCase + digits; // Fill the rest - random
    for (int i = password.length(); i < length; ++i)
        password.append(allChars[QRandomGenerator::global()->bounded(allChars.length())]);

    std::random_device rd;
    std::default_random_engine rng(rd());
    std::shuffle(password.begin(), password.end(), rng); // Shuffle the QString

    return password;
}

void VaultModel::exportJson(const QString &key) {
    if(key == "") {
        emit incorrectForm("The key can not be empty!");
        return;
    }

    QJsonDocument jsonDoc = authentication(key);
    if(!jsonDoc.isNull()) {
        QString filePath = QFileDialog::getSaveFileName(nullptr, "Save JSON File", "", "JSON Files (*.json);;All Files (*)");

        if (filePath.isEmpty()) {
            qWarning("No file selected.");
            return;
        }

        QFile file(filePath);
        if (!file.open(QIODevice::WriteOnly)) {
            QMessageBox::warning(nullptr, "Error", "Couldn't open file for writing.");
            return;
        }

        file.write(jsonDoc.toJson());
        file.close();
        emit exportSuccessful();
        emit alertTriggered("EXPORT SUCCESFFUL");
        qDebug() << "JSON data exported successfully to" << filePath;
    } else {
        emit loginFailed("Incorrect master key!");
        qCritical() << "INVALID KEY!";
    }
}

void VaultModel::editData(const int &modelIndex, const QString &title, const QString &username, const QString &password) {
    if(title == "") {
        emit incorrectForm("Title can not be empty!");
    } else if(username == "") {
        emit incorrectForm("Username can not be empty!");
    } else if(password == "") {
        emit incorrectForm("Password can not be empty!");
    } else {
        mVaultCredentials[modelIndex].localTitle = title;
        mVaultCredentials[modelIndex].localUsername = username;
        mVaultCredentials[modelIndex].localPassword = mEncryption->encryptKey(password);
        mIsDataModified = true;
        qDebug() << "Element Edited Successful";
        emit dataChanged(index(modelIndex), index(modelIndex));
        emit editDataSuccessful();
    }
}

void VaultModel::addData(const QString &title, const QString &username, const QString &password) {
    if(title == "") {
        emit incorrectForm("Title can not be empty!");
    } else if(username == "") {
        emit incorrectForm("Username can not be empty!");
    } else if(password == "") {
        emit incorrectForm("Password can not be empty!");
    } else {
        beginInsertRows(QModelIndex(), mVaultCredentials.size(), mVaultCredentials.size());
        VaultCredentials vaultCredentials;
        vaultCredentials.localTitle = title;
        vaultCredentials.originalTitle = title;
        vaultCredentials.localUsername = username;
        vaultCredentials.originalUsername = username;
        vaultCredentials.localPassword = mEncryption->encryptKey(password);
        vaultCredentials.originalPassword = mEncryption->encryptKey(password);
        mVaultCredentials.append(vaultCredentials);
        endInsertRows();
        mIsDataModified = true;
        qDebug() << "Element Added Successful";
        emit addDataSuccessful();
    }
}

void VaultModel::deleteData(const int &modelIndex) {
    if(modelIndex < 0 && modelIndex >= mVaultCredentials.size()) {
        qDebug() << "Invalid Model Index";
        return;
    }
    beginRemoveRows(QModelIndex(), modelIndex, modelIndex);
    mVaultCredentials.removeAt(modelIndex);
    endRemoveRows();
    mIsDataModified = true;
    qDebug() << "Element Deleted Successful";
}

VaultModel::VaultStatus VaultModel::getVaultStatus() const {
    return mVault;
}

void VaultModel::setVaultStatus(const VaultStatus &newStatus) {
    if(mVault == newStatus)
        return;
    mVault = newStatus;
    emit vaultStatusChanged();
}

bool VaultModel::hasMasterKey() const {
    return QFile::exists(mAppDataLocation + "\encrypted_output.dat");
}

int VaultModel::rowCount(const QModelIndex &parent) const {
    return mVaultCredentials.size();
}

QVariant VaultModel::data(const QModelIndex &index, int role) const {
    const VaultCredentials vaultCredentials = mVaultCredentials[index.row()];
    switch (role) {
        case RoleVaultCredentials: return QVariant::fromValue(vaultCredentials);
        case RoleTitle: return vaultCredentials.localTitle;
        case RoleUsername: return vaultCredentials.localUsername;
        case RolePassword: return vaultCredentials.localPassword;
        case RoleRowNumber: return index.row();
    }
    return QVariant();
}

QHash<int, QByteArray> VaultModel::roleNames() const {
    return {
        {RoleVaultCredentials, "RoleVaultCredentials"},
        {RoleTitle, "RoleTitle"},
        {RoleUsername, "RoleUsername"},
        {RolePassword, "RolePassword"},
        {RoleRowNumber, "RoleRowNumber"},
     };
}

void VaultModel::onTimeout() {
    mFailAttempts = 0;
    mTimer->stop();
}
