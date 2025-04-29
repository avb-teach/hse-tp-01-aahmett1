#!/usr/bin/env bash

if [ "$1" = "max_depth" ]; then
  shift
  max_depth="$1"
  input_dir="$2"
  output_dir="$3"
  root_out="$output_dir"

  declare -A cnt

  copy_dir() {
    local in_dir="$1"
    local out_dir="$2"
    local level="$3"

    if [ "$level" -gt "$max_depth" ]; then
      bn=$(basename "${in_dir%/}")
      count=${cnt[$bn]:-0}
      if [ "$count" -gt 0 ]; then
        new="${bn%.*}${count}${bn##${bn%.*}}"
      else
        new="$bn"
      fi
      cnt[$bn]=$((count+1))

      cp -r "${in_dir%/}" "$root_out/$new"

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
    for d in "${in_dir%/}"/*/; do
      [ -d "$d" ] || continue
      name=$(basename "${d%/}")
      copy_dir "$d" "$out_dir/$name" $((level+1))
    done
  }

  copy_dir "$input_dir" "$output_dir" 0

else
  input_dir="$1"
  output_dir="$2"
  mkdir -p "$output_dir"

  declare -A cnt

  find "$input_dir" -type f -print0 | while IFS= read -r -d '' file; do
    base=$(basename "$file")
    count=${cnt[$base]:-0}
    if [ "$count" -gt 0 ]; then
      name="${base%.*}"
      ext="${base#$name}"
      new="${name}${count}${ext}"
    else
      new="$base"
    fi
    cnt[$base]=$((count+1))
    cp "$file" "$output_dir/$new"
  done
fi

