#!/bin/bash
#Author: Ceylavi
#Company: Ceylavi Technologies Inc. ©2019
echo "CeyMan 1.0"
#Master Script For Managing Email Accounts

if ! test -e /ceymail/ceyman;
then
	printf "CeyMail is not installed!\nInstall CeyMail.\n"
	exit 0
fi

#printf "Author: Ceylavi\n"
#printf "Company: Ceylavi Technologies Inc. ©2019\n"

printf "This is a software to create email accounts using MySQL for CeyMail.\n"
echo "Remember, every input is CASE SENSITIVE!"
echo "support: cey@ceylavi.com"

if [[ ! -d /ceymail/ceyman/database ]]; then
	mkdir -p /ceymail/ceyman/database
fi

create_database(){
	if [[ ! -d /ceymail/ceyman/database ]]; then
	mkdir -p /ceymail/ceyman/database
	fi
	echo "type exit to exit."
read -p "Database Name: " db
if [[ $db = exit ]]; then
	return
fi
read -p "Database User: " dbuser
if [[ $dbuser = exit ]];
then
	return
fi
read -p "Database Password: " dbpass
if [[ $dbpass = exit ]];
then
	return
fi

cat <<EOF > /ceymail/ceyman/database/db_info.txt
Database Information
--------------------
Database: $db
User: $dbuser
Password: $dbpass

EOF

if [[ -d /var/lib/mysql/$db ]]; then
	printf "Database exists!\n"
	echo "Be CAREFUL!"
	echo "Recreating it means DELETING it and CREATING it again."
	read -p "Would you like to delete and recreate it? (y/n): " ans
	#	GRANT ALL ON $db.* TO '$dbuser'@'localhost' IDENTIFIED BY '$dbpass';
	if [[ $ans = y ]]; then
		mysql -u root <<EOF
		DROP DATABASE IF EXISTS $db;
		CREATE DATABASE $db;
		GRANT ALL ON $db.* TO '$dbuser'@'localhost' IDENTIFIED BY '$dbpass';
		FLUSH PRIVILEGES;
		USE $db;
		CREATE TABLE virtual_domains (id int(11) NOT NULL, name varchar(50) NOT NULL, PRIMARY KEY (id))
		ENGINE=InnoDB DEFAULT CHARSET=utf8;
		CREATE TABLE virtual_users (id int(11) NOT NULL auto_increment,
		domain_id int(11) NOT NULL, password varchar(106) NOT NULL, email varchar(100) NOT NULL,
		PRIMARY KEY (id), UNIQUE KEY email (email), FOREIGN KEY (domain_id)
		REFERENCES virtual_domains(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8;
		CREATE TABLE virtual_aliases (id int(11) NOT NULL auto_increment,
		domain_id int(11) NOT NULL, source varchar(100) NOT NULL,
		destination varchar(100) NOT NULL, PRIMARY KEY (id),
		FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE)
		ENGINE=InnoDB DEFAULT CHARSET=utf8;
EOF

	elif [[ $ans = n ]]; then
	printf "Okay. Goodbye\n"
	return

	else printf "Your input is incorrect\n"	

	fi
else
		mysql -u root <<EOF
		DROP DATABASE IF EXISTS $db;
		CREATE DATABASE $db;
		GRANT ALL ON $db.* TO '$dbuser'@'localhost' IDENTIFIED BY '$dbpass';
		FLUSH PRIVILEGES;
		USE $db;
		CREATE TABLE virtual_domains (id int(11) NOT NULL, name varchar(50) NOT NULL, PRIMARY KEY (id))
		ENGINE=InnoDB DEFAULT CHARSET=utf8;
		CREATE TABLE virtual_users (id int(11) NOT NULL auto_increment,
		domain_id int(11) NOT NULL, password varchar(106) NOT NULL, email varchar(100) NOT NULL,
		PRIMARY KEY (id), UNIQUE KEY email (email), FOREIGN KEY (domain_id)
		REFERENCES virtual_domains(id) ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8;
		CREATE TABLE virtual_aliases (id int(11) NOT NULL auto_increment,
		domain_id int(11) NOT NULL, source varchar(100) NOT NULL,
		destination varchar(100) NOT NULL, PRIMARY KEY (id),
		FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE)
		ENGINE=InnoDB DEFAULT CHARSET=utf8;
EOF
fi
printf "Your database has been created.\n
Database: $db
User: $dbuser
Password: $dbpass\n
Write it down and keep it safe and secure.
Goodbye"
return
}


	login(){

		if [[ ! -d /ceymail/ceyman/database ]]; then
		mkdir -p /ceymail/ceyman/database
		fi

		echo "Database Login"
		 read -p "Do you want to login? (y/n): " loginans

		if [[ $loginans = n ]]; then
			return

		elif [[ $loginans = exit ]]; then
			return

		elif [[ $loginans = y ]]; then
			read -p "Database: " db
			if [[ $db = exit ]]; then
				return
			fi
			while [[ ! -e /var/lib/mysql/$db ]]; do
				echo "Database does not exist!"
				read -p "Database: " db
				if [[ $db = exit ]]; then
				return
				fi
			done
		read -p "Database User: " dbuser
		if [[ $dbuser = exit ]];
		then
			return
		fi
		read -p "Database Password: " dbpass
		if [[ $dbpass = exit ]];
		then
			return
		fi
	fi

		list_databases(){

	echo "Listing Databases..."
	
	mysqlshow -u root > /ceymail/ceyman/database/db.txt
	cat /ceymail/ceyman/database/db.txt

	read -p "Press Enter to Continue..." </dev/tty
return

	}

	database_info(){

		if [[ -f /ceymail/ceyman/database/db_info.txt ]]; then
echo ""
cat /ceymail/ceyman/database/db_info.txt
read -p "Press Enter to Continue..." </dev/tty
return
else echo "Database hasn't been created."
	return
fi
	}

	delete_database(){
		echo "BE CAREFUL!!!"
echo "Be sure you really want to delete this database."
read -p "Are you sure you want to delete this database? (y/n): " deletedb
if [[ $deletedb = n ]];
then
	return

elif [[ $deletedb = y ]];
	then
	mysql -u root -e "DROP DATABASE $db;"
	printf "Database deleted.\n"
	exit 0
else
	echo "Input incorrect."
	return
fi
	}

	new_domain(){

echo "List domains to check the last used id number."
echo "List domains to make sure you don't duplicate domains."
echo "Make sure your domain name is pointed to this server."
echo ""

mysql -u $dbuser -p$dbpass -D $db <<EOF > /ceymail/ceyman/database/vdomains.txt
SELECT * FROM virtual_domains;
EOF
echo ""
echo "Virtual Domains"
cat /ceymail/ceyman/database/vdomains.txt
echo ""

di=0
while [ $di -lt 20 ]
do
	echo "Type exit to quit."
read -p "ID: " id

if [[ $id = exit ]];
then
	return
fi

read -p "Domain Name: " domain
if [[ $domain = exit ]];
then
	return
fi

echo "Creating Domain..."

mysql -u $dbuser -p$dbpass -D $db <<EOF
INSERT INTO virtual_domains
 (id, name) 
VALUES 
('$id', '$domain');
EOF

echo "Virtual domain added"
printf "Remember the domain id for the domain you added\nfor creating the email account!\n"

mysql -u $dbuser -p$dbpass -D $db <<EOF > /ceymail/ceyman/database/vdomains.txt
SELECT * FROM virtual_domains;
EOF
echo ""
cat /ceymail/ceyman/database/vdomains.txt
echo ""
(( di++ ))
done
return
	}

	new_user(){

echo "Make sure you know the domain id before adding a new user."
echo "You must first add a domain before adding a user account."
echo "You must know the name of the database you created."
printf "Domain part of the email address should be \nconsistent with the Domain ID and Domain you created.\n"

mysql -u $dbuser -p$dbpass -D $db <<EOF > /ceymail/ceyman/database/vdomains.txt
SELECT * FROM virtual_domains;
EOF
echo ""
echo "Virtual Domains"
cat /ceymail/ceyman/database/vdomains.txt

mysql -u $dbuser -p$dbpass -D $db <<EOF > /ceymail/ceyman/database/vusers.txt
SELECT * FROM virtual_users;
EOF
echo ""
echo "Virtual Users"
cat /ceymail/ceyman/database/vusers.txt
echo ""

ui=0
while [ $ui -lt 20 ]
do
	echo "Type exit to quit."
read -p "Domain ID: " dmid

if [[ $dmid = exit ]];
then
	return
fi

read -p "Email: " email
if [[ $email = exit ]];
then
	return
fi
read -p "Password: " pass
if [[ $pass = exit ]];
then
	return
fi

echo "Creating email."

cd /ceymail
doveadm pw -s SHA512-CRYPT -p $pass > encrypted.txt
sed -i 's/{SHA512-CRYPT}//g' encrypted.txt
epass=$(cat encrypted.txt)

mysql -u $dbuser -p$dbpass -D $db <<EOF

INSERT INTO virtual_users 
 (domain_id, password, email)
VALUES 
 ('$dmid', '${epass}', '$email');

EOF
echo "Virtual email created."

mysql -u $dbuser -p$dbpass -D $db <<EOF > /ceymail/ceyman/database/vusers.txt
SELECT * FROM virtual_users;
EOF
echo ""
cat /ceymail/ceyman/database/vusers.txt
echo ""
(( ui++ ))
done
return

	}

	new_alias(){

printf "Adding virtual aliases is for mail forwarding.\nAdd a source and a destination email and email received by the source will be\nforwarded to the destination email.\n"

mysql -u $dbuser -p$dbpass -D $db <<EOF > /ceymail/ceyman/database/vdomains.txt
SELECT * FROM virtual_domains;
EOF
echo ""
echo "Virtual Domains"
cat /ceymail/ceyman/database/vdomains.txt

mysql -u $dbuser -p$dbpass -D $db <<EOF > /ceymail/ceyman/database/valiases.txt
SELECT * FROM virtual_aliases;
EOF
echo ""
echo "Virtual Aliases"
cat /ceymail/ceyman/database/valiases.txt
echo ""

ai=0
while [ $ai -lt 20 ]
do
	echo "Type exit to quit."
read -p "Domain ID: " dmid
if [[ $dmid = exit ]];
then
	return
fi
read -p "Source: " source
if [[ $source = exit ]];
then
	return
fi
read -p "Destination: " destination
if [[ $destination = exit ]];
then
	return
fi

echo "Creating Alias..."

mysql -u $dbuser -p$dbpass -D $db <<EOF
INSERT INTO virtual_aliases
 (domain_id, source, destination) 
VALUES 
('$dmid', '$source', '$destination');
EOF

echo "Virtual alias added"

mysql -u $dbuser -p$dbpass -D $db <<EOF > /ceymail/ceyman/database/valiases.txt
SELECT * FROM virtual_aliases;
EOF
echo ""
cat /ceymail/ceyman/database/valiases.txt
(( ai++ ))
done
return
	}

	list_domains(){

echo "Listing Virtual Domains..."

mysql -u $dbuser -p$dbpass -D $db <<EOF > /ceymail/ceyman/database/vdomains.txt
SELECT * FROM virtual_domains;
EOF

cat /ceymail/ceyman/database/vdomains.txt

read -p "Press Enter to Continue..." </dev/tty
return

if [[ -d /ceymail/ceyman/database ]]; then
	echo "Listing Virtual Domains..."
	
mysql -u $dbuser -p$dbpass -D $db <<EOF > /ceymail/ceyman/database/vdomains.txt
SELECT * FROM virtual_domains;
EOF

cat /ceymail/ceyman/database/vdomains.txt

read -p "Press Enter to Continue..." </dev/tty
return

else echo "An error occurred!"
fi
	}

	list_users(){

echo "Listing Virtual Users..."

mysql -u $dbuser -p$dbpass -D $db <<EOF > /ceymail/ceyman/database/vusers.txt
SELECT * FROM virtual_users;
EOF

cat /ceymail/ceyman/database/vusers.txt

read -p "Press Enter to Continue..." </dev/tty
return

if [[ -d /ceymail/ceyman/database ]]; then
	echo "Listing Virtual Users..."
	
mysql -u $dbuser -p$dbpass -D $db <<EOF > /ceymail/ceyman/database/vusers.txt
SELECT * FROM virtual_users;
EOF

cat /ceymail/ceyman/database/vusers.txt

read -p "Press Enter to Continue..." </dev/tty
return

else echo "An error occurred!"
fi
	}

	list_aliases(){

echo "Listing Virtual Aliases..."

mysql -u $dbuser -p$dbpass -D $db <<EOF > /ceymail/ceyman/database/valiases.txt
SELECT * FROM virtual_aliases;
EOF

cat /ceymail/ceyman/database/valiases.txt

read -p "Press Enter to Continue..." </dev/tty
return

if [[ -d /ceymail/ceyman/database ]]; then
	echo "Listing Virtual Aliases..."
	
mysql -u $dbuser -p$dbpass -D $db <<EOF > /ceymail/ceyman/database/valiases.txt
SELECT * FROM virtual_aliases;
EOF

cat /ceymail/ceyman/database/valiases.txt

read -p "Press Enter to Continue..." </dev/tty
return

else echo "An error occurred!"
fi
	}

	delete_domain(){
echo "BECAREFUL!"
echo "Be sure of the domain id before you delete!"

mysql -u $dbuser -p$dbpass -D $db <<EOF > /ceymail/ceyman/database/vdomains.txt
SELECT * FROM virtual_domains;
EOF
echo ""
cat /ceymail/ceyman/database/vdomains.txt
echo ""

ddi=0
while [ $ddi -lt 20 ]
do
echo "Type exit to quit."
read -p "Domain ID: " dmid
if [[ $dmid = exit ]];
then
	return
fi
echo "Deleting virtual domain..."

mysql -u $dbuser -p$dbpass -D $db <<EOF
DELETE FROM virtual_domains WHERE id = $dmid;
EOF

echo "Virtual domain deleted"

mysql -u $dbuser -p$dbpass -D $db <<EOF > /ceymail/ceyman/database/vdomains.txt
SELECT * FROM virtual_domains;
EOF
echo ""
cat /ceymail/ceyman/database/vdomains.txt
echo ""

(( ddi++ ))
done
return
	}

	delete_user(){
echo "BECAREFUL!"
echo "Be sure of the id before you delete!"

mysql -u $dbuser -p$dbpass -D $db <<EOF > /ceymail/ceyman/database/vusers.txt
SELECT * FROM virtual_users;
EOF
echo ""
cat /ceymail/ceyman/database/vusers.txt
echo ""

dui=0
while [ $dui -lt 20 ]
do
echo "Type exit to quit."
read -p "ID: " id
if [[ $id = exit ]];
then
	return
fi
echo "Deleting virtual user..."

mysql -u $dbuser -p$dbpass -D $db <<EOF
DELETE FROM virtual_users WHERE id = $id;
EOF

echo "Virtual user deleted"

mysql -u $dbuser -p$dbpass -D $db <<EOF > /ceymail/ceyman/database/vusers.txt
SELECT * FROM virtual_users;
EOF
echo ""
cat /ceymail/ceyman/database/vusers.txt
echo ""

(( dui++ ))
done
return
	}

	delete_alias(){
echo "BECAREFUL!"
echo "Be sure of the id before you delete!"

mysql -u $dbuser -p$dbpass -D $db <<EOF > /ceymail/ceyman/database/valiases.txt
SELECT * FROM virtual_aliases;
EOF
echo ""
cat /ceymail/ceyman/database/valiases.txt
echo ""

dai=0
while [ $dai -lt 20 ]
do
echo "Type exit to quit."
read -p "ID: " id
if [[ $id = exit ]];
then
	return
fi
echo "Deleting virtual alias..."

mysql -u $dbuser -p$dbpass -D $db <<EOF
DELETE FROM virtual_aliases WHERE id = $id;
EOF

echo "Virtual alias deleted"

mysql -u $dbuser -p$dbpass -D $db <<EOF > /ceymail/ceyman/database/valiases.txt
SELECT * FROM virtual_aliases;
EOF
echo ""
cat /ceymail/ceyman/database/valiases.txt
echo ""

(( dai++ ))
done
return
	}

	email_password(){
echo "type exit to exit"

mysql -u $dbuser -p$dbpass -D $db <<EOF > /ceymail/ceyman/database/vusers.txt
SELECT * FROM virtual_users;
EOF
echo ""
cat /ceymail/ceyman/database/vusers.txt
echo ""

epi=0
while [ $epi -lt 20 ]
do
echo "Type exit to quit."
read -p "ID: " id
if [[ $id = exit ]];
then
	return
fi
read -p "New Password: " npass
if [[ $npass = exit ]];
then
	return
fi
echo "Changing email account password..."

cd /ceymail
doveadm pw -s SHA512-CRYPT -p $npass > encrypted.txt
sed -i 's/{SHA512-CRYPT}//g' encrypted.txt
epass=$(cat encrypted.txt)

mysql -u $dbuser -p$dbpass -D $db <<EOF
UPDATE virtual_users
SET
	password = '${epass}'
WHERE
	id = $id;
EOF

echo "Email account password changed"

mysql -u $dbuser -p$dbpass -D $db <<EOF > /ceymail/ceyman/database/vusers.txt
SELECT * FROM virtual_users;
EOF
echo ""
cat /ceymail/ceyman/database/vusers.txt
echo ""

(( epi++ ))
done
return
	}

	database_password(){
echo "type exit to exit."
read -p "New Database Password: " npass
if [[ $npass = exit ]];
then
	return
fi
echo "Changing database password..."
mysql -u root -D $db <<EOF
SET PASSWORD FOR '$dbuser'@'localhost' = PASSWORD('$npass');
EOF

cat <<EOF > /ceymail/ceyman/database/db_info.txt
Database: $db
User: $dbuser
Password: $npass
EOF

echo "Database password changed."
return
	}
	
	iz=0
while [ $iz -lt 99 ]
	do

a="1 - List Databases"
b="2 - View Database Info"
c="3 - Delete Database"
d="4 - Add New Domain"
e="5 - Add New Users"
f="6 - Add New Aliases"
g="7 - List Virtual Domains"
h="8 - List Virtual Users"
i="9 - List Virtual Aliases"
j="10 - Delete Domain"
k="11 - Delete User"
l="12 - Delete Alias"
m="13 - Change Email Password"
n="14 - Change Database Password"
x="e - Logout"

		echo ""
		echo $a
		echo $b
		echo $c
		echo $d
		echo $e
		echo $f
		echo $g
		echo $h
		echo $i
		echo $j
		echo $k
		echo $l
		echo $m
		echo $n
		echo "--------------------"
		echo $x
		echo ""

		read -p "Enter an option: " y

		if [ $y = exit ]
		then
			echo "Goodbye!"
			return

		elif [ $y = e ]
		then
			echo "Goodbye!"
			return
		fi

		while [[ $y = "" ]]; do
			echo "You have not entered an input."
			echo "Try again."
			read -p "Enter an option: " y
		done

	if [ $y = 1 ]
then
	list_databases

	elif [ $y = 2 ]
then
	database_info

	elif [ $y = 3 ]
then
	delete_database

	elif [ $y = 4 ]
then
	new_domain

	elif [ $y = 5 ]
then
	new_user

	elif [ $y = 6 ]
then
	new_alias
	
	elif [ $y = 7 ]
then
	 list_domains
	
	elif [ $y = 8 ]
then
	 list_users

	elif [ $y = 9 ]
then
	 list_aliases

	elif [ $y = 10 ]
then
	 delete_domain

	elif [ $y = 11 ]
then 
	 delete_user
	
	elif [ $y = 12 ]
then
	 delete_alias
	
	elif [ $y = 13 ]
then
	 email_password
	
	elif [ $y = 14 ]
then
	 database_password

	else printf "Sorry, your input is incorrect. Try again.\n"

fi

((iz++))
done

}

	backup_db(){

		if [[ ! -d /ceymail/ceyman/dbbackups ]]; then
			mkdir -p /ceymail/ceyman/dbbackups
		fi

		echo "type exit to exit"
		
		dba="1. Backup 1 Database"
		dbb="2. Backup Multiple Databases"
		dbc="3. Backup All Databases"
		echo ""
		echo $dba
		echo $dbb
		echo $dbc
		echo ""

		read -p "Enter an option: " opt

		if [[ $opt = exit ]]; then
			return
		fi

		while [[ $opt = "" ]]; do
			echo "You have not entered an input"
			echo "Try again."
			read -p "Enter an option: " opt
		done

		if [[ $opt = 1 ]]; then
			read -p "Database Name: " db
			if [[ $db = exit ]]; then
			return
			fi
			while [[ ! -e /var/lib/mysql/$db ]]; do
				echo "Database does not exist!"
				read -p "Database Name: " db
			done
			read -p "Database User: " dbuser
			if [[ $dbuser = exit ]]; then
			return
			fi
			read -p "Database Password: " dbpass
			if [[ $dbpass = exit ]]; then
			return
			fi
			
			echo "Backing up database..."

			mysqldump -u $dbuser -p$dbpass $db > /ceymail/ceyman/dbbackups/$db.sql
			
			echo "$db database backup created and stored at /ceymail/ceyman/dbbackups/$db.sql"
		return
		fi

		if [[ $opt = 2 ]]; then

		read -p "How many databases are you backing up?: " dbn

		if [[ $dbn = exit ]]; then
			return
		fi

		while [[ $dbn -gt 0 ]]; do

			read -p "Database Name: " db
			if [[ $db = exit ]]; then
			return
			fi
			while [[ ! -e /var/lib/mysql/$db ]]; do
				echo "Database does not exist!"
				read -p "Database Name: " db
			done
			read -p "Database Username: " dbuser
			if [[ $dbuser = exit ]]; then
			return
			fi
			read -p "Database Password: " dbpass
			if [[ $dbpass = exit ]]; then
			return
			fi
			echo "Backing up database..."
			mysqldump --opt -u $dbuser -p$dbpass $db > /ceymail/ceyman/dbbackups/$db.sql
			echo "$db database backup created and stored at /ceymail/ceyman/dbbackups/$db.sql"
			(( n-- ))
		done
		return
		fi
		
		if [[ $opt = 3 ]]; then

		read -p "Are you sure you want to backup all databases? (y/n): " ans

		if [[ $ans = exit ]]; then
			return
		fi
		if [[ $ans = n ]]; then
			return
		fi
		if [[ $ans = y ]]; then

			if [[ -e /ceymail/ceyman/dbbackups/all_databases.sql ]]; then
				mv /ceymail/ceyman/dbbackups/all_databases.sql /ceymail/ceyman/dbbackups/all_databases.sql.bk
			fi
			echo "Backing up all databases..."
			mysqldump --opt -u root --all-databases > /ceymail/ceyman/dbbackups/all_databases.sql
			echo "all databases have been backed up at /ceymail/ceyman/dbbackups/all_databases.sql."
		fi
		return
	fi
	}

z=0
while [ $z -lt 99 ]
	do


a="1. Create Database"
login="2. Login to Database"
backup="3. Backup Database"
exit="e - exit"

echo ""
echo $a
echo $login
echo $backup
echo "-------------------"
echo $exit
echo ""
read -p "Enter an option: " tans

	while [[ $tans = "" ]]; do
			echo "You have not entered an input."
			echo "Try again."
			read -p "Enter an option: " tans
			if [[ $tans = exit ]]; then
				exit 0
			fi
	done

	if [ $tans = 1 ]
then
	create_database

elif [[ $tans = 2 ]]; then
	login

elif [[ $tans = 3 ]]; then
	backup_db

elif [[ $tans = e ]]; then
	exit 0

elif [[ $tans = exit ]]; then
	exit 0

else echo "Incorrect input."
	exit 0
	fi 

	((z++))
done