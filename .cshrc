#!/bin/csh
# DPH .cshrc v0.2 

# Check for IRIX first, it's a doozie


if( $?loginsh ) then
	#echo "--Original Terminal: " ${term} "--"
endif

if( `uname -s` == "IRIX64" ) then
	source ~/.cshrc.irix64
	exit
endif

set tcsh_ver=""
set tcsh_ver=`echo ${version} | grep tcsh`

# If we don't have tcsh, die (for now)
if( "${tcsh_ver}" == "" ) then
	echo
	echo "cshrc: tcsh not found; skipping everything useful"
	echo
else
	# Execute perl for heavy lifting
	if( -x .cshrc.pl) then
		eval `./.cshrc.pl`
	else

		umask 022

		# Aliases
	
		alias	l	"ls -l ${color_ls}"
		alias	la	"ls -la ${color_ls}"
		alias	ll	"ls -alF ${color_ls}"
		alias	ls 	"ls -F ${color_ls}"
	
		# undo stupid LONI aliases
		unalias cd
	
		# Annoy before deleting stuff
		alias   rm	"rm -i"
	
		# Make ping behave normally on Solaris
		#if(${hosttype} == "SunOS") then
			#alias ping "ping -s"
		#endif

		set color_ls=""

		# TCSH OPTIONS	
		set nobeep
		set color
		set colorcat
	
	endif
endif

