#!/bin/bash

filename=$1
args_qnt=$#
required_args_qnt=1

if [ $args_qnt -ne $required_args_qnt ]; then
    echo "Erro: Foram passados $args_qnt argumentos, mas $required_args_qnt eram esperados." >&2
    exit 1
fi

if test ! -f "$filename"; then
    echo "O arquivo $filename não existe."
    exit 1
fi

dir=$(echo $RANDOM | md5sum | head -c 20)
project_dir="projects/"$dir"/audios"
mkdir -p $project_dir
line_number=1

while read line; do
    echo $line
    curl -s -X POST -u "apikey:g4ltE0eDraLRUf37793esUWRUMWHAiR5KfFcoXOQY1xU" \
        --header "Content-Type: application/json" \
        --header "Accept: audio/wav" \
        --data "{\"text\":\"$line\"}" \
        --output $project_dir/$line_number.wav \
        "https://api.us-south.text-to-speech.watson.cloud.ibm.com/instances/e50b3681-11e9-4115-a0d4-98cd30b87517/v1/synthesize?voice=pt-BR_IsabelaV3Voice"
    line_number=$((line_number + 1))

done <$filename
