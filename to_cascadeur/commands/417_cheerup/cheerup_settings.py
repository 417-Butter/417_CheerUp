"""417_cheerup v1.0.0 -- Settings command."""
import sys, os, importlib.util

def name():        return "417_cheerup.Settings"
def description(): return "Open CheerUp! settings"
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
        import csc
        csc.view.PythonModelsManager.instance().show_qml_view("417_cheerup")
    except Exception as e:
        import traceback; traceback.print_exc()
        try:
            scene.error(f"[CheerUp!] Failed to open settings: {e}")
        except: pass