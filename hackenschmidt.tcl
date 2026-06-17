#!/usr/bin/env -S tclsh
# Hackenschmidt - A weightlifting logging utility that uses SQLite
# Vilyaem - https://vilyaem.xyz - Public Domain CC0

package require sqlite3


puts "Hackenschmidt by  Vilyaem https://vilyaem.xyz thekenyaz@yandex.com\n
This script is public domain.
w {weight} - report your current weight (assumed to be pounds)
a {activity} {weight} {sets} {reps} {energy} - report activity
la - list activities
lw - list weight overtime
ra {id} - remove an activity
rw {id} - remove a weight report
q - quit gracefully
"

# ANSI escape sequences
set RESET "\033\[0m"
set FGBLACK "\033\[30m"
set FGRED "\033\[31m"
set FGGREEN "\033\[32m"
set FGYELLOW "\033\[33m"
set FGYELLOW "\033\[33m"
set FGBLUE "\033\[34m"
set FGMAGENTA "\033\[35m"
set FGCYAN "\033\[36m"
set FGWHITE "\033\[37m"
set BGBLACK "\033\[40m"
set BGRED "\033\[41m"
set BGGREEN "\033\[42m"
set BGYELLOW "\033\[43m"
set BGYELLOW "\033\[43m"
set BGBLUE "\033\[44m"
set BGMAGENTA "\033\[45m"
set BGCYAN "\033\[46m"
set BGWHITE "\033\[47m"

# path of database
set dbdir "$env(HOME)/.local/share/vlmtools/"
file mkdir $dbdir
puts "$dbdir"

# open it, and create a command 'sql'
sqlite3 sql "$dbdir/hackenschmidt.db"

# create necessary tables if they don't exist
sql eval {
  CREATE TABLE IF NOT EXISTS bodyweight (
  id INTEGER PRIMARY KEY,
  weight REAL,
  date INTEGER
  )
}

sql eval {
  CREATE TABLE IF NOT EXISTS activities (
  id INTEGER PRIMARY KEY,
  name TEXT,
  weight REAL,
  sets INTEGER,
  reps INTEGER,
  energy INTEGER,
  date INTEGER
  )
}

##############################################
## Description: Format unix time the way I want!
## Author:      Vilyaem
##############################################
proc tfmt {time} {
  return [clock format $time -format "%Y-%m-%d %a %I:%M:%S %p"]
}

##############################################
## Description: Add a bodyweight entry
## Author:      Vilyaem
##############################################
proc w {weight} {
  # get curtime
  set t [clock seconds]

  # put it in!
  sql eval {
    BEGIN;
    INSERT INTO bodyweight VALUES(NULL,$weight,$t);
    END;
  }

  puts  "$::FGBLUE Inserted $weight lbs to database @ [tfmt $t]$::RESET" 
}

##############################################
## Description: Add  a weightlifting activity
## Author:      Vilyaem
##############################################
proc a {activity weight sets reps energy} {
  # get curtime
  set t [clock seconds]

  # energy level can only be 0-4
  if {$energy < 0 || $energy > 4} {
    puts  "$::FGRED Your reported energy has to be ranged from 0 to 4.$::RESET" 
    return
  }

  # put it in!
  sql eval {
    BEGIN;
    INSERT INTO activities VALUES(NULL,$activity,$weight,$sets,$reps,$energy,$t);
    END;
  }

  puts  "$::FGBLUE Inserted \"$activity\" to database @ [tfmt $t]$::RESET" 
}

##############################################
## Description: Remove  a weightlifting activity
## Author:      Vilyaem
##############################################
proc ra {id} {

  # put it in!
  sql eval {
    BEGIN;
    DELETE FROM activities WHERE id == $id;
    END;
  }

  puts  "$::FGBLUE Attempted to remove activity with an ID of \"$id\" from the database $::RESET" 
}

##############################################
## Description: Remove  a bodyweight record
## Author:      Vilyaem
##############################################
proc rw {id} {

  # put it in!
  sql eval {
    BEGIN;
    DELETE FROM bodyweight WHERE id == $id;
    END;
  }

  puts  "$::FGBLUE Attempted to remove bodyweight record with an ID of \"$id\" from the database $::RESET" 
}

##############################################
## Description: List bodyweight records
## Author:      Vilyaem
##############################################
proc lw {} {
  set rowthick "$::BGBLUE$::FGBLACK"
  set rowlight "$::FGBLUE"

  set rowcol "$rowthick"

  puts "ID\tBODYWEIGHT\tDATE"

  sql eval {
    SELECT * FROM bodyweight ORDER BY date
  } row {
    
    if {$rowcol == "$rowthick"} {
      set rowcol "$rowlight"
    } else {
      set rowcol "$rowthick"
    }

    puts "$rowcol$row(id)\t$row(weight)\t[tfmt $row(date)]$::RESET"
  }

}

##############################################
## Description: List activities
## Author:      Vilyaem
##############################################
proc la {} {
  set rowthick "$::BGBLUE$::FGBLACK"
  set rowlight "$::FGBLUE"

  set rowcol "$rowthick"

  puts "ID\tACTIVITY\tWEIGHT\tSETS\tREPS\tENERGY\tDATE"

  sql eval {
    SELECT * FROM activities ORDER BY date
  } row {
    
    if {$rowcol == "$rowthick"} {
      set rowcol "$rowlight"
    } else {
      set rowcol "$rowthick"
    }

    puts "$rowcol$row(id)\t$row(name)\t$row(weight)\t$row(sets)\t$row(reps)\t$row(energy)\t[tfmt $row(date)]$::RESET"
  }

}

##############################################
## Description: A quitting command
## Author:      Vilyaem
##############################################
proc q {} {
  puts "Goodbye."
  sql close
  exit
}

# Reimplement the repl, it's like tclsh https://wiki.tcl-lang.org/page/REPL
while 1 {
  puts -nonewline "% "
  flush stdout
  gets stdin line
  if [eof stdin] break
  catch $line res
  puts $res
}
