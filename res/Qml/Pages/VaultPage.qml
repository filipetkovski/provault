import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../Controls"
import "../Popups"

Rectangle {
    color: applicationResources.primaryColor
    radius: applicationResources.radius

    property var vaultStatus: vaultModel.getVaultStatus

    Component.onDestruction: {
        vaultModel.isModelChanged() ? vaultModel.saveData() : vaultModel.exit()
    }

    onVaultStatusChanged: {
        popupLoader.visible = vaultStatus === 0
        popupLoader.source = "qrc:/res/Qml/Popups/VaultLogin.qml"
    }

    function closePopups() {
        popupLoader.visible = vaultStatus === 0
        popupLoader.source = "qrc:/res/Qml/Popups/VaultLogin.qml"
    }

    Component {
        id: deleteCredentialsPopupComponent
        DeleteCredentialsPopup {}
    }

    Connections {
        target: vaultModel

        function onAddDataSuccessful() { closePopups() }
        function onEditDataSuccessful() { closePopups() }
        function onExportSuccessful() { closePopups() }
        function onDeleteVaultStart() {
            popupLoader.visible = true
            popupLoader.setSource("qrc:/res/Qml/Popups/ManageVault.qml",
                {"type": "DELETE", "title": "Proceed with Caution", "description": "Enter your Password to delete your vault."})
        }
    }

    Loader {
        id: popupLoader
        anchors.centerIn: parent
        source: "qrc:/res/Qml/Popups/VaultLogin.qml"
        z: 2
    }

    Rectangle {
        id: disableScreen
        anchors.fill: parent
        color: Qt.rgba(37/255, 40/255, 47/255, 0.9)
        radius: applicationResources.radius
        visible: popupLoader.visible
        z: 1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: applicationResources.margin
        enabled: !disableScreen.visible
        spacing: applicationResources.spacing

        QHeader {
            Layout.fillWidth: true
        }

        ListView {
            id: userListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: vaultModel
            spacing: applicationResources.spacing - 10
            clip: true

            onContentYChanged: {
                if (contentY <= 0) {
                    Qt.callLater(function() {
                        if (contentY !== 0)
                            contentY = 0
                    });
                } else if (contentY >= (contentHeight - height)) {
                    Qt.callLater(function() {
                        if (contentY !== contentHeight - height)
                            contentY = contentHeight - height
                    });
                }
            }

            delegate: Rectangle {
                id: dataRow
                width: userListView.width
                height: 35
                visible: vaultStatus
                color: applicationResources.transparent

                RowLayout {
                    anchors.fill: parent
                    spacing: applicationResources.spacing
                    z: 1

                    QLabel {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredWidth: 24
                        text: RoleRowNumber + 1
                        color: applicationResources.grayColor
                        font.pixelSize: 18
                    }

                    QLabel {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredWidth: 300
                        text: RoleTitle
                        color: applicationResources.grayColor
                        font.pixelSize: 18
                    }

                    QLabel {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredWidth: 300
                        text: RoleUsername
                        color: applicationResources.grayColor
                        font.pixelSize: 18
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        id: listViewIcons
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: applicationResources.spacing

                        QImgButton {
                            source: "qrc:/res/Img/copy.svg"
                            onBtnClicked: vaultModel.copy(RolePassword)
                        }

                        QImgButton {
                            source: "qrc:/res/Img/edit.svg"
                            onBtnClicked: {
                                popupLoader.visible = true
                                popupLoader.setSource("qrc:/res/Qml/Popups/VaultCredentials.qml",  {
                                    "addCredentials": false,
                                    "titleText": RoleTitle,
                                    "userText": RoleUsername,
                                    "passwordText": vaultModel.getUserPassword(RolePassword),
                                    "index": index
                                })
                            }
                        }

                        QImgButton {
                            source: "qrc:/res/Img/bin.svg"
                            onBtnClicked: {
                                popupLoader.sourceComponent = deleteCredentialsPopupComponent
                                popupLoader.item.index = index
                                popupLoader.item.open()
                            }
                        }
                    }
                }
            }
        }

        QFooter {
            Layout.fillWidth: true
        }
    }
}
