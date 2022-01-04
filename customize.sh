SKIPUNZIP=1

# extract files
ui_print "- Extracting module files"

unzip -o "$ZIPFILE" module.prop -d $MODPATH >&2
unzip -o "$ZIPFILE" system.prop -d $MODPATH >&2

# Bootloader string.
BL=$(getprop ro.boot.bootloader);
# Device is first 5 characters of bootloader string.
DEVICE=${BL:0:5};
# Zero last character of device string.
DEVICEOFF=${DEVICE%?}0;
# Replace BASIC string with DEVICEOFF string.
sed -i "s/BASIC/SM\-${DEVICEOFF}/g" $MODPATH/system.prop;

set_perm_recursive "$MODPATH" 0 0 0755 0644
