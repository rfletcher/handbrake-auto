Years ago I ripped my DVD library. I wrote these scripts to automate the process.

Once configured, you only have to insert your DVD, wait for it to be ripped, and put it away again once it's ejected. Rips are saved to ~/Movies, named after the DVD volume label.

The scripts are probably not useful as-is, but could be with some minor edits. (handbrake.rb is also somewhat ugly, but was one of the first things I ever did with Ruby. Don't judge me!)

## Requirements ##

- Handbrake CLI
- `nice`, installed to the standard MacPorts path
  (That MacPorts requirement is one of those things you could fix with a minor edit. As I said, it was years ago.)
- a Handbrake preset named "Default"

## Setup ##

1. Open System Preferences -> CDs & DVDs
2. Configure "When you insert a video DVD" to run the included AppleScript

Handbrake output is logged to ~/Library/Logs/handbrake.rb.log
