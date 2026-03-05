import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    spacing: applicationResources.spacing

    QLabel {
        text: "PROVAULT"
        color: applicationResources.secondaryColor
        font.pixelSize: 24
        font.bold: true
    }

    Item {
        Layout.fillWidth: true
    }

    // QImgButton {
    //     source: "qrc:/res/Img/minimize.svg"
    //     visible: vaultModel.hasMasterKey
    //     onBtnClicked: window.showMinimized()
    // }

    QImgButton {
        source: "qrc:/res/Img/close.svg"
        onBtnClicked: window.close()
    }
}
