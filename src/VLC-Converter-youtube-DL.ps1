Import-Module $PSScriptRoot\DiscogAPI.psm1

<#
.SYNOPSIS
  This script simply download youtube with youtube-dl song or playlist and convert it into .mp3 with VLC converter.
.DESCRIPTION
  
.PARAMETER <Parameter_Name>
    None
.INPUTS
 You will be asked to enter the destination path and youtube URL.
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
#############################Settings############################################
$outputExtension = ".mp3"
$bitrate = 128
$channels = 2
$samplerate = 48000
$path = ""
$pathHash = ""
$count = get-childitem $path -recurse -include *.mp4, *.webm, *.mkv | Measure-Object
$i = $count.Count
#################################################################################

#################################MENU############################################
$menu = Read-Host -Prompt "
What do you want to do ?
1 - Download playlist as mp3
2 - Get metadata from downloaded song
"
switch ($menu) {


    1 {
        Read-Host ("Enter the path destination of downloaded songs") | Set-Variable path, pathHash
        Read-Host ("Enter URL from youtube playlist or song`n Plase enter the entire URL") | Set-Variable yturl
        ytb-dl-converter -path $path -yturl $yturl
    }
    2 {
        $path = Read-Host "enter path"
        DiscogsAPI -path $path
    }



}

#################################################################################

#############################Function############################################

function ytb-dl-converter($path, $yturl) {
    ##############################Download part######################################
    & pathtoyoutube-dl\youtube-dl.exe -o "$path/%(title)s.%(ext)s" "$yturl" 

    Start-Sleep 3
    #################################################################################
    #######################Duplicate tracker by Hash part############################
    $b = gci $pathHash\* -file -recurse | Group-Object Length | Where-Object { $_.Count -gt 1 } | select -ExpandProperty group | foreach {get-filehash -literalpath $_.fullname} | group -property hash | where { $_.count -gt 1 } | foreach { $_.group | select -skip 1 }

    Write-Host "Looking for duplicates by HASH" -ForegroundColor Yellow

    foreach ($p in $b) {
        Write-Host "Deleting" $p.Path -ForegroundColor Cyan
        Start-Sleep 1
        Remove-Item -LiteralPath $p.Path

        if (Test-Path $p.Path) {

            Write-Host "Failed to delete" $p.Path -ForegroundColor Red

        }
        else {


            Write-Host $p.Path" Succesfully deleted because it was a duplicate file" -ForegroundColor Green
            Start-Sleep 1
        }
    }

    start-sleep 2
    $x = gci $pathHash -Filter *.mp3

    $y = gci $pathHash -Recurse -include *.webm, *.mkv, *.mp4
    Write-Host "Looking for duplicates by Name" -ForegroundColor Yellow

    start-sleep 2
    foreach ($m in $x) {
 
        foreach ($p in $y) {
            if (Compare-Object -ReferenceObject $m.BaseName.Replace("[", "").Replace("]", "").Replace(' ', '%20').Replace("'", "-") -DifferenceObject $p.BaseName.Replace("[", "").Replace("]", "").Replace(' ', '%20').Replace("'", "-"))
            {

            }

            Else {
                Write-Host $m.FullName + " and`n " + $p.FullName + " are the same`n" -ForegroundColor Green
         
                Write-Host "Removing" $p.FullName
                Remove-Item -LiteralPath $p.FullName
           
            }

        }
    }

    #################################################################################

    #############################Duplicate by name part##############################
    foreach ($inputFile in get-childitem $path -recurse -include *.mp4, *.mkv, *.webm) { 
        $inputFile2 = $inputFile.FullName.Replace("[", "").Replace("]", "")
        $outputFileName = [System.IO.Path]::GetFileNameWithoutExtension($inputFile.FullName) + $outputExtension;
        $outputFileName = [System.IO.Path]::Combine($path, $outputFileName);
     
     
        #$inputFile -replace ' ','%20'
        $outputFileName.Replace("[", "").Replace("]", "") 

        if (Test-Path $outputFileName) {
            Write-Host "Already exists !!!"
            Write-Host "Removing $inputFile"
            Remove-Item -LiteralPath $inputFile -Force
            $job = {param($p, $s) Remove-Item -LiteralPath $p\$s -Force}
            Start-Job $job -ArgumentList $path, $inputFile.Name
     
            Get-Job | Wait-Job 
            Get-Job | Remove-Job

            if (Test-Path $path\$inputFile) {
                Write-Host "Removing failed"

                Write-Host "Check if you have the rights to delete on this folder."
                Write-Host "Exiting..."
                Start-Sleep 5
                exit
            }
            else {
                write-Host "Removing succesful"
     
            }
     
        }
        #################################################################################
        ###############################Converter Part####################################
        else {
     
            $outputFileName = $outputFileName.Replace("[", "").Replace("]", "").Replace(' ', '%20').Replace("'", "-")
            $programFiles = ${env:ProgramFiles(x86)};
            if ($programFiles -eq $null) { $programFiles = $env:ProgramFiles; }
     
            $processName = $programFiles + "\VideoLAN\VLC\vlc.exe"
            $processArgs = "-I mp3 `"$($inputFile.FullName)`" --sout=#transcode{vcodec=none,acodec=mp3,ab=128,channels=2,samplerate=48000,scodec=none}:std{access=file,mux=mp3,dst='$outputFileName'} vlc://quit"
            Write-Host "=============="
            Write-Host "Converting $inputFile"
            Write-Host "=============="
            start-process $processName $processArgs -wait
            $outputFile2 = $outputFileName.Replace("%20", " ").Replace("[", "").Replace("]", "").Replace("'", "-")
     
     
            Write-Host "=============="
            Write-Host "$i songs remaining"
            Write-Host "=============="
            Start-Sleep 2
            if (Test-Path $outputFileName) {


                Write-Host "$InputFile.Name was succesfully converted into $outputFileName !!!" -ForegroundColor Green
                Write-Host "=============="
                Write-Host "Removing Mp4 song !!!"
                Write-Host "=============="
                Remove-Item -LiteralPath $inputFile.FullName
                Rename-Item  -Path $outputFileName -NewName $outputFile2
     
                $i--
     
            }
            else {
                Write-Host "=============="
                Write-Host "$InputFile.Name failed to converted into $outputFileName !!!" -ForegroundColor DarkCyan
                Write-Host "=============="
          
                $i--
            }
        }
        #################################################################################
    }
}
start-sleep 2
