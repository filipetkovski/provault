import QtQuick
import QtQuick.Layouts

RowLayout {
    spacing: applicationResources.spacing

    QImgButton {
        Layout.alignment: Qt.AlignBottom
        source: "qrc:/res/Img/settings.svg"
        onBtnClicked: {
            popupLoader.visible = true
            popupLoader.setSource("qrc:/res/Qml/Popups/ManageVault.qml",
                {"type": "EXPORT", "title": "Authorize Database Export", "description": "Enter your Password to export your credentials."})
        }
    }

    QImgButton {
        Layout.alignment: Qt.AlignBottom
        source: "qrc:/res/Img/delete.svg"
        visible: vaultModel.hasMasterKey
        onBtnClicked: vaultModel.deleteVault()
    }

    QImgButton {
        Layout.alignment: Qt.AlignBottom
        source: "qrc:/res/Img/vault.svg"
        onBtnClicked: vaultModel.lock()
    }

    Item { Layout.fillWidth: true }

    QImgButton {
        source: "qrc:/res/Img/addButton.svg"
        btnEnabled: vaultStatus === 0 ? false : true
        onBtnClicked: {
            popupLoader.visible = true
            popupLoader.setSource("qrc:/res/Qml/Popups/VaultCredentials.qml", {"addCredentials": true})
        }
    }
}
