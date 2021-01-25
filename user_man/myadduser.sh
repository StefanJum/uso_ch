#!/bin/bash

instructions () {
    echo -e "Usage: $0 [options] username password\n"
    echo "Options:"
    echo -e "\t -i, --interactive \t\t Add unset parametres interactively"
    echo -e "\t\t\t\t\t password will not be visible in terminal"
    echo -e "\t -c, --comment COMMENT \t\t Set comment for user"
    echo -e "\t -d, --home-dir HOME_DIR \t New home directory for user account"
    echo -e "\t -s, --shell SHELL \t\t Set SHELL as default login shell"
    echo -e "\t\t\t\t\t (/bin/bash is used if no option is given)"
    echo -e "\t -e, --expire-date EXPIRE_DATE \t Set account expiration date"
    echo -e "\t -f, --inactive INACTIVE \t Set password inactive after INACTIVE days"
    echo -e "\t -m, --minimum DAYS\t\t Minimum number of days until user is allowed"
    echo -e "\t\t\t\t\t to change password set to DAYS"
    echo -e "\t -M, --maximum DAYS \t\t Maximum number of days until user is forced"
    echo -e "\t -w, --warn DAYS \t\t Number of days the user will be warned before expiration"
    echo -e "\t\t\t\t\t to change password set to DAYS"
    echo -e "\t -g, --group GROUP \t\t Use GROUP as primary group"
    echo -e "\t -h, --help \t\t\t Display this message and exit"
    echo -e "\t --group-id ID \t\t\t Use group with ID as primary group"
    echo -e "\t --user-id ID \t\t\t Set ID as uid for new user\n"
}

check_integer () {
    [[ $1 =~ ^[0-9]+$ ]] && return 1 || return 0
}

inter=0
while true; do
    case $1 in
        -i | --interactive)
            inter=1
            shift
            ;;
        -c | --comment)
            comm="$2"
            shift 2
            ;;
        -d | --home-dir)
            home_dir="$2"
            shift 2
            ;;
        -e | --expire-date)
            expire_date="$2"
            shift 2
            ;;
        -f | --inactive)
            inactive_days="$2"
            if check_integer $inactive_days; then
                echo "Argument passed to -f, --inactive must be integer"
                echo "Exiting....."
                exit 1
            fi
            shift 2
            ;;
        -g | --group)
            group_name="$2"
            shift 2
            ;;
        -s | --shell)
            shell="$2"
            grep -e "^$shell$" /etc/shells &> /dev/null
            if test $? -ne 0; then
                echo "Given shell can not be found in /etc/shells"
                echo "Default shell set as /usr/sbin/nologin"
                shell="/usr/sbin/nologin"
            fi
            shift 2
            ;;
        -m | --minimum)
            min_days="$2"
            if check_integer $min_days; then
                echo "Argument passed to -m, --minimum must be integer"
                echo "Exiting....."
                exit 1
            fi
            shift 2
            ;;
        -M | --maximum)
            max_days="$2"
            if check_integer $max_days; then
                echo "Argument passed to -M, --maximum must be integer"
                echo "Exiting....."
                exit 1
            fi
            shift 2
            ;;
        -w | --warn)
            warn_days="$2"
            if check_integer $warn_days; then
                echo "Argument passed to -w, --warn must be integer"
                echo "Exiting......"
                exit 1
            fi
            shift 2
            ;;
        --group-id)
            new_gid="$2"
            if check_integer $new_gid; then
                echo "Argument passed to --group-id  must be integer"
                echo "Exiting....."
                exit 1
            fi
            cut -d':' -f3 /etc/group | grep -e "^$new_gid:"
            if test $? -eq 0; then
                echo "Group id already in use."
                echo "Adding user to group...."
            fi
            shift 2
            ;;
        --user-id)
            new_uid="$2"
            if check_integer $new_uid; then
                echo "Argument passed to --user-id must be integer"
                echo "Exiting....."
                exit 1
            fi
            cut -d':' -f1 /etc/passwd | grep -e "^$new_uid:"
            if test $? -eq 0; then
                echo "User id already exists."
                echo "Exiting....."
                exit 1
            fi
            shift 2
            ;;
        -h | --help)
            instructions
            exit 0
            ;;
        ?*)
            test $# -eq 2 && break
            echo "Unknown argument \"$1\", skipping"
            shift
            ;;
        * )
            break
            ;;
    esac
done

if test $# -ne 2; then
    if test -z "$inter"; then
        echo "Usage: $0 [options] username password"
        echo "Use $0 --help for more informations"
        exit 1
    fi
fi

if test $(id -u) -ne 0; then
    echo "Only root can add users to the system."
    exit 2
fi

test -z "$username" && username="$1"
test -z "$password" && password="$2"

IFS=
if test $inter -eq 1; then
    test -z "$comm" && echo -n "Comment: " && read comm
    test -z "$home_dir" && echo -n "Home directory: " && read home_dir
    test -z "$expire_date" && echo -n "Number of days until user expires: " && read expire_date
    test -z "$inactive_days" && echo -n "Number of maximum inactive days: " && read inactive_days
    test -z "$group_name" && echo -n "User group name: " && read group_name
    test -z "$shell" && echo -n "Default user shell: " && read shell
    test -z "$min_days" && echo -n "Minimum numbers of days for password changing: " && read min_days
    test -z "$max_days" && echo -n "Days until user will be forced to change his password: " && read max_days
    test -z "$warn_days" && echo -n "Days user will be warned before expiration: " && read warn_days
    test -z "$username" && echo -n "Username: " && read username
    test -z "$password" && echo -n "Password: " && read -s password && echo -e -n "\nConfirm password: " && read -s pass2
    if [ "$password" != "$pass2" ]; then
        echo -e "\nPassword does not match!"
        exit 1
    fi
fi

q=0
test -z "$username" && q=1
test -z "$password" && q=1
test "$q" -eq 1 && echo -e "You must give the username and password\nExiting....." && exit 1

grep -e "^$username:" /etc/passwd &> /dev/null
if test $? -eq 0; then
    echo "User $username exists."
    exit 1
fi

test -z "$group_name" && group_name="$username"
test -z "$comm" && comm="$username"
test -z "$home_dir" && home_dir="/home/$username"
test -z "$expire_date" && expire_date=""
test -z "$inactive_days" && inactive_days=""
test -z "$shell" && shell="/bin/bash"
test -z "$min_days" && min_days=0
test -z "$max_days" && max_days=99999
test -z "$warn_days" && warn_days=7

creation_date=$(echo $(( $(date +%s) / 86400 )))
last_uid=$(sort -n -t':' -k3,3 /etc/passwd | cut -d':' -f3 | tail -2 | head -1)
test -z "$new_uid" && let "new_uid=last_uid+1"
while grep -e ":$new_uid:" /etc/passwd; do
    let "new_uid=last_uid+1"
done

last_gid=$(sort -n -t':' -k3,3 /etc/group | cut -d':' -f3 | tail -2 | head -1)
test -z "$new_gid" && let "new_gid=last_gid+1"
while grep -e ":$new_gid:" /etc/group; do
    let "new_gid=last_gid+1"
done

test -z "$expire_date" || let "expire_date+=creation_date"
salt=$(dd if=/dev/urandom bs=10 count=1 2> /dev/null | base64 | cut -d'=' -f1)
encr_passw=$(echo "$salt$password" | md5sum | cut -d' ' -f1)
enc_pass=$(openssl passwd -6 -stdin -salt $salt <<< "$password")
#enc_pass=$(python3 -c "import crypt; print(crypt.crypt('$password', '\$6\$$salt'))")

passwd_entry="$username:x:$new_uid:$new_gid:$comm:$home_dir:$shell"
groups_entry="$group_name:x:$new_gid:$user_list"
shadow_entry="$username:$enc_pass:$creation_date:$min_days:$max_days:$warn_days:$inactive_days:$expire_date:"
mkdir "$home_dir" &> /dev/null

#echo -e "$passwd_entry\n$groups_entry\n$shadow_entry"
echo "$passwd_entry" >> /etc/passwd
echo "$groups_entry" >> /etc/group
echo "$shadow_entry" >> /etc/shadow
cp -r /etc/skel/. "$home_dir" &> /dev/null
chown -R "$username:$group_name" "$home_dir"

id "$username" &> /dev/null
if test "$?" -eq 0; then
    echo "User $username added successfully"
    exit 0
else
    echo "User $username not added"
    exit 1
fi
