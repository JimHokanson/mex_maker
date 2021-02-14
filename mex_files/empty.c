// mex -v empty.c

///usr/local/Cellar/gcc/8.3.0_2/lib/gcc/8

/* 2020b
 Building with 'Xcode with Clang'.
/usr/bin/xcrun -sdk macosx10.14 clang -c 
    -DMATLAB_DEFAULT_RELEASE=R2017b  
    -DUSE_MEX_CMD
    -DMATLAB_MEX_FILE 
    -I"/Applications/MATLAB_R2020b.app/extern/include" 
    -I"/Applications/MATLAB_R2020b.app/simulink/include" 
    -fno-common -arch x86_64
    -mmacosx-version-min=10.14 
    -fexceptions -isysroot 
    /Library/Developer/CommandLineTools/SDKs/MacOSX10.14.sdk -O2 
    -fwrapv -DNDEBUG 
    "/Users/jim/Documents/repos/matlab_git/mex_maker/mex_files/empty.c" 
    -o /var/folders/9q/cmrfj0px5jz8hq7lpym6vxc40000gn/T/mex_11552018155210_27773/empty.o
/usr/bin/xcrun -sdk macosx10.14 clang 
    -c -DMATLAB_DEFAULT_RELEASE=R2017b  
    -DUSE_MEX_CMD   -DMATLAB_MEX_FILE -I"/Applications/MATLAB_R2020b.app/extern/include" 
    -I"/Applications/MATLAB_R2020b.app/simulink/include" -fno-common -arch x86_64 
    -mmacosx-version-min=10.14 -fexceptions -isysroot 
    /Library/Developer/CommandLineTools/SDKs/MacOSX10.14.sdk -O2 -fwrapv 
    -DNDEBUG "/Applications/MATLAB_R2020b.app/extern/version/c_mexapi_version.c" 
    -o /var/folders/9q/cmrfj0px5jz8hq7lpym6vxc40000gn/T/mex_11552018155210_27773/c_mexapi_version.o
/usr/bin/xcrun -sdk macosx10.14 clang 
    -Wl,-twolevel_namespace -undefined error -arch x86_64 
    -mmacosx-version-min=10.14 
    -Wl,-syslibroot,/Library/Developer/CommandLineTools/SDKs/MacOSX10.14.sdk 
    -bundle  
    -Wl,-exported_symbols_list,"/Applications/MATLAB_R2020b.app/extern/lib/maci64/mexFunction.map" 
    /var/folders/9q/cmrfj0px5jz8hq7lpym6vxc40000gn/T/mex_11552018155210_27773/empty.o 
    /var/folders/9q/cmrfj0px5jz8hq7lpym6vxc40000gn/T/mex_11552018155210_27773/c_mexapi_version.o  
    -O -Wl,-exported_symbols_list,"/Applications/MATLAB_R2020b.app/extern/lib/maci64/c_exportsmexfileversion.map"  
    -L"/Applications/MATLAB_R2020b.app/bin/maci64" 
    -lmx -lmex -lmat -lc++ 
    -o empty.mexmaci64
MEX completed successfully.
 
 */

#include "mex.h"

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{

}