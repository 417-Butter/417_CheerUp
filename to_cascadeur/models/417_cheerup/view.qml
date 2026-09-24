import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Dialogs as Dialogs

Dialogs.DialogBase {
    id: root
    implicitWidth: 420
    implicitHeight: 580

    // Python側モデルを root スコープで明示的に保持
    // （ListView内で "model" キーワードが衝突するのを防ぐ）
    property var cheerup: model

    readonly property var uiStrings: ({
        "en": {
            title:        "\uD83C\uDF89 CheerUp! v1.0.0",
            tab_settings: "Settings",
            tab_presets:  "Messages",
            grp_lang:     "Language",
            grp_interval: "Interval",
            unit:         "min",
            grp_opts:     "Options",
            opt_elapsed:  "Show elapsed time",
            opt_prefix:   "Show [CheerUp!] prefix",
            opt_quotes:   "Wrap messages in quotes",
            grp_timer:    "Timer Control",
            running:      "\u23F0 Running",
            stopped:      "\u23F8 Stopped",
            btn_start:    "Start / Reset",
            btn_stop:     "Stop",
            btn_close:    "Close",
            lbl_group:    "Group:",
            ph_rename:    "Rename group...",
            btn_rename:   "Rename",
            btn_add_grp:  "New Group",
            btn_del_grp:  "Delete Group",
            ph:           "Type a new message...",
            btn_add:      "Add",
            btn_update:   "Update",
            btn_export:   "Export JSON",
            btn_export_short: "Export",
            btn_import:   "Import (JSON / TXT)",
            btn_import_short: "Import",
            btn_cancel:   "Cancel",
            export_scope_title:   "Export Default presets as:",
            export_scope_current: "Current language",
            export_scope_all:     "All languages",
            locked:       "\uD83D\uDD12 Default (read-only)"
        },
        "ja": {
            title:        "\uD83C\uDF89 CheerUp! v1.0.0",
            tab_settings: "\u8A2D\u5B9A",
            tab_presets:  "\u30E1\u30C3\u30BB\u30FC\u30B8",
            grp_lang:     "\u8A00\u8A9E",
            grp_interval: "\u901A\u77E5\u9593\u9694",
            unit:         "\u5206",
            grp_opts:     "\u30AA\u30D7\u30B7\u30E7\u30F3",
            opt_elapsed:  "\u7D4C\u904E\u6642\u9593\u3092\u8868\u793A\u3059\u308B",
            opt_prefix:   "\u30D7\u30EC\u30D5\u30A3\u30C3\u30AF\u30B9 [CheerUp!] \u3092\u8868\u793A",
            grp_timer:    "\u30BF\u30A4\u30DE\u30FC\u64CD\u4F5C",
            running:      "\u23F0 \u7A3C\u50CD\u4E2D",
            stopped:      "\u23F8 \u505C\u6B62\u4E2D",
            btn_start:    "\u958B\u59CB / \u30EA\u30BB\u30C3\u30C8",
            btn_stop:     "\u505C\u6B62",
            btn_close:    "\u9589\u3058\u308B",
            lbl_group:    "\u30B0\u30EB\u30FC\u30D7:",
            ph_rename:    "\u30B0\u30EB\u30FC\u30D7\u540D\u3092\u5909\u66F4...",
            btn_rename:   "\u540D\u524D\u5909\u66F4",
            btn_add_grp:  "\u30B0\u30EB\u30FC\u30D7\u8FFD\u52A0",
            btn_del_grp:  "\u30B0\u30EB\u30FC\u30D7\u524A\u9664",
            ph:           "\u65B0\u3057\u3044\u30E1\u30C3\u30BB\u30FC\u30B8...",
            btn_add:      "\u8FFD\u52A0",
            btn_update:   "\u66F4\u65B0",
            opt_quotes:   "\u30E1\u30C3\u30BB\u30FC\u30B8\u306B\u300C\u300D\u3092\u4ED8\u3051\u308B",
            btn_export:   "\u30A8\u30AF\u30B9\u30DD\u30FC\u30C8",
            btn_export_short: "\u30A8\u30AF\u30B9\u30DD\u30FC\u30C8",
            btn_import:   "\u30A4\u30F3\u30DD\u30FC\u30C8 (JSON / TXT)",
            btn_import_short: "\u30A4\u30F3\u30DD\u30FC\u30C8",
            btn_cancel:   "\u30AD\u30E3\u30F3\u30BB\u30EB",
            export_scope_title:   "Default\u3092\u30A8\u30AF\u30B9\u30DD\u30FC\u30C8:",
            export_scope_current: "\u73FE\u5728\u306E\u8A00\u8A9E\u306E\u307F",
            export_scope_all:     "\u5168\u8A00\u8A9E",
            locked:       "\uD83D\uDD12 \u30C7\u30D5\u30A9\u30EB\u30C8\uFF08\u5909\u66F4\u4E0D\u53EF\uFF09"
        },
        "ko": {
            title:        "\uD83C\uDF89 CheerUp! v1.0.0",
            tab_settings: "\uC124\uC815",
            tab_presets:  "\uBA54\uC2DC\uC9C0",
            grp_lang:     "\uC5B8\uC5B4",
            grp_interval: "\uC54C\uB9BC \uAC04\uACA9",
            unit:         "\uBD84",
            grp_opts:     "\uC635\uC158",
            opt_elapsed:  "\uACBD\uACFC \uC2DC\uAC04 \uD45C\uC2DC",
            opt_prefix:   "\uC811\uB450\uC0AC [CheerUp!] \uD45C\uC2DC",
            opt_quotes:   "\uBA54\uC2DC\uC9C0\uC5D0 \u300C\u300D \uCD94\uAC00",
            grp_timer:    "\uD0C0\uC774\uBA38",
            running:      "\u23F0 \uC2E4\uD589 \uC911",
            stopped:      "\u23F8 \uC815\uC9C0\uB428",
            btn_start:    "\uC2DC\uC791 / \uC7AC\uC124\uC815",
            btn_stop:     "\uC815\uC9C0",
            btn_close:    "\uB2EB\uAE30",
            lbl_group:    "\uADF8\uB8F9:",
            ph_rename:    "\uADF8\uB8F9 \uC774\uB984 \uBCC0\uACBD...",
            btn_rename:   "\uC774\uB984 \uBCC0\uACBD",
            btn_add_grp:  "\uADF8\uB8F9 \uCD94\uAC00",
            btn_del_grp:  "\uADF8\uB8F9 \uC0AD\uC81C",
            ph:           "\uC0C8 \uBA54\uC2DC\uC9C0...",
            btn_add:      "\uCD94\uAC00",
            btn_update:   "\uC218\uC815",
            btn_export:   "\uB0B4\uBCF4\uB0B4\uAE30",
            btn_export_short: "\uB0B4\uBCF4\uB0B4\uAE30",
            btn_import:   "\uAC00\uC838\uC624\uAE30 (JSON / TXT)",
            btn_import_short: "\uAC00\uC838\uC624\uAE30",
            btn_cancel:   "\uCDE8\uC18C",
            export_scope_title:   "Default \uB0B4\uBCF4\uB0B4\uAE30:",
            export_scope_current: "\uD604\uC7AC \uC5B8\uC5B4\uB9CC",
            export_scope_all:     "\uBAA8\uB4E0 \uC5B8\uC5B4",
            locked:       "\uD83D\uDD12 \uAE30\uBCF8 (\uC218\uC815 \uBD88\uAC00)"
        },
        "zh": {
            title:        "\uD83C\uDF89 CheerUp! v1.0.0",
            tab_settings: "\u8BBE\u7F6E",
            tab_presets:  "\u6D88\u606F",
            grp_lang:     "\u8BED\u8A00",
            grp_interval: "\u901A\u77E5\u95F4\u9694",
            unit:         "\u5206\u949F",
            grp_opts:     "\u9009\u9879",
            opt_elapsed:  "\u663E\u793A\u7ECF\u8FC7\u65F6\u95F4",
            opt_prefix:   "\u663E\u793A\u524D\u7F00 [CheerUp!]",
            opt_quotes:   "\u7ED9\u6D88\u606F\u52A0\u4E0A\u201C\u201D",
            grp_timer:    "\u8BA1\u65F6\u5668",
            running:      "\u23F0 \u8FD0\u884C\u4E2D",
            stopped:      "\u23F8 \u5DF2\u505C\u6B62",
            btn_start:    "\u5F00\u59CB / \u91CD\u7F6E",
            btn_stop:     "\u505C\u6B62",
            btn_close:    "\u5173\u95ED",
            lbl_group:    "\u5206\u7EC4:",
            ph_rename:    "\u91CD\u547D\u540D\u5206\u7EC4...",
            btn_rename:   "\u91CD\u547D\u540D",
            btn_add_grp:  "\u6DFB\u52A0\u5206\u7EC4",
            btn_del_grp:  "\u5220\u9664\u5206\u7EC4",
            ph:           "\u8F93\u5165\u65B0\u6D88\u606F...",
            btn_add:      "\u6DFB\u52A0",
            btn_update:   "\u66F4\u65B0",
            btn_export:   "\u5BFC\u51FA JSON",
            btn_export_short: "\u5BFC\u51FA",
            btn_import:   "\u5BFC\u5165 (JSON / TXT)",
            btn_import_short: "\u5BFC\u5165",
            btn_cancel:   "\u53D6\u6D88",
            export_scope_title:   "\u5BFC\u51FA Default \u9884\u8BBE\u4E3A:",
            export_scope_current: "\u4EC5\u5F53\u524D\u8BED\u8A00",
            export_scope_all:     "\u6240\u6709\u8BED\u8A00",
            locked:       "\uD83D\uDD12 \u9ED8\u8BA4\uFF08\u53EA\u8BFB\uFF09"
        }
    })

    property string currentLang: cheerup ? (cheerup.language || "en") : "en"
    property var t: uiStrings[currentLang] || uiStrings["en"]

    Connections {
        target: root.cheerup
        function onLanguageChanged() {
            if (root.cheerup) root.currentLang = root.cheerup.language
        }
    }

    contentItem: Rectangle {
        color: "#1e1e1e"
        Loader {
            anchors.fill: parent
            anchors.margins: 10
            sourceComponent: root.cheerup ? mainComponent : null
        }
    }

    Component {
        id: mainComponent

        ColumnLayout {
            anchors.fill: parent
            spacing: 12

            // ボタンスタイル共通
            QtObject {
                id: bs
                readonly property color bg:    "#3a3a3a"
                readonly property color bgHov: "#4d4d4d"
                readonly property color bgPrs: "#252525"
                readonly property color bdr:   "#5a5a5a"
                readonly property color txt:   "#e8e8e8"
                readonly property int   r:     4
            }

            // タイトル
            Text {
                text: root.t.title
                font.pixelSize: 20; font.bold: true; color: "#4CAF50"
            }

            // タブバー
            RowLayout {
                id: tabBar
                Layout.fillWidth: true
                spacing: 2
                property int currentIndex: 0

                Repeater {
                    model: 2
                    Rectangle {
                        Layout.fillWidth: true; height: 35; radius: 4
                        color: tabBar.currentIndex === index ? "#4CAF50" : "#333"
                        Text {
                            anchors.centerIn: parent
                            text: index === 0 ? root.t.tab_settings : root.t.tab_presets
                            color: "white"; font.pixelSize: 14; font.bold: tabBar.currentIndex === index
                        }
                        MouseArea { anchors.fill: parent; onClicked: tabBar.currentIndex = index }
                    }
                }
            }

            // ページ切り替え
            StackLayout {
                currentIndex: tabBar.currentIndex
                Layout.fillWidth: true
                Layout.fillHeight: true

                // ========== PAGE 1: Settings ==========
                ColumnLayout {
                    spacing: 12

                    Flickable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentWidth: width
                        contentHeight: settingsCol.height
                        clip: true

                        Column {
                            id: settingsCol
                            width: parent.width
                            spacing: 18

                            // 言語選択
                            Column {
                                spacing: 8; width: parent.width
                                Text { text: root.t.grp_lang; color: "#e0e0e0"; font.pixelSize: 14; font.bold: true }
                                Row {
                                    spacing: 8
                                    Repeater {
                                        model: ListModel {
                                            ListElement { lcode: "en"; llabel: "EN" }
                                            ListElement { lcode: "ja"; llabel: "\u65E5\u672C\u8A9E" }
                                            ListElement { lcode: "ko"; llabel: "\ud55c\uad6d\uc5b4" }
                                            ListElement { lcode: "zh"; llabel: "\u4E2D\u6587" }
                                        }
                                        Rectangle {
                                            property string myCode: lcode
                                            width: 80; height: 32; radius: 4
                                            color: root.currentLang === myCode ? "#4CAF50" : "#333"
                                            Text {
                                                anchors.centerIn: parent
                                                text: llabel; color: "white"
                                                font.pixelSize: 13
                                                font.bold: root.currentLang === myCode
                                            }
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    root.currentLang = myCode
                                                    if (root.cheerup) root.cheerup.language = myCode
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // 間隔
                            Column {
                                spacing: 8; width: parent.width
                                Text { text: root.t.grp_interval; color: "#e0e0e0"; font.pixelSize: 14; font.bold: true }
                                Row {
                                    spacing: 10
                                    SpinBox {
                                        from: 1; to: 120
                                        value: root.cheerup ? root.cheerup.intervalMinutes : 5
                                        font.pixelSize: 14; height: 32
                                        onValueModified: if (root.cheerup) root.cheerup.intervalMinutes = value
                                    }
                                    Text {
                                        text: root.t.unit; color: "#ccc"
                                        font.pixelSize: 14; anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }

                            // オプション
                            Column {
                                spacing: 8; width: parent.width
                                Text { text: root.t.grp_opts; color: "#e0e0e0"; font.pixelSize: 14; font.bold: true }
                                Column {
                                    spacing: 8
                                    Repeater {
                                        model: [
                                            { label: root.t.opt_elapsed, prop: "showElapsed" },
                                            { label: root.t.opt_prefix,  prop: "showPrefix"  },
                                            { label: root.t.opt_quotes,  prop: "showQuotes"  }
                                        ]
                                        Row {
                                            spacing: 10
                                            property bool propVal: root.cheerup ? root.cheerup[modelData.prop] : false
                                            Switch {
                                                checked: parent.propVal
                                                onToggled: if (root.cheerup) root.cheerup[modelData.prop] = checked
                                                indicator: Rectangle {
                                                    implicitWidth: 36; implicitHeight: 20
                                                    x: parent.leftPadding
                                                    y: parent.height / 2 - height / 2
                                                    radius: 10
                                                    color: parent.checked ? "#4CAF50" : "#555"
                                                    Rectangle {
                                                        x: parent.parent.checked ? parent.width - width - 2 : 2
                                                        y: 2; width: 16; height: 16; radius: 8; color: "white"
                                                        Behavior on x { NumberAnimation { duration: 150 } }
                                                    }
                                                }
                                            }
                                            Text {
                                                text: modelData.label; color: "#ccc"
                                                font.pixelSize: 14; anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                    }
                                }
                            }

                            // タイマー
                            Column {
                                spacing: 8; width: parent.width
                                Text { text: root.t.grp_timer; color: "#e0e0e0"; font.pixelSize: 14; font.bold: true }
                                Row {
                                    spacing: 12
                                    Row {
                                        spacing: 8
                                        Rectangle {
                                            width: 12; height: 12; radius: 6
                                            color: root.cheerup && root.cheerup.isRunning ? "#4CAF50" : "#777"
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        Text {
                                            text: root.cheerup && root.cheerup.isRunning ? root.t.running : root.t.stopped
                                            color: root.cheerup && root.cheerup.isRunning ? "#4CAF50" : "#999"
                                            font.pixelSize: 14; font.bold: true
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                    Button {
                                        background: Rectangle {
                                            color: parent.pressed ? bs.bgPrs : (parent.hovered ? bs.bgHov : bs.bg)
                                            radius: bs.r
                                            border.color: bs.bdr; border.width: 1
                                        }
                                        contentItem: Text {
                                            text: parent.text; color: bs.txt
                                            font.pixelSize: 13
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        text: root.t.btn_start; font.pixelSize: 13; height: 32
                                        onClicked: if (root.cheerup) root.cheerup.start_timer_from_ui()
                                    }
                                    Button {
                                        background: Rectangle {
                                            color: parent.pressed ? bs.bgPrs : (parent.hovered ? bs.bgHov : bs.bg)
                                            radius: bs.r
                                            border.color: bs.bdr; border.width: 1
                                        }
                                        contentItem: Text {
                                            text: parent.text; color: bs.txt
                                            font.pixelSize: 13
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        text: root.t.btn_stop; font.pixelSize: 13; height: 32
                                        enabled: root.cheerup && root.cheerup.isRunning
                                        onClicked: if (root.cheerup) root.cheerup.stop_timer_from_ui()
                                    }
                                }
                            }
                        }
                    }
                }

                // ========== PAGE 2: Messages ==========
                ColumnLayout {
                    id: presetsPage
                    spacing: 8
                    property int selIdx: -1
                    property bool isDefault: root.cheerup ? (root.cheerup.activeGroup === "Default") : true
                    property bool renaming: false
                    property bool addingGroup: false

                    // グループ選択行（コンボ + ✏️ + 追加 + 削除）
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text { text: root.t.lbl_group; color: "#ccc"; font.pixelSize: 14 }

                        ComboBox {
                            id: groupCombo
                            Layout.fillWidth: true
                            font.pixelSize: 14
                            model: root.cheerup ? root.cheerup.availableGroups : []
                            currentIndex: {
                                if (!root.cheerup) return 0
                                var idx = root.cheerup.availableGroups.indexOf(root.cheerup.activeGroup)
                                return idx >= 0 ? idx : 0
                            }
                            onActivated: {
                                if (root.cheerup) {
                                    root.cheerup.activeGroup = currentText
                                    msgList.refreshModel()
                                    presetsPage.renaming = false
                                }
                            }
                            Connections {
                                target: root.cheerup
                                function onGroupsDictChanged() {
                                    var arr = root.cheerup.availableGroups
                                    groupCombo.model = arr
                                    var idx = arr.indexOf(root.cheerup.activeGroup)
                                    groupCombo.currentIndex = idx >= 0 ? idx : 0
                                    presetsPage.renaming = false
                                }
                            }
                        }

                        // ✏️ リネームボタン（Default以外のみ）
                        Rectangle {
                            visible: !presetsPage.isDefault
                            width: 30; height: 30; radius: 4
                            color: editHover.containsMouse ? "#444" : "transparent"
                            Text {
                                anchors.centerIn: parent
                                text: presetsPage.renaming ? "\u2713" : "\u270F\uFE0F"
                                font.pixelSize: presetsPage.renaming ? 16 : 14
                                color: presetsPage.renaming ? "#4CAF50" : "#aaa"
                            }
                            MouseArea {
                                id: editHover
                                anchors.fill: parent; hoverEnabled: true
                                onClicked: {
                                    if (presetsPage.renaming) {
                                        // 確定
                                        if (root.cheerup && renameField.text.trim() !== "" &&
                                            renameField.text.trim() !== root.cheerup.activeGroup) {
                                            root.cheerup.rename_group(root.cheerup.activeGroup, renameField.text.trim())
                                        }
                                        presetsPage.renaming = false
                                    } else {
                                        // 編集開始
                                        renameField.text = root.cheerup ? root.cheerup.activeGroup : ""
                                        presetsPage.renaming = true
                                        renameField.forceActiveFocus()
                                        renameField.selectAll()
                                    }
                                }
                            }
                            ToolTip.visible: editHover.containsMouse
                            ToolTip.delay: 500
                            ToolTip.text: presetsPage.renaming ? root.t.btn_rename : root.t.ph_rename
                        }

                        // 追加・削除
                        Button {
                            background: Rectangle {
                                color: parent.pressed ? bs.bgPrs : (parent.hovered ? bs.bgHov : bs.bg)
                                radius: bs.r
                                border.color: bs.bdr; border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text; color: bs.txt
                                font.pixelSize: 13
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            text: "+"; font.pixelSize: 16; width: 30; height: 30
                            onClicked: {
                                if (root.cheerup && newGroupField.text.trim()) {
                                    root.cheerup.add_new_group(newGroupField.text.trim())
                                    newGroupField.text = ""
                                } else {
                                    presetsPage.addingGroup = !presetsPage.addingGroup
                                    if (presetsPage.addingGroup) newGroupField.forceActiveFocus()
                                }
                            }
                            ToolTip.visible: hovered
                            ToolTip.delay: 500
                            ToolTip.text: root.t.btn_add_grp
                        }
                        Button {
                            background: Rectangle {
                                color: parent.pressed ? bs.bgPrs : (parent.hovered ? bs.bgHov : bs.bg)
                                radius: bs.r
                                border.color: bs.bdr; border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text; color: bs.txt
                                font.pixelSize: 13
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            text: "\u2212"; font.pixelSize: 16; width: 30; height: 30
                            enabled: !presetsPage.isDefault
                            onClicked: if (root.cheerup) root.cheerup.remove_current_group()
                            ToolTip.visible: hovered
                            ToolTip.delay: 500
                            ToolTip.text: root.t.btn_del_grp
                        }
                    }

                    // インライン: グループ名リネーム入力（✏️クリック時のみ表示）
                    TextField {
                        id: renameField
                        Layout.fillWidth: true
                        visible: presetsPage.renaming && !presetsPage.isDefault
                        placeholderText: root.t.ph_rename
                        font.pixelSize: 13; height: 32
                        Keys.onReturnPressed: {
                            if (root.cheerup && text.trim() !== "" && text.trim() !== root.cheerup.activeGroup)
                                root.cheerup.rename_group(root.cheerup.activeGroup, text.trim())
                            presetsPage.renaming = false
                        }
                        Keys.onEscapePressed: { presetsPage.renaming = false }
                    }

                    // インライン: 新規グループ入力（+ クリック後に表示）
                    RowLayout {
                        Layout.fillWidth: true
                        visible: presetsPage.addingGroup
                        spacing: 6
                        TextField {
                            id: newGroupField
                            Layout.fillWidth: true
                            placeholderText: root.t.btn_add_grp + "..."
                            font.pixelSize: 13; height: 32
                            Keys.onReturnPressed: {
                                if (root.cheerup && text.trim()) root.cheerup.add_new_group(text.trim())
                                text = ""; presetsPage.addingGroup = false
                            }
                            Keys.onEscapePressed: { text = ""; presetsPage.addingGroup = false }
                        }
                        Button {
                            background: Rectangle {
                                color: parent.pressed ? bs.bgPrs : (parent.hovered ? bs.bgHov : bs.bg)
                                radius: bs.r
                                border.color: bs.bdr; border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text; color: bs.txt
                                font.pixelSize: 13
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            text: root.t.btn_add_grp; font.pixelSize: 13; height: 32
                            enabled: newGroupField.text.trim() !== ""
                            onClicked: {
                                if (root.cheerup) root.cheerup.add_new_group(newGroupField.text.trim())
                                newGroupField.text = ""; presetsPage.addingGroup = false
                            }
                        }
                    }

                    // メッセージ一覧
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#1e1e1e"; border.color: "#444"; radius: 4; clip: true

                        ListView {
                            id: msgList
                            anchors.fill: parent
                            anchors.margins: 4
                            clip: true

                            // ListModel は ListView のローカルモデル
                            model: ListModel { id: msgListModel }

                            // cheerup を直接使う（"model" キーワード衝突を回避）
                            function refreshModel() {
                                msgListModel.clear()
                                if (!root.cheerup) return
                                var arr = root.cheerup.getActiveMessages()
                                if (!arr) return
                                for (var i = 0; i < arr.length; i++) {
                                    msgListModel.append({ msg: arr[i], idx: i })
                                }
                                presetsPage.selIdx = -1
                                inputField.text = ""
                            }

                            Component.onCompleted: refreshModel()

                            Connections {
                                target: root.cheerup
                                function onGroupsDictChanged() { msgList.refreshModel() }
                                function onLanguageChanged()   { msgList.refreshModel() }
                            }

                            delegate: Rectangle {
                                width: msgList.width
                                height: 34
                                color: idx === presetsPage.selIdx ? "#2e4a6e"
                                     : hovered ? "#2a2a3a" : "transparent"
                                radius: 4
                                property bool hovered: false

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered:  parent.hovered = true
                                    onExited:   parent.hovered = false
                                    onClicked: {
                                        presetsPage.selIdx = idx
                                        inputField.text = msg
                                    }
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 4
                                    spacing: 4

                                    // ロックアイコン（Default時のみ）
                                    Text {
                                        visible: presetsPage.isDefault
                                        text: "\uD83D\uDD12"; font.pixelSize: 11; color: "#777"
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: msg
                                        color: presetsPage.isDefault ? "#999" : "#eee"
                                        font.pixelSize: 13
                                        elide: Text.ElideRight
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    // × 削除ボタン（Defaultでない場合のみ）
                                    Rectangle {
                                        visible: !presetsPage.isDefault
                                        width: 24; height: 24; radius: 4
                                        color: delHover.containsMouse ? "#c0392b" : "transparent"
                                        Text {
                                            anchors.centerIn: parent
                                            text: "\u00D7"; color: "#e74c3c"
                                            font.pixelSize: 16; font.bold: true
                                        }
                                        MouseArea {
                                            id: delHover
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                if (root.cheerup) root.cheerup.remove_message(idx)
                                            }
                                        }
                                    }
                                }
                            }

                            ScrollBar.vertical: ScrollBar {}
                        }
                    }

                    // Default時の注記
                    Text {
                        visible: presetsPage.isDefault
                        text: root.t.locked
                        color: "#777"; font.pixelSize: 12; font.italic: true
                    }

                    // 入力欄（Defaultでない場合のみ）
                    TextField {
                        id: inputField
                        Layout.fillWidth: true
                        visible: !presetsPage.isDefault
                        placeholderText: root.t.ph
                        font.pixelSize: 13; height: 32
                    }

                    // 追加・更新ボタン（Defaultでない場合のみ）
                    RowLayout {
                        Layout.fillWidth: true
                        visible: !presetsPage.isDefault
                        spacing: 8
                        Button {
                            background: Rectangle {
                                color: parent.pressed ? bs.bgPrs : (parent.hovered ? bs.bgHov : bs.bg)
                                radius: bs.r
                                border.color: bs.bdr; border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text; color: bs.txt
                                font.pixelSize: 13
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            text: root.t.btn_add; font.pixelSize: 13; height: 32
                            Layout.fillWidth: true
                            enabled: inputField.text.trim() !== ""
                            onClicked: {
                                if (root.cheerup) root.cheerup.add_message(inputField.text.trim())
                                inputField.text = ""
                            }
                        }
                        Button {
                            background: Rectangle {
                                color: parent.pressed ? bs.bgPrs : (parent.hovered ? bs.bgHov : bs.bg)
                                radius: bs.r
                                border.color: bs.bdr; border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text; color: bs.txt
                                font.pixelSize: 13
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            text: root.t.btn_update; font.pixelSize: 13; height: 32
                            Layout.fillWidth: true
                            enabled: presetsPage.selIdx >= 0 && inputField.text.trim() !== ""
                            onClicked: {
                                if (root.cheerup) root.cheerup.update_message(presetsPage.selIdx, inputField.text.trim())
                                inputField.text = ""; presetsPage.selIdx = -1
                            }
                        }
                    }



                    // Default エクスポート: 言語範囲選択ポップアップ
                    Popup {
                        id: exportScopePopup
                        anchors.centerIn: Overlay.overlay
                        width: 300; height: 140
                        modal: true
                        background: Rectangle {
                            color: "#2d2d2d"; border.color: "#555"; radius: 8
                        }
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12
                            Text {
                                text: root.t.export_scope_title
                                color: "#e0e0e0"; font.pixelSize: 13; font.bold: true
                                Layout.fillWidth: true
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Button {
                                    background: Rectangle {
                                        color: parent.pressed ? bs.bgPrs : (parent.hovered ? bs.bgHov : bs.bg)
                                        radius: bs.r
                                        border.color: bs.bdr; border.width: 1
                                    }
                                    contentItem: Text {
                                        text: parent.text; color: bs.txt
                                        font.pixelSize: 13
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    text: root.t.export_scope_current
                                    Layout.fillWidth: true; font.pixelSize: 13; height: 32
                                    onClicked: {
                                        exportScopePopup.close()
                                        if (root.cheerup) root.cheerup.export_current("current")
                                    }
                                }
                                Button {
                                    background: Rectangle {
                                        color: parent.pressed ? bs.bgPrs : (parent.hovered ? bs.bgHov : bs.bg)
                                        radius: bs.r
                                        border.color: bs.bdr; border.width: 1
                                    }
                                    contentItem: Text {
                                        text: parent.text; color: bs.txt
                                        font.pixelSize: 13
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    text: root.t.export_scope_all
                                    Layout.fillWidth: true; font.pixelSize: 13; height: 32
                                    onClicked: {
                                        exportScopePopup.close()
                                        if (root.cheerup) root.cheerup.export_current("all")
                                    }
                                }
                            }
                            Button {
                                background: Rectangle {
                                    color: parent.pressed ? bs.bgPrs : (parent.hovered ? bs.bgHov : bs.bg)
                                    radius: bs.r
                                    border.color: bs.bdr; border.width: 1
                                }
                                contentItem: Text {
                                    text: parent.text; color: bs.txt
                                    font.pixelSize: 13
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                text: root.t.btn_cancel
                                Layout.alignment: Qt.AlignRight; font.pixelSize: 13; height: 28
                                onClicked: exportScopePopup.close()
                            }
                        }
                    }
                }
            }

            // ボトムバー
            Rectangle { Layout.fillWidth: true; height: 1; color: "#444" }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                // メッセージタブ時のみ表示：エクスポート・インポート
                Button {
                    background: Rectangle {
                        color: parent.pressed ? bs.bgPrs : (parent.hovered ? bs.bgHov : bs.bg)
                        radius: bs.r
                        border.color: bs.bdr; border.width: 1
                    }
                    contentItem: Text {
                        text: parent.text; color: bs.txt
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    visible: tabBar.currentIndex === 1
                    text: root.t.btn_export_short; font.pixelSize: 13; height: 32
                    onClicked: {
                        if (!root.cheerup) return
                        if (root.cheerup.activeGroup === "Default") {
                            exportScopePopup.open()
                        } else {
                            root.cheerup.export_current("")
                        }
                    }
                    ToolTip.visible: hovered
                    ToolTip.delay: 300
                    ToolTip.text: "JSON / TXT"
                }
                Button {
                    background: Rectangle {
                        color: parent.pressed ? bs.bgPrs : (parent.hovered ? bs.bgHov : bs.bg)
                        radius: bs.r
                        border.color: bs.bdr; border.width: 1
                    }
                    contentItem: Text {
                        text: parent.text; color: bs.txt
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    visible: tabBar.currentIndex === 1
                    text: root.t.btn_import_short; font.pixelSize: 13; height: 32
                    onClicked: if (root.cheerup) root.cheerup.import_custom_json()
                    ToolTip.visible: hovered
                    ToolTip.delay: 300
                    ToolTip.text: "JSON / TXT"
                }

                Text {
                    id: statusMsg
                    text: root.cheerup ? root.cheerup.statusText : ""
                    color: "#4CAF50"; opacity: 0; font.pixelSize: 13
                    Behavior on opacity { NumberAnimation { duration: 250 } }
                    function pop() { opacity = 1; fadeTimer.restart() }
                    Connections {
                        target: root.cheerup
                        function onStatusTextChanged() {
                            if (root.cheerup && root.cheerup.statusText !== "") statusMsg.pop()
                        }
                    }
                }
                Timer {
                    id: fadeTimer; interval: 3500
                    onTriggered: {
                        statusMsg.opacity = 0
                        if (root.cheerup) root.cheerup.clear_status()
                    }
                }

                Item { Layout.fillWidth: true }
                Button {
                    text: root.t.btn_close
                    implicitHeight: 32; implicitWidth: 80
                    background: Rectangle {
                        color: parent.pressed ? bs.bgPrs : (parent.hovered ? bs.bgHov : bs.bg)
                        radius: bs.r
                        border.color: bs.bdr; border.width: 1
                    }
                    contentItem: Text {
                        text: parent.text; color: bs.txt
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: { if (root.window) root.window.close() }
                }
            }
        }
    }
}