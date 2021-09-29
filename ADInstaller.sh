echo
    clear
	echo "

     █████╗ ██████╗     ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     ███████╗██████╗ 
    ██╔══██╗██╔══██╗    ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔════╝██╔══██╗
    ███████║██║  ██║    ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     █████╗  ██████╔╝
    ██╔══██║██║  ██║    ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══╝  ██╔══██╗
    ██║  ██║██████╔╝    ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗███████╗██║  ██║
    ╚═╝  ╚═╝╚═════╝     ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
    
    Active Directory Installer For Ubuntu
"
	echo "    [1] Cofiguration"
	echo "    [2] Install"
    echo "    [3] Create User Account"
    echo "    [4] Delete User Account"
    echo "    [5] Reset Password User Account"
	echo "    [6] Exit"
    echo
	read -p "    {#} Option : " option
    echo
	until [[ "$option" =~ ^[1-6]$ ]]; do
		echo -e "    \e[1;31m{!} Invalid Option {!}\e[0m"
		read -p "    {#} Option : " option
	done
	case "$option" in
		1)
            echo -e "    \e[1;36m{#} Configuration {#}\e[0m"
            echo
            read -p "    {#} NetBIOS Name : " host
            read -p "    {#} Domain : " domain
            read -p "    {#} Domain IP : " domain_ip
            echo
            echo "$host"."$domain" > /etc/hostname
            run=$(sed -i '3 i '$domain_ip' '$host'.'$domain' '$host /etc/hosts)
            reboot
            exit
		;;
		2)
            echo -e "    \e[1;36m{#} Install {#}\e[0m"
            echo
            read -p "    {#} Domain : " domain
            echo
            sudo apt-get install samba krb5-user krb5-config winbind smbclient -y
            sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.original
            sudo samba-tool domain provision
            sudo mv /etc/krb5.conf /etc/krb5.conf.original
            sudo cp /var/lib/samba/private/krb5.conf /etc/
            sudo systemctl disable --now smbd nmbd winbind systemd-resolved
            sudo systemctl unmask samba-ad-dc
            sudo systemctl enable --now samba-ad-dc
            sudo samba-tool domain level show
            sudo rm -rf /etc/resolv.conf
            sudo apt install resolvconf -y
            sudo systemctl start resolvconf.service
            add_one=$(sed -i '1 i nameserver 127.0.0.1' /etc/resolvconf/resolv.conf.d/head)
            add_two=$(sed -i '2 i domain '$domain /etc/resolvconf/resolv.conf.d/head)
            sudo rm -rf /etc/resolv.conf
			exit
		;;
        3)
            echo -e "    \e[1;36m{#} Create User Account {#}\e[0m"
            echo
            users=$(sudo samba-tool user list)
            echo "    {#}" $users
            echo
            read -p "    {#} Username : " user_name
            echo
            sudo samba-tool user create $user_name
			exit
		;;
        4)
            echo -e "    \e[1;36m{#} Delete User Account {#}\e[0m"
            echo
            users=$(sudo samba-tool user list)
            echo "    {#}" $users
            echo
            read -p "    {#} Username : " user_name
            echo
            sudo samba-tool user delete $user_name
            exit
        ;;
        5)
            echo -e "    \e[1;36m{#} Reset Password User Account {#}\e[0m"
            echo
            users=$(sudo samba-tool user list)
            echo "    {#}" $users
            echo
            read -p "    {#} Username : " user_name
            echo
            sudo samba-tool user setpassword $user_name
            exit
        ;;
        6)
            exit
        ;;
    esac