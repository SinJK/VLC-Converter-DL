# VLC-Converter-youtube-DL

This script download youtube using [youtube-dl](https://github.com/rg3/youtube-dl) song or playlist and convert it into .mp3 with **VLC** converter.
## Last update:
**27/12/2018** : 
- Made a menu to make different actions 
- Added a function to get metadatas of songs that are in a folder.
It is the second choice of the menu. You need to input the path of the folder you
want like **"C:\file\filethatyouwanttoscan\"**

- This new metadata module also offer a clean renamer for songs as **artist - songname**
(Giving the randomness of certains songs on youtube, this can mess up sometimes)

**_important_**
if you want to enable this feature, get an API key on:
https://www.discogs.com/developers/#page:authentication

and add the key at the end of $uri on the metadata.psm1
"token=yourKEY"

**The process is simple**:
1. Enter the path to destination folder.
2. Enter URL of youtube **playlist** or **song** to download.
3. The youtube-dl download will start.
4. At the end of the download, the script will check for possible duplicates songs.
5. The vlc converter process will start.

## Requirements
You will need [youtube-dl](https://github.com/rg3/youtube-dl) and VLC to get it work.
Please be sure that VLC is stored in the C:\programfiles folder.

Be sure to add the path of youtube-dl.exe at the line beginning with "&"
## What's next ?
**_First_**
I know the code is messy, i'm planning on some code management asap.

my next goals are:
1. Improve my duplicates tracker
2. Reduce duplicates downloads by getting the songs that are already existing before launching youtube-dl
3. Sort songs by Artists
4. ~~Manage naming convention of songs~~
5. List latest Youtube playlists 
6. ~~Add navigation Menu~~
7. Add FLAC extension
8. ~~Get metadata of songs~~
