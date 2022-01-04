SKIPUNZIP=1

# Extract files
ui_print "- Extracting module files"
unzip -o "$ZIPFILE" module.prop -d $MODPATH >&2

# paths
patched_keystore="$MODPATH/system/bin/keystore"
original_keystore="/bin/keystore"
replace_path="$MODPATH/system/bin"
hardware=$(getprop ro.hardware)

# hex pattern
pre="0074696d657374616d7000"
post="0000696d657374616d7000"

ui_print "- Start patching..."
mkdir -p $replace_path
cp -f -p $original_keystore $replace_path
set_perm_recursive $replace_path 0 0 0755 0755
if `/data/adb/magisk/magiskboot hexpatch $patched_keystore $pre $post` ; then
  ui_print "- Successfully patched!"
else
  ui_print "- Not found hex pattern in keystore, Aborting..."
  rm -rf $MODPATH
  abort
fi
