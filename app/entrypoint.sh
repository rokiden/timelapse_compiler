#!/bin/bash
FFMPEG=/ffmpegwrapper.sh
EXIV2=exiv2
MOGRIFY=mogrify

FOLDER=$1

SRT=video/${FOLDER}.srt
OUTPUT=video/${FOLDER}.mp4

IDENT=$($EXIV2 $FOLDER/*.jpg | grep -a "Image size" | awk '{print $1,$5,$7}')
MAX_W=$(echo "$IDENT" | awk '{print $2}' | sort -nr | head -n1)
MAX_H=$(echo "$IDENT" | awk '{print $3}' | sort -nr | head -n1)
MAX_SIZE="${MAX_W}x${MAX_H}"
echo "MAX IMAGE SIZE: $MAX_SIZE"
VIDEO_H=$TL_VIDEO_H
let VIDEO_W=${MAX_W}*${VIDEO_H}/${MAX_H}
echo "VIDEO SIZE: ${VIDEO_W}x${VIDEO_H}"

SMALLER=$(echo "$IDENT" | grep -v " $MAX_W $MAX_H" | awk '{print $1}')
IMG_CNT=$(echo -n "$SMALLER" | wc -l)
echo Images to resize: $IMG_CNT

if (( $IMG_CNT > 0 )); then
    $MOGRIFY -resize "${MAX_SIZE}" -background black -gravity center -extent "${MAX_SIZE}" -limit thread $TL_THREADS $SMALLER
else
    echo Nothing to resize
fi && \
python3 /app/sub.py $FOLDER $SRT $TL_FPS $TL_SUB_FPS && \
$FFMPEG -y \
    -hwaccel qsv -hwaccel_output_format qsv -c:v mjpeg_qsv \
    -framerate $TL_FPS -pattern_type glob -i "${FOLDER}/*.jpg" \
    -filter_complex "\
    color=size=${VIDEO_W}x${VIDEO_H}:rate=8:color=#00000000,\
    subtitles=${SRT}:alpha=1:fontsdir=fonts:force_style='$TL_SUB_STYLE',\
    crop=${TL_SUB_W}:${TL_SUB_H}:0:0,format=bgra,hwupload=extra_hw_frames=64 [sub];\
    [0] scale_qsv=w=${VIDEO_W}:h=${VIDEO_H} [scaled];
    [scaled][sub] overlay_qsv=x=0:y=0:shortest=1 [out]\
    " -map [out] \
    -c:v h264_qsv \
    $TL_ENC \
    ${OUTPUT}
rm ${SRT}
