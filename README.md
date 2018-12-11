# VLC-Converter-youtube-DL

This script download youtube using [youtube-dl](https://github.com/rg3/youtube-dl) song or playlist and convert it into .mp3 with **VLC** converter.

**The process is simple**:
1. Enter the path to destination folder.
2. Enter URL of youtube **playlist** or **song** to download.
3. The youtube-dl download will start.
4. At the end of the download, the script will check for possible duplicates songs.
5. The vlc converter process will start.

## Requirements
You will need [youtube-dl](https://github.com/rg3/youtube-dl) and VLC to get it work.
Please be sure that VLC is stored in the C:\programfiles folder.

## What's next ?
**_First_**
I know the code is messy, i'm planning on some code management asap.

my next goals are:
1. Improve my duplicates tracker
2. Reduce duplicates downloads by getting the songs that are already existing before launching youtube-dl
3. Sort songs by Artists
4. Manage naming convention of songs
5. List latest Youtube playlists 
6. Add navigation Menu
7. Add FLAC extension
