# Usage: extract <archive>
function auto_extract
{
    path=$1
    name=`echo $path|sed -e "s/.*\///"`
    ext=`echo $name|sed -e "s/.*\.//"`
    
    echo "Extracting $name..."
    
    case $ext in
        "tar"|"xz") tar --no-same-owner -xf $path ;;
        "gz"|"tgz") tar --no-same-owner -xzf $path ;;
        "bz2"|"tbz2") tar --no-same-owner -xjf $path ;;
        "zip") unzip $path ;;
        *) echo "I don't know how to extract $ext archives!"; return 1 ;;
    esac
    
    return $?
}

# Usage: download_and_extract URL DIRECTORY
function download_and_extract
{
    url=$1
    name=`echo $url|sed -e "s/.*\///"`
    outdir=$2
    
    # If there are already an extracted directory, delete it, otherwise
    # reapplying patches gets messy. I tried.
    [ -d $outdir ] && echo "Deleting old version of $outdir" && rm -rf $outdir
    
    # First, if the archive already exists, attempt to extract it. Failing
    # that, attempt to continue an interrupted download. If that also fails,
    # remove the presumably corrupted file.
    [ -f $name ] && auto_extract $name || { wget --continue --no-check-certificate $url -O $name || rm -f $name; }
    
    # If the file does not exist at this point, it means it was either never
    # downloaded, or it was deleted for being corrupted. Just go ahead and
    # download it.
    # Using wget --continue here would make buggy servers flip out for nothing.
    [ -f $name ] || wget --no-check-certificate $url -O $name && auto_extract $name
    
    # Switch to the newly created directory
    cd $outdir || return 1
}

function apply_patch {
    patch -p1 < "${BASE_PATH}/patches/$1.patch"
}

## Install meson and ninja in the current directory using a venv
function setup_build_system {
    python3 -m venv venv
    . venv/bin/activate
    pip install meson ninja
}