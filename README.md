# mex_maker

The goal is to try and simplify building mex files. Specifically, the goal is to try and call compilers directly, rather than go through Matlab's intermediate processing steps. This is very much a (slow) work in progress. 

I have some basic functionality with gcc working.

This is some example code that I used to compile two programs for a repository. It works on both Mac and Windows (if GCC has been installed).
```
verbose = true;
c = mex.compilers.gcc('./private/same_diff_mex.c','verbose',verbose);
c.build();

c = mex.compilers.gcc('./private/reduce_to_width_mex.c','verbose',verbose);
c.addLib('openmp');
c.build();
```

Another example:
```
%Compiling of turtle_json_mex.c and associated files
%-------------------------------------------------------
fprintf('Compiling turtle_json_mex.c\n');
c = mex.compilers.gcc('./turtle_json_mex.c',...
    'files',{...
    './turtle_json_main.c', ...
    './turtle_json_post_process.c', ...
    './turtle_json_mex_helpers.c', ...
    './turtle_json_pp_objects.c', ...
    './turtle_json_number_parsing.c'});
c.addLib('openmp');
c.addCompileFlags('-mavx');
c.build();

%Compiling of json_info_to_data.c and associated files
%--------------------------------------------------------
fprintf('Compiling json_info_to_data.c\n');
c = mex.compilers.gcc('./json_info_to_data.c',...
    'files',{...
    './json_info_to_data__arrays.c', ...
    './json_info_to_data__objects.c', ...
    './json_info_to_data__utils.c', ...
    './json_info_to_data__option_handling.c'});
c.build();
```



Collaborators are welcome!
