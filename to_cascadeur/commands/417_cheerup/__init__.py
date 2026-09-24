import os
import json
import random
import time
import sys

ADDON_VERSION = "1.0.0"

ADDON_DIR     = os.path.join(os.environ.get('LOCALAPPDATA', os.path.expanduser('~')), '417_Casc_Addons', 'CheerUp')
SETTINGS_PATH = os.path.join(ADDON_DIR, 'settings.json')
PRESETS_PATH  = os.path.join(ADDON_DIR, 'presets.json')

DEFAULT_SETTINGS = {
    "language":         "en",
    "interval_minutes": 5,
    "show_elapsed":     True,
    "show_prefix":      False,
    "show_quotes":      True,
    "active_group":     "Default"
}

# ---- モジュールレベル定数（毎 tick の dict 生成コストを排除）----
_QUOTES = {
    'ja': ('\u300c', '\u300d'),
    'ko': ('\u300c', '\u300d'),
    'zh': ('\u201c', '\u201d'),
    'en': ('"', '"'),
}
_UNIT_MAP = {'en': 'min', 'ja': '\u5206', 'ko': '\ubd84', 'zh': '\u5206\u949f'}

# ビルトインプリセットキャッシュ（起動後は不変なので1回だけ読む）
_BUILTIN_CACHE = None


class CheerUpState:
    def __init__(self):
        self.timer = None
        self.start_time = 0.0
        self.elapsed_ticks = 0


def _get_state() -> CheerUpState:
    key = '_cheerup417_state'
    if not hasattr(sys.modules[__name__], key):
        setattr(sys.modules[__name__], key, CheerUpState())
    return getattr(sys.modules[__name__], key)


def _ensure_addon_dir():
    os.makedirs(ADDON_DIR, exist_ok=True)


def _atomic_write_json(path: str, data) -> None:
    """一時ファイルに書いてからアトミックにリネーム（書き込み途中のファイル破損を防ぐ）。"""
    tmp = path + '.tmp'
    with open(tmp, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    os.replace(tmp, path)


def load_settings() -> dict:
    try:
        if os.path.exists(SETTINGS_PATH):
            with open(SETTINGS_PATH, 'r', encoding='utf-8') as f:
                data = json.load(f)
            if isinstance(data, dict):
                merged = dict(DEFAULT_SETTINGS)
                merged.update(data)
                return merged
    except Exception as e:
        print(f"[CheerUp] load_settings error: {e}")
    return dict(DEFAULT_SETTINGS)


def save_settings(settings: dict) -> None:
    try:
        _ensure_addon_dir()
        _atomic_write_json(SETTINGS_PATH, settings)
    except Exception as e:
        print(f"[CheerUp] save_settings error: {e}")


def load_user_preset_groups() -> dict:
    try:
        if os.path.exists(PRESETS_PATH):
            with open(PRESETS_PATH, 'r', encoding='utf-8') as f:
                data = json.load(f)
            if isinstance(data, dict):
                if 'groups' in data and isinstance(data['groups'], dict):
                    return data['groups']
                if 'user_presets' in data and isinstance(data['user_presets'], list):
                    return {"My Presets": data['user_presets']}
            elif isinstance(data, list):
                return {"My Presets": data}
    except Exception as e:
        print(f"[CheerUp] load_user_preset_groups error: {e}")
    return {}


def save_user_preset_groups(groups: dict) -> None:
    try:
        _ensure_addon_dir()
        _atomic_write_json(PRESETS_PATH, {'groups': groups})
    except Exception as e:
        print(f"[CheerUp] save_user_preset_groups error: {e}")


def load_builtin_presets() -> dict:
    """ビルトインプリセットを返す（初回のみディスク読み込み、以降はキャッシュ）。"""
    global _BUILTIN_CACHE
    if _BUILTIN_CACHE is not None:
        return _BUILTIN_CACHE
    try:
        p = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'presets', 'default.json')
        with open(p, 'r', encoding='utf-8-sig') as f:
            _BUILTIN_CACHE = json.load(f)
        return _BUILTIN_CACHE
    except Exception as e:
        print(f"[CheerUp] Error loading presets/default.json: {e}")
        # フォールバック（エラー時はキャッシュせず毎回試みる）
        return {
            "en": ["Keep up the great work!"],
            "ja": ["\u3044\u3044\u8abf\u5b50\u3067\u3059\uff01\u305d\u306e\u8abf\u5b50\uff01"],
            "ko": ["\uc815\ub9d0 \uc798\ud558\uace0 \uc788\uc5b4\uc694!"],
            "zh": ["\u7ee7\u7eed\uff01\u4f60\u505a\u5f97\u5f88\u597d\uff01"]
        }


def pick_message(settings: dict) -> str:
    lang     = settings.get('language', 'en')
    active   = settings.get('active_group', 'Default')
    builtins = load_builtin_presets()

    if active == 'Default':
        pool = builtins.get(lang, builtins.get('en', []))
    else:
        groups = load_user_preset_groups()
        pool   = groups.get(active, []) or builtins.get(lang, builtins.get('en', []))

    return random.choice(pool) if pool else "Keep up the great work!"


def _post_message(text: str, show_prefix: bool = True):
    """Cascadeur のステータスバーにメッセージを表示する。"""
    final_text = text
    if show_prefix and not text.startswith("[CheerUp!]"):
        final_text = f"[CheerUp!] {text}"
    elif not show_prefix and text.startswith("[CheerUp!] "):
        final_text = text.replace("[CheerUp!] ", "", 1)

    try:
        import csc
        app = csc.app.get_application()
        if app:
            scene_manager = app.get_scene_manager()
            if scene_manager:
                app_scene = scene_manager.current_scene()
                if app_scene:
                    domain_scene = app_scene.domain_scene()
                    if domain_scene:
                        for method_name in ('success', 'info', 'error'):
                            try:
                                getattr(domain_scene, method_name)(final_text)
                                return
                            except Exception:
                                pass
    except Exception:
        pass
    print(final_text)


def _on_tick():
    state = _get_state()
    state.elapsed_ticks += 1
    settings    = load_settings()
    lang        = settings.get('language', 'en')
    show_prefix = settings.get('show_prefix', True)
    msg         = pick_message(settings)

    # 引用符ラップ
    if settings.get('show_quotes', False):
        q = _QUOTES.get(lang, ('"', '"'))
        msg = q[0] + msg + q[1]

    # 経過時間
    if settings.get('show_elapsed', True):
        interval    = max(1, int(settings.get('interval_minutes', 5)))
        elapsed_min = state.elapsed_ticks * interval
        unit        = _UNIT_MAP.get(lang, 'min')
        msg = f"{msg}  ({elapsed_min} {unit})"

    _post_message(msg, show_prefix=show_prefix)


def start_timer(settings_override: dict = None) -> dict:
    from PySide6 import QtCore
    if settings_override:
        save_settings(settings_override)

    state = _get_state()
    _stop_internal(state)

    state.start_time    = time.time()
    state.elapsed_ticks = 0

    settings    = load_settings()
    interval_ms = max(1, int(settings.get('interval_minutes', 5))) * 60 * 1000
    lang = settings.get('language', 'en')

    greet = {
        'en': f"\U0001f389 Timer started! Encouragement every {interval_ms//60000} min.",
        'ja': f"\U0001f389 \u30bf\u30a4\u30de\u30fc\u8d77\u52d5\uff01{interval_ms//60000}\u5206\u3054\u3068\u306b\u5fdc\u63f4\u3057\u307e\u3059",
        'ko': f"\U0001f389 \ud0c0\uc774\uba38 \uc2dc\uc791! {interval_ms//60000}\ubd84\ub9c8\ub2e4 \uc751\uc6d0\ud569\ub2c8\ub2e4",
        'zh': f"\U0001f389 \u8ba1\u65f6\u5668\u5df2\u542f\u52a8\uff01\u6bcf {interval_ms//60000} \u5206\u949f\u9f13\u52b1\u60a8\u4e00\u6b21"
    }
    _post_message(greet.get(lang, greet['en']))

    timer = QtCore.QTimer()
    timer.timeout.connect(_on_tick)
    timer.start(interval_ms)
    state.timer = timer
    return settings


def stop_timer() -> None:
    state = _get_state()
    settings = load_settings()
    lang = settings.get('language', 'en')
    stop_msg = {
        'en': "Timer stopped.",
        'ja': "\u30bf\u30a4\u30de\u30fc\u3092\u505c\u6b62\u3057\u307e\u3057\u305f\u3002",
        'ko': "\ud0c0\uc774\uba38\uac00 \uc911\uc9c0\ub418\uc5c8\uc2b5\ub2c8\ub2e4.",
        'zh': "\u8ba1\u65f6\u5668\u5df2\u505c\u6b62\u3002"
    }
    _post_message(stop_msg.get(lang, stop_msg['en']))
    _stop_internal(state)


def is_timer_running() -> bool:
    state = _get_state()
    return state.timer is not None and state.timer.isActive()


def _stop_internal(state) -> None:
    """タイマーを安全に停止・破棄する（disconnect で二重 connect を防ぐ）。"""
    if state.timer is not None:
        try:
            state.timer.stop()
            state.timer.timeout.disconnect()  # 二重connect防止
            state.timer.deleteLater()
        except Exception:
            pass
        state.timer = None