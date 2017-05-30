# How to run this application

Assuming you pointed R to the directory of this file:

```
source('pippeline.R')
```

# Known issues

* The browser window doesn't close after the Quit button is pressed.
  There is currently no solution for this as JavaScript's 
  `window.close()` method is disabled in browsers due to security
  concerns. Just close the window with Ctrl/Cmd-W.
* There is no preset filename in the download dialog in RStudio's 
  internal app window; apparently a bug in RStudio. You 
  simply have to choose a filename yourself. This works in a browser
  window, though.
* No PDFs are generated with R 3.2.3, rmarkdown 1.4, and pandoc 
  1.16.0.2, therefore the docFormat has been set to "html" in 
  file globals.R. This may change with other versions; then the value
  "pdf" might be possible. This works in RStudio 1.0.136, though.
* The package maintainer may consider removing the column "Subfile"
  in the file "options.csv"; it is currently not in use.