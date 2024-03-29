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
    [~,name] = fileparts(compiler.compiler_root);
    %name(1) => 6,7,8
    lib_dir_path = fullfile(compiler.compiler_root,'lib','gcc',name(1));
    if ~exist(lib_dir_path,'dir')
        %For 11.2 the folder is just 11
        %Actually it seems like the problem is a single to double digit
        %change ...
        lib_dir_path = fullfile(compiler.compiler_root,'lib','gcc',name(1:2));
        if ~exist(lib_dir_path,'dir')
            error('Case not yet handled')
        end 
    end
    
    %compiler.addLinkerIncludeDirs(lib_dir_path);
    %compiler.addStaticLibs(lib_name);
    
    
    temp = mex.sl.dir.getList(lib_dir_path,...
    'file_pattern','libgomp.a',...
    'search_type','files',...
    'output_type','paths',...
    'recursive',true);

    %Example result:
    %{'/usr/local/Cellar/gcc/8.3.0_2/lib/gcc/8/libgomp.a'}

    if isempty(temp)
        error('Unexpected result looking for libgomp.a')
    end
    
    libgomp_path = temp{1};
    compiler.addLinkerDirectLibs(['"' libgomp_path '"']);
    
else
    %C:\TDM-GCC-64\lib\gcc\x86_64-w64-mingw32\5.1.0
    %libgomp.a
    
    root_path = fullfile(compiler.compiler_root,'lib','gcc');
    temp = mex.sl.dir.getList(root_path,...
    'file_pattern','libgomp.a',...
    'search_type','files',...
    'output_type','paths',...
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
    %- actually on mac this caused problems ...
    compiler.addLinkerDirectLibs(['"' libgomp_path '"']);
    
    %TODO: Just include:
    %C:\Program Files\mingw-w64\x86_64-8.1.0-posix-seh-rt_v6-rev0\mingw64\x86_64-w64-mingw32\lib
    
    
    
    
    
    
    
    root_path = fullfile(compiler.compiler_root,'lib','gcc');
    temp = mex.sl.dir.getList(root_path,...
    'file_pattern','libgomp.a',...
    'search_type','files',...
    'output_type','paths',...
    'recursive',true);


%     root_path = fullfile(compiler.compiler_root,'lib','gcc');
    temp = mex.sl.dir.getList(compiler.compiler_root,...
    'file_pattern','libwinpthread.a',...
    'search_type','files',...
    'output_type','paths',...
    'recursive',true);

    if isempty(temp)
        error('Unexpected result looking for libwinpthread.a')
    end
    winpthread_path = temp{1};
    compiler.addLinkerDirectLibs(['"' winpthread_path '"']);
    
    %compiler.addLinkerIncludeDirs('C:\Program Files\mingw-w64\x86_64-8.1.0-posix-seh-rt_v6-rev0\mingw64\x86_64-w64-mingw32\lib')
    
    %compiler.addStaticLibs('pthread')
    %compiler.addStaticLibs('winpthread')
    %compiler.addLinkerFlags('-l:libwinpthread.a')
%     compiler.addLinkerFlags('"-static -lpthread"')
    %compiler.addLinkerFlags('-static')
end

end
