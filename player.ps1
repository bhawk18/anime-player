if ($MyInvocation.MyCommand.CommandType -eq "ExternalScript")
{ # Powershell script
	$ScriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
}
else
{ # PS2EXE compiled script
	$ScriptPath = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0])
}


Add-Type -AssemblyName PresentationFramework

function Find-Folders {
    [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $browse = New-Object System.Windows.Forms.FolderBrowserDialog
    #$browse.SelectedPath = "C:\"
    $browse.ShowNewFolderButton = $false
    $browse.Description = "Select a directory"
    $loop = $true
    $browse.ShowDialog() | out-null
    $browse.SelectedPath
  #  $browse.Dispose()
} 



$count=0
if(Test-Path -Path "$ScriptPath\playlog.csv"){
$playlog=Import-Csv -Path "$ScriptPath\playlog.csv"
[int]$epno=$playlog.epno
$path = $playlog.filelocation
}
else{
$epno =$null
$path=Find-Folders
}
(Get-ChildItem -Path "$path" -Filter "*.mkv").FullName | % {
if(!$epno)
{
[int]$epno = ($_ | Select-String -Pattern "\b\d+\b").Matches.Value

}

if ($_ -match $epno)
{
Write-Output "$_"
$processd=Start-Process vlc.exe -ArgumentList "--start-time=183 --stop-time=1383 --play-and-exit --aspect-ratio 16:9 --fullscreen --started-from-file `"$_`""-Wait -PassThru
$processd.HasExited
$count++
$epno++

$data=[PSCustomObject]@{
epno=$epno
filelocation=$path}

Export-Csv -InputObject $data -Path "$ScriptPath\playlog.csv" -Force -NoTypeInformation
}
if ($count -ge 4){
$msgBoxInput =  [System.Windows.MessageBox]::Show('Would you like to play Next?','Anime Player','YesNoCancel','Information')
switch  ($msgBoxInput) {

  'Yes' {

  continue

  }

  'No' {

  exit

  }

  'Cancel' {

  continue

  }

  }
}

}