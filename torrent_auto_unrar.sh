#!/bin/env /bin/bash
echo "Starting Torrent Unrarer Withing mounted put.io folder";
inotifywait --monitor --recursive "$HOME_DIR/plex/tv" -e create -e moved_to |
    while read path action file; do
        
        if [[ "$file" =~ .*rar$ ]]; then # Does the file end with .rar?
            echo "The file is not a RAR archive. Skipping [ $file ]"; 
        else
            echo "Waiting 3 seconds to make sure that all the rar parts are present.";
            sleep 3;
            echo "Starting unrar of [ $path$file ]";

            cd "$path";
            unrar x "$file";
        fi
    done