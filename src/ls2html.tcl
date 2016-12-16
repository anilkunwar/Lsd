# ****************************************************
# ****************************************************
# LSD 7.0 - August 2015
# written by Marco Valente
# Universita' dell'Aquila
# 
# Copyright Marco Valente
# Lsd is distributed according to the GNU Public License
# 
# Comments and bug reports to marco.valente@univaq.it
# ****************************************************
# ****************************************************

# Collection of procedures to manage HTML and other external files

proc LsdHelp a {
	global HtmlBrowser tcl_platform RootLsd
	set here [ pwd ]
	set f [ open $RootLsd/Manual/temp.html w ]
	puts $f "<meta http-equiv=\"Refresh\" content=\"0;url=$a\">"
	close $f
	set b "[file nativename $RootLsd/Manual/temp.html]"
	if { $tcl_platform(platform) == "unix" } {
		exec $HtmlBrowser $b &
	} {
		exec cmd.exe /c start $b &
	}
}


# proc LsdHelp a {
	# global tcl_platform RootLsd
	# set here [ pwd ]
	# cd $RootLsd
	# cd Manual
	# set f [ open temp.html w ]
	# puts $f "<meta http-equiv=\"Refresh\" content=\"0;url=$a\">"
	# close $f
	# set b "temp.html"
	# if { $tcl_platform(platform) == "unix" } {
		# exec konqueror $b &
	# } {
		# if { $tcl_platform(os) == "Windows NT" } {
			# if { $tcl_platform(osVersion) == "4.0" || $tcl_platform(osVersion) == "5.1" || $tcl_platform(osVersion) == "5.0" } {
				# exec cmd.exe /c start $b &
			# } {
				# catch [ exec open.bat & ]
			# }
		# } {
			# exec command.com /c start $b &
		# }
	# } 
	# cd $here 
# }


proc LsdHtml a {
	global HtmlBrowser tcl_platform
	set f [ open temp.html w ]
	puts $f "<meta http-equiv=\"Refresh\" content=\"0;url=$a\">"
	close $f
	set b "temp.html"
	if { $tcl_platform(platform) == "unix" } {
		exec $HtmlBrowser $b &
	} {
		exec cmd.exe /c start $b &
	}
}


proc LsdTkDiff { a b } {
	global tcl_platform RootLsd wish LsdSrc
	if { $tcl_platform(platform) == "unix" } {
		exec $wish $RootLsd/$LsdSrc/tkdiffb.tcl $a $b &
	} {
		if { $tcl_platform(os) == "Windows NT" } {
			if { $tcl_platform(osVersion) == "4.0" } {
				exec cmd /c start $wish $RootLsd/$LsdSrc/tkdiffb.tcl $a $b &
			} {
				exec $wish $RootLsd/$LsdSrc/tkdiffb.tcl $a $b &
			} 
		} {
			exec start $wish $RootLsd/$LsdSrc/tkdiffb.tcl $a $b &
		}
	}
}


# Procedure used to allocate a file 'index.html' in each directory
# containing links to each file
# the "from" parameter is the directory root where to start inserting the index.html files
# the "chop" parameter is the number of characters to chop from the beginning of the directory.
# For example, if the directory is C:/Lsd5.1, setting chop=3 will make appear the directory names as Lsd5.1

proc ls2html {from chop} {

catch [set list [glob *]]
if { [info exists list] == 0 } {return } {}


foreach i $list {

 if { [file isdirectory $i] == 1 } {lappend ldir $i} {lappend lfile $i } 
}

if { [info exists ldir] == 1 } {

set sortedlist [lsort -dictionary $ldir]
foreach i $sortedlist {

 cd $i; ls2html $from $chop; cd ..;
 
} } {}

set f [open index.html w]
puts $f "<B><font size=+3><U>Directory: [string range [pwd] $chop end ]</U></font></B>"
if { [pwd] != $from } {puts $f "\n<br><a href=\"../index.html\">Return</a> to UP directory" } {}

puts $f "\n<br>"

if { [info exists ldir] == 1 } {
puts $f "\n<br><hr style=\"width: 100%; height: 2px;\">"
puts $f "<B><font size=+2>List of directories</B></font>\n<br>"
foreach i $sortedlist {
 puts $f "\n<br><B>Dir: </B><a href=\"$i/index.html\">$i</a>" 
 } 
} {} 

if { [info exists lfile] == 1 } {
set sortedlist [lsort -dictionary $lfile]
puts $f "\n<br><hr style=\"width: 100%; height: 2px;\">"
puts $f "<B><font size=+2>List of files</font></B>\n<br>"
puts $f "<br><b><font face=\"Courier New,Courier\">File name...................Size, &nbsp Date</font></b><br>\n"

foreach i $sortedlist {
  if { [string compare $i index.html] } {
  puts $f "<font face=\"Courier New,Courier\"><a href=\"$i\">$i</a>" 
  set len [string length $i]
  set np [expr 30 -$len]
  set np [expr $np - [string length [file size $i]]]
  set fill [string repeat . $np]
  puts $f "$fill [file size $i], "
  set fdate [clock format [file mtime $i] -format "%e %h %Y"]
  puts $f "$fdate </font>\n<br>"
  } {}
}
} {}

if { [file exist description.txt] } {
  puts $f "<hr style=\"width: 100%; height: 2px;\">"
  puts $f "<B><font size=+2>Description</font></B>\n<br>\n<br>"
  set desc [open description.txt r]
  while { ![eof $desc] } {
    puts $f [gets $desc]
    puts $f "<br>"
   }   
  close $desc
  } {}
close $f
}
