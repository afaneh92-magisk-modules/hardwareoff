SKIPUNZIP=1

# Extract files
ui_print "- Extracting module files"

unzip -o "$ZIPFILE" module.prop -d $MODPATH >&2

# os string.
os=$(getprop ro.build.version.release)
major=${os%%.*}

# Extract keystore executables and libraries
unzip -o "$ZIPFILE" "system_$major/*" -d "$MODPATH" >&2;
mv $MODPATH/system_$major $MODPATH/system

# Set executable permissions
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm_recursive $MODPATH/system/bin 0 0 0755 0755
