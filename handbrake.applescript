tell application "Finder"
	set scriptname to "handbrake.rb"
	set scriptlog to "~/Library/Logs/" & scriptname & ".log"
	
	do shell script "date >>" & scriptlog
	do shell script "echo 'starting up...' >>" & scriptlog

	do shell script "~/bin/" & scriptname & " &>>" & scriptlog & " &"
end tell
