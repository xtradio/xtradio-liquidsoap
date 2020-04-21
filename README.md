# xtradio-liquidsoap
XTRadio Liquidsoap configuration

[![Docker Repository on Quay](https://quay.io/repository/xtradio/liquidsoap/status "Docker Repository on Quay")](https://quay.io/repository/xtradio/liquidsoap)

## Files

- docker-compose.yaml - included for local development
- icecast.xml - included for local development
- radio.liq - included liquidsoap configuration
- Dockerfile - build liquidsoap container

## Environment variables needed

`DJ_PASSWORD` - The password for the stream. Ex. `testPassword`

`ICECAST_HOST` - Hostname of the icecast instance. ex. `icecast.example.com`

`ICECAST_PASSWORD` - Password for the source when connecting to icecast. ex. `test`

`API_HOST` - Hostname of the API where song updates should be sent, where you run [xtradio-api](https://github.com/xtradio/xtradio-api). ex. `api.xtradio.org`

`PLAYLIST_FILE` - Name and local path of annotation playlist file. ex. 

## Volumes needed

`/MUSIC` - for music library.

`/path/playlist.txt` - Text file of annotation playlist.
