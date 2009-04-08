#!/bin/csh
# DPH .login v0.1

echo "${welcome_color}"
echo "****"
if( ${?distro_pretty} ) then
	echo ${distro_pretty}
else
	uname -a;
endif

if( $?REMOTEHOST ) then
	echo "${welcome_color}${bold_color}remote: ${normal_color}${welcome_color}${REMOTEHOST}"
else if( $?SSH_CLIENT ) then
  set remh=`echo ${SSH_CLIENT} | awk '{print $1'}`
	echo "${welcome_color}${bold_color}remote: ${normal_color}${welcome_color}${remh}"
endif

echo `uptime`
if( -X gcc ) then
	echo "${bold_color}gcc:${normal_color}${welcome_color}" `gcc --version | head -n 1`
else
	echo "gcc not found"
endif
echo "${bold_color}cpu(s)${normal_color}${welcome_color}:" ${num_cpus} "x" ${cpu_name}
echo "${bold_color}memory:${normal_color}${welcome_color}" ${memory_info}
echo "****"
echo ""

#set autologout=240
set complete="enhance"

echo "${white_color}"
echo "${xterm_title}"

# SSH Agent

# We only want to run agent on ssh gateways - inire, autarch, cerebellum
#set sshAgent=/usr/bin/ssh-agent
#set sshAgentArgs="-c" 
#set tmpFile=~/.ssh/ssh-agent-info-${hostname}

#  Check for existing ssh-agent process
#    if ( -s $tmpFile ) source $tmpFile
#    if ( $?SSH_AGENT_PID ) then
#      set this=`ps -elf | grep ${SSH_AGENT_PID} | grep ssh-agent > /dev/null`
#      # start ssh-agent if status is nonzero
#      if (( $? != 0 ) && ( -x "$sshAgent" )) then
#        $sshAgent $sshAgentArgs | head -2 > $tmpFile
#        source $tmpFile
#        echo "ssh agent started [${SSH_AGENT_PID}]"
#        ssh-add
#      endif
#    endif

