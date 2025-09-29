#!/usr/bin/zsh

# invoking pyenv with optimisation parameters for python build
# this is claimed to reduce exec time upto 30%.
# Ref: https://github.com/pyenv/pyenv/wiki#how-to-build-cpython-for-maximum-performance
[[ $1 != '' ]] && \
  env PYTHON_CONFIGURE_OPTS='--enable-optimizations --with-lto' PYTHON_CFLAGS='-march=native -mtune=native' \
  PROFILE_TASK='-m test.regrtest --pgo -j0' pyenv install $1
