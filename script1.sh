#!/bin/bash
read -p "New users\n1) Delete users\n2)" action
read -p "Users.txt " file
for line in $( cat $file )
do
	username=$(echo $line | cut -d : -f1);
	usergroup=$(echo $line | cut -d : -f2);
	password=$(echo $line | cut -d : -f3);
	newpassword=$(openssl passwd -1 $password);
	shell=$(echo $line | cut -d : -f4);
	
	case $action in
	1)
	
	if [[ `grep $username /etc/passwd` ]]
	then
		read -p "Do you need to make any changes? [Y/N] " make_changes
		if [[ "$make_changes" =~ ^([yY])$ ]]
		then
			read -p "Do I need to change the primary group? [Y/N] " change_group
			if [[ "$change_group" =~ ^([yY])$ ]]
			then
				new_group=`groups $username | cut -d "" -f4`
				if [[ $new_group != $group ]]
				then
					usermod -g $usergroup $username
				fi
			fi

			read -p "Do I need to change password? [Y/N] " change_password
			if [[ "$change_password" =~ ^([yY])$ ]]
			then
				usermod -p $newpassword $username
			fi

			read -p "Do I need to change shell? [Y/N] " change_shell
			if [[ "$change_shell" =~ ^([yY])$ ]]
			then
				new_shell=`grep $username /etc/passwd | cut -d : -f5`
				if [[ $current_shell != $shell ]]
				then
					usermod -s $shell $username
				fi
			fi
		fi
	
	else
		echo "Creating group $usergroup"
		groupadd -f $usergroup;
		echo "User $username was created!"
		useradd $username -p $newpassword -g $usergroup -s $shell;
	fi
			
	;;
	2)
	if [[ `grep $username /etc/password` ]]
	then
		userdel -r $username
	fi
	;;
	esac
done

