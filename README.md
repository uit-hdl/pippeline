# How to run this application

Assuming you pointed R to the directory of this file:

```
source('pippeline.R')
```

# Known issues

* The browser window doesn't close after Quit button is pressed.
  There is currently no solution for this as JavaScript's 
  `window.close()` method is disabled in browsers due to security
  concerns. Just close the window with Ctrl/Cmd-W.
* There is no preset filename in the download dialog in RStudio's 
  internal app window. This appears to be a bug in RStudio. You 
  simply have to choose a filename yourself.