# mex_maker

The goal is to try and simplify building mex files. Specifically, the goal is to try and call compilers directly, rather than go through Matlab's intermediate processing steps. This is very much a (slow) work in progress. 

I have some basic functionality with gcc working.

This is some example code that I used to compile two programs for a repository. It works on both Mac and Windows.
```
%Note that "$this" indicates to start at the local directory. I will probably redo
%this in the near future to use "." and ".." to navigate folders
c = mex.compilers.gcc('$this/private/same_diff_mex.c');
c.build();

c = mex.compilers.gcc('$this/private/reduce_to_width_mex.c');
c.addLib('openmp');
c.build();
```

Collaborators are welcome!
