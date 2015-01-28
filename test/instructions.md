Testing instructions
====================

This file lists some instructions of how to test functions against
results of other programming languages.

Input data
----------

Some functions will directly be tested on real data. The following
rules hold:
- input data comes from the EconDatasets package and is not contained
  in the git repository
- input data is created by function *createTestData* in *utils*
- input data has name *no_git_dataname*

Output data
-----------

Test results of other programming languages is computed in scripts in
folder *build*. The naming convention is to denote language and
application. For example:
- *r_cir.R*
- *matlab_cir.m*

In addition, helper functions can be stored in separate folder of
*build*, for example *mat_help_funcs*.

Test results are stored in folder *data* and will be *committed* to
the git repository! This way, tests can be run even without access to
the other programming languages (MATLAB could be a problem). In
general, the results of other languages only need to be re-built once
in a while.

Running tests
-------------

If tests are run, input data will be re-built and current version of
results are used for other languages.

Re-building results
-------------------

### Individual tests

Individual results can be re-built in Julia itself. 

#### R 

R results are computed within docker container:

````
rscriptPath = joinpath(Pkg.dir("Econometrics"), "test/")
run(`docker run -t --rm -v $rscriptPath:/home/docker/ juliafinmetrix/rfinm_deb bash R CMD BATCH --no-save --no-restore r_results.R`)
````

In words: the *test* directory is mounted within the container in
order to be able to access the input data in *data* and the build
files in *build* subdirectory. 

Maybe the user is required to be changed so that data output
permission will not be restricted to root.


#### Interactive use (customized)

R:

For interactive use, simply start container inside of *test* directory
with alias *rdock* and add it as remote ess process.


Re-building docker
-------------------

In order to add additional packages into a docker image, add the
package in *r_debian/Dockerfile* and re-built with *rdock_build*.
