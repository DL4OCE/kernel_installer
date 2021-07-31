#!/usr/bin/bash

single_action () {
    [ "$run_action" != "help" ] && {
        err "Abort, only one argument can be supplied. See -h"
        exit 2
    }
}

log () {
    [ $quiet -eq 0 ] && echo "$@"
}

logn () {
    [ $quiet -eq 0 ] && echo -n "$@"
}

warn () {
    [ $quiet -eq 0 ] && echo "$@" >&2
}

err () {
    echo "$@" >&2
}

action_data=()
https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.13.6.tar.xz
install () {
  mkdir $1
  cd $1
  wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$1.tar.xz
  tar xvf linux-$1.tar.xz
  cd linux-$1
  find /boot/ \( -iname "*config*" -a -iname "*`uname -r`*" \) -exec cp -i -t ./ {} \;
  mv *`uname -r`* .config
  ls /boot | grep config
  sed -i '/^[^#]/ s/\(^.*CONFIG_SYSTEM_TRUSTED_KEYS.*$\)/#\1/' .config
  make menuconfig
  make clean
  make deb-pkg LOCALVERSION=-custom KDEB_PKGVERSION=$(make kernelversion)-1
  cd ..
  ls *.deb | grep image
  echo "Please install kernel package.."
}

#while (( "$#" )); do
    argarg_required=0

    case $1 in
        -i|--install)
            run_action="install"
            if [ -z "$2" ] || [ "${2##-}" != "$2" ]; then
                err "Option $1 requires an argument."
                exit 2
            else
              install $2
            fi
            ;;
        -l|--list)
            run_action="list"
            if [ -z "$2" ] || [ "${2##-}" != "$2" ]; then
                err "Option $1 requires an argument."
                exit 2
            else
              curl -s https://cdn.kernel.org/pub/linux/kernel/v5.x/|grep .tar.gz|grep linux-$2|sed -E "s/<a href=\"linux-$2.([0-9]*).*/$2.\1/"
            fi
#            argarg_required=1
            ;;
        -h|--help)
            run_action="help"
            ;;
        *)
            run_action="help"
            err "Unknown argument $1"
            ;;
    esac
    if [ $argarg_required -eq 1 ]; then
        [ -n "$2" ] && [ "${2##-}" == "$2" ] && {
            action_data+=("$2")
            shift
        }
    elif [ $argarg_required -eq 2 ]; then
        # shellcheck disable=SC2015
        [ -n "$2" ] && [ "${2##-}" == "$2" ] && {
            action_data+=("$2")
            shift
        } || {
            err "Option $1 requires an argument"
            exit 2
        }
    fi

#done


#echo $1
#cd 5.13/
