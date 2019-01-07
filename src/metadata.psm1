function DiscogsAPI($path) {
    <#
.SYNOPSIS
  This script try to get .mp3 metadatas from Discogs.
.DESCRIPTION
  
.PARAMETER <Parameter_Name>
    None
.INPUTS
 Just input the path of the directory that contains mp3 you want to update.
.OUTPUTS
  None
.NOTES
  Version:        1.0
  Author:         SinJK
  Creation Date:  07/11/2018
  Purpose/Change: Script mp3 converter
  
.EXAMPLE
  None
#>
    #region Settings
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $path = "path"
    $staticpath = "path"
    $basedURL = 'https://api.discogs.com/database/' 
    $p2 = gci -Path $path -Filter *.mp3
    $vanillasong = gci -Path $path -Filter *.mp3 | select FullName
    $song1 = $p2.BaseName
    #endregion Settings
    ###########################Loop through each song################################

    #region First loop to clean up songs name
    foreach ($song in $song1) {
        $stat = $song
        if ($song -match "()") {
            $song = $song -replace '\(([^\)]+)\)', ''

        }

        if ($song -match "'") {
            $song = $song -replace "( ' )", ' - '

        }
        if ($song -match "official") {
            $song = $song -replace 'official', ""

        }


        if ($song -match "music") {
            $song = $song -replace "music", ""

        }
        if ($song -match "lyrics") {
            $song = $song -replace "lyrics", ""

        }

        if ($song -match "video") {
            $song = $song -replace "video", ""

        }

        if ($song -match "feat") {
            $song = $song -replace '(feat).*?(?=-)', ''
            $song = $song -replace '(feat.).*', ''

        }
        if ($song -match "explicit") {
            $song = $song -replace "explicit", ""

        }
        if ($song -match "officialvideo") {
            $song = $song -replace "official video", ""

        }
        if ($song -match "clip officiel") {
            $song = $song -replace "clip officiel", ""

        }
        if ($song -match "copie") {
            $song = $song -replace "copie", ""

        }

        $song = $song -replace '\[([^\)]+)\]', ''

        if ($song -match "ft") {

            #$song = $song -replace '(ft).*?(?=-)', ''
            $song = $song -replace '(ft).*?(?= - )', ''
            $song = $song -replace '(ft.).*', ''

        }


        #$song = $song -replace "(')", '-'
        $oldtitle = $song.Split("-")[1]

        $title = $song.Split("-")[1]
        $title = $title -replace "’", "'"
        $title = $title -replace "_", ""
        $artist = $song.Split("-")[0]
        Write-Host $artist - $title -ForegroundColor Cyan
        $title = $title.Trim()
        #endregion First loop to clean up songs name

        #region API SETTINGS
        $headers = "ytconverterdl/1.0 +https://github.com/SinJK/VLC-Converter-youtube-DL" 
                                           
        $uri = $basedURL + "search?q=$title - $artist&per_page=5&type=all&token=*******"
        $uri = $uri -replace ' ', '+'
        Write-host [$uri]

        write-host "avant"  
        #endregion API SETTINGS
        #region API CALL
        $y = Invoke-RestMethod -Uri $uri -UserAgent $headers -method Get

        write-host "apres"
        $results = $y.results

        $w = $results -match $artist.Trim()

        $album = $results | Where-Object {$_.format -match "Album"} | select -First 5
        #endregion API CALL

        #region Loop to get song's infos
        #$ivalbum=$album.master_url
        foreach ($release in $album) {
            #if($release){

            $release.resource_url
            $release.master_url

            $ivalbum = Invoke-RestMethod -Uri $release.resource_url -UserAgent $headers -method Get

            if ($ivalbum.artists.name -replace '\(([^\)]+)\)', '' -notmatch $artist.Trim()) {break}
            if ($tracklist = $ivalbum.tracklist | where {$_ -match $title.Trim()}) {
                $tracklistpos = $tracklist.position|select -First 1
                #$tracklistpos = ($tracklist.toCharArray()|%{if($_ -Match '\w'){$_}}) -Join "" | Out-Null
                $tracklistpos = $tracklist.position -replace "\D", ""
                $track = $tracklist.title |select -First 1
                $ivalbum.title
                $tracklistpos
                $year = $ivalbum.year
                $year
                $artist = $ivalbum.artists.name -replace '\(([^\)]+)\)', ''
                $artist
                break
            }
            #endregion Loop to get song's infos

            Start-Sleep 3
            #}
        }

        #region In case the title is not found
        #get the Name cleaned at the beginning
        if ($track -eq $null) {$track = $title}
        $newSongName = "$artist - $title"
        Rename-Item -LiteralPath "$staticpath$stat.mp3" -NewName "$newSongName.mp3"
        #endregion In case the title is not found


        #region Metadata add to the song file
        [string]$id3path = "$staticpath$newSongName.mp3"
        #\$stat.mp3
        [string]$Title = $track
        [string]$Artist = $artist
        [string]$Album = $ivalbum.title
        [string]$Year = $year
   
        [int]$Track = $tracklistpos
        [int]$Genre = "" 
        [bool]$BackDate = $true
       
        Try {
            $enc = [System.Text.Encoding]::Default
            $currentID3Bytes = New-Object byte[] (128)
            $strm = New-Object System.IO.FileStream ($id3path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
            $strm.Seek(-128, 'End') | Out-Null
            $strm.Read($currentID3Bytes, 0, $currentID3Bytes.Length) | Out-Null
            Write-Host "$path `nCurrentID3: $($enc.GetString($currentID3Bytes))"
            $strm.Seek(-128, 'End') | Out-Null
            If ($enc.GetString($currentID3Bytes[0..2]) -ne 'TAG') {
                Write-Warning "No existing ID3v1 found - adding to end of file"
                $strm.Seek(0, 'End') 
                $currentID3Bytes = $enc.GetBytes(('TAG' + (' ' * (30 + 30 + 30 + 4 + 30)))) 
                $currentID3Bytes += 255 
                $strm.Write($currentID3Bytes, 0, $currentID3Bytes.length)
                $strm.Flush()
                $Strm.Close()
                $strm = New-Object System.IO.FileStream ($id3path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
                $strm.Seek(-128, 'End') 
            } 
            $strm.Seek(3, 'Current')  #skip over 'TAG' to get to the good stuff
            #Skip over
            $strm.Write($enc.GetBytes($Title.PadRight(30, ' ').Substring(0, 30)), 0, 30)
            $strm.Write($enc.GetBytes($Artist.PadRight(30, ' ').Substring(0, 30)), 0, 30)
            $strm.Write($enc.GetBytes($Album.PadRight(30, ' ').Substring(0, 30)), 0, 30)
            $strm.Write($enc.GetBytes($Year.PadRight(4, ' ').Substring(0, 4)), 0, 4)
           
            $currentID3Bytes[125] -eq 0
            $CommentMaxLen = 28 #If a Track is specified or present in the file, Comment is 28 chars
            $Comment -eq "`0" 
            $strm.Seek($CommentMaxLen, 'Current') | Out-Null 
             
            $strm.Write(@(0, $Track), 0, 2)
            # $strm.Write($Genre,0,1) | Out-Null
       
          
        }
        Catch {
            Write-Error $_.Exception.Message
        }
        Finally {
            If ($strm) {
                $strm.Flush()
                $strm.Close()
            }
        }
        #endregion Metadata add to the song file

        Start-Sleep 5 # to don't get call limits from the API

        #region variables clear
        Remove-Variable * -Exclude $path -ErrorAction SilentlyContinue
        # redeclaring some variables that are neaded at the start
        # I have to clear every variable first because it can mess up the api and metadata update part
        $path = "path"
        $staticpath = "path"
        $basedURL = 'https://api.discogs.com/database/' 
        $p2 = gci -Path $path -Filter *.mp3
        $vanillasong = gci -Path $path -Filter *.mp3 | select FullName
        $song1 = $p2.BaseName
        #endregion variables clear
    }

}
