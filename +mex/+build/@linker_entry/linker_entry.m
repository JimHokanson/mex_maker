classdef linker_entry < handle
    %
    %   Class:
    %   mex.build.linker_entry
    %
    %   See Also
    %   --------
    %   mex.build.main_spec
    %   mex.matlab.linker_settings.main
    %
    %   Options
    %   -------
    %   mex.matlab.linker_settings.main
    %   mex.matlab.compile_settings.main
    %
    %
    %   TODO: This has started to become gcc specific. I should probably
    %   split this out into types
    
    properties (Hidden)
        caller_path %The path from which the compile call occurs. This
        %is used to resolve relative paths (i.e. paths are relative to the
        %calling script/function)
    end
    
    properties
        verbose
        cmd_path    %'/usr/local/Cellar/gcc/6.3.0_1/bin/gcc-6'
        params
        % '-L"/Applications/MATLAB_R2017a.app/bin/maci64"'
        % '-L"/usr/local/Cellar/gcc/6.3.0_1/lib/gcc/6"'
        % '-static-libgcc'
        % '-Wl,-twolevel_namespace'
        % '-undefined error'
        % '-bundle'
        % '-O'
    end
    
    properties
        compiler_entries
        mex_file_path %Path to the mexFunction file
        static_libs %{'-lgomp'}
    end
    
    properties 
        compiler
        %   Ex. mex.compilers.gcc
    end
    
    methods
        function obj = linker_entry(compiler, compiler_entries)
            %
            %   Inputs
            %   ------
            %   compiler : e.g. mex.compilers.gcc
            %   compiler_entries : mex.build.compiler_entry
            
            obj.caller_path = compiler.caller_path;
            
            obj.verbose = compiler.verbose;
            obj.compiler = compiler;
            obj.cmd_path = compiler.compiler_path;
            obj.mex_file_path = compiler.mex_file_path;
            obj.compiler_entries = compiler_entries;
            
            %TODO: This is a bit messy, we want to include the
            %path for the resulting object files ...
            
            %HACK ....
            
            file_root = fileparts(compiler_entries(1).target_file_path);
            
            includes = [compiler.linker_include_dirs {file_root}];
            params = cellfun(@(x) ['-L"' x '"'],includes,'un',0);
            
            params = [params compiler.linker_flags];
            
            %On windows, we need to have c_mexapi_version.o
            %before the libs ...
            %
            %Ideally we could handle this a bit nicer ...
            
            %return_full = true;
            objects = obj.compiler_entries.getObjectPaths();
            
            %Maybe always do this?
            %if return_full
            objects = cellfun(@(x) ['"' x '"'],objects,'un',0);
            %end
            
            params = [params objects];
            
            params = [params compiler.linker_direct_libs];
            
            %TODO: http://stackoverflow.com/a/6578558/764365
            %To link your program with lib1, lib3 dynamically and lib2 statically, use such gcc call:
            %gcc program.o -llib1 -Wl,-Bstatic -llib2 -Wl,-Bdynamic -llib3
            libs = compiler.linker_dynamic_libs;
            params = [params cellfun(@(x) ['-l' x ],libs,'un',0)];
            
            libs = compiler.linker_static_libs;
            obj.static_libs = cellfun(@(x) ['-l' x ],libs,'un',0);           

            %Added 2018-02-21 for mingw64 and pthread
            %TODO: This seems like it could be compiler specific ...
            if ~isempty(obj.static_libs)
                params = [params '-Wl,-Bstatic' obj.static_libs];
            end
            
            obj.params = params;
        end
%         function removeObjects(obj)
%             %
%             %   see also
%             %   --------
%             %   
%             return_full = true;
%             object_paths = obj.compiler_entries.getObjectPaths(return_full);
%             keyboard
%         end
        function cmd_str = getCompileStatement(obj)
            
            %[~,target_file_name] = fileparts(obj.mex_file_path);
            %output_name = ['-o ' target_file_name '.' mexext];
            
            temp_file_path = mex.sl.dir.getAbsolutePath(obj.mex_file_path,obj.caller_path);
            file_path_out = mex.sl.dir.changeFileExtension(temp_file_path,mexext());
            
            output_name = ['-o "' file_path_out '"'];
            safe_cmd_path = ['"' obj.cmd_path '"'];
            %TODO: Support moving ...
            %-------------------------
            %- explicit target folder
            %   => 'C:/my_folder/result/'
            %- relative move of file  
            %   => '../..'  => move up 2 directories
            %   
            
            %keyboard
            
            %TODO: Ask about order of static vs dynamic linking on SO
            cmd_str = mex.sl.cellstr.join([...
                {safe_cmd_path} ...
                obj.params  ...
                {output_name}],'d',' ');
        end
        function execute(obj)
            %
            %   
            
            %TODO: Clear the output file if in memory
            %   - make the user do this with the library
            %   - this would allow 
            %[M X] = inmem;
            %TODO: Build in output file support
            
            cmd_str = obj.getCompileStatement();
            if obj.verbose
                fprintf('%s\n',cmd_str);
            end
            [failed,result] = system(cmd_str);
            if failed
                %Check for output failure
                %keyboard
                error(result)
            end
            
        end
    end
    
end

