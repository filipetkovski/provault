import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../Controls"

Rectangle {
    width: 600
    height: 380
    color: applicationResources.backgroundColor
    radius: applicationResources.radius
    border.color: applicationResources.secondaryColor
    border.width: 1

    Component.onDestruction: {
        titleInput.text = ""
        userInput.text = ""
        passwordInput.text = ""
        index = ""
    }

    property bool addCredentials
    property bool hasMasterKey: vaultModel.hasMasterKey
    property alias titleText: titleInput.text
    property alias userText: userInput.text
    property alias passwordText: passwordInput.text
    property var index

    Connections {
        target: vaultModel
        function onIncorrectForm(message) {
            border.color = applicationResources.warningColor
            dialogMessage.text = message
            hideTimer.start();
        }
    }

    Timer {
        id: hideTimer
        interval: 2000
        running: false
        repeat: false
        onTriggered: {
            border.color = applicationResources.secondaryColor
            dialogMessage.text = ""
        }
    }

    ColumnLayout {
        anchors.margins: applicationResources.margin
        anchors.fill: parent
        spacing: applicationResources.spacing - 15

        QLabel {
            Layout.alignment: Qt.AlignHCenter
            text: addCredentials ? qsTr("Add New Entry") : qsTr("Edit Old Entry")
            font.bold: true
            font.pixelSize: 22
        }

        QLabel {
            Layout.alignment: Qt.AlignHCenter
            text: addCredentials ? qsTr("Create a new entry to store your credentials.") : qsTr("Edit your credentials.")
            font.pixelSize: 18
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: applicationResources.spacing - 10

            QTextInput {
                id: titleInput
                placeholderText: qsTr("Title")
            }

            QTextInput {
                id: userInput
                placeholderText: qsTr("Username")
            }

            QTextInput {
                id: passwordInput
                placeholderText: qsTr("Password")
                echoMode: TextInput.Password
                textFieldType: "PASSWORD"
            }

            Item {
                Layout.preferredWidth: 320
                Layout.preferredHeight: 22

                RowLayout {
                    anchors.fill: parent
                    spacing: applicationResources.spacing

                    Item {
                        implicitHeight: 22

                        QLabel {
                            id: dialogMessage
                            text: ""
                            color: applicationResources.warningColor
                            font.pixelSize: 16
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    QButton {
                        id: generate
                        btnText: qsTr("Generate")
                        color: applicationResources.backgroundColor
                        btnFontSize: 16
                        border.width: 0
                        visible: hasMasterKey
                        onBtnClicked: {
                            var generatedPassword = vaultModel.generateStrongPassword()
                            passwordInput.text = generatedPassword

                            passwordInput.isPassHide = false
                            passwordInput.echoMode = TextInput.Normal
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: applicationResources.spacing

            QButton {
                id: addBtn
                btnText: qsTr("Save")
                color: applicationResources.activeButtonColor
                border.width: 0
                onBtnClicked: {
                    addCredentials ?
                        vaultModel.addData(titleInput.text.trim(), userInput.text.trim(), passwordInput.text.trim()) :
                        vaultModel.editData(index, titleInput.text.trim(), userInput.text.trim(), passwordInput.text.trim())
                }
            }

            QButton {
                btnText: qsTr("Cancel")
                color: applicationResources.primaryColor
                onBtnClicked: closePopups()
            }
        }
    }
}
