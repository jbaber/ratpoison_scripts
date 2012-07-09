#!/bin/sh
#
# $Id: rpvd.sh,v 0.06.2 2006/06/02 20:33:03 emss Exp $
#
# Copyright (c) 2005, 2006 Edward M. S. Scholtz
#
# Permission to use, copy, modify, and distribute this software for any 
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies. 
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES 
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#

# -START-[ MODIFIABLE VARIABLES ]----------------------------------- #
# Path to alternative ratpoison binary
ratpoison=""
# File for writing group information to
rpvdrc="$HOME/.rpvdrc"
# -END-[ MODIFIABLE VARIABLES ]------------------------------------- #

# -START-[ USEFUL FUNCTIONS ]--------------------------------------- #
# Run a ratpoison command
rpc() {
	${ratpoison:-ratpoison} --command "$*"
}

# Format input from ratpoison -c/--command groups/windows
format() {
	awk '
		{
			match ( $0, /(\*|\+|\-)/ )
			status = substr ( $0, RSTART, RLENGTH )
			split ( $0, a, status )
			printf ( "%s%s%s%s%s\n", a[1], "@@", status, "@@", a[2] )
		}
	'
}

# Output from ratpoison -c/--command groups nicely formatted
groups() {
	rpc groups | format
}

# Total number of currently existing groups
total_groups() {
	groups | awk 'END { printf ( "%s\n", NR ) }'
}

# Group numbers
group_numbers() {
	groups | awk -F "@@" '{ printf ( "%s\n", $1 ) }'
}

# Current group number
group_number() {
	groups | awk -F "@@" '$2 == "*" { printf ( "%s\n", $1 ) }'
}

# Current group name
group_name() {
	groups | awk -F "@@" '$2 == "*" { printf ( "%s\n", $3 ) }'
}

# Output from ratpoison -c/--command windows nicely formatted
# Deal with ratpoison returning "No managed windows"
windows() {
	winfmtbkp="$(rpc set winfmt)"
	rpc set winfmt %n%s%t
	rpc windows | awk '$0 !~ /No managed windows/' | format
	rpc set winfmt "$winfmtbkp"
}

# Current group window numbers
window_numbers() {
	windows | awk -F "@@" '{ printf ( "%s\n", $1 ) }'
}

# Kill all windows belonging to the current group
kill_windows() {
	for a in $(window_numbers); do rpc select $a; rpc kill; done
}

# An existing group number unequal to $1
# Default to current group number if $1 is null
# Currently the lowest group number possible
different_group_number() {
	set -- ${1:-$(group_number)}
	groups |
	awk -F "@@" '$1 != "'$1'" { printf ( "%s\n", $1 ); exit 0 }'
}

# Restore current group frame dump from a ratpoison environment
#+ variable
restore_group_frame_dump() {
	rpc frestore $(rpc getenv rpvd$(group_number)framedump)
}

# Delete saved group information in ratpoison environment variables
# Default to current group number if $1 is null
delete_saved_group_information() {
	set -- ${1:-$(group_number)} framedump groupname
	for a in $2 $3; do rpc unsetenv rpvd$1$a; done
}

# Save current group information in ratpoison environment variables
save_group_information() {
	rpc setenv rpvd$(group_number)framedump $(rpc fdump)
	rpc setenv rpvd$(group_number)groupname $(group_name)
}

# Delete written group information from $rpvdrc
# Default to current group number if $1 is null
delete_written_group_information() {
	set -- ${1:-$(group_number)} framedump groupname
	filedump="$(<$rpvdrc)"
	echo "$filedump" |
	awk '$0 !~ /^$/ && $2 !~ /rpvd'$1'('$2'|'$3')/' > $rpvdrc
}

# Write group information to $rpvdrc
# Default to current group number if $1 is null
write_group_information() {
	set -- ${1:-$(group_number)} framedump groupname
	line0="setenv rpvd$1$2 $(rpc getenv rpvd$1$2)"
	line1="setenv rpvd$1$3 $(rpc getenv rpvd$1$3)"
	echo -e $line0\\n$line1 >> $rpvdrc
}

# Delete last remaining group
delete_last_group() {
	if [ $(group_number) -eq 0 ]; then
		rpc gnewbg rpvdatleastone
		if [ "X$behavior" = Xkill ]; then
			kill_windows
			rpc gselect 1
		elif [ "X$behavior" = Xmerge ]; then
			rpc gselect 1
			rpc gmerge 0
		fi
		rpc gdelete 0
		rpc gnewbg default
		rpc gselect 0
		[ "X$behavior" = Xmerge ] && rpc gmerge 1
		rpc gdelete 1
	else
		rpc gnewbg default
		if [ "X$behavior" = Xkill ]; then
			kill_windows
			rpc gselect 0
		elif [ "X$behavior" = Xmerge ]; then
			rpc gselect 0
			rpc gmerge $(different_group_number)
		fi
		rpc gdelete $(different_group_number)
	fi
}

# Ouput nicely formatted written groups in numerical order
# (least to greatest)
written_groups() {
	awk '
		$2 ~ /rpvd[0-9]+groupname/ {
		  match ( $2, /[0-9]+/ )
		  number[0]++
		  entry[number[0]] = substr ( $2, RSTART, RLENGTH )" "$3
		}
		
		END {
		  number[1] = 1
		  number[2] = 0
		  do {
		    for ( a = 1; a <= number[0]; a++ ) { 
		      split ( entry[a], b )
		      if ( b[1] == number[2] ) {
		        number[1]++
		        printf ( "%s%s%s\n", b[1], "@@", b[2] )
		      }
		    }
		    number[2]++
		  } while ( number[1] <= number[0] )
		}
	' $rpvdrc
}

# Written group numbers in numerical order (least to greatest)
written_group_numbers() {
	written_groups | awk -F "@@" '{ printf ( "%s\n", $1 ) }'
}
# -END-[ USEFUL FUNCTIONS ]----------------------------------------- #

# -START-[ POSITIONAL PARAMETERS ]---------------------------------- #
while getopts :d:D:f:hinpr:s:vw:W opt; do
	case $opt in
		(d)
			parse_option_arguments() {
				echo |
				awk '
					{
						split ( "'$OPTARG'", a, ":" )
						printf ( "%s\n", a['$1'] )
					}
				'
			}
			delete=yes
			behavior=$(parse_option_arguments 1)
			grpnum0=$(parse_option_arguments 2)
			grpnum1=$(parse_option_arguments 3)
		;;
		(D)
			deleteall=yes
			behavior=$OPTARG
		;;
		(f)
			rpvdrc=$OPTARG
		;;
		(h)
			help=yes
		;;
		(i)
			initialize=yes
		;;
		(n)
			switch=yes
			next=yes
		;;
		(p)
			switch=yes
			previous=yes
		;;
		(r)
			restore=yes
			behavior=$OPTARG
		;;
		(s)
			switch=yes
			select=yes
			grpnum=$OPTARG
		;;
		(w)
			write=yes
			grpnum=$OPTARG
		;;
		(W)
			writeall=yes
		;;
		(?)
			usage=yes
		;;
	esac
done
# -END-[ POSITIONAL PARAMETERS ]------------------------------------ #

# -START-[ DELETE CURRENT OR SPECIFIED GROUP AND ITS INFORMATION ]-- #
if [ "X$delete" = Xyes ]; then
	grpnum0=${grpnum0:-$(group_number)}
	grpnum1=${grpnum1:-$(different_group_number $grpnum0)}
	delete_saved_group_information $grpnum0
	delete_written_group_information $grpnum0
	if [ $(total_groups) -eq 1 ]; then
		delete_last_group
	else
		if [ "X$behavior" = Xkill ]; then
			rpc gselect $grpnum0
			kill_windows
			#rpc gselect $(different_group_number $grpnum0)
			rpc gselect $grpnum1
		elif [ "X$behavior" = Xmerge ]; then
			rpc gselect $grpnum1
			rpc gmerge $grpnum0
		fi
		rpc gdelete $grpnum0
	fi
	restore_group_frame_dump
fi
# -END-[ DELETE CURRENT OR SPECIFIED GROUP AND ITS INFORMATION ]---- #

# -START-[ DELETE ALL GROUPS AND THEIR INFORMATION ]---------------- #
if [ "X$deleteall" = Xyes ]; then
	echo "$(<$rpvdrc)" > $rpvdrc.undo
	> $rpvdrc
	for a in $(group_numbers); do
		delete_saved_group_information $a
	done
	until [ $(total_groups) -eq 1 ]; do
		if [ "X$behavior" = Xkill ]; then
			rpc gselect $(different_group_number)
			kill_windows
			rpc gselect $(different_group_number)
		elif [ "X$behavior" = Xmerge ]; then
			rpc gselect $(different_group_number)
			rpc gmerge $(different_group_number)
		fi
		rpc gdelete $(different_group_number)
	done
	delete_last_group
fi
# -END-[ DELETE ALL GROUPS AND THEIR INFORMATION ]------------------ #

# -START-[ HELP ]--------------------------------------------------- #
if [ "X$help" = Xyes ]; then
	echo "-d behavior:groupnumber:groupnumber"
	echo "   Delete specified group and all information pertaining to it"
	echo "   If behavior is merge and you specify a second group-"
	echo "    number, all windows belonging to the first specified group-"
	echo "    number will be merged with the second specified group"
	echo ""
	echo "-D behavior"
	echo "   Delete all groups and information pertaining to them"
	echo ""
	echo "-f file"
	echo "   Alternate file for written group information"
	echo ""
	echo "-h"
	echo "   Print this help"
	echo ""
	echo "-i"
	echo "   Setup useful ratpoison aliases"
	echo "    (aliases are prepended with \"rpvd\")"
	echo "-n"
	echo "   Switch to next group and restore frame layout"
	echo ""
	echo "-p"
	echo "   Switch to previous group and restore frame layout"
	echo ""
	echo "-r behavior"
	echo "   Restore written groups, and frame layouts"
	echo ""
	echo "-s groupnumber"
	echo "   Switch to specified group and restore frame layout"
	echo ""
	echo "-w groupnumber"
	echo "   Write information on specified group"
	echo "    (defaults to the current group)"
	echo ""
	echo "-W"
	echo "   Write information on all groups"
	echo ""
	echo "behavior is kill or merge (group windows)"
	echo "file is any file rpvd.sh can read and write group information"
	echo "groupnumber is any currently existing ratpoison group number"
fi
# -END-[ HELP ]----------------------------------------------------- #

# -START-[ INITIALIZE SCRIPT ]-------------------------------------- #
if [ "X$initialize" = Xyes ]; then
	rpc alias rpvd-delete-kill exec sh $0 -d kill
	rpc alias rpvd-delete-merge exec sh $0 -d merge
	rpc alias rpvd-delete-all-kill exec sh $0 -D kill
	rpc alias rpvd-delete-all-merge exec sh $0 -D merge
	rpc alias rpvd-write exec sh $0 -w
	rpc alias rpvd-write-all exec sh $0 -W
	rpc alias rpvd-next exec sh $0 -n
	rpc alias rpvd-previous exec sh $0 -p
	rpc alias rpvd-select exec sh $0 -s
	rpc alias rpvd-restore-kill exec sh $0 -r kill
	rpc alias rpvd-restore-merge exec sh $0 -r merge
fi
# -END-[ INITIALIZE SCRIPT ]---------------------------------------- #

# -START-[ SWITCH TO NEXT, PREVIOUS, OR SPECIFIED GROUP ]----------- #
if [ "X$switch" = Xyes ]; then
	[ "X$next" = Xyes ] && rpccmd=gnext
	[ "X$previous" = Xyes ] && rpccmd=gprev
	[ "X$select" = Xyes ] && rpccmd="gselect $grpnum"
	save_group_information
	rpc "$rpccmd"
	restore_group_frame_dump
fi
# -END-[ SWITCH TO NEXT, PREVIOUS, OR SPECIFIED GROUP ]------------- #

# -START-[ RESTORE SAVED GROUPS IN $rpvdrc NUMERICALLY ]------------ #
if [ "X$restore" = Xyes ]; then
	# Unset all ratpoison environment varibles used to store group
	#+ information
	# We do this to avoid ending up with unnecessary ratpoison
	#+ environment varibles for group(s) that no longer exist after
	#+ a restore
	for a in $(group_numbers); do
		delete_saved_group_information $a
	done

	# Add necessary group padding to accommodate restoring saved groups
	#+ in numerical order (least to greatest) so they end up having the
	#+ same group number they had when saving the group(s) originally
	# Increment $gwgrpnum by one if "kill" behavior is chosen, we do this
	#+ because ratpoison must have at least one group at all times
	gwgrpnum="$(
		written_group_numbers |
		awk '
			{
				lastline = $0
			}

			END {
				printf ( "%s\n", lastline )
			}
		'
	)"
	[ "X$behavior" = Xkill ] && gwgrpnum=$((++gwgrpnum))
	while [ $((number++)) -le $gwgrpnum ]; do
		until [ -n "$(group_numbers | awk '/'$number'/')" ]; do
			rpc gnewbg rpvdpad
		done
	done
	unset number

	# Backup currently existing group(s), so we can merge their windows
	#+ later on with the restored group if rpvd.sh -r merge behavior is
	#+ used
	if [ "X$behavior" = Xmerge ]; then
		for a in $(groups | awk -F "@@" '$3 != "rpvdpad"'); do
			rpc gnewbg rpvdbackup@@${a%%@@*}@@${a##*@@}
			bkpgrpnum="$(
				groups |
				awk -F "@@" '
					$3 == "rpvdbackup" && $4 == "'${a%%@@*}'" {
						printf ( "%s\n", $1 )
					}
				'
			)"
			rpc gselect $bkpgrpnum
			rpc gmerge ${a%%@@*}
		done
	fi

	# Restore written groups in numerical order (least to greatest)
	for a in $(written_groups); do
		rpc gdelete ${a%%@@*}
		rpc gnewbg ${a##*@@}
	done

	# If behavior is merge, merge any existing backup group(s)
	#+ window(s), with their restored counterpart
	if [ "X$behavior" = Xmerge ]; then
		for a in $(groups | awk -F "@@" '$3 == "rpvdbackup"'); do
			# Backed up groups current group number
			bgcgn="${a%%@@*}"
			# Backed up groups original group number
			bgogn="$(bgogn="${a%@@*}"; echo ${bgogn##*@@})"
			# Backed up groups original group title
			bgogt="${a##*@@}"
			for c in $(groups | awk -F "@@" '$3 !~ /rpvd(pad|backup)/'); do
				# Restored groups group number
				rggn="${c%%@@*}"
				# Restored groups group title
				rggt="${c##*@@}"
				if [ "$bgogn" -eq "$rggn" ]; then
					if [ "$bgogt" = "$rggt" ]; then
						rpc gselect "$rggn"
						rpc gmerge "$bgcgn"
						success=yes
					fi
				fi
			done
			if [ "X$success" != Xyes ]; then
				rpc gselect $(written_group_numbers | awk 'NR == 1')
				rpc gmerge "$bgcgn"
				unset success
			fi
		done
	fi

	# Delete all non-restored groups
	for a in $(group_numbers); do
		for b in $(written_group_numbers); do
			[ $a -eq $b ] && restored=yes
		done
		if [ "X$restored" != Xyes ]; then
			rpc gdelete $a
			unset restored
		fi
	done

	# Restore saved group information from written group information
	rpc source $rpvdrc

	# Restore current groups frame layout
	restore_group_frame_dump
fi
# -END-[ RESTORE SAVED GROUPS IN $rpvdrc NUMERICALLY ]-------------- #

# -START-[ VERSION ]------------------------------------------------ #
[ "X$version" = Xyes ] && echo "$scriptversion"
# -END-[ VERSION ]-------------------------------------------------- #

# -START-[ WRITE CURRENT OR SPECIFIED GROUP INFORMATION TO $rpvdrc ] #
if [ "X$write" = Xyes ]; then
	save_group_information
	delete_written_group_information $grpnum
	write_group_information $grpnum
fi
# -END-[ WRITE CURRENT OR SPECIFIED GROUP INFORMATION TO $rpvdrc ]-- #

# -START-[ WRITE ALL GROUP INFORMATION TO $rpvdrc ]----------------- #
if [ "X$writeall" = Xyes ]; then
	[ -f "$rpvdrc" ] && mv "$rpvdrc" "$rpvdrc".bak
	save_group_information
	for a in $(group_numbers); do write_group_information $a; done
fi
# -END-[ WRITE ALL GROUP INFORMATION TO $rpvdrc ]------------------- #

# -START-[ USAGE ]-------------------------------------------------- #
if [ "X$usage" = Xyes ]; then
	echo "usage: rpvd.sh [-dDfhinprswW]"
	echo "               [-d behavior:groupnumber:groupnumber]"
	echo "               [-f file] [-r behavior] [-s groupnumber]"
	echo "               [-w groupnumber]"
fi
# -END-[ USAGE ]---------------------------------------------------- #
