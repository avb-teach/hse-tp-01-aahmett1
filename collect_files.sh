#!/bin/bash

[ "$1" = "max_depth" ] && shift

max_depth="$1"
input_dir="$2"
output_dir="$3"
root_out="$output_dir"

copy_dir() {
  local in_dir="$1"
  local out_dir="$2"
  local level="$3"

  if [ "$level" -ge "$max_depth" ]; then
    bn=$(basename "${in_dir%/}")
    cp -r "${in_dir%/}" "$root_out/$bn"
    for sub in "${in_dir%/}"/*/; do
      [ -d "$sub" ] || continue
      copy_dir "$sub" "$root_out" $((level+1))
    done
    return
  fi

  mkdir -p "$out_dir"

  for f in "$in_dir"/*; do
    [ -f "$f" ] && cp "$f" "$out_dir/"
  done

  for d in "$in_dir"/*/; do
    [ -d "$d" ] || continue
    dir_name="${d%/}"
    dir_name="${dir_name##*/}"
    copy_dir "$d" "$out_dir/$dir_name" $((level + 1))
  done
}

copy_dir "$input_dir" "$output_dir" 0

