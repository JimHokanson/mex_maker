classdef linker_entry
    %
    %   Class:
    %   mex.build.linker_entry
    %
    %   See Also
    %   --------
    %   mex.build.main_spec
    %   mex.matlab.linker_settings.main
    
    properties
        verbose
        cmd_path
        params
    end
    
    properties
        compiler_entries
        mex_file_path
        static_libs
    end
    
    properties 
        compiler
    end
    
    methods
        function obj = linker_entry(compiler, compiler_entries)
            
            obj.verbose = compiler.verbose;
            obj.compiler = compiler;
            obj.cmd_path = compiler.compiler_path;
            obj.mex_file_path = compiler.mex_file_path;
            obj.compiler_entries = compiler_entries;
            
            includes = compiler.linker_include_dirs;
            params = cellfun(@(x) ['-L"' x '"'],includes,'un',0);
            
            params = [params compiler.linker_flags];
            
            %On windows, we need to have c_mexapi_version.o
            %before the libs ...
            %
            %Ideally we could handle this a bit nicer ...
            
            objects = obj.compiler_entries.getObjectPaths();
            
            params = [params objects];
            
            params = [params compiler.linker_direct_libs];
            
            %TODO: http://stackoverflow.com/a/6578558/764365
            %To link your program with lib1, lib3 dynamically and lib2 statically, use such gcc call:
            %gcc program.o -llib1 -Wl,-Bstatic -llib2 -Wl,-Bdynamic -llib3
            libs = compiler.linker_dynamic_libs;
            params = [params cellfun(@(x) ['-l' x ],libs,'un',0)];
            
            libs = compiler.linker_static_libs;
            obj.static_libs = cellfun(@(x) ['-l' x ],libs,'un',0);
                        
            obj.params = params;
        end
        function cmd_str = getCompileStatement(obj)
            
            [~,target_file_name] = fileparts(obj.mex_file_path);
            output_name = ['-o ' target_file_name '.' mexext];
            
            %TODO: Ask about order of static vs dynamic linking on SO
            cmd_str = mex.sl.cellstr.join([...
                {obj.cmd_path} ...
                obj.params  ...
                {output_name} ],'d',' ');
        end
        function execute(obj)
            %
            %   
            
            %TODO: Clear the output file if in memory
            %TODO: Build in output file support
            
            cmd_str = obj.getCompileStatement();
            if obj.verbose
                fprintf('%s\n',cmd_str);
            end
            [failed,result] = system(cmd_str);
            if failed
                error(result)
            end
            
        end
    end
    
end

