---
title: FFmpeg
comments: ture
---

# FFmpeg
 

# FFmpeg
ffmpeg commands usage

## mp4 to webp

Example command which would convert an mp4 file to a lossless loop playing webp file in 20FPS with resolution 800px(width) * h600px(height):

```
ffmpeg -i input_filename.mp4 -vcodec libwebp -filter:v fps=fps=20 -lossless 1 -loop 0 -preset default -an -vsync 0 -s 800:600 output_filename.webp
```

Export an animated lossy WebP with preset mode picture：
```
ffmpeg -i input.mp4 -vcodec libwebp -filter:v fps=fps=20 -lossless 0  -compression_level 3 -q:v 70 -loop 1 -preset picture -an -vsync 0 -s 800:600 output.webp
```

## mp4 resize

Mp4 resize, reduce resolution rate, bit rate, compress audio, and using H.265

```
ffmpeg -i input.mp4 -vf "scale=1280:720" -b:v 1000k -b:a 128k -c:v libx265 -crf 28 output.mp4
```

## mp4 to GIF:

```
ffmpeg -i "youfile.mp4" -c:v gif "output.gif"
```
or with a specific frame rate and scale:

```
ffmpeg -i "yourfile.mp4" -vf "fps=60,scale=480:-1:flags=lanczos" -c:v gif "output.gif"
```

## GIF to frame images

```
ffmpeg -i "yourFile.gif"  -vsync 0 frame%d.png 
```


 more:
  [mp4 to webp](https://gist.github.com/witmin/1edf926c2886d5c8d9b264d70baf7379)