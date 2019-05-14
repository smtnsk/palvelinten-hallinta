disk_cleanup_context_menu:
  reg.present:
    - name: HKEY_CLASSES_ROOT\Drive\shell\Disk cleanup
    - vname: icon
    - vdata: cleanmgr.exe

disk_cleanup_context_menu_2:
  reg.present:
    - name: HKEY_CLASSES_ROOT\Drive\shell\Disk cleanup\command
    - vname: "@"
    - vdata: cleanmgr.exe /d $1
