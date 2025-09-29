# Anirban - 2/11/2024 - Initial version
# Will be used to primarily set paths

# Custom functions path for autoload
[[ $fpath = *customfns* ]] || fpath=(~/.customfns $fpath)
# pyenv related paths

typeset -U path # Making sure duplicate entries are removed
export PYENV_ROOT=$HOME/.pyenv
[[ -d $PYENV_ROOT/bin ]] && path=($PYENV_ROOT/bin $path)

export GO_ROOT=$HOME/go
[[ -d $GO_ROOT/bin ]] && path=($path $GO_ROOT/bin)

#adding scripts folder in the path
[[ -d ~/scripts ]] && path=($path ~/scripts)
