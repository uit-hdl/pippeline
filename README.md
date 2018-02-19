# Installing
After having installed this package in a regular manner (e.g., with `install.packages()` in R),
additional non-CTAN packages are needed to finalize the installation.
They can be installed by means of the included script. Write this in an R terminal:

```
source('install.R')
```

In case this does not succeed on a Linux box, run

```
sudo apt-get install libcairo2-dev libglu1-mesa-dev
```

in a Shell terminal. The former is to be able to install the Cairo package (from CTAN),
a prerequisite for the arrayQualityMetrics package, and the latter is required by the lumi
package. You may also have to run

```
install.packages( 'Cairo', dependencies=T)
```

in an R terminal afterwards.


# How to run this application

The following assumes that this package is properly installed,
and that you pointed R to the directory of this file.

First, load all necessary datasets. Example:

```
library(nowac)
```

You should now have a set of datasets available and can check that by:

```
data()
```

You may also have to configure the app.
For this, edit the files *shiny/options.csv* and *shiny/questionnaires.txt* accordingly.
The former contains the names of the R objects holding the available gene expression datasets
(and their descriptions), while the latter contains the names of the R objects holding the
available questionnaire data. See also the next section.
Set working directory inside pippeline, if you are working from RStudio.

That's it.
Now write in an R terminal:

```
source('run.R')
```

You may be needed to generate outliers for the datasets. For this you can use nowaclean-gen.R script.
This is interactive exploratory script you can use before you perform outlier removal step in the pippeline. It is not the actual part of pippeline.

# File formats

## options.csv

A file with comma-separated values to store the available options and R
objects in a spreadsheet-like manner. The app reads the file by means of
*read.csv()*.  The first row contains column labels and must not be
changed. While the column values describe the dataset objects with (character)
attributes like *Design* and *Material*, each entry for the up to three
objects consists of two names, separated by a comma. The first name is
interpreted as the name of the object holding the original dataset (a lumi
object), the second is the (lumi) object with the negative controls
([gene expressions, negative controls]).


## questionnaires.txt

A file with one object name per line.  The app reads them in by means of
*readLine()*.


# Known issues
* The browser window doesn't close after the Quit button is pressed.
  There is currently no solution for this as JavaScript's
  `window.close()` method is disabled in browsers due to security
  concerns. Just close the window with Ctrl/Cmd-W.
* No PDFs are generated with R 3.2.3, rmarkdown 1.4, and pandoc
  1.16.0.2, therefore the docFormat has been set to "html" in
  file globals.R. This may change with other versions; then the value
  "pdf" might be possible. This works in RStudio 1.0.136, though.
* The checkbox regarding control-case transitions has currently no
  function.
