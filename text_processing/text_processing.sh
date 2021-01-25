#!/bin/bash

if test "$#" -ne 2; then
    echo -e "Usage:\t$0 file_to_process output_file"
    exit 1
fi

in_file="$1"
out_file="$2"

if [ ! -f "$in_file" ]; then
    echo "File "$in_file" doesn't exists"
    exit 1
fi

last_word=""
last_sym=""
sym=""
declare -A duplicates

> "$out_file"
while read -a word; do
    size="${#word[@]}"
    fw="${word[0]}"
    [[ "${fw: -1}" =~ [.,?:\;!] ]] && sym="${fw: -1}" && fw="${fw%?}"
    cmp_fw=$(echo "$fw" | tr [:upper:] [:lower:])

    for index in $(seq 1 "$size"); do
        cw="${word[$index]}" 
        [[ "${cw: -1}" =~ [.,?:\;!] ]] && csym="${cw: -1}" && cw="${cw%?}"
        cmp_cw=$(echo "$cw" | tr [:upper:] [:lower:])

        if test "$cmp_cw" == "$cmp_fw"; then
            if [ ${duplicates[$cmp_cw]+_} ]; then
                (( duplicates["$cmp_cw"]++ ))
            else
                duplicates+=([$cmp_cw]=1)
            fi
            test -z "$sym" && sym="$csym"
            csym=""
            continue
        fi
        echo -n "$fw$sym " >> "$out_file"
        fw="$cw"
        cmp_fw="$cmp_cw"
        sym="$csym"
        csym=""
        cw=""
        cmp_cw=""
    done
    echo "$cw$csym" >> "$out_file"
    cw=""
    csym=""
    cmp_cw=""
    sym=""
done < "$in_file"
sed 's/[ ]*$//' -i "$out_file"

format="%-20s --> deleted %s times"
for key in "${!duplicates[@]}"; do printf "$format\n" "$key" "${duplicates[$key]}"; done
exit 0
