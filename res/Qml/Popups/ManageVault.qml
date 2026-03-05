import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../Controls"

Rectangle {
    width: 480
    height: 280
    color: applicationResources.backgroundColor
    radius: applicationResources.radius
    border.color: applicationResources.secondaryColor
    border.width: 1

    property string type
    property string title
    property string description

    signal btnClicked

    function resetInputs() {
        keyInput.isPassHide = true
        keyInput.echoMode = TextInput.Password
        keyInput.text = ""
        closePopups();
    }

    function showDialogMessage(message) {
        border.color = applicationResources.warningColor
        dialogMessage.text = message
        hideTimer.start();
    }

    Connections {
        target: vaultModel
        function onExportSuccessful() { resetInputs() }
        function onIncorrectForm(message) { showDialogMessage(message) }
        function onLoginFailed(message) { showDialogMessage(message) }
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
            text: title
            font.pixelSize: 22
            font.bold: true
        }

        QLabel {
            Layout.alignment: Qt.AlignHCenter
            text: description
            font.pixelSize: 18
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: applicationResources.spacing - 15

            QTextInput {
                id: keyInput
                placeholderText: qsTr("Enter Password")
                echoMode: TextInput.Password
                textFieldType: "PASSWORD"
            }

            Item {
                Layout.preferredWidth: 320
                Layout.preferredHeight: dialogMessage.height

                QLabel {
                    id: dialogMessage
                    anchors.centerIn: parent
                    text: ""
                    color: applicationResources.warningColor
                    font.pixelSize: 16
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: applicationResources.spacing

            QButton {
                btnText: qsTr("Continue")
                color: applicationResources.activeButtonColor
                border.width: 0
                onBtnClicked: {
                    if(type == "EXPORT")
                        vaultModel.exportJson(keyInput.text)
                    else
                        vaultModel.deleteKey(keyInput.text)
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
