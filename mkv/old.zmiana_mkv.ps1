#Systemowe importy
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
#Zmienne
$Sciezka = "" #Zmienna do przechowywania sciezki
$PlikList = @("","") #Zmienna do przechowywania listy plikow
$IleNapisow = 0 #Ile jest juz napisow w pliku
$Metadata = "" #Zmienna do parametryzowania dodawania napisow
$UsunNapisy = "false"
$SubtitlesMetaDataLanguage = "pol"
$MetadataLanguage = "language=pol"
$MetadataHandlerName = "handler_name=Polish"
$MetadataTitle       = "title=Polski"
$rozv = "mkv" #rozszerzenie plikow wideo
$rozs = "srt" #rozszerzenie plikow z napisami

#Funkcje
#Sprawdzanie formatu tekstu
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

#Wybieranie opcji
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
        $x
    }
}

#Wybieranie Folderu
Function Get-Folder($initialDirectory="D:\test")
{
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select a folder"
    $foldername.rootfolder = "MyComputer"
    $foldername.SelectedPath = $initialDirectory

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return $folder
}

#Funkcja ktora zwraca pozycje domyslnych napisow
Function ZnajdzPozycjeDomyslnychNapisow($PlikWideo)
{
    $IleStrumieniWideo = (ffmpeg -i $PlikWideo 2>&1 | Select-String "Stream" | Select-String "Video").count
    $IleStrumieniAudio = (ffmpeg -i $PlikWideo 2>&1 | Select-String "Stream" | Select-String "Audio").count
    $PozycjaDomyslnychNapisow = (ffmpeg -i $PlikWideo 2>&1 | Select-String "Subtitle" | Select-String "(default)")
    If ($PozycjaDomyslnychNapisow -ne $null)
    {
        $PozycjaDomyslnychNapisow = $PozycjaDomyslnychNapisow.ToString()
        $Index = $PozycjaDomyslnychNapisow.IndexOf(":")
        $ZwroconaPozycja= $PozycjaDomyslnychNapisow.Substring($Index+1,1)
        $ZwroconaPozycja = $ZwroconaPozycja - ($IleStrumieniWideo + $IleStrumieniAudio)
    }
    else 
    {
        $ZwroconaPozycja = 0
        Write-Host "Jest null takze zwrocona pozycja = $($ZwroconaPozycja)"
    }
    Return $ZwroconaPozycja
}

#Funkcja do szybkiej zmiany metadanych jezyka napisów
Function ZmianaJezyka($LangCode)
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
    } 
}

#Kod
$Sciezka = Get-Folder
cd $Sciezka
$PlikList = Get-ChildItem -Path $Sciezka -Filter "*.$($rozv)" -Name
foreach($Plik in $PlikList)
{
    $IleNapisow = (ffmpeg -i $Plik 2>&1 | Select-String "Subtitle").count
    if (($UsunNapisy -eq "true") -and ($IleNapisow -ne 0))
    {
        ffmpeg -i $Plik -c copy -sn "file:output.mkv" -loglevel error
        del $Plik
        mv output.mkv $Plik
        $IleNapisow = 0
    }
    $Plik = $Plik.Substring(0,$Plik.Length-4)
    if ((Test-Path "$($Sciezka)`\$($Plik).$($rozv)" -PathType Leaf) -and (Test-Path "$($Sciezka)`\$($Plik).$($rozs)" -PathType Leaf))
    {
        $PlikMkv = "$($Plik).$($rozv)"
        $PlikSrt = "$($Plik).$($rozs)"
        $PlikAss = "$($Plik).ass"
        Write-Host "Pliki Istnieja"
        Write-Host "Przetwarzanie: `t$($PlikMkv)"
        Write-Host "Przetwarzanie: `t$($PlikSrt)"
        Write-Host "Konwertowanie napisow do formatu ASS"
        ZmianaJezyka("pol")
        Write-host "$($MetadataLanguage)`t$($MetadataHandlerName)`t$($MetadataTitle)"
        ffmpeg -sub_charenc UTF-8 -i $PlikSrt "file:$($PlikAss)" -loglevel error #-sub_charenc UTF-8 -sub_charenc CP1250
        if ($IleNapisow -ne 0) 
        {
            Write-Host "Plik $($PlikMkv) ma juz napisy w ilosci: $($IleNapisow)"
            $PozycjaDomyslnychNapisow = ZnajdzPozycjeDomyslnychNapisow($PlikMkv)
            Write-Host "Pozycja Domyslnych: `t $($PozycjaDomyslnychNapisow), Ile Napisow: `t$($IleNapisow)"
            $Metadata = "-metadata:s:s:$($IleNapisow)"
            ffmpeg -i $PlikMkv -i $PlikAss -map 0 -c copy -map "1:0" $Metadata $MetadataLanguage $Metadata $MetadataHandlerName $Metadata $MetadataTitle -disposition:s:s:$IleNapisow default -disposition:s:s:$PozycjaDomyslnychNapisow 0 "file:output.mkv" -loglevel error #-disposition:s:s:$IleNapisow default -disposition:s:s:$PozycjaDomyslnychNapisow 0
        }
        else
        {
            $Metadata = "-metadata:s:s:$($IleNapisow)"
            ffmpeg -i $PlikMkv -i $PlikAss -map 0 -c copy -map "1:0" $Metadata $MetadataLanguage $Metadata $MetadataHandlerName $Metadata $MetadataTitle -disposition:s:s:$IleNapisow default "file:output.mkv" -loglevel error #-disposition:s:0 0 
        }
#        del $PlikMkv
#        del $PlikSrt
#        del $PlikAss
        mv output.mkv "2$($PlikMkv)"
    }
    else 
    {
        if ($UsunNapisy -eq "false") {Write-host "Jeden z dwoch wymaganych plikow nie istnieje"}
        else {Write-Host "Usunieto napisy z pliku $($Plik)"}
    }
}