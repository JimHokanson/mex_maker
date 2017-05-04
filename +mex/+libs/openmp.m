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
lib_name = 'gomp';
if ismac
    
    %$root/lib/gcc/6
    lib_dir_path = fullfile(compiler.compiler_root,'lib','gcc','6');
    if ~exist(lib_dir_path,'dir')
        error('Case not yet handled')
    end
    
    compiler.addLinkerIncludeDirs(lib_dir_path);
    compiler.addStaticLibs(lib_name);
else
    %C:\TDM-GCC-64\lib\gcc\x86_64-w64-mingw32\5.1.0
    %libgomp.a
    
    root_path = fullfile(compiler.compiler_root,'lib','gcc');
    temp = mex.sl.dir.getList(root_path,...
    'file_pattern','libgomp.a','search_type','files','output_type','paths',...
    'recursive',true);

    %Example result:
    %'C:\TDM-GCC-64\lib\gcc\x86_64-w64-mingw32\5.1.0\libgomp.a'    'C:\TDM-GCC-64\lib\gcc\x86_64-w64-mingw32\5.1.0\32\libgomp.a'

    if isempty(temp)
        error('Unexpected result looking for libgomp.a')
    end
    %Currently let's assume that the first one is the one we want
    %since deeper files get added after files in their parent directory
    libgomp_path = temp{1};
    
    %TODO: Let's use static linking instead ...
    compiler.addLinkerDirectLibs(['"' libgomp_path '"']);
end

end
