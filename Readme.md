# My tools repository
## MKV Tool
### Why?
MKV tool has been created because of the lack a gui for ffmpeg and i was tired of inputing the commands manually.
### Purpose
The aim is to provide a simple gui for ffmpeg using the existing system components with scirpting languages and make the file as lightweight as possible.
### Technicalities
FFMPEG version 2025-01-22 - as of now the tool works with previous versions since the stream operators has changed and for exampel option --disposition:s:s:1 is no longer correct way to manage streams in the output file. As of now the tool is **not operational**.
Windows: 	powershell
Linux:		bash
### To do
1. add recognition of text file encoding and convertion to utf-8 if different
2. add different language support. 
3. settings saving (preferebly in registry)
4. more gui options (options chooser)
5. re-write comments and variables in english