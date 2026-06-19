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
r {optional comment} - toggle sleep tracking
rr {id} - remove a sleep record
lr - list sleep records
s - Summarize status
E {table} - export an SQLite table to a CSV file of the same name
q - quit gracefully
"

# ANSI escape sequences
set RESET "\033\[0m"
set FGBLACK "\033\[30m"
set FGRED "\033\[31m"
set FGGREEN "\033\[32m"
set FGYELLOW "\033\[33m"
set FGBLUE "\033\[34m"
set FGMAGENTA "\033\[35m"
set FGCYAN "\033\[36m"
set FGWHITE "\033\[37m"
set BGBLACK "\033\[40m"
set BGRED "\033\[41m"
set BGGREEN "\033\[42m"
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

sql eval {
  CREATE TABLE IF NOT EXISTS sleep (
  id INTEGER PRIMARY KEY,
  start INTEGER,
  end INTEGER,
  comment TEXT
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
    INSERT INTO bodyweight VALUES(NULL,$weight,$t);
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
    INSERT INTO activities VALUES(NULL,$activity,$weight,$sets,$reps,$energy,$t);
  }

  puts  "$::FGBLUE Inserted \"$activity\" to database @ [tfmt $t]$::RESET" 
}

##############################################
## Description: Sleep tracking toggle
## Author:      Vilyaem
##############################################
proc r {{note "None"}} {
  # get curtime
  set t [clock seconds]

  set incomplete false

  # Search for an existing incomplete sleep entry
  sql eval {
    SELECT * FROM sleep WHERE end is NULL
  } row {
    set incomplete "$row(id)"
  }

  if {$incomplete} {
    sql eval {
      UPDATE sleep SET end = $t WHERE id == $incomplete
    }
    puts  "$::FGBLUE Finished sleep tracking @ [tfmt $t] $::RESET" 
  } else  {
    sql eval {
      INSERT INTO sleep VALUES(NULL, $t , NULL, $note)
    }
    puts  "$::FGBLUE Started sleep tracking @ [tfmt $t] $::RESET" 
  }
}

##############################################
## Description: Remove  a weightlifting activity
## Author:      Vilyaem
##############################################
proc ra {id} {

  sql eval {
    DELETE FROM activities WHERE id == $id;
  }

  puts  "$::FGBLUE Attempted to remove activity with an ID of \"$id\" from the database $::RESET" 
}

##############################################
## Description: Remove  a bodyweight record
## Author:      Vilyaem
##############################################
proc rw {id} {

  sql eval {
    DELETE FROM bodyweight WHERE id == $id;
  }

  puts  "$::FGBLUE Attempted to remove bodyweight record with an ID of \"$id\" from the database $::RESET" 
}

##############################################
## Description: Remove a sleep record
## Author:      Vilyaem
##############################################
proc rr {id} {

  sql eval {
    DELETE FROM sleep WHERE id == $id;
  }

  puts  "$::FGBLUE Attempted to remove sleep record with an ID of \"$id\" from the database $::RESET" 

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
## Description: List sleeps
## Author:      Vilyaem
##############################################
proc lr {} {
  set rowthick "$::BGBLUE$::FGBLACK"
  set rowlight "$::FGBLUE"

  set rowcol "$rowthick"

  puts "ID\tSTART\t\t\t\tEND\t\t\t\tNOTE"

  sql eval {
    SELECT * FROM sleep ORDER BY start
  } row {

    if {$rowcol == "$rowthick"} {
      set rowcol "$rowlight"
    } else {
      set rowcol "$rowthick"
    }

    # Ends may be null
    if {$row(end) == ""} {
      set end "Unknown yet"
    } else {
      set end [tfmt $row(end)]
    }

    puts "$rowcol$row(id)\t[tfmt $row(start)]\t$end\t$row(comment)\t$::RESET"
  }

}

##############################################
## Description: Export a SQLite table to CSV
## No checks or anything.
## Author:      Vilyaem
##############################################
proc E {table} {
  set res [sql eval "SELECT * FROM \"$table\""]
  regsub -all " " $res {,} res
  set f [open "$table.csv" w]
  puts $f $res
  close $f

  puts "$::FGBLUE Exported table:$table to '$table.csv' $::RESET"
}

##############################################
## Description: Get current status
# - show whether or net user is sleeping
# - show latest activity & last update
# - show current bodyweight & last update
## No checks or anything.
## Author:      Vilyaem
##############################################
proc s {} {

  # Don't proceed if any of the tables are empty
  foreach table {"bodyweight" "activities" "sleep"} {
    set cnt [sql exists "SELECT * FROM $table"]
    if {$cnt == 0} {
      puts "$::FGRED You have not used hackenschmidt enough to get a status.$::RESET"
      return
    }
  }

  set lastact [sql onecolumn {SELECT name FROM activities ORDER BY date DESC LIMIT 1}]
  set lastactdate [tfmt [sql onecolumn {SELECT date FROM activities ORDER BY date DESC LIMIT 1}]]
  set lastweight [sql onecolumn {SELECT weight FROM bodyweight ORDER BY date DESC LIMIT 1}]
  set lastweightdate [tfmt [sql onecolumn {SELECT date FROM bodyweight ORDER BY date DESC LIMIT 1}]]
  set asleep [sql exists {SELECT * FROM sleep WHERE end IS NULL}]


  if {$asleep == "1"} {
    set asleep "Asleep"
  } else {
    set asleep "Awake"
  }


  puts "$asleep
Last Action: $lastact @ $lastactdate
Last Weigh-in: $lastweight @ $lastweightdate
  "
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
