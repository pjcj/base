#!/bin/bash

# Originally written by Yu-Jie Lin

FONTNAME='Envy Code R'
FONTNAME='Inconsolata NF'
FONTSIZE='16'
FONTSTYLE='Regular'

while getopts "f:s:S:" opt; do
    case $opt in
        f)
            FONTNAME="$OPTARG"
            ;;
        s)
            FONTSIZE="$OPTARG"
            ;;
        S)
            FONTSTYLE="$OPTARG"
            ;;
        *)
            echo "Unrecognised flag $opt"
    esac
done

FONT="xft:$FONTNAME:style=$FONTSTYLE:size=$FONTSIZE:antialias=false"
# FONT="xft:$FONTNAME:pizelsize=$FONTSIZE"

echo setting font "$FONT"

printf '\e]710;%s\007' "$FONT"
