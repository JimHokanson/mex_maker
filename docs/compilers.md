# Compilers #

## Windows ##

### TDM-GCC ###

1. You might need to install the code at the link below first. I would recommend skipping it for now and only using if you encounter an error later on. Specifically, it depends on whether or not "extern\lib\win64\mingw64" already exists in the matlab root or not.

https://www.mathworks.com/matlabcentral/fileexchange/52848-matlab-support-for-the-mingw-w64-c-c++-compiler-from-tdm-gcc

2. Download and install TDM-GCC 5.1 (or other version) WITH OPENMP ENABLED. This requires checking the OPENMP box (under GCC)?


Note, if you wanted to use this directly in Matlab without the mex maker code, you would need to run "setenv('MW_MINGW64_LOC','C:\TDM-GCC-64')", which I put in my startup file. You would also need to run "mex -setup" to select TDM-GCC as the compiler.   

## Mac ##

### GCC ###

This was written after the fact, so it might be slightly inaccurate.

0. Make sure homebrew is installed
1. In the terminal run "brew update xcode-select". This should install/update the XCODE command line tools.
2. In the terminal run "brew install gcc"

If you wanted to use this compiler directly in Matlab, you would need to specify the path to the compiler as an argument to XCODE. XCODE might also need to be fully installed, rather than the command line tools.





