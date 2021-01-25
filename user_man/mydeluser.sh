#!/bin/bash

instructions () {
    echo -e "Usage: $0 [options] USERNAME"
    echo -e "\t $0 -g, --group GID\n"
    echo "Options"
    echo -e "\t-f, --force \t\t force remove all files from home directory"
    echo -e "\t\t\t\t even if not owned by user"
    echo -e "\t-h, --help \t\t display this message and exit"
    echo -e "\t-r, --remove \t\t remove files owned by user from home directory"
    echo -e "\t\t\t\t use -f, --force to force remove all files"
    echo -e "\t-g, --group GID \t removes group with gid"
    echo -e "\t-s, --skip-group\t only remove user, leave user group intact"
}

check_integer () {
    [[ $1 =~ ^[0-9]+$ ]] && return 1 || return 0
}

skip=0
while true; do
    case $1 in
        -f | --force)
            force=1
            shift
            ;;
        -h | --help)
            instructions
            exit 0
            ;;
        -r | --remove)
            remove=1
            shift
            ;;
        -g | --group)
            gid="$2"
            if check_integer "$gid"; then
                echo "Argument passed to -g, --group must be integer"
                echo "Exiting....."
                exit 1
            fi
            shift
            break
            ;;
        -s | --skip-group)
            skip=1
            shift
            ;;
        -?*)
            echo "Unknown argument \"$1\", skipping"
            shift
            break
            ;;
        * )
            break
            ;;
    esac
    #shift
done

if test $# -ne 1; then
    echo "Usage: $0 [options] username"
    echo -e "       $0 -g (--group) gid\n"
    echo "Use $0 --help for more informations"
    exit 1
fi

if test $(id -u) -ne 0; then
    echo "Only root can remove users to the system."
    exit 2
fi

test -z "$gid"
if test $? -ne 0; then
    sed -i "/:$gid:/d" /etc/group
    test $? -eq 0 && exit 0 || exit 1
fi
username="$1"

grep -e "^$username:" /etc/passwd &> /dev/null
if test "$?" -ne 0; then
    echo "User $username does dot exists."
    echo "Exiting....."
    exit 1
fi

group=$(grep -e "^$username:" /etc/passwd | cut -d':' -f4)
home_dir=$(grep -e "^$username:" /etc/passwd | cut -d':' -f6)

test -z "$force" || rm -rf $home_dir
test -z "$remove" || runuser -l $username -c "rm -r $home_dir 2> /dev/null"

sed -i "/^$username:/d" /etc/shadow
test "$skip" -eq 0 && sed -i "/:$group:/d" /etc/group
sed -i "/^$username:/d" /etc/passwd
sed -i "s/,student,/,/g" /etc/group
sed -i "s/:student$/:/g" /etc/group
sed -i "s/:student,/:/g" /etc/group
sed -i "s/,student$//g" /etc/group

id "$username" &> /dev/null
if test "$?" -ne 0; then
    echo "User $username removed successfully."
    exit 0
else
    echo "User $username could not be removed."
    exit 1
fi
