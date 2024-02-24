FROM linuxserver/ffmpeg
RUN \
  echo "**** install image processing ****" && \
    apt-get update && \
    apt-get install -y \
    python3 \
    exiv2 \
    imagemagick \
    && \
  echo "**** clean up ****" && \
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/*
WORKDIR /data
ENTRYPOINT ["/app/entrypoint.sh"]
ENV TL_THREADS=8
ENV TL_VIDEO_H=2160
ENV TL_ENC="-global_quality 29 -look_ahead 1 -look_ahead_depth 1 -preset 1"
ENV TL_FPS=24
ENV TL_SUB_FPS=8
ENV TL_SUB_H=128
ENV TL_SUB_W=1024
ENV TL_SUB_STYLE="Alignment=5,MarginL=2,MarginV=2,Fontsize=10,Outline=0.5,AlphaLevel=64,Fontname=Credit Card"
COPY app /app
