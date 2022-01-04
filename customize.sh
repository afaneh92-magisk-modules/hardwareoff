SKIPUNZIP=1

# Extract files
ui_print "- Extracting module files"

unzip -o "$ZIPFILE" module.prop -d $MODPATH >&2
unzip -o "$ZIPFILE" system.prop -d $MODPATH >&2
unzip -o "$ZIPFILE" post-fs-data.sh -d $MODPATH >&2

# Bootloader string.
BL=$(getprop ro.boot.bootloader);
# Device is first 5 characters of bootloader string.
DEVICE=${BL:0:5};
DEVICEVARIANT=${BL:4:1};
# Zero last character of device string.
DEVICEOFF=${DEVICE%?}0;
# U last character of device string for HK devices.
[ "$DEVICEVARIANT" = "0" ] && DEVICEOFF=${DEVICE%?}U;
# Replace BASIC string with DEVICEOFF string.
sed -i "s/BASIC/SM\-${DEVICEOFF}/g" $MODPATH/system.prop;

# os string.
os=$(getprop ro.build.version.release)
major=${os%%.*}

# Extract keystore executables and libraries
unzip -o "$ZIPFILE" "system_$major/*" -d "$MODPATH" >&2;
mv $MODPATH/system_$major $MODPATH/system

# Set executable permissions
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm_recursive $MODPATH/system/bin 0 0 0755 0755
