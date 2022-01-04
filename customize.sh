SKIPUNZIP=1

# Extract files
ui_print "- Extracting module files"
unzip -o "$ZIPFILE" module.prop -d $MODPATH >&2

evaltype() {
  unzip -o "$ZIPFILE" system.prop -d $MODPATH >&2
  # Bootloader string
  BL=$(getprop ro.boot.bootloader);
  # Device is first 5 characters of bootloader string.
  DEVICE=${BL:0:5};
  DEVICEVARIANT=${BL:4:1};
  # Zero last character of device string.
  DEVICEOFF=${DEVICE%?}0;
  # U last character of device string for HK devices.
  [ "$DEVICEVARIANT" = "0" ] && DEVICEOFF=${DEVICE%?}U;
  # N last character of device string for International devices.
  [ "$DEVICEVARIANT" = "B" ] && DEVICEOFF=${DEVICE%?}N;
  # Replace BASIC string with DEVICEOFF string.
  sed -i "s/BASIC/SM\-${DEVICEOFF}/g" $MODPATH/system.prop;
}

# Paths
patched_keystore="$MODPATH/system/bin/keystore"
original_keystore="/bin/keystore"
replace_path="$MODPATH/system/bin"

# Hex pattern
pre="0074696d657374616d7000"
post="0000696d657374616d7000"

ui_print "- Start patching..."
mkdir -p $replace_path
cp -f -p $original_keystore $replace_path
set_perm_recursive $replace_path 0 0 0755 0755
if `/data/adb/magisk/magiskboot hexpatch $patched_keystore $pre $post` ; then
  ui_print "- Successfully patched keystore!"
  # Needed in Google's device-based testing stage.
  #evaltype
elif [ -d "/data/adb/modules/hardwareoff" ]; then
  ui_print "- keystore already patched!"
  evaltype
else
  ui_print "- Not found hex pattern in keystore, Aborting..."
  rm -rf $MODPATH
  abort
fi
