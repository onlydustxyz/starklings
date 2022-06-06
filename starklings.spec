# -*- mode: python ; coding: utf-8 -*-
from PyInstaller.utils.hooks import collect_data_files, collect_submodules

block_cipher = None
extra_files = [
    ('pyproject.toml', 'info'),
    ('.solutions/*', '.solutions')
] + collect_data_files('starkware')
# Extra imports which are necessary for executing hints
extra_imports = [
        "eth_hash.auto",
    ] + collect_submodules('starkware')

a = Analysis(['starklings.py'],
             pathex=[],
             binaries=[],
             datas=extra_files,
             hiddenimports=extra_imports,
             hookspath=[],
             hooksconfig={},
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher,
             noarchive=False)
pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)

exe = EXE(pyz,
          a.scripts, 
          [],
          exclude_binaries=True,
          name='starklings',
          debug=False,
          bootloader_ignore_signals=False,
          strip=False,
          upx=True,
          console=True,
          disable_windowed_traceback=False,
          target_arch=None,
          codesign_identity=None,
          entitlements_file=None )
coll = COLLECT(exe,
               a.binaries,
               a.zipfiles,
               a.datas, 
               strip=False,
               upx=True,
               upx_exclude=[],
               name='starklings')
