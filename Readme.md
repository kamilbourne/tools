# **My tools repository**
# Windows
### Unblock powershell file
First Check execution policy:
```
Get-ExecutionPolicy
```
Then set execution policy to run only signed files. 
```
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
```
The unblock specific file:
```
Unblock-File -Path .\optimize.ps1
```
From [Powershell Documentaion](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-7.5)
>-ExecutionPolicy
>Specifies the execution policy. If there are no Group Policies and each scope's execution policy is set to Undefined, then Restricted becomes the effective policy for all users.
>The acceptable execution policy values are as follows:
>AllSigned. Requires that all scripts and configuration files are signed by a trusted publisher, including scripts written on the local computer.
>Bypass. Nothing is blocked and there are no warnings or prompts.
>Default. Sets the default execution policy. Restricted for Windows clients or RemoteSigned for Windows servers.
>RemoteSigned. Requires that all scripts and configuration files downloaded from the Internet are signed by a trusted publisher. The default execution policy for Windows server computers.
>Restricted. Doesn't load configuration files or run scripts. The default execution policy for Windows client computers.
>Undefined. No execution policy is set for the scope. Removes an assigned execution policy from a scope that is not set by a Group Policy. If the execution policy in all scopes is Undefined, the effective execution policy is Restricted.
>Unrestricted. Beginning in PowerShell 6.0, this is the default execution policy for non-Windows computers and can't be changed. Loads all configuration files and runs all scripts. If you run an unsigned script that was downloaded from the internet, you're prompted for permission before it runs.
## MKV Tool
### Why?
MKV tool has been created because of the lack a gui for ffmpeg and i was tired of inputing the commands manually.
### Purpose
The aim is to provide a simple gui for ffmpeg using the existing system components with scirpting languages and make the file as lightweight as possible. Intendend to operate on multiple files in one directory.
### Technicalities
FFMPEG version 2025-01-22 - as of now the tool works with previous versions since the stream operators has changed and for exampel option --disposition:s:s:1 is no longer correct way to manage streams in the output file. As of now the tool is operation in limited matter - you have to make changes in the code yourself when it comes to metadata and switches.  
Windows: 	powershell  
Linux:		bash  
As of now the tool is operating in chosen folder, takes the mkv file and srt file (the names have to match), converts srt to ass and adds it to the video file as another subtitle track, and sets it as default (assumed that if you need subtitles you are watching movie not in your native language and you will need to choose them either way)
### To do
1. add recognition of text file encoding and convertion to utf-8 if different
3. settings saving (preferebly in registry)
5. add setting up default subtitle with mutltipe files
6. add removing all the subtitle files besides chosen language
7. add adding an audio stream from another file
8. add option to change the time of subtitles
9. add option to resync audio
10. add file chooser for single file 
## Optimize Tool
### Why?
For Practice :). And also sometimes even the changes made in Group Policy (gpedit.msc) won't work. 
### Purpose
Simple Powershell Script to turn on / off the features of windows. 
### To do
1. Add more features!
2. Lang Support - As of now all the outputs are written in polish. 
