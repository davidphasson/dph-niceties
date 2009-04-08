#!/usr/bin/env perl

my @path;
my @exports = ("path", "prompt", "promptchars", "editor", "pager");
my %aliases;
my %s_CshVars;
my $s_HostType;
my $s_HostName;
my $s_Arch;
my $b_64Bit;
my $s_MemoryInfo;
my %hwinfo;

my %shell_colors = (
	'green' => "\033[032m",
	'blue' => "\033[034m",
	'white' => "\033[037m",
	'red' => "\033[031m",
	'cyan' => "\033[36m",
	'magenta' => "\033[35m",
	'bold' => "\033[001m",
	'normal' => "\033[002m",
	'reset' => "\033[0m"
	);

# Temp
$s_CshVars{'num_cpus'} = "";
$s_CshVars{'cpu_name'} = "";
$s_CshVars{'welcome_color'} = $shell_colors{'blue'};
$s_CshVars{'white_color'} = $shell_colors{'white'};
$s_CshVars{'bold_color'} = $shell_colors{'bold'};
$s_CshVars{'normal_color'} = $shell_colors{'reset'};

sub color
{
	my $color = shift;
	my $text = shift;
	return $shell_colors{$color} . $text . $shell_colors{'white'};
}

# set_path( bool bAppend, string &sPaths )
sub set_path
{
# TODO: Detect if append is there or not (overload) 
	my $bAppend, @sPaths;
	($bAppend, @sPaths) = @_;

	# Set path to existing path if bAppend was specified
	my $path = ($bAppend ? $ENV{'path'} : "");

	foreach(@sPaths)
	{
		$path .= ":" unless $path eq "";
		$path .= $_;
	}
	$ENV{'path'} = $path;
}

sub get_hosttype
{
	my $uname;
	chomp($uname = `uname`);
	my $arch;
	chomp($arch = `uname -m`);
	$s_Arch = $arch;

	if($uname eq "Linux")
	{
		$s_HostType = "linux";
	}
	elsif($uname eq "FreeBSD")
	{
		$s_HostType = "freebsd";
	}
	elsif($uname eq "Darwin")
	{
		$s_HostType = "darwin";
	}
	elsif($uname)
	{
		$s_HostType = $uname;
	}
	else
	{
		$s_HostType = "unknown";
	}
	$s_CshVars{'hosttype'} = $s_HostType;
	return 1;
}

sub get_hostname
{
	my $hostname;

	# We need to know the type of host to do this correctly 
	unless(length($s_HostType)) 
	{
		return 0;
	}

	# Known host types	
	if($s_HostType =~ /linux|freebsd|darwin/)
	{
		chomp($hostname = `hostname -s`);
	}
	elsif($s_HostType =~ /unknown/)
	# Unknown host type 
	{
		if(`which hostname`)
		{
			chomp($hostname = `hostname`);
		}
		elsif(`which uname`)
		{
			chomp($hostname = `uname -n`);
		}
	}

	if(length($hostname))
	{
		$s_HostName = $hostname;
		$s_CshVars{'host'} = $hostname;
		return 1;
	}
	return 0;
}

sub get_hwinfo
{
	return 0 unless $s_HostType;

# Memory

	if( -e "/proc/meminfo" ) 
	{
		open(FILE, "/proc/meminfo");
		my @buf = <FILE>;
		close(FILE);
		foreach(@buf)
		{
			/MemTotal/ && do 
			{
				my @split = split(/\W+/, $_);
				$hwinfo{'totalmem'} = $split[1];

			}
		}
	}
	elsif( $s_HostType eq "SunOS" )
	{
		@buf = split(/\n/, `prtconf`);
		foreach(@buf)
		{
			/Memory/ && do
			{
				s/^.*size: //;
				$s_MemoryInfo = $_;
			}
		}
	}
	 
	 if($s_MemoryInfo == "")
	 {
	 	$s_MemoryInfo = $hwinfo{'totalmem'} . " kB";
	 }
	$s_CshVars{'memory_info'} = $s_MemoryInfo;

# CPU

	if( -e "/proc/cpuinfo" )
	{
		open(FILE, '/proc/cpuinfo');
		my @buf = <FILE>;
		close(FILE);

		foreach(@buf)
		{
			/model name/ && 0;
		}
	}	
	 return 0;
}



get_hosttype();

@path = (	"/bin", 
			"/sbin",
			"/usr/bin",
			"/usr/sbin",
			"/usr/local/bin",
			"/usr/local/sbin",
			"/usr/X11R6/bin",
			"/usr/X11R6/sbin",
			"/usr/local/loni/bin",
			"/usr/sge/bin/lx24-amd64"
		);

if($s_HostType eq "linux") {
	if($s_Arch eq 'x86_64')
	{
		unshift(@path, $ENV{'HOME'} . "/bin/linux-x86_64-gcc34/bin");
		unshift(@path, $ENV{'HOME'} . "/bin/linux-x86_64-gcc34/sbin");
	}
	else
	{
		unshift(@path, $ENV{'HOME'} . "/bin/linux-i386-gcc34/bin");
		unshift(@path, $ENV{'HOME'} . "/bin/linux-i386-gcc34/sbin");
	}
}

# Some standard mac paths
# Also for git as installed by git-osx-installer
if($s_HostType eq "darwin") 
{
	unshift(@path, "/usr/local/git/bin");
}


set_path(1, @path);


#$s_CshVars{'prompt'} = '${user}@${host}[\!]% ';
$s_CshVars{'prompt'} = '[${user}@${host}]% ';
$s_CshVars{'promptchars'} = "%#";

unless(get_hostname())
{
	print "echo Failed to get hostname;\n";
}
get_hwinfo();



# VIM

if(`which vim`) 
{
	$aliases{'vi'} = "vim";
	$ENV{'editor'} = "vim";
}

# less

if(`which less`) 
{
	$ENV{'pager'} = "less";
}

# ls
if($s_HostType eq "freebsd" || $s_HostType eq "darwin")
{
	$aliases{'ls'} = "ls -G";
}

# Approximate sockstat if not on BSD
if($s_HostType ne "freebsd")
{
	$aliases{'sockstat'} = "netstat -tl";
}

$aliases{'dh-gencsr'} = "openssl req -new -nodes -keyout $1.key -out $1.csr";

# Distro
if($s_HostType eq "freebsd" || $s_HostType eq "darwin")
{
	$s_CshVars{'distro_pretty'} = color("cyan", `uname -s`) . " " . color("blue", `uname -mr`);
}


# Xterm Title
$s_CshVars{'xterm_title'} = "\033]0;$s_HostName\007";

#####
# Send commands to tcsh
#####

foreach(@exports)
{
	print "setenv " . uc($_) . " \"" . $ENV{$_} . "\";\n";
}

foreach(keys %aliases)
{
	print "alias " . $_ . " \"" . $aliases{$_} . "\";\n";
}

foreach(keys %s_CshVars)
{ 
	print "set " . $_ . "=\"" . $s_CshVars{$_} . "\";\n";
}
