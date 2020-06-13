#!/usr/bin/env bash

# Bash script to turn open trivia db into a game
# Original improved by Glenn Jackman
# https://unix.stackexchange.com/a/553467/16792

main() {
    local -a questions
    mapfile -t questions < <(
        get_quiz |
        jq -r '.results[] | [.question] + [.correct_answer] + .incorrect_answers | @sh'
    )

    for i in "${!questions[@]}"; do
        local -a q="( ${questions[i]} )"
        question $((i+1)) "${q[@]}"
    done
}

question() {
    local num=$1 question=$2 correct=$3
    local -a answers=("${@:3}")

    # shuffle the answers
    mapfile -t answers < <(printf "%s\n" "${answers[@]}" | sort -R)

    echo
    echo "Question #$num"
    PS3="${question//&quot;/\'} "

    select answer in "${answers[@]}"; do
        if [[ $answer == "$correct" ]]; then
            echo "Correct"
            break
        fi
        echo "Incorrect"
    done
}

get_quiz() {
    curl -s https://opentdb.com/api.php?amount=3
}

main
