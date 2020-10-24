#!/bin/env /bin/bash
echo "Starting Blackhole Torrent Uploader at $TORRENT_BLACKHOLE_DIR";
inotifywait -m "$TORRENT_BLACKHOLE_DIR" -e create -e moved_to |
    while read path action file; do
        
        if [[ "$file" =~ .*torrent$ ]]; then # Does the file end with .torrent?
            echo "The file is not a torrent. Skipping [ $file ]"; 
        else
            echo "Uploading $path$file";
            curl -X POST "https://upload.put.io/v2/files/upload" \
                  -H "accept: application/json" \
                  -H "Authorization: Bearer $PUTIO_AUTH_TOKEN" \
                  -H "Content-Type: multipart/form-data" \
                  -F "filename=" \
                  -F "parent_id=$PUTIO_PARENT_ID" \
                  -F "file=@$path$file"
        fi
    done