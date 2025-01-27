#Windows system imports needed for gui
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
#Variables
$DirPath    = ""        #Variable to store Path
$FileList   = @("","")  #Variable to store list of files found in a directory
$HowManySubtitles = 0   #Variable to store amount of subtitles in a file
$Metadata   = ""        #Variable to store metadata stream position - lowers the amount of text in commands
$RemoveSubtitles = "false" #Variable a boolean switch if you want to remove other subtitles from the container
$SubtitlesMetaDataLanguage  = "pol"
$MetadataLanguage           = "language=pol"
$MetadataHandlerName        = "handler_name=Polish"
$MetadataTitle              = "title=Polski"
$extv       = "mkv" #extension for video files
$exts       = "srt" #extension for subtitle files
$DeleteSourceFiles          = 0 #Variable to check if you want to delete source files
$LangIndex                  = 1 #Variable for messages basically it is a language selection for the script
#Output Messages
$Message = 
@(
    [PSCustomObject]@{SelectFolder="Select Folder"; NoDefSub="The are no subtitles set to be default."; RemoveSubNoSub="You have chosen to remove subtitles from file but there no subtitles found."; FileExists="Files exists."; Processing="Processing"; ConvAss="Converting subtitles to ass format."; File="File"; HasSub="has already subtitles"; FileNotExists="One of two required files doesn't exist."; RemSub="Subtitles has been removed from file"; ChooseMetaLang="Choose language for metadata that will be used to describe subtitles"}
    [PSCustomObject]@{SelectFolder="Wybierz Folder"; NoDefSub="Nie znaleziono napisow które by były ustawione jako domyslne."; RemoveSubNoSub="Wybrales usuniecie napisów z pliku, ale nie znaleziono napisów w pliku"; FileExists="Pliki Istnieja."; Processing="Przetwarzanie"; ConvAss="Konwertowanie napisow do formatu ass."; File="Plik"; HasSub="ma juz napisy"; FileNotExists="Jeden z dwoch wymaganych plikow nie istnieje."; RemSub="Usunieto napisy z pliku"; ChooseMetaLang="Wybierz jezyk dla metadanych ktore zostana uzyte do opisu napisow"}
    [PSCustomObject]@{SelectFolder="Seleziona la Cartella"; NoDefSub="Non ci sono sottotitoli impostati come predefiniti."; RemoveSubNoSub="Hai scelto di rimuovere i sottotitoli dal file ma non sono stati trovati sottotitoli."; FileExists="I file esistono."; Processing="Lavorazione"; ConvAss="Conversione dei sottotitoli in formato ass."; File="File"; HasSub="ha i sottotitoli"; FileNotExists="Uno dei due file richiesti non esiste."; RemSub="I sottotitoli sono stati rimossi dal file"; ChooseMetaLang="Scegli i metadati della lingua che verranno utilizzati per i sottotitoli"}
)

#Functions
#Checking file encoding
function Get-Encoding
{
  param
  (
    [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [Alias('FullName')]
    [string]
    $Path
  )
 
  process
  {
    $bom = New-Object -TypeName System.Byte[](4)
         
    $file = New-Object System.IO.FileStream($Path, 'Open', 'Read')
     
    $null = $file.Read($bom,0,4)
    $file.Close()
    $file.Dispose()
     
    $enc = [Text.Encoding]::ASCII
    if ($bom[0] -eq 0x2b -and $bom[1] -eq 0x2f -and $bom[2] -eq 0x76) 
      { $enc =  [Text.Encoding]::UTF7 }
    if ($bom[0] -eq 0xff -and $bom[1] -eq 0xfe) 
      { $enc =  [Text.Encoding]::Unicode }
    if ($bom[0] -eq 0xfe -and $bom[1] -eq 0xff) 
      { $enc =  [Text.Encoding]::BigEndianUnicode }
    if ($bom[0] -eq 0x00 -and $bom[1] -eq 0x00 -and $bom[2] -eq 0xfe -and $bom[3] -eq 0xff) 
      { $enc =  [Text.Encoding]::UTF32}
    if ($bom[0] -eq 0xef -and $bom[1] -eq 0xbb -and $bom[2] -eq 0xbf) 
      { $enc =  [Text.Encoding]::UTF8}
         
    [PSCustomObject]@{
      Encoding = $enc
      Path = $Path
    }
  }
}

#Options Chooser
Function DropDown {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Select a Computer'
    $form.Size = New-Object System.Drawing.Size(300,200)
    $form.StartPosition = 'CenterScreen'

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(75,120)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'OK'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(150,120)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,20)
    $label.Size = New-Object System.Drawing.Size(280,20)
    $label.Text = 'Please select a computer:'
    $form.Controls.Add($label)

    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Location = New-Object System.Drawing.Point(10,40)
    $listBox.Size = New-Object System.Drawing.Size(260,20)
    $listBox.Height = 80

    [void] $listBox.Items.Add('atl-dc-001')
    [void] $listBox.Items.Add('atl-dc-002')
    [void] $listBox.Items.Add('atl-dc-003')
    [void] $listBox.Items.Add('atl-dc-004')
    [void] $listBox.Items.Add('atl-dc-005')
    [void] $listBox.Items.Add('atl-dc-006')
    [void] $listBox.Items.Add('atl-dc-007')

    $form.Controls.Add($listBox)

    $form.Topmost = $true

    $result = $form.ShowDialog()
`
    if ($result -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $x = $listBox.SelectedItem
    }
}
Function DetectAndSetSystemLanguage
{
    $LangCode = (Get-Uiculture).ThreeLetterIsoLanguageName
    Switch($LangCode)
    {
        "eng" { Set-Variable -Scope Global -Name "LangIndex" -Value 0 }
        "pol" { Set-Variable -Scope Global -Name "LangIndex" -Value 1 }
        "ita" { Set-Variable -Scope Global -Name "LangIndex" -Value 2 }
        default
        {
            Set-Variable -Scope Global -Name "LangIndex" -Value 0
            Write-Host "Your system language is not supported, setting to English"
        }

    }
}
Function ChooseMetadataLanguage
{
    $form = New-Object System.Windows.Forms.Form
    $form.Text = $Message[$LangIndex].ChooseMetaLang
    $form.Size = New-Object System.Drawing.Size(300,200)
    $form.StartPosition = 'CenterScreen'

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(75,120)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'OK'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(150,120)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,20)
    $label.Size = New-Object System.Drawing.Size(270,40)
    $label.Text = $Message[$LangIndex].ChooseMetaLang
    $form.Controls.Add($label)

    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Location = New-Object System.Drawing.Point(10,60)
    $listBox.Size = New-Object System.Drawing.Size(260,20)
    $listBox.Height = 50

    [void] $listBox.Items.Add('English')
    [void] $listBox.Items.Add('Polski')
    [void] $listBox.Items.Add('Italiano')

    $form.Controls.Add($listBox)

    $form.Topmost = $true

    $result = $form.ShowDialog()
`
    if ($result -eq [System.Windows.Forms.DialogResult]::OK)
    {
        Switch ($listBox.SelectedItem)
        {
            'English' { ChangeSubtitleMetadataLang("eng") }
            'Polski' { ChangeSubtitleMetadataLang("pol") }
            'Italiano' { ChangeSubtitleMetadataLang("ita") }
            default { ChangeSubtitleMetadataLang("eng") }
        }
    }
}
#Folder Chooser
Function Get-Folder($initialDirectory="E:\Test")
{
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = $Message[$LangIndex].SelectFolder
    $foldername.rootfolder = "MyComputer"
    $foldername.SelectedPath = $initialDirectory

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return $folder
}

#Fucntion that returns position of default subtitles in containerfile
Function FindPositionOfDefaultSubtitles($FileVideo)
{
    $HowManyStreamsVideo = (ffmpeg -i $FileVideo 2>&1 | Select-String "Stream" | Select-String "Video").count
    $HowManyStreamsAudio = (ffmpeg -i $FileVideo 2>&1 | Select-String "Stream" | Select-String "Audio").count
    $DefaultSubtitlesPosition = (ffmpeg -i $FileVideo 2>&1 | Select-String "Subtitle" | Select-String "(default)")
    If ($DefaultSubtitlesPosition -ne $null)
    {
        $DefaultSubtitlesPosition = $DefaultSubtitlesPosition.ToString()
        $Index = $DefaultSubtitlesPosition.IndexOf(":")
        $ReturnedPosition= $DefaultSubtitlesPosition.Substring($Index+1,1)
        $ReturnedPosition = $ReturnedPosition - ($HowManyStreamsVideo + $HowManyStreamsAudio)
    }
    else 
    {
        $ReturnedPosition = 0
        Write-Host $Message[$LangIndex].NoDefSub
    }
    Return $ReturnedPosition
}

#Function to quickly change metadata values for subtitle file added to container
Function ChangeSubtitleMetadataLang($LangCode)
{
    Switch ($LangCode)
    {
        "pol"
        {
            Set-Variable -Scope Global -Name "MetadataLanguage" -Value "language=pol"
            Set-Variable -Scope 1 -Name "MetadataHandlerName" -Value "handler_name=Polish"
            Set-Variable -Scope 1 -Name "MetadataTitle" -Value "title=Polski"
        }
        "eng"
        {
            Set-Variable -Scope 1 -Name "MetadataLanguage" -Value "language=eng"
            Set-Variable -Scope 1 -Name "MetadataHandlerName" -Value "handler_name=English"
            Set-Variable -Scope 1 -Name "MetadataTitle" -Value "title=English"
        }
        "ita"
        {
            Set-Variable -Scope 1 -Name "MetadataLanguage" -Value "language=ita"
            Set-Variable -Scope 1 -Name "MetadataHandlerName" -Value "handler_name=Italian"
            Set-Variable -Scope 1 -Name "MetadataTitle" -Value "title=Italiano"
        }
    } 
}

#Code
DetectAndSetSystemLanguage
$DirPath = Get-Folder
cd $DirPath
ChooseMetadataLanguage
$FileList = Get-ChildItem -Path $DirPath -Filter "*.$($extv)" -Name
foreach($File in $FileList)
{
    $HowManySubtitles = (ffmpeg -i $File 2>&1 | Select-String "Subtitle").count
    if (($RemoveSubtitles -eq "true") -and ($HowManySubtitles -eq 0)) {Write-Host $Message[$LangIndex].RemoveSubNoSub}
    elseif (($RemoveSubtitles -eq "true") -and ($HowManySubtitles -ne 0))
    {
        ffmpeg -i $File -c copy -sn "file:output.mkv" -loglevel error
        del $File
        mv output.mkv $File
        $HowManySubtitles = 0
    }
    $File = $File.Substring(0,$File.Length-4)
    if ((Test-Path "$($DirPath)`\$($File).$($extv)" -PathType Leaf) -and (Test-Path "$($DirPath)`\$($File).$($exts)" -PathType Leaf))
    {
        $FileMkv = "$($File).$($extv)"
        $FileSrt = "$($File).$($exts)"
        $FileAss = "$($File).ass"
        Write-Host $Message[$LangIndex].FileExists
        Write-Host "$($Message[$LangIndex].Processing): `t$($FileMkv)"
        Write-Host "$($Message[$LangIndex].Processing): `t$($FileSrt)"
        Write-Host $Message[$LangIndex].ConvAss
        Write-host "$($MetadataLanguage)`t$($MetadataHandlerName)`t$($MetadataTitle)"
        ffmpeg -sub_charenc UTF-8 -i $FileSrt "file:$($FileAss)" -loglevel error #-sub_charenc UTF-8 -sub_charenc CP1250
        if ($HowManySubtitles -ne 0) 
        {
            Write-Host "$($Message[$LangIndex].File) $($FileMkv) $($Message[$LangIndex].HasSub): $($HowManySubtitles)"
            $DefaultSubtitlesPosition = FindPositionOfDefaultSubtitles($FileMkv)
            #Write-Host "Posiition of Default: `t $($DefaultSubtitlesPosition)"
            $Metadata = "-metadata:s:s:$($HowManySubtitles)"
            ffmpeg -i $FileMkv -i $FileAss -map 0 -c copy -map "1:0" $Metadata $MetadataLanguage $Metadata $MetadataHandlerName $Metadata $MetadataTitle -disposition:s:$HowManySubtitles default -disposition:s:$DefaultSubtitlesPosition 0 "file:output.mkv" -loglevel error #-disposition:s:s:$HowManySubtitles default -disposition:s:s:$DefaultSubtitlesPosition 0
        }
        else
        {
            $Metadata = "-metadata:s:s:$($HowManySubtitles)"
            ffmpeg -i $FileMkv -i $FileAss -map 0 -c copy -map "1:0" $Metadata $MetadataLanguage $Metadata $MetadataHandlerName $Metadata $MetadataTitle -disposition:s:$HowManySubtitles default "file:output.mkv" -loglevel error #-disposition:s:0 0 
        }
        if ($DeleteSourceFiles -ne 0)
        {
            del $FileMkv
            del $FileSrt
            del $FileAss
            mv output.mkv "$($FileMkv)"
        }
        else 
        {
            sleep 3 
            del $FileAss
            mv output.mkv "new_$($FileMkv)"
        }
    }
    else 
    {
        if ($RemoveSubtitles -eq "false") {Write-host $Message[$LangIndex].FileNotExists}
        else {Write-Host "$($Message[$LangIndex].RemSub): $($File)"}
    }
}