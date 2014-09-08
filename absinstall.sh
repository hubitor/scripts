#!/usr/bin/bash
[[ $(id --user) -ne 0  ]] && echo "needs root permessions!" && exit 1
. /etc/abs.conf || exit 1
. /etc/makepkg.conf || exit 1
ABSROOT="${ABSROOT%/}"

### INTERN VARS
tmp=`mktemp -d "/tmp/absinstall.XXXXXX"`
DB_ORIG="/var/lib/absinstall/abs.db"
DB="$tmp/abs.db"
op_update=false
op_install=false
op_upgrade=false
pacman="pacman --needed --noconfirm"
_USER=${SUDO_USER:-$USER}
chown -R $_USER:$_USER $tmp
# PKGDEST for may differ between users if $HOME,$USER,... are used on makepkg.conf
PKGDEST="$(su -s /usr/bin/bash - $_USER -c '. /etc/makepkg.conf; echo $PKGDEST')"
PKGEXT=${PKGEXT:-.pkg.tar.xz}
DEBUG=1

install_apps () {
	local app
	for app in $@;
	do
		app=$(getpkgname $app)
		[[ " ${builded[@]} " =~ " $app " ]] && continue
		install $app
	done
}

install() {
	local pkgname pkgrepo pkgbasename pkgver makedepends optdepends depends appdb depend pkgnames pkgs_to_install
	appdb=($(grep "^$1 " $DB)) #| read pkgname pkgrepo pkgbasename pkgver
	pkgname=${appdb[0]}
	pkgrepo=${appdb[1]}
	pkgbasename=${appdb[2]}
	if [ -z $pkgname ]; then
		error "NOT FOUND" "$1"
		return 1
	fi
	IFS=$',' read pkgnames pkgver depends makedepends < <(
		su -s /usr/bin/bash - $_USER -c 'source '$ABSROOT/$pkgrepo/$pkgbasename/PKGBUILD';\
			echo "${pkgname[@]},${pkgver}-${pkgrel},${depends[@]},${makedepends[@]} ${checkdepends[@]}"'
		)
	debug "APP" "$pkgname:$pkgver depends:(${depends}) makdedepends:(${makedepends})"
	if [ 1 -gt "$(vercmp "$pkgver" $(pacman -Q $pkgname 2>/dev/null| awk '{print $2}'))" ]; then
		[[ " ${toInstall[@]} $toupdate " =~ " $pkgname " ]] && info "UPTODATE" "$pkgname:$pkgver"
		return 2
	fi
	info "INSTALLING" "$pkgname:$pkgver from $pkgrepo/$pkgbasename"
	cp -r $ABSROOT/$pkgrepo/$pkgbasename $tmp/$pkgbasename
	cd $tmp/$pkgbasename
	[ -n "$depends" ] && {
#	        for depend in ${depends[@]}; do
#			depend=$(getpkgname $depend)
#			[[ " $toupdate " =~ " $depend " ]] && updated=( ${updated[@]} "$depend" )
#		done
	        install_apps ${depends[@]}
	}
	[ -n "$makedepends" ] && $pacman -Sq --asdeps ${makedepends[@]} 2> /dev/null
#	[ -n "$optdepends" ] && true # ???????
	chown -R $_USER:$_USER .
	su -s /usr/bin/bash - $_USER --session-command="cd $tmp/$pkgbasename; makepkg -f" || { # -fs --rmdeps --needed
	        error "BUILD FAIL" "$pkgname" && failed=( ${failed[@]} ${pkgname[@]} ) && return 3
	}
	echo $pkgnames
	for package in $pkgnames; do
		pkg_path=$(ls $PKGDEST/$package-$pkgver-*$PKGEXT)
		if (pacman -Q $package); then
			pkgs_to_install="$pkgs_to_install $pkg_path"
			builded=( ${builded[@]} $package )
		elif (pacman -Qpi $pkg_path | grep "Depends On.* $pkgname\($\|=\|<\|>\| .*\)"); then
			pkgs_to_install="$pkgs_to_install $pkg_path"
			builded=( ${builded[@]} $package )
		fi
	done
	if [[ ! "$pkgs_to_install" =~ "$PKGDEST/$pkgname-$pkgver" ]]; then
		pkg_path=$(ls $PKGDEST/$pkgname-$pkgver-*$PKGEXT)
		pkgs_to_install="$pkgs_to_install $pkg_name"
	fi
	$pacman -U $pkgs_to_install
	if [[ " $toupdate " =~ " $pkgname " ]]; then
	       ok "UPDATED" "$pkgname:$pkgver"
       else
	       ok "INSTALLED" "$pkgname:$pkgver"
       fi

	builded=( ${builded[@]} $pkgname )
}

updateDB () {
	if [ -e /var/lib/absinstall/lock.pid ]; then
		error "DB LOCKED" "an other process is locking the DB (/var/lib/absinstall/lock.pid)"
		exit 1
	fi
	echo "$PID" > /var/lib/absinstall/lock.pid
	info "SYNC ABS"
	abs
	info "UPDATING DB"
	su -s /usr/bin/bash - $_USER --session-command="\
		$(declare -f getpkgname);$(declare -f user_updateDB);\
		ABSROOT=$ABSROOT; user_updateDB" 2>/dev/null || {
		error "UPGRADE FAIL" && rm /tmp/${_USER}.absinstall.db 2> /dev/null
	} || do_exit
	mv /tmp/${_USER}.absinstall.db $DB
	cp $DB $DB_ORIG
	rm /var/lib/absinstall/lock.pid
	info "UPDATING PACMAN"
	$pacman -Sy
}
user_updateDB(){
	ls $ABSROOT/*/*/PKGBUILD | while read file;
        do
		unset provides app_path
		app_path=$(echo $file| sed 's,'$ABSROOT'/*\(.*\)/\(.*\)/PKGBUILD,\1 \2,')
	        source $file
#		for app in ${pkgname[@]}; do echo "${app%=*} $app_path $pkgver-$pkgrel";done >> /tmp/${USER}.absinstall.db
		for app in ${pkgname[@]}; do echo "$(getpkgname $app) $app_path";done >> /tmp/${USER}.absinstall.db
	done
}
upgrade () {
	local app
	toupdate="$(pacman -Qnu | awk '{print $1}' | tr '\n' ' ')"
	if [ -z "$toupdate" ]; then
		info "SYSTEM UPTODATE"
	else
		info "TO UPDATE" "$toupdate"
	fi
	for app in $toupdate
	do
		[[ " ${builded[@]} " =~ " $app " ]] && continue
		install $app
#		updated=( ${updated[@]} $app )
	done
}
error(){
	echo -e "\e[31;1m[${1}]\e[0m $2"
}
warn(){
	echo -e "\e[33;1m[${1}]\e[0m $2"
}
info(){
	echo -e "\e[39;1m[${1}]\e[0m $2"
}
ok(){
	echo -e "\e[32;1m[${1}]\e[0m $2"
}
debug(){
	[ "1" -eq "$DEBUG" ] && info "$1" "$2"
}

getpkgname() {
	unset pkg_name
	pkg_name=${1%=*}
	pkg_name=${pkg_name%>*}
	echo ${pkg_name%<*}
}

do_exit(){
	rm -rf $tmp
	if [[ -e /var/lib/absinstall/lock.pid && \
		"$(cat /var/lib/absinstall/lock.pid)" == "$PID" ]]; then
		rm /var/lib/absinstall/lock.pid
	fi
	[ -n "$builded" ] && ok "BUILDED" "${builded[@]}"
	[ -n "$failed" ] && error "FAILED" "${failed[@]}"
	exit ${1:-1}
}
trap "error 'INTERRUPTED';do_exit" HUP TERM INT QUIT
#trap 'error "EXEC ERROR" "line:$LINENO command:$BASH_COMMAND"' ERR

set -- $(getopt uyi "$@")
while [ $# -gt 0 ]
do
	case "$1" in
		(-i) op_install=true;;
		(-u) op_upgrade=true;;
		(-y) op_update=true;;
		(--) shift; break;;
		(-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
	        (*)  toInstall=( ${toInstall[@]} $1 );;
	esac
	shift
done


cp $DB_ORIG $DB

toInstall=( ${apps[@]} $@ )

$op_update && updateDB
$op_upgrade && upgrade
$op_install && install_apps ${toInstall[@]}
do_exit 0
