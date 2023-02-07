#!/bin/bash

project=$1
args_qnt=$#
required_args_qnt=1

if [ $args_qnt -ne $required_args_qnt ]; then
  echo "Erro: Foram passados $args_qnt argumentos, mas $required_args_qnt eram esperados." >&2
  exit 1
fi

project_dir=projects/$project

if test ! -d "$project_dir"; then
  echo "O projeto $project não existe."
  exit 1
fi

speech_dir="$project_dir/audios"
speech_files=$(ls "$speech_dir")

for speech_file in $speech_files; do
  audio_duration=$(ffprobe -i "$speech_dir/$speech_file" -show_entries format=duration -v quiet -of csv="p=0")
  dirname=$(basename "$speech_file" .wav)
  video_dir="$project_dir/videos/$dirname"
  video_files=$(ls "$video_dir")
  video_files_qnt=$(ls "$video_dir" | grep .mp4 | wc -l)
  video_duration=0.0
  mkdir -p "$video_dir/editeds"

  for video_file in $video_files; do
    if [ ! -f "$video_dir/$video_file" ]; then
      continue
    fi

    duration=$(bc -l <<<"$(ffprobe -i "$video_dir/$video_file" -show_entries format=duration -v quiet -of csv="p=0")")
    video_duration=$(echo "$video_duration + $duration" | bc | awk '{printf "%.2f\n", $0}')
  done

  audio_duration=$(echo "$audio_duration" | bc)
  total_cut_duration=$(echo "scale=2; $audio_duration/$video_files_qnt" | bc | awk '{printf "%.2f\n", $0}')
  
  for video_file in $video_files; do
    if [ ! -f "$video_dir/$video_file" ]; then
      continue
    fi

    video_duration=$(bc -l <<<"$(ffprobe -i "$video_dir/$video_file" -show_entries format=duration -v quiet -of csv="p=0")")
    if ($(echo "$total_cut_duration > $video_duration" | bc -l)); then
      total_cut_duration=$video_duration
    fi

    hours=$(printf "%02d" $(bc <<<"scale=0; $total_cut_duration / 3600"))
    minutes=$(printf "%02d" $(bc <<<"scale=0; ($total_cut_duration % 3600) / 60"))
    seconds=$(printf "%02d" $(bc <<<"scale=0; $total_cut_duration % 60"))

    duration_formated="$hours:$minutes:$seconds"

    ffmpeg -i "$video_dir/$video_file" -t "$duration_formated" "$video_dir/editeds/$video_file"
    ffmpeg -i "$video_dir/editeds/$video_file" "-c:v" libx264 "-c:a" aac "-b:v" 1M "-b:a" 128k "$video_dir/editeds/formated-$video_file"
  done

  if [ "${#video_files[@]}" -gt 0 ]; then
    output_file=$video_dir/editeds/joined.mp4
    input_files=()
    for video_file in $video_files; do
      if [ ! -f "$video_dir/editeds/formated-$video_file" ]; then
        continue
      fi

      input_files+=(-i "$video_dir/editeds/formated-$video_file")
    done
    ffmpeg "${input_files[@]}" "-c:v" libx264 "-c:a" aac "-b:v" 1M "-b:a" 128k "$output_file"
  fi
done
