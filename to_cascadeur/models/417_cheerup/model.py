import os
import json
import shiboken6
import sys
import importlib
from PySide6 import QtCore
from PySide6.QtCore import Property, Signal

# モジュールレベルでパスを計算（_core() 呼び出しごとの計算を排除）
_CORE_PATH = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
    "commands", "417_cheerup", "__init__.py"
)

# インポート処理で使う言語キー集合（モジュールレベル定数）
_LANG_KEYS = frozenset({'en', 'ja', 'ko', 'zh'})


def _core():
    """コアモジュール（commands/417_cheerup/__init__.py）をキャッシュして返す。"""
    key = '_cheerup417_core_module'
    if key in sys.modules:
        return sys.modules[key]
    spec = importlib.util.spec_from_file_location(key, _CORE_PATH)
    mod  = importlib.util.module_from_spec(spec)
    sys.modules[key] = mod
    spec.loader.exec_module(mod)
    return mod


class CheerUpModel(QtCore.QObject):
    languageChanged        = Signal()
    intervalMinutesChanged = Signal()
    showElapsedChanged     = Signal()
    showPrefixChanged      = Signal()
    showQuotesChanged      = Signal()
    activeGroupChanged     = Signal()
    isRunningChanged       = Signal()
    groupsDictChanged      = Signal()
    statusTextChanged      = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._status_text = ""
        self._load_from_core()

    def _load_from_core(self):
        c = _core()
        settings = c.load_settings()
        self._language         = settings.get('language', 'en')
        self._interval_minutes = int(settings.get('interval_minutes', 5))
        self._show_elapsed     = bool(settings.get('show_elapsed', True))
        self._show_prefix      = bool(settings.get('show_prefix', False))
        self._show_quotes      = bool(settings.get('show_quotes', True))
        self._active_group     = settings.get('active_group', 'Default')
        self._groups           = c.load_user_preset_groups()
        self._is_running       = c.is_timer_running()

    def _auto_save(self):
        _core().save_settings({
            'language':         self._language,
            'interval_minutes': self._interval_minutes,
            'show_elapsed':     self._show_elapsed,
            'show_prefix':      self._show_prefix,
            'show_quotes':      self._show_quotes,
            'active_group':     self._active_group
        })

    # ---- Properties ----

    @Property(str, notify=languageChanged)
    def language(self): return self._language
    @language.setter
    def language(self, v):
        v = str(v)
        if self._language != v:
            self._language = v
            self._auto_save()
            self.languageChanged.emit()
            self.groupsDictChanged.emit()

    @Property(int, notify=intervalMinutesChanged)
    def intervalMinutes(self): return self._interval_minutes
    @intervalMinutes.setter
    def intervalMinutes(self, v):
        v = int(v)
        if self._interval_minutes != v:
            self._interval_minutes = v
            self._auto_save()
            self.intervalMinutesChanged.emit()

    @Property(bool, notify=showElapsedChanged)
    def showElapsed(self): return self._show_elapsed
    @showElapsed.setter
    def showElapsed(self, v):
        v = bool(v)
        if self._show_elapsed != v:
            self._show_elapsed = v
            self._auto_save()
            self.showElapsedChanged.emit()

    @Property(bool, notify=showPrefixChanged)
    def showPrefix(self): return self._show_prefix
    @showPrefix.setter
    def showPrefix(self, v):
        v = bool(v)
        if self._show_prefix != v:
            self._show_prefix = v
            self._auto_save()
            self.showPrefixChanged.emit()

    @Property(bool, notify=showQuotesChanged)
    def showQuotes(self): return self._show_quotes
    @showQuotes.setter
    def showQuotes(self, v):
        v = bool(v)
        if self._show_quotes != v:
            self._show_quotes = v
            self._auto_save()
            self.showQuotesChanged.emit()

    @Property(str, notify=activeGroupChanged)
    def activeGroup(self): return self._active_group
    @activeGroup.setter
    def activeGroup(self, v):
        v = str(v)
        if self._active_group != v:
            self._active_group = v
            self._auto_save()
            self.activeGroupChanged.emit()
            self.groupsDictChanged.emit()

    @Property(bool, notify=isRunningChanged)
    def isRunning(self): return self._is_running

    @Property(list, notify=groupsDictChanged)
    def availableGroups(self):
        groups = ["Default"]
        for g in self._groups:
            if g not in groups:
                groups.append(g)
        return groups

    @QtCore.Slot(result=list)
    def getActiveMessages(self):
        c        = _core()
        builtins = c.load_builtin_presets()
        if self._active_group == "Default":
            return builtins.get(self._language, builtins.get('en', []))
        return self._groups.get(self._active_group, [])

    @Property(str, notify=statusTextChanged)
    def statusText(self): return self._status_text

    # ---- Slots ----

    @QtCore.Slot()
    def save_settings_btn(self):
        if self._is_running:
            # start_timer_from_ui 内で save_settings が呼ばれるため二重保存しない
            self.start_timer_from_ui()
        else:
            self._auto_save()
            self._notify({'en': 'Settings saved.',
                          'ja': '\u8a2d\u5b9a\u3092\u4fdd\u5b58\u3057\u307e\u3057\u305f',
                          'ko': '\uc124\uc815\uc774 \uc800\uc7a5\ub418\uc5c8\uc2b5\ub2c8\ub2e4',
                          'zh': '\u8bbe\u7f6e\u5df2\u4fdd\u5b58'})

    @QtCore.Slot()
    def start_timer_from_ui(self):
        try:
            c = _core()
            override = {
                'language':         self._language,
                'interval_minutes': self._interval_minutes,
                'show_elapsed':     self._show_elapsed,
                'show_prefix':      self._show_prefix,
                'active_group':     self._active_group
            }
            c.start_timer(settings_override=override)
            self._is_running = True
            self.isRunningChanged.emit()
            self._notify({'en': 'Timer started.',
                          'ja': '\u30bf\u30a4\u30de\u30fc\u3092\u958b\u59cb\u3057\u307e\u3057\u305f',
                          'ko': '\ud0c0\uc774\uba38\ub97c \uc2dc\uc791\ud588\uc2b5\ub2c8\ub2e4',
                          'zh': '\u8ba1\u65f6\u5668\u5df2\u542f\u52a8'})
        except Exception as e:
            print(f"[CheerUp!] start ERROR: {e}")

    @QtCore.Slot()
    def stop_timer_from_ui(self):
        try:
            _core().stop_timer()
            self._is_running = False
            self.isRunningChanged.emit()
            self._notify({'en': 'Timer stopped.',
                          'ja': '\u30bf\u30a4\u30de\u30fc\u3092\u505c\u6b62\u3057\u307e\u3057\u305f',
                          'ko': '\ud0c0\uc774\uba38\ub97c \uc911\uc9c0\ud588\uc2b5\ub2c8\ub2e4',
                          'zh': '\u8ba1\u65f6\u5668\u5df2\u505c\u6b62'})
        except Exception as e:
            print(f"[CheerUp!] stop ERROR: {e}")

    @QtCore.Slot(str)
    def add_new_group(self, group_name):
        g = group_name.strip()
        if not g or g == "Default" or g in self._groups:
            return
        self._groups[g] = []
        _core().save_user_preset_groups(self._groups)
        self._active_group = g
        self._auto_save()
        self.activeGroupChanged.emit()
        self.groupsDictChanged.emit()

    @QtCore.Slot()
    def remove_current_group(self):
        if self._active_group == "Default" or self._active_group not in self._groups:
            return
        del self._groups[self._active_group]
        _core().save_user_preset_groups(self._groups)
        self._active_group = "Default"
        self._auto_save()
        self.activeGroupChanged.emit()
        self.groupsDictChanged.emit()

    @QtCore.Slot(str)
    def add_message(self, text):
        t = text.strip()
        if not t or self._active_group == "Default":
            return
        msgs = self._groups.setdefault(self._active_group, [])
        if t not in msgs:
            msgs.append(t)
            _core().save_user_preset_groups(self._groups)
            self.groupsDictChanged.emit()

    @QtCore.Slot(int, str)
    def update_message(self, index, text):
        t = text.strip()
        if self._active_group == "Default":
            return
        msgs = self._groups.get(self._active_group, [])
        if 0 <= index < len(msgs) and t:
            msgs[index] = t
            _core().save_user_preset_groups(self._groups)
            self.groupsDictChanged.emit()

    @QtCore.Slot(int)
    def remove_message(self, index):
        if self._active_group == "Default":
            return
        msgs = self._groups.get(self._active_group, [])
        if 0 <= index < len(msgs):
            msgs.pop(index)
            _core().save_user_preset_groups(self._groups)
            self.groupsDictChanged.emit()

    @QtCore.Slot(str, str)
    def rename_group(self, old_name, new_name):
        new_name = new_name.strip()
        if (not new_name) or old_name == "Default" or old_name not in self._groups:
            return
        if new_name == "Default" or new_name in self._groups:
            self._notify({'en': 'Name already exists.',
                          'ja': '\u305d\u306e\u540d\u524d\u306f\u65e2\u306b\u5b58\u5728\u3057\u307e\u3059',
                          'ko': '\uc774\ubbf8 \uc874\uc7ac\ud558\ub294 \uc774\ub984\uc785\ub2c8\ub2e4',
                          'zh': '\u540d\u79f0\u5df2\u5b58\u5728'})
            return
        self._groups[new_name] = self._groups.pop(old_name)
        _core().save_user_preset_groups(self._groups)
        self._active_group = new_name
        self.activeGroupChanged.emit()
        self.groupsDictChanged.emit()

    # scope: "" = カスタムグループ, "current" = Default現在言語, "all" = Default全言語
    @QtCore.Slot(str)
    def export_current(self, scope):
        try:
            import csc
            manager    = csc.app.get_application().get_file_dialog_manager()
            is_default = (self._active_group == "Default")

            if is_default:
                suffix       = "all" if scope == "all" else self._language
                default_name = f"cheerup_default_{suffix}.json"
            else:
                default_name = f"{self._active_group}.json"
            default_path = os.path.join(os.path.expanduser('~'), default_name)

            # クロージャ: self はダイアログ完了まで短命なので強参照で問題なし
            def handle_export(paths):
                if not paths:
                    return
                path = paths[0] if isinstance(paths, list) else str(paths)
                if not path.strip():
                    return
                ext = os.path.splitext(path)[1].lower()
                if not ext:
                    path += '.json'
                    ext  = '.json'
                try:
                    if is_default:
                        builtin = _core().load_builtin_presets()
                        if scope == "all":
                            out_path = os.path.splitext(path)[0] + '.json'
                            with open(out_path, 'w', encoding='utf-8') as f:
                                json.dump(builtin, f, ensure_ascii=False, indent=2)
                            path = out_path
                        else:
                            msgs = builtin.get(self._language, builtin.get('en', []))
                            if ext == '.txt':
                                with open(path, 'w', encoding='utf-8') as f:
                                    f.write('\n'.join(msgs))
                            else:
                                with open(path, 'w', encoding='utf-8') as f:
                                    json.dump({self._language: msgs}, f, ensure_ascii=False, indent=2)
                    else:
                        msgs = self._groups.get(self._active_group, [])
                        if ext == '.txt':
                            with open(path, 'w', encoding='utf-8') as f:
                                f.write('\n'.join(msgs))
                        else:
                            with open(path, 'w', encoding='utf-8') as f:
                                json.dump({'groups': {self._active_group: msgs}}, f, ensure_ascii=False, indent=2)

                    self._notify({'en': f'Exported: {os.path.basename(path)}',
                                  'ja': f'\u30a8\u30af\u30b9\u30dd\u30fc\u30c8: {os.path.basename(path)}',
                                  'ko': f'\ub0b4\ubcf4\ub0b4\uae30: {os.path.basename(path)}',
                                  'zh': f'\u5bfc\u51fa: {os.path.basename(path)}'})
                except Exception as e:
                    print(f"[CheerUp] export error: {e}")
                    self._notify({'en': 'Export failed.',
                                  'ja': '\u5931\u6557\u3057\u307e\u3057\u305f',
                                  'ko': '\uc2e4\ud328',
                                  'zh': '\u5bfc\u51fa\u5931\u8d25'})

            manager.show_save_file_dialog(
                "Export CheerUp Messages", default_path,
                ["JSON / Text (*.json *.txt)", "JSON Files (*.json)", "Text Files (*.txt)"],
                handle_export
            )
        except Exception:
            pass

    @QtCore.Slot()
    def import_custom_json(self):
        try:
            import csc
            manager      = csc.app.get_application().get_file_dialog_manager()
            default_path = os.path.expanduser('~')

            def handle_import(paths):
                if not paths:
                    return
                path = paths[0] if isinstance(paths, list) else str(paths)
                if not path.strip():
                    return

                ext        = os.path.splitext(path)[1].lower()
                group_name = None  # インポート後に選択するグループ名

                try:
                    if ext == '.txt':
                        with open(path, 'r', encoding='utf-8-sig') as f:
                            lines = [l.strip() for l in f if l.strip()]
                        group_name = os.path.splitext(os.path.basename(path))[0]
                        existing   = self._groups.setdefault(group_name, [])
                        for m in lines:
                            if m not in existing:
                                existing.append(m)

                    elif ext == '.json':
                        with open(path, 'r', encoding='utf-8-sig') as f:
                            data = json.load(f)

                        if isinstance(data, dict) and 'groups' in data and isinstance(data['groups'], dict):
                            for g, msgs in data['groups'].items():
                                if g == "Default":
                                    continue
                                existing = self._groups.setdefault(g, [])
                                for m in msgs:
                                    if isinstance(m, str) and m not in existing:
                                        existing.append(m)
                                group_name = g  # 最後にインポートしたグループを選択

                        elif isinstance(data, dict) and set(data.keys()) & _LANG_KEYS:
                            lang       = self._language
                            msgs       = data.get(lang) or data.get('en') or []
                            group_name = os.path.splitext(os.path.basename(path))[0]
                            existing   = self._groups.setdefault(group_name, [])
                            for m in msgs:
                                if isinstance(m, str) and m not in existing:
                                    existing.append(m)

                        elif isinstance(data, dict) and 'user_presets' in data:
                            group_name = "Imported"
                            existing   = self._groups.setdefault(group_name, [])
                            for m in data['user_presets']:
                                if isinstance(m, str) and m not in existing:
                                    existing.append(m)

                        elif isinstance(data, list):
                            group_name = os.path.splitext(os.path.basename(path))[0]
                            existing   = self._groups.setdefault(group_name, [])
                            for m in data:
                                if isinstance(m, str) and m not in existing:
                                    existing.append(m)

                        else:
                            self._notify({'en': 'Unsupported format.',
                                          'ja': '\u5f62\u5f0f\u4e0d\u660e\u3002{"groups":{...}}\u30fb{"en":[...]}\u30fb\u30ea\u30b9\u30c8\u5f62\u5f0f\u306b\u5bfe\u5fdc',
                                          'ko': '\uc9c0\uc6d0\ud558\uc9c0 \uc54a\ub294 \ud615\uc2dd',
                                          'zh': '\u4e0d\u652f\u6301\u7684\u683c\u5f0f'})
                            return
                    else:
                        self._notify({'en': 'Use .json or .txt files.',
                                      'ja': '.json \u307e\u305f\u306f .txt \u30d5\u30a1\u30a4\u30eb\u3092\u4f7f\u7528\u3057\u3066\u304f\u3060\u3055\u3044',
                                      'ko': '.json \ub610\ub294 .txt \ud30c\uc77c\uc744 \uc0ac\uc6a9\ud558\uc138\uc694',
                                      'zh': '\u8bf7\u4f7f\u7528 .json \u6216 .txt \u6587\u4ef6'})
                        return

                    _core().save_user_preset_groups(self._groups)
                    if group_name and group_name in self._groups:
                        self._active_group = group_name
                        self._auto_save()
                    self.groupsDictChanged.emit()
                    self._notify({'en': 'Imported successfully.',
                                  'ja': '\u8aad\u307f\u8fbc\u307f\u307e\u3057\u305f',
                                  'ko': '\uac00\uc838\uc624\uae30 \uc644\ub8cc',
                                  'zh': '\u5bfc\u5165\u6210\u529f'})
                except Exception as e:
                    print(f"[CheerUp] import error: {e}")
                    self._notify({'en': f'Import error: {e}',
                                  'ja': f'\u30a4\u30f3\u30dd\u30fc\u30c8\u30a8\u30e9\u30fc: {e}',
                                  'ko': f'\uc624\ub958: {e}',
                                  'zh': f'\u5bfc\u5165\u9519\u8bef: {e}'})

            manager.show_open_file_dialog(
                "Import CheerUp Messages", default_path,
                ["JSON / Text (*.json *.txt)", "JSON Files (*.json)", "Text Files (*.txt)"],
                handle_import
            )
        except Exception:
            pass

    @QtCore.Slot()
    def clear_status(self):
        # 空文字のときは emit しない（不要な QML 更新を抑制）
        if self._status_text:
            self._status_text = ''
            self.statusTextChanged.emit()

    def _notify(self, msgs: dict):
        self._status_text = msgs.get(self._language, msgs.get('en', ''))
        self.statusTextChanged.emit()


def qml_view_name(): return "view"


def create_model():
    model = CheerUpModel()
    ptr   = shiboken6.getCppPointer(model)
    if isinstance(ptr, tuple):
        ptr = ptr[0]
    return model, ptr


def show_qml_view(model, name):
    import csc
    csc.view.PythonModelsManager.instance().show_dialog("CheerUp! v1.0.0", name)