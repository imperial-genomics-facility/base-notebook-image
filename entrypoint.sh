#!/usr/bin/env bash
case "$1" in
notebook)
  . /home/vmuser/miniconda3/etc/profile.d/conda.sh
  conda activate notebook-env
  jupyter lab --no-browser --port=8888 --ip=0.0.0.0
  
  ;;
*)
  . /home/vmuser/miniconda3/etc/profile.d/conda.sh
  conda activate notebook-env
  exec "$@"
     ;;
esac
