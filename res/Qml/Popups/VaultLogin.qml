import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../Controls"

Rectangle {
    width: 480
    height: hasMasterKey ? 280 : 340
    color: applicationResources.backgroundColor
    radius: applicationResources.radius
    border.color: applicationResources.secondaryColor
    border.width: 1

    property bool hasMasterKey: vaultModel.hasMasterKey

    function resetInputs() {
        if(!hasMasterKey) {
            confirmKeyInput.text = ""
            keyInput.isPassHide = true
            confirmKeyInput.isPassHide = true
            keyInput.echoMode = TextInput.Password
            confirmKeyInput.echoMode = TextInput.Password
        }
        keyInput.text = ""
    }

    function showDialogMessage(message) {
        border.color = applicationResources.warningColor
        dialogMessage.text = message
        hideTimer.start();
    }

    Connections {
        target: vaultModel
        function onLoginSuccessful() { resetInputs() }
        function onKeyCreatedSuccessful() { resetInputs() }
        function onIncorrectForm(message) { showDialogMessage(message) }
        function onLoginFailed(message) { showDialogMessage(message) }
    }

    Timer {
        id: hideTimer
        interval: 3000
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
        // spacing: applicationResources.spacing - 15
        spacing: 0

        QLabel {
            Layout.alignment: Qt.AlignHCenter
            text: hasMasterKey ? qsTr("Unlock the Vault") : qsTr("Create Vault Password")
            font.pixelSize: 22
            font.bold: true
        }

        QLabel {
            Layout.alignment: Qt.AlignHCenter
            text: hasMasterKey ? qsTr("Enter your Password to unlock the vault.") : qsTr("You only need to remember this password!")
            font.pixelSize: 18
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: applicationResources.spacing - 15

            QTextInput {
                id: keyInput
                placeholderText: qsTr("Password")
                echoMode: TextInput.Password
                textFieldType: "PASSWORD"
            }

            QTextInput {
                id: confirmKeyInput
                Layout.topMargin: !hasMasterKey ? 15 : 7
                placeholderText: qsTr("Re-type Vault Password")
                echoMode: TextInput.Password
                textFieldType: "PASSWORD"
                visible: !hasMasterKey
            }

            RowLayout {
                implicitWidth: 320
                implicitHeight: 22

                Item {
                    implicitWidth: 320 - (hasMasterKey ? 0 : generate.width)
                    implicitHeight: 22

                    QLabel {
                        id: dialogMessage
                        anchors.centerIn: parent
                        text: ""
                        color: applicationResources.warningColor
                        font.pixelSize: 16
                    }
                }

                QButton {
                    id: generate
                    btnText: qsTr("Generate")
                    color: applicationResources.backgroundColor
                    btnFontSize: 16
                    border.width: 0
                    visible: !hasMasterKey
                    onBtnClicked: {
                        var generatedPassword = vaultModel.generateStrongPassword()
                        keyInput.text = generatedPassword
                        confirmKeyInput.text = generatedPassword

                        keyInput.isPassHide = false
                        confirmKeyInput.isPassHide = false
                        keyInput.echoMode = TextInput.Normal
                        confirmKeyInput.echoMode = TextInput.Normal
                    }
                }
            }
        }

        QButton {
            Layout.alignment: Qt.AlignHCenter
            btnText: hasMasterKey ? qsTr("Unlock Vault") : qsTr("Save & Continue")
            color: applicationResources.activeButtonColor
            border.width: 0
            onBtnClicked: hasMasterKey ? vaultModel.login(keyInput.text.trim()) : vaultModel.createKey(keyInput.text.trim(), confirmKeyInput.text.trim())
        }
    }
}
