#!/bin/bash

filename=$1
args_qnt=$#
required_args_qnt=1
min_words_length=7

if [ $args_qnt -ne $required_args_qnt ]; then
    echo "Erro: Foram passados $args_qnt argumentos, mas $required_args_qnt eram esperados." >&2
    exit 1
fi

if test ! -f "$filename"; then
    echo "O arquivo $filename não existe."
    exit 1
fi

dir=$(echo $RANDOM | md5sum | head -c 20)
project_dir="projects/"$dir"/videos"
mkdir -p $project_dir
line_number=1

while read line; do
    frase_dir="$project_dir/$line_number"
    mkdir -p $frase_dir

    IFS=" " read -a words <<<"$line"
    word_number=1
    for word in "${words[@]}"; do
        word="$(echo "$word" | sed -e 's/[,.]//g')"
        word_length=${#word}
        if [ $word_length -le $min_words_length ]; then
            continue
        fi

        result=$(curl -s -L "https://pixabay.com/api/videos?key=32813020-ea2d766c2b68f0d68b304b97d&q=$word")

        link=$(echo "$result" | jq -r '.hits[0].videos.large.url')
        if [ $link == "null" ]; then
            continue
        fi

        destiny="$frase_dir/$word_number.mp4"
        echo "downloading $link to $destiny..."
        curl -s -LJ $link -o $destiny
        word_number=$((word_number + 1))
    done
    line_number=$((line_number + 1))

done <$filename
