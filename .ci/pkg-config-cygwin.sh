ROOT="$(cygpath -m /)"
echo "cygwin root: $ROOT"
LOCAL_PACKAGE_DIR="$(cygpath -w /var/cache/setup)"
$ROOT/setup-x86_64.exe --root $ROOT -q --packages=pkg-config --local-package-dir $LOCAL_PACKAGE_DIR --site=http://cygwin.mirror.constant.com/ --no-desktop --no-startmenu --no-shortcuts --verbose
