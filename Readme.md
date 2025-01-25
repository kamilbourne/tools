# My tools repository
## MKV Tool
### Why?
MKV tool has been created because of the lack a gui for ffmpeg and i was tired of inputing the commands manually.
### Purpose
The aim is to provide a simple gui for ffmpeg using the existing system components with scirpting languages and make the file as lightweight as possible.
### Technicalities
FFMPEG version 2025-01-22 - as of now the tool works with previous versions since the stream operators has changed and for exampel option --disposition:s:s:1 is no longer correct way to manage streams in the output file. As of now the tool is operation in limited matter - you have to make changes in the code yourself when it comes to metadata and switches.  
Windows: 	powershell  
Linux:		bash  
As of now the tool is operating in chosen folder, takes the mkv file and srt file (the names have to match), converts srt to ass and adds it to the video file as another subtitle track, and sets it as default (assumed that if you need subtitles you are watching movie not in your native language and you will need to choose them either way)
### To do
1. add recognition of text file encoding and convertion to utf-8 if different
2. add different language support. 
3. settings saving (preferebly in registry)
4. more gui options (options chooser)
5. add setting up default subtitle with mutltipe files
6. add removing all the subtitle files besides chosen language
7. add adding an audio stream from another file
8. add option to change the time of subtitles
9. add option to resync audio
10. add file chooser for single file 