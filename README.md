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
* Generating PDFs with pandoc is buggy in R 3.2.3, rmarkdown 1.4, 
  pandoc 1.16.0.2. If so, set to docFormat to 'html' in file globals.R.
  PDFs work in RStudio 1.0.136, though.
* The package maintainer may consider removing the column "Subfile"
  in the file "options.csv"; it is currently not in use.