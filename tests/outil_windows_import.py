from importlib.util import module_from_spec, spec_from_file_location
from pathlib import Path


def load_core():
    path = Path(__file__).resolve().parents[1] / "outil-windows" / "portrait_core.py"
    spec = spec_from_file_location("portrait_core_for_tests", path)
    module = module_from_spec(spec)
    assert spec and spec.loader
    import sys
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module
