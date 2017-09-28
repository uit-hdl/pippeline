---
output:
  pdf_document: default
  html_document: default
---

# Installing
After having installed this package in a regular manner (i.e., with `install.packages()`),
additional non-CTAN packages are needed to finalize the installation.
They can be installed by means of the included script. Write this in an R terminal:

```
source('install.R')
```

In case this does not succeed on a Linux box, run

```
sudo apt-get install libcairo2-dev libglu1-mesa-dev
```

in a Shell terminal. The former is to be able to install the Cairo R package (from CTAN), 
a prerequisite for the arrayQualityMetrics package, and the latter is required by the lumi 
package. You may also have to run 

```
install.packages( 'Cairo', dependencies=T)
```

in an R terminal afterwards.


# How to run this application

The following assumes that the app is properly installed, 
and that you pointed R to the directory of this file.

First, load all necessary datasets. Example:

```
library(nowac)
```

You should now have a set of datasets available and can check that by:

```
ls()
```

You may also have to configure the app. 
For this, edit the files *shiny/options.csv* and *shiny/questionnaires.csv* accordingly.
The former contains the names of the R objects holding the available gene expression datasets 
(and their descriptions), while the latter contains the names of the R objects holding the 
available questionnaire data.

That's it.
Now write in an R terminal:

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
