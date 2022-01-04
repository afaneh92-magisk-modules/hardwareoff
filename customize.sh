SKIPUNZIP=1

# Extract files
ui_print "- Extracting module files"
unzip -o "$ZIPFILE" module.prop -d $MODPATH >&2

# paths
patched_keystore="$MODPATH/system/bin/keystore"
original_keystore="/bin/keystore"
replace_path="$MODPATH/system/bin"
# os string.
os=$(getprop ro.build.version.release)
major=${os%%.*}
hardware=$(getprop ro.hardware)

ui_print "- Checking Android version..."
if [[ "$major" == "11" ]]; then
  if [[ "$hardware" == "qcom" ]]; then
    # qcom
    pre="790074696d657374616d7000636f6d2e"
    post="790000696d657374616d7000636f6d2e"
  else
    # exynos
    pre="4e0074696d657374616d7000616e6472"
    post="4e0000696d657374616d7000616e6472"
  fi
elif [[ "$major" == "10" ]]; then
  pre="5d0074696d657374616d7000636f6d2e"
  post="5d0000696d657374616d7000636f6d2e"
else
  ui_print "- Unsupported Android version. Aborting..."
  abort
fi

ui_print "- Found Android $os, Start patching..."
ls $replace_path
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
