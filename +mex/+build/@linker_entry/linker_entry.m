classdef linker_entry
    %
    %
    %   mex.build.linker_entry
    
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
            
            includes = compiler.linker_include_dirs;
            params = cellfun(@(x) ['-L"' x '"'],includes,'un',0);
            params = [params compiler.linker_flags];
            
            libs = compiler.linker_dynamic_libs;
            params = [params cellfun(@(x) ['-l' x ],libs,'un',0)];
            
            libs = compiler.linker_static_libs;
            obj.static_libs = cellfun(@(x) ['-l' x ],libs,'un',0);
            
            %params = [params ];
            
            obj.params = params;
            obj.compiler_entries = compiler_entries;
        end
        function cmd_str = getCompileStatement(obj)
            
            %We need to get the object files ...
            objects = obj.compiler_entries.getObjectPaths();
            
            [~,target_file_name] = fileparts(obj.mex_file_path);
            output_name = ['-o ' target_file_name '.' mexext];
            
            %TODO: Ask about order of static vs dynamic linking on SO
            cmd_str = sl.cellstr.join([...
                {obj.cmd_path} ...
                obj.params objects ...
                obj.static_libs ...
                {output_name} ],'d',' ');
        end
        function execute(obj)
            %
            %   
            
            %TODO: Clear the output file if in memory
            %TODO: Build in output file support
            
            cmd_str = obj.getCompileStatement();
            [failed,result] = system(cmd_str);
            if failed
                error(result)
            end
            
        end
    end
    
end
