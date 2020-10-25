## A setup for wiring together Plex Media player, PutIO and Medusa.

This is complete plan to run an end-to-end torrent-to-plex automation.

### Components:
- [PyMedusa](https://github.com/pymedusa/Medusa) - Automatic Video Library Manager
- [Plex](https://www.plex.tv/) - Streamer and transcoder
- [put.io](https://put.io/)- Torrent Cloud Storage
- [RClone](https://rclone.org/) - Mount the remote as file system on a mountpoint.
- [inotifywait](https://linux.die.net/man/1/inotifywait) - Wait for changes to files using inotify
- [unrar](https://wiki.archlinux.org/index.php/rar#UNRAR) - Decompress RAR archives
- [Docker-Compose](https://docs.docker.com/compose/reference/overview/) - Multi Container Orchestrator
- [SystemD Service Units](https://www.freedesktop.org/software/systemd/man/systemd.service.html) (Another reference [here](https://www.digitalocean.com/community/tutorials/understanding-systemd-units-and-unit-files))

Architecture:
1. A `docker-compose` system unit starts Medusa and Plex servers upon system startup.
2. Medusa is subsribing to torrent trackers, and waits for new episodes of TV Shows. Once a new episode's torrent is found, the torrent file is "snatched" into `~/medusa/downloads` directory, aka _torrent blackhole_.
3. A running system unit (`blackhole-torent-uploader`) waits for new `.torrent` files to appear in the _torrent blackhole_ directory and uploads the torrent to `put.io` to start a new transfer into a specified parent folder on the cloud storage.
4. The parent folder on the cloud storage is mounted to the local system at `~/plex/tv` using the system unit `rclone-mount`.
5. Plex Media server is configured to use the mounted `put.io` folder as the TV Library root. It notices changes (additions) and adds them to the library.
5a. If the downloaded torrent contains a `.rar` archive, it needs to be extracted for Plex to be able to play it.
5b. An additional system unit (`torrent-auto-unrar`) is waiting for additions of `.rar` files into the mounted `~/plex/tv` directory and its subdirectories, and starts to `unrar` it in the same folder, which essentially uploads the extracted media file into the cloud storage.


### Installation:
Required tools (install using the relavant linux package manager):  
docker-compose
rclone
unrar
inotifywait

#### Steps:
1. Setup rclone and put.io. [Guide](https://help.put.io/en/articles/3480094-plex-rclone), [Docs](https://rclone.org/putio/).
2. Create `variables.env` file with the following structure inside `/var/local`:
```sh
HOME_DIR="/home/your-user" # The user home folder
TORRENT_BLACKHOLE_DIR="$HOME_DIR/medusa/downloads" # default
PUTIO_AUTH_TOKEN="YOUR_APP_TOKEN" # Create a put.io app and copy the token here
PUTIO_PARENT_ID="REMOTE_)DIR_ID" # Target put.io directory parent id (can be copied from the url)
```
3. Clone this repo into your home folder
4. `cd` into the directory of this repo and start the service units

```bash
sudo systemctl link ./rclone-mount.service
sudo systemctl enable rclone-mount.service
sudo systemctl start rclone-mount.service

sudo systemctl link ./blackhole-torrent-uploader.service
sudo systemctl enable blackhole-torrent-uploader.service
sudo systemctl start blackhole-torrent-uploader.service

sudo systemctl link ./torrent-auto-unrar.service
sudo systemctl enable torrent-auto-unrar.service
sudo systemctl start torrent-auto-unrar.service

sudo systemctl link ./docker-compose.service
sudo systemctl enable docker-compose.service
sudo systemctl start docker-compose.service
```