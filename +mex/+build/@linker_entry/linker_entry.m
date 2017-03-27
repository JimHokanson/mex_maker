classdef linker_entry
    %
    %
    %   mex.build.linker_entry
    
    properties
        cmd_path
        params
    end
    
    properties
        compiler_entries
        mex_file_path
    end
    
    methods
        function obj = linker_entry(compiler,compiler_entries)
            
            obj.cmd_path = compiler.compiler_path;
            obj.mex_file_path = compiler.mex_file_path;
            
            includes = compiler.linker_include_dirs;
            params = cellfun(@(x) ['-L"' x '"'],includes,'un',0);
            params = [params compiler.linker_flags];
            libs = compiler.linker_libs;
            params = [params cellfun(@(x) ['-l' x ],libs,'un',0)];
            obj.params = params;
            obj.compiler_entries = compiler_entries;
        end
        function cmd_str = getCompileStatement(obj)
            
            %We need to get the object files ...
            temp = obj.compiler_entries.getObjectPaths();
            
            [~,target_file_name] = fileparts(obj.mex_file_path);
            output_name = ['-o ' target_file_name '.' mexext];
            cmd_str = sl.cellstr.join([{obj.cmd_path} obj.params temp {output_name}],'d',' ');
        end
        function execute(obj)
            %
            %   
            
            cmd_str = obj.getCompileStatement();
            [failed,result] = system(cmd_str);
            if failed
                error(result)
            end
            
        end
    end
    
end

