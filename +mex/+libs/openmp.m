function openmp(compiler)
%
%   mex.libs.openmp(compiler)

%This may be compiler dependent ...


compiler.addCompileFlags('-fopenmp');
compiler.addLinkerFlags('-fopenmp');

h__gcc(compiler);

end

function h__gcc(compiler)
%This
if ismac
    lib_name = 'gomp';
    
    %$root/lib/gcc/6
    lib_dir_path = fullfile(compiler.compiler_root,'lib','gcc','6');
    if ~exist(lib_dir_path,'dir')
        error('Case not yet handled')
    end
    
    compiler.addLinkerIncludeDirs(lib_dir_path);
    compiler.addStaticLibs(lib_name);
else
    error('Not yet implemented')
end

end
