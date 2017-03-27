classdef gcc < handle
    %
    %   mex.compilers.gcc
    
    %https://gcc.gnu.org/onlinedocs/gcc/Option-Summary.html
    
    %{
    big_plot.compile();
    
    
    %How I want the programs to work
    %--------------------------------------------
    c = mex.compilers.gcc('$this/same_diff_mex.c');
    c.build();
    
    c = mex.compilers.gcc('$cd/reduce_to_width_mex.c');
    c.libs.addStatic('openmp');
    c.build();
        
    %}
    
    %{
        c = mex.compilers.gcc;
    %}
    
    properties
        caller_path = ''
        verbose = false
        mex_file_path
        output_path = ''
        
        files = {} %files to compile
        %add via addFiles()
        
        compiler_path
        
        %-----------------------------------
        compile_flags = {}
        compile_defines = {}
        compile_include_dirs = {}
        
        %-----------------------------------
        linker_flags = {...
            '-static-libgcc',... %This means others shouldn't need gcc to run this code ...
            }
        linker_include_dirs = {}
        linker_libs = {}
    end
    
    properties (Dependent)
        version
    end
    
    methods
        function value = get.version(obj)
            %--version is very verbose
            %-dumpversion is less verbose
            cmd = sprintf('%s -dumpversion',obj.compiler_path);
            [~,result] = system(cmd);
            value = strtrim(result);
        end
    end
    
    methods
        function obj = gcc(mex_file_path,varargin)
            %1) How to get the compiler path?
            %- environment variables?
            
            in.files = {};
            in = sl.in.processVarargin(in,varargin);
            
            try %#ok<TRYNC>
                obj.caller_path = fileparts(sl.stack.getCallingFilePath());
                %TODO: Ideally we could pass in an option to now throw an 
                %error if too deep
            end
            
            obj.files = in.files;
            
            if nargin
                obj.mex_file_path = mex_file_path;
            else
                obj.mex_file_path = '';
            end
            
            obj.compiler_path = h__getCompilerPath();
            
            mex.matlab.compile_settings.add(obj);
        end
        %------------------------------------------------------------------
        function addFiles(obj,file_paths)
            %
            %   These should be .c files
            
            if ischar(file_paths)
                file_paths = {file_paths};
            end
            obj.files = [obj.files file_paths];
        end
        %------------------------------------------------------------------
        function addLib(obj,lib_name)
            mex.libs.add(lib_name,obj);
        end
        %------------------------------------------------------------------
        function addCompileFlags(obj,flags)
            %TODO: Allow splitting
            %TODO: Look for redundant flags with different
            %values, but this could be tough since multiple may be ok ...

            obj.compile_flags = [obj.compile_flags flags];
        end
        function addCompileDefines(obj,defines)
            obj.compile_defines = [obj.compile_defines defines];
        end
        function addCompileIncludeDirs(obj,include_dirs)
            obj.compile_include_dirs = [obj.compile_include_dirs include_dirs];
        end
        %------------------------------------------------------------------
        function addLinkerFlags(obj,flags)
            obj.linker_flags = [obj.linker_flags flags];
        end
        function addLinkerIncludeDirs(obj,include_dirs)
            obj.linker_include_dirs = [obj.linker_include_dirs include_dirs];
        end
        function addLinkerLibs(obj,libs)
            obj.linker_libs = [obj.linker_libs libs];
        end
        %------------------------------------------------------------------
        function build_spec = getBuildSpec(obj)
            %
            %   This is meant to allow the user access to the end 
            %   details of building
            %
            %   Outputs
            %   -------
            %   build_spec: mex.build.main_spec
            
            if isempty(obj.mex_file_path)
               error('File to compile has not been specified'); 
            end
            
            compiler_entries = h__getCompileEntries(obj);
            linker_entry = mex.build.linker_entry(obj,compiler_entries);
            
            build_spec = mex.build.main_spec(...
                compiler_entries,linker_entry);
        end
        function build(obj)
            %
            %
            %   See Also
            %   --------
            %   mex.build.main_spec
            
            build_spec = obj.getBuildSpec();
            build_spec.build();
        end
    end
    
end

function compile_entries = h__getCompileEntries(obj)
    %
    %   mex.build.compiler_entry

    fh = @(target_file)mex.build.compiler_entry(...
        target_file,obj);

    all_files = [{obj.mex_file_path} obj.support_files];
    temp_entries = cellfun(fh,all_files,'un',0);
    compile_entries = [temp_entries{:}];
end


function compiler_path = h__getCompilerPath()
%
%
%   TODO: 

    persistent output_compiler_path
    
    if ~isempty(output_compiler_path)
        compiler_path = output_compiler_path;
        return
    end

    if ismac()
        %enviroment variables?
        brew_path = '/usr/local/Cellar/gcc/';
        
        search_function = @(x) sl.dir.getList(brew_path,...
            'file_pattern',x,'search_type','files','output_type','paths',...
            'recursive',true);
        
        gcc_search = {'gcc-5','gcc-6'};
        
        if exist(brew_path,'dir')
            for i = 1:length(gcc_search)
                cur_name = gcc_search{i};
                gcc_paths = search_function(cur_name);
                if ~isempty(gcc_paths)
                    if length(gcc_paths) > 1
                        %Not sure how to handle this
                        error('Unhandled case')
                    else
                        compiler_path = gcc_paths{1};
                        break;
                    end
                end
            end
        end
    else
    end
    
    output_compiler_path = compiler_path;
end

%{
/usr/local/Cellar/gcc/6.3.0_1/bin/gcc-6 -c -DTARGET_API_VERSION=700  -DUSE_MEX_CMD   -DMATLAB_MEX_FILE -I"/Applications/MATLAB_R2017a.app/extern/include" -I"/Applications/MATLAB_R2017a.app/simulink/include" -fno-common -arch x86_64 -mmacosx-version-min=10.9 -fexceptions -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk -std=c11 -fopenmp -mavx -O3 -DNDEBUG /Users/jim/Documents/repos/matlab_git/matlab_sl_modules/plotBig_Matlab/+big_plot/private/reduce_to_width_mex.c -o /var/folders/9q/cmrfj0px5jz8hq7lpym6vxc40000gn/T/mex_1516748429666_28289/reduce_to_width_mex.o
/usr/local/Cellar/gcc/6.3.0_1/bin/gcc-6 -c -DTARGET_API_VERSION=700  -DUSE_MEX_CMD   -DMATLAB_MEX_FILE -I"/Applications/MATLAB_R2017a.app/extern/include" -I"/Applications/MATLAB_R2017a.app/simulink/include" -fno-common -arch x86_64 -mmacosx-version-min=10.9 -fexceptions -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk -std=c11 -fopenmp -mavx -O3 -DNDEBUG /Applications/MATLAB_R2017a.app/extern/version/c_mexapi_version.c -o /var/folders/9q/cmrfj0px5jz8hq7lpym6vxc40000gn/T/mex_1516748429666_28289/c_mexapi_version.o
/usr/local/Cellar/gcc/6.3.0_1/bin/gcc-6 -Wl,-twolevel_namespace -undefined error -arch x86_64 -mmacosx-version-min=10.9 -Wl,-syslibroot,/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk -bundle  -Wl,-exported_symbols_list,"/Applications/MATLAB_R2017a.app/extern/lib/maci64/mexFunction.map" -fopenmp /var/folders/9q/cmrfj0px5jz8hq7lpym6vxc40000gn/T/mex_1516748429666_28289/reduce_to_width_mex.o /var/folders/9q/cmrfj0px5jz8hq7lpym6vxc40000gn/T/mex_1516748429666_28289/c_mexapi_version.o  -O -Wl,-exported_symbols_list,"/Applications/MATLAB_R2017a.app/extern/lib/maci64/c_exportsmexfileversion.map"  libgomp.a  -L"/Applications/MATLAB_R2017a.app/bin/maci64" -lmx -lmex -lmat -lc++ -o reduce_to_width_mex.mexmaci64


/usr/local/Cellar/gcc/6.3.0_1/bin/gcc-6 -c -DTARGET_API_VERSION=700  -DUSE_MEX_CMD   -DMATLAB_MEX_FILE -I"/Applications/MATLAB_R2017a.app/extern/include" -I"/Applications/MATLAB_R2017a.app/simulink/include" -fno-common -arch x86_64 -mmacosx-version-min=10.9 -fexceptions -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk -std=c11 -fopenmp -mavx -O3 -DNDEBUG /Users/jim/Documents/repos/matlab_git/matlab_sl_modules/plotBig_Matlab/+big_plot/private/reduce_to_width_mex.c -o /var/folders/9q/cmrfj0px5jz8hq7lpym6vxc40000gn/T/mex_1516748429666_28289/reduce_to_width_mex.o
/usr/local/Cellar/gcc/6.3.0_1/bin/gcc-6 -c -DTARGET_API_VERSION=700  -DUSE_MEX_CMD   -DMATLAB_MEX_FILE -I"/Applications/MATLAB_R2017a.app/extern/include" -I"/Applications/MATLAB_R2017a.app/simulink/include" -fno-common -arch x86_64 -mmacosx-version-min=10.9 -fexceptions -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk -std=c11 -fopenmp -mavx -O3 -DNDEBUG /Applications/MATLAB_R2017a.app/extern/version/c_mexapi_version.c 
/usr/local/Cellar/gcc/6.3.0_1/bin/gcc-6 -Wl,-twolevel_namespace -undefined error -arch x86_64 -mmacosx-version-min=10.9 -Wl,-syslibroot,/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk -bundle  -Wl,-exported_symbols_list,"/Applications/MATLAB_R2017a.app/extern/lib/maci64/mexFunction.map" -fopenmp reduce_to_width_mex.o c_mexapi_version.o  -O -Wl,-exported_symbols_list,"/Applications/MATLAB_R2017a.app/extern/lib/maci64/c_exportsmexfileversion.map"  libgomp.a  -L"/Applications/MATLAB_R2017a.app/bin/maci64" -lmx -lmex -lmat -lc++ -o reduce_to_width_mex.mexmaci64

/usr/local/Cellar/gcc/6.3.0_1/bin/gcc-6 -Wl,-twolevel_namespace -undefined error -arch x86_64 -mmacosx-version-min=10.9  -bundle  -Wl,-exported_symbols_list,"/Applications/MATLAB_R2017a.app/extern/lib/maci64/mexFunction.map" -fopenmp reduce_to_width_mex.o c_mexapi_version.o  -O -Wl,-exported_symbols_list,"/Applications/MATLAB_R2017a.app/extern/lib/maci64/c_exportsmexfileversion.map"  libgomp.a  -L"/Applications/MATLAB_R2017a.app/bin/maci64" -lmx -lmex -lmat -lc++ -o reduce_to_width_mex.mexmaci64



/usr/local/Cellar/gcc/6.3.0_1/bin/gcc-6 -Wl,-twolevel_namespace -L"/Users/jim/Documents/repos/matlab_git/matlab_sl_modules/plotBig_Matlab/+big_plot/private" -undefined error -arch x86_64 -mmacosx-version-min=10.12  -bundle  -Wl,-exported_symbols_list,"/Applications/MATLAB_R2017a.app/extern/lib/maci64/mexFunction.map" -fopenmp reduce_to_width_mex.o c_mexapi_version.o  -O -Wl,-exported_symbols_list,"/Applications/MATLAB_R2017a.app/extern/lib/maci64/c_exportsmexfileversion.map"  libgomp.a  -L"/Applications/MATLAB_R2017a.app/bin/maci64" -lmx -lmex -lmat -lc++ -o reduce_to_width_mex.mexmaci64


%Added rpath - didn't seem to work
/usr/local/Cellar/gcc/6.3.0_1/bin/gcc-6 -Wl,-twolevel_namespace -Wl,-rpath,'$ORIGIN/'  -L"/Users/jim/Documents/repos/matlab_git/matlab_sl_modules/plotBig_Matlab/+big_plot/private" -undefined error -arch x86_64 -mmacosx-version-min=10.12  -bundle  -Wl,-exported_symbols_list,"/Applications/MATLAB_R2017a.app/extern/lib/maci64/mexFunction.map" -fopenmp reduce_to_width_mex.o c_mexapi_version.o  -O -Wl,-exported_symbols_list,"/Applications/MATLAB_R2017a.app/extern/lib/maci64/c_exportsmexfileversion.map"  libgomp.a  -L"/Applications/MATLAB_R2017a.app/bin/maci64" -lmx -lmex -lmat -lc++ -o reduce_to_width_mex.mexmaci64

%Adding dylib call
/usr/local/Cellar/gcc/6.3.0_1/bin/gcc-6 -Wl,-twolevel_namespace -static-libgcc  -L"/Users/jim/Documents/repos/matlab_git/matlab_sl_modules/plotBig_Matlab/+big_plot/private" -undefined error -arch x86_64 -mmacosx-version-min=10.12  -bundle  -Wl,-exported_symbols_list,"/Applications/MATLAB_R2017a.app/extern/lib/maci64/mexFunction.map" -fopenmp reduce_to_width_mex.o c_mexapi_version.o  -O -Wl,-exported_symbols_list,"/Applications/MATLAB_R2017a.app/extern/lib/maci64/c_exportsmexfileversion.map"  libgomp.a  -L"/Applications/MATLAB_R2017a.app/bin/maci64" -lmx -lmex -lmat -lc++ -o reduce_to_width_mex.mexmaci64

otool -L reduce_to_width_mex.mexmaci64

%}