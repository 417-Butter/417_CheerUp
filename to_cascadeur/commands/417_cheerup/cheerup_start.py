"""417_cheerup v1.0.0 -- Start (Reset) command."""
import sys, os, importlib.util

def name():        return "417_cheerup.Start (Reset)"
def description(): return "Start or reset the CheerUp! encouragement timer"
command_name = name

def _core():
    key = '_cheerup417_core_module'
    if key in sys.modules:
        return sys.modules[key]
    p = os.path.join(os.path.dirname(os.path.abspath(__file__)), '__init__.py')
    spec = importlib.util.spec_from_file_location(key, p)
    mod  = importlib.util.module_from_spec(spec)
    sys.modules[key] = mod
    spec.loader.exec_module(mod)
    return mod

def run(scene):
    try:
        core = _core()
        core.start_timer()
    except Exception as e:
        import traceback; traceback.print_exc()
        try:
            scene.error(f"[CheerUp!] Start error: {e}")
        except Exception:
            print(f"[CheerUp!] Start error: {e}")