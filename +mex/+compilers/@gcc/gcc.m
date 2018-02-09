classdef gcc < handle
    %
    %   Class
    %   mex.compilers.gcc
    %
    %   See Also
    %   ---------
    %   mex.build.compiler_entry
    %   mex.matlab.compile_settings.main

    
    %https://gcc.gnu.org/onlinedocs/gcc/Option-Summary.html
    
    %{
        c = mex.compilers.gcc;
    %}
    
    properties
        gcc_type 
        %This is windows specific and is currently discovered (not
        %specified)
        %- 'default'
        %- 'tdm-gcc'
        %- 'cygwin' NYI
        %- 'mingw' NYI
        
        caller_path = ''
        verbose = false
        mex_file_path
        output_path = ''
        
        files = {} %files to compile
        %add via addFiles()
        
        compiler_path %Executable path to call
        
        compiler_root %Base path of the compiler
        
        %-----------------------------------
        compile_flags = {}
        compile_defines = {}
        compile_include_dirs = {}
        
        %-----------------------------------
        linker_flags = {...
            '-static-libgcc',... %This means others shouldn't need gcc to run this code ...
            ... %It also seems to statically link libgomp as well
            }
        
        linker_include_dirs = {}
        linker_direct_libs = {}
        linker_dynamic_libs = {}
        linker_static_libs = {}
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
            %x Create instance of gcc compiler
            %   
            %      
            
            %1) How to get the compiler path?
            %- environment variables?
            
            in.verbose = false;
            in.files = {};
            in = mex.sl.in.processVarargin(in,varargin);
            
            try %#ok<TRYNC>
                obj.caller_path = fileparts(mex.sl.stack.getCallingFilePath());
                %TODO: Ideally we could pass in an option to now throw an 
                %error if too deep
            end
            
            obj.verbose = in.verbose;
            obj.files = in.files;
            
            if nargin
                obj.mex_file_path = mex_file_path;
            else
                obj.mex_file_path = '';
            end
            
            [obj.compiler_path,obj.gcc_type] = h__getCompilerPath();
            obj.compiler_root = fileparts(fileparts(obj.compiler_path));
            
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
            if ischar(flags)
                flags = {flags};
            end
            
            
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
            if ischar(flags)
                flags = {flags};
            end
            obj.linker_flags = [obj.linker_flags flags];
        end
        function addLinkerIncludeDirs(obj,include_dirs)
            if ischar(include_dirs)
                include_dirs = {include_dirs};
            end
            obj.linker_include_dirs = [obj.linker_include_dirs include_dirs];
        end
        %linker_dynamic_libs = {}
        %linker_static_libs = {}
        function addLinkerDirectLibs(obj,libs)
            if ischar(libs)
                libs = {libs};
            end
            obj.linker_direct_libs = [obj.linker_direct_libs libs];
        end
        function addLinkerDynamicLibs(obj,libs)
            if ischar(libs)
                libs = {libs};
            end
            obj.linker_dynamic_libs = [obj.linker_dynamic_libs libs];
        end
        function addStaticLibs(obj,libs)
            if ischar(libs)
                libs = {libs};
            end
            obj.linker_static_libs = [obj.linker_static_libs libs];
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
            
            build_spec = mex.build.main_spec(obj.verbose,...
                compiler_entries,linker_entry);
        end
        function build(obj)
            %x This is the terminal call to generate the output
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

    all_files = [{obj.mex_file_path} obj.files];
    temp_entries = cellfun(fh,all_files,'un',0);
    compile_entries = [temp_entries{:}];
end


function [compiler_path,compiler_type] = h__getCompilerPath()
%
%   Outputs
%   -------
%   compiler_path : string
%   compiler_type : string
%       Specifies the type of compiler, currently only 'tdm-gcc' for 
%       possible code variances at a later point in time based on this value

    BREW_PATH = '/usr/local/Cellar/gcc/';
    %TODO: Make this more generic
    MINGW_PATH = 'C:\Program Files\mingw-w64\x86_64-7.2.0-posix-seh-rt_v5-rev1\mingw64\bin';
    TDM_GCC_PATH = 'C:\TDM-GCC-64\bin';

    persistent output_compiler_path output_compiler_type
    
    if ~isempty(output_compiler_path)
        compiler_path = output_compiler_path;
        compiler_type = output_compiler_type;
        return
    end
    
    compiler_type = 'default';

    if ismac()        
        search_function = @(x) mex.sl.dir.getList(BREW_PATH,...
            'file_pattern',x,'search_type','files','output_type','paths',...
            'recursive',true);
        
        gcc_search = {'gcc-5','gcc-6','gcc-7'};
        
        if exist(BREW_PATH,'dir')
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
    elseif ispc()
        compiler_path = fullfile(MINGW_PATH,'gcc.exe');
        if exist(compiler_path,'file')
             compiler_type = 'mingw64';
        else
            compiler_path = fullfile(TDM_GCC_PATH,'gcc.exe');
            if exist(compiler_path,'file')
                 compiler_type = 'tdm-gcc';
            else
               error('Unhandled case - couldn''t find gcc compiler') 
            end
        end
    else
        error('Not yet implemented')
    end
    
    if isempty(compiler_path)
       error('Unable to find the compiler path') 
    end
    
    output_compiler_path = compiler_path;
    output_compiler_type = compiler_type;
end


%{
otool -L reduce_to_width_mex.mexmaci64

%}