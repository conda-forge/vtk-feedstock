#!/bin/bash

set -x

PARENT_DIR=$(dirname $PREFIX)
FFMPEG_DIR="$PARENT_DIR/ffmpeg_dir"
# Move vtkIOFFMPEG files to $PREFIX
find $FFMPEG_DIR -name "*vtkIOFFMPEG*" -print0 | xargs -0 -I {} rsync -av --remove-source-files {} $PREFIX/{}
