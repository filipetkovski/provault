#ifndef VAULTCREDENTIALS_H
#define VAULTCREDENTIALS_H

#include <QObject>

struct VaultCredentials {
    QString localTitle;
    QString originalTitle;
    QString localUsername;
    QString originalUsername;
    QByteArray localPassword;
    QByteArray originalPassword;

    bool isDataChanged() {
        return localPassword != originalPassword
            || localUsername != originalUsername
            || localTitle != originalTitle;
    };
};

#endif // VAULTCREDENTIALS_H
