#!/system/bin/sh
MODDIR="${0%/*}"

# remove youtube updates

umount -l /data/app/com.google.android.youtube-*/base.apk
umount -l /data/app/*/com.google.android.youtube-*/base.apk
rm -rf /data/app/com.google.android.youtube-*
rm -rf /data/app/*/com.google.android.youtube-*



while [ "$(getprop sys.boot_completed | tr -d '\r')" != "1" ]; do sleep 1; done



base_path="$MODDIR/revanced.apk"
stock_path="/system/priv-app/youtube/base.apk"

if [ "$(ls -id "$MODDIR/$stock_path" | awk '{ print $1 }')" != "$(ls -id "$stock_path" | awk '{ print $1 }')" ]; then
    # youtube is not mounted, abort
    exit 1
fi

umount -l "$stock_path"

chmod 666 "$base_path"
chcon u:object_r:system_file:s0 "$base_path"
mount -o bind "$base_path" "$stock_path"

PK=com.google.android.youtube
PS=com.android.vending

LDB=/data/data/$PS/databases/library.db
LADB=/data/data/$PS/databases/localappstate.db 

chmod 755 -R "$MODDIR/bin"

cmd appops set --uid $PS GET_USAGE_STATS ignore

for user_id in $(ls /data/user); do
    pm disable --user "$user_id" "$PS"
    "$MODDIR/bin/sqlite3" "/data/user/$user_id/$PS/databases/library.db" "UPDATE ownership SET doc_type = '25' WHERE doc_id = '$PK'"; 
    "$MODDIR/bin/sqlite3" "/data/user/$user_id/$PS/databases/localappstate.db" "UPDATE appstate SET auto_update = '2' WHERE package_name = '$PK'"; 
    rm -rf "/data/user/$user_id/$PS/cache/"*
    pm enable --user "$user_id" "$PS"
done
