# Hackenschmidt

REPL tool I made for myself to track my workouts, sleep, and bodyweight, the
data is stored in an SQLite database. This is my first project in Tcl, I wanted
to get a feel for it, I quite like it.

## Showcase

[![asciicast](https://asciinema.org/a/PqeVivqbBKqBMjXy.svg)](https://asciinema.org/a/PqeVivqbBKqBMjXy)

## Usage
```
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
```

## Examples
```
# Start it

$ hackenschmidt

# Use it comfortably with readline

$ rlwrap hackenschmidt
```
## Dependencies

- tclsh
- libsqlite3-tcl

## INFO
Website: https://vilyaem.xyz

Support this project:

XMR:48Sxa8J6518gqp4WeGtQ4rLe6SctPrEnnCqm6v6ydjLwRPi9Uh9gvVuUsU2AEDw75meTHCNY8KfU6Txysom4Bn5qPKMJ75w
        
WOW:WW2L2yC6DMg7GArAH3nqXPA6UBoRogf64GodceqA32SeZQpx27xd6rqN82e36KE48a8SAMSoXDB5WawAgVEFKfkw1Q5KSGfX9
    
Liberapay: https://liberapay.com/vilyaem/donate

## "LICENSE"

Public Domain CC0.
