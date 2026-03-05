#ifndef VAULTMODEL_H
#define VAULTMODEL_H

#include "vaultcredentials.h"
#include "qaesencryption.h"

#include <QObject>
#include <QAbstractListModel>
#include <QTimer>

class VaultModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(VaultStatus getVaultStatus READ getVaultStatus WRITE setVaultStatus NOTIFY vaultStatusChanged FINAL)
    Q_PROPERTY(bool hasMasterKey READ hasMasterKey NOTIFY hasMasterKeyChanged FINAL)

public:
    VaultModel(QObject *parent = nullptr);
    ~VaultModel();

    enum VaultStatus {
        LOCKED,
        UNLOCKED
    };
    enum Roles {
        RoleVaultCredentials = Qt::ItemDataRole::UserRole,
        RoleTitle,
        RoleUsername,
        RolePassword,
        RoleRowNumber
    };

    Q_INVOKABLE void createKey(const QString &key, const QString &confirmKey);
    Q_INVOKABLE void deleteKey(const QString &key);
    Q_INVOKABLE void changeKey(const QString &key, const QString &newKey, const QString &confirmKey);
    Q_INVOKABLE void login(const QString &key);
    Q_INVOKABLE void exit();
    Q_INVOKABLE void lock();
    Q_INVOKABLE void copy(const QByteArray &password);
    Q_INVOKABLE void saveData();
    Q_INVOKABLE void addData(const QString &title, const QString &username, const QString &password);
    Q_INVOKABLE void editData(const int &modelIndex, const QString &title, const QString &username, const QString &password);
    Q_INVOKABLE void deleteData(const int &modelIndex);
    Q_INVOKABLE void deleteVault();
    Q_INVOKABLE bool isModelChanged();
    Q_INVOKABLE void exportJson(const QString &key);
    Q_INVOKABLE QString getUserPassword(const QByteArray &password);
    Q_INVOKABLE QString generateStrongPassword() const;


    QJsonDocument authentication(const QString &key) const;
    VaultStatus getVaultStatus() const;
    bool hasMasterKey() const;
    void setVaultStatus(const VaultStatus &newStatus);
    void clearModel();

    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

signals:
    bool modelDataChanged();
    bool dataSaved();
    bool loginSuccessful();
    bool lockSuccessful();
    bool addDataSuccessful();
    bool editDataSuccessful();
    bool keyCreatedSuccessful();
    void vaultStatusChanged();
    void hasMasterKeyChanged();
    void masterKeyChanged();
    void exportSuccessful();
    void deleteVaultStart();
    void vaultDeletedSuccessful();
    bool loginFailed(const QString &message);
    bool incorrectForm(const QString &message);
    void alertTriggered(const QString &message);

public slots:
    void onTimeout();

private:
    int mFailAttempts;
    bool mIsDataModified;
    QTimer* mTimer;
    QByteArray mMasterKey = NULL;
    QString mAppDataLocation;
    QAESEncryption* mEncryption;
    VaultStatus mVault;
    QList<VaultCredentials> mVaultCredentials;
};

#endif // VAULTMODEL_H
