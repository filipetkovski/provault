import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import SettingsModel 1.0

import "../Controls"
import "../Popups"

Item {
    id: root
    anchors.fill: parent

    property SettingsModel settingsModel
    property bool hasMasterKey: vaultModel.hasMasterKey
    property var vaultStatus: vaultModel.getVaultStatus

    Component.onDestruction: vaultModel.isModelChanged() ? vaultModel.saveData() : vaultModel.exit()
    onVaultStatusChanged: closePopups()

    function closePopups() {
        popupLoader.visible = root.vaultStatus === 0
    }

    Connections {
        target: vaultModel
        function onDataSaved() { mainPanel.customLoader.pagePopupLoader.item.close() }
        function onAddDataSuccessful() { closePopups() }
        function onEditDataSuccessful() { closePopups() }
    }

    Loader {
        id: popupLoader
        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top }
        source: "qrc:/res/Controls/VaultLogin.qml"
        z: 2
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(37/255, 40/255, 47/255, 0.8)
        visible: popupLoader.visible
        z: 1
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        CustomSubHeader {
            Layout.fillWidth: true
            title1: qsTr("Title")
            title2: qsTr("Username")
        }

        ListView {
            id: userListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 0

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

            model: vaultModel
            delegate: Rectangle {
                id: listViewDelegate
                width: root.width
                height: 35
                color: applicationResources.backgroundColor
                visible: vaultStatus

                RowLayout {
                    id: listViewRowDelegate
                    z: 1
                    spacing: 20

                    Item {
                        Layout.alignment: Qt.AlignVCenter
                        implicitWidth: 193
                        Layout.leftMargin: 7
                        implicitHeight: 35

                        CustomLabel {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            text: RoleTitle
                            color: applicationResources.grayColor
                            font.pixelSize: 18
                        }
                    }

                    Item {
                        Layout.alignment: Qt.AlignVCenter
                        implicitWidth: 310
                        implicitHeight: 35

                        CustomLabel {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            text: RoleUsername
                            color: applicationResources.grayColor
                            font.pixelSize: 18
                        }
                    }

                    Item { Layout.fillWidth: true }

                    RowLayout {
                        id: listViewIcons
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 10

                        property bool hovered: false

                        CustomImgButton {
                            source: listViewIcons.hovered ? "qrc:/res/Img/greenCopy.svg" : "qrc:/res/Img/copy.svg"
                            onBtnClicked: vaultModel.copy(RolePassword)
                        }

                        CustomImgButton {
                            source: listViewIcons.hovered ? "qrc:/res/Img/greenEdit.svg" :  "qrc:/res/Img/edit.svg"
                            onBtnClicked: {
                                popupLoader.visible = true
                                popupLoader.setSource("qrc:/res/Controls/ManageCredentials.qml",  {
                                                "addCredentials": false,
                                                "titleText": RoleTitle,
                                                "userText": RoleUsername,
                                                "passwordText": vaultModel.getUserPassword(RolePassword),
                                                "index": index
                                            })
                            }
                        }

                        CustomImgButton {
                            source: listViewIcons.hovered ? "qrc:/res/Img/greenBin.svg" : "qrc:/res/Img/bin.svg"
                            onBtnClicked: {
                                pagePopupLoader.sourceComponent = deleteCredentialsPopupComponent
                                pagePopupLoader.item.index = index
                                pagePopupLoader.item.open()
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: listViewRowDelegate
                    hoverEnabled: true
                    onEntered: {
                        listViewDelegate.color = applicationResources.primaryColor
                        listViewIcons.hovered = true
                    }
                    onExited: {
                        listViewDelegate.color = applicationResources.backgroundColor
                        listViewIcons.hovered = false
                    }
                }
            }
        }

        CustomVaultFooter {
            Layout.fillWidth: true
            implicitHeight: 55
        }
    }
}
