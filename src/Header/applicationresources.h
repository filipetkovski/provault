#ifndef APPLICATIONRESOURCES_H
#define APPLICATIONRESOURCES_H

#include <QAbstractListModel>
#include <QObject>
#include <QColor>


#include "vaultmodel.h"
#include "qaesencryption.h"

/*!
 * \brief The ApplicationResources class is the core of this application. It controls the following:
 *        - colors and window properties
 *        - list of settings model
 */
class ApplicationResources : public QObject {
    Q_OBJECT

    Q_PROPERTY(QColor backgroundColor MEMBER mBackgroundColor CONSTANT)
    Q_PROPERTY(QColor primaryColor MEMBER mPrimaryColor CONSTANT)
    Q_PROPERTY(QColor secondaryColor MEMBER mSecondaryColor CONSTANT)
    Q_PROPERTY(QColor thirdColor MEMBER mThirdColor CONSTANT)
    Q_PROPERTY(QColor warningColor MEMBER mWarningColor CONSTANT)
    Q_PROPERTY(QColor grayColor MEMBER mGrayColor CONSTANT)
    Q_PROPERTY(QColor darkGrayColor MEMBER mDarkGrayColor CONSTANT)
    Q_PROPERTY(QColor activeButtonColor MEMBER mActiveButtonColor CONSTANT)
    Q_PROPERTY(QColor inactiveButtonColor MEMBER mInactiveButtonColor CONSTANT)
    Q_PROPERTY(int screenWidth MEMBER mScreenWidth CONSTANT)
    Q_PROPERTY(int screenHeight MEMBER mScreenHeight CONSTANT)
    Q_PROPERTY(int radius READ radius CONSTANT FINAL)
    Q_PROPERTY(int margin READ margin CONSTANT FINAL)
    Q_PROPERTY(int spacing READ spacing CONSTANT FINAL)
    Q_PROPERTY(QColor transparent READ transparent CONSTANT FINAL)

public:
    enum Roles {
        RoleSettingsModel = Qt::ItemDataRole::UserRole,
        RoleTitle,
        RoleIcon,
        RoleGreenIcon
    };

    ApplicationResources(QObject *parent = nullptr);
    ~ApplicationResources();

    QJsonDocument loadFile(const QString &fileName);
    VaultModel *vaultModel() const;

    int radius() const;

    int margin() const;

    int spacing() const;

    QColor transparent() const;

private:
    // Screen Size
    const int mScreenWidth = 960;
    const int mScreenHeight = 600;
    // Component Metrics
    const int mRadius = 30;
    const int mMargin = 25;
    const int mSpacing = 20;
    // Colors
    const QColor mBackgroundColor = "#1E2228";
    const QColor mPrimaryColor = "#262B33";
    const QColor mSecondaryColor = "#22F3A8";
    const QColor mThirdColor = "#FFFFFF";
    const QColor mWarningColor = "#FFC000";
    const QColor mGrayColor = "#C8C8C8";
    const QColor mDarkGrayColor = "#3B4450";
    const QColor mActiveButtonColor = "#2CBA86";
    const QColor mInactiveButtonColor = "#7F7F7F";
    const QColor mTransparent = "transparent";
    // Models
    VaultModel* mVaultModel;
    QString mAppDataLocation;
    QAESEncryption* mEncryption;
};

#endif // APPLICATIONRESOURCES_H
