# FFmpeg Video Generator
## A powerful and efficient tool for generating high-quality videos using FFmpeg technology.

## Introduction
This repository provides a shell script for automating the process of generating videos using FFmpeg. The script uses FFmpeg to concatenate multiple video files into a single output file. It also allows you to specify the encoding options for the output video, such as video and audio codecs, bitrates, etc.

## Requirements
FFmpeg installed and accessible in your PATH.
Bash shell.

## TODO

1. Download the videos of each phrase. [OK]

2. Creates spoken audio through the text of each sentence. [OK]

3. Check the sentence length and relate it to the videos
   -> The total duration of the videos added together should give the total duration of the speech, so I must interrupt the percentage of the duration of each video, so that together they form the total duration

4. Merge the cut videos of the phrase into one.

5. Insert the speech in the video that was joined.

6. Do the process with all the phrases.