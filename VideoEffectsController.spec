# -*- mode: python ; coding: utf-8 -*-


a = Analysis(
    ['python/main.py'],
    pathex=[],
    binaries=[],
    datas=[('README.md', '.'), ('VideoEffects', 'VideoEffects')],
    hiddenimports=['tkinter', 'tkinter.ttk'],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='VideoEffectsController',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch='universal2',
    codesign_identity='-',
    entitlements_file=None,
)
coll = COLLECT(
    exe,
    a.binaries,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='VideoEffectsController',
)
app = BUNDLE(
    coll,
    name='VideoEffectsController.app',
    icon=None,
    bundle_identifier='com.videoeffects.controller',
)
