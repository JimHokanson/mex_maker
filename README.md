# mex_maker

The goal is to try and simplify building mex files ...

I have some basic functionality with gcc on a mac working.

This is some example code ...
```
c = mex.compilers.gcc('$this/private/same_diff_mex.c');
c.build();

c = mex.compilers.gcc('$this/private/reduce_to_width_mex.c');
c.addLib('openmp'); %This part isn't finished yet
c.build();
```
