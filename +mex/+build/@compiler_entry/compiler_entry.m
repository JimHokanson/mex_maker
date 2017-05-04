classdef compiler_entry
    %
    %   Class
    %   mex.build.compiler_entry
    
    properties
        verbose
        cmd_path
        target_file_path
        params
    end
    
    methods
        function obj = compiler_entry(target_file_path,compiler)
            %
            %   obj = mex.build.compiler_entry(target_file, compiler)
            
            %TODO: I think we should clean up the target file here ...
            
            obj.verbose = compiler.verbose;
            obj.cmd_path = compiler.compiler_path;
            caller_path = compiler.caller_path;
            obj.target_file_path = h__clean_target_file(caller_path,target_file_path);
            
            defines = compiler.compile_defines;
            params = cellfun(@(x) ['-D' x],defines,'un',0);
            includes = compiler.compile_include_dirs;
            params = [params cellfun(@(x) ['-I"' x '"'],includes,'un',0)];
            params = [params compiler.compile_flags];
            obj.params = params;
            
        end
        function strings = getCompileStatements(objs,as_char)
            if nargin == 1
                as_char = false;
            end
            n_objects = length(objs);
            strings = cell(1,n_objects);
            for iObj = 1:n_objects
                obj = objs(iObj);
                safe_output_name = ['"' obj.target_file_path '"'];
                strings{iObj} = sl.cellstr.join([{obj.cmd_path} obj.params {safe_output_name}],'d',' ');
            end
            if as_char
                strings = strings{1};
            end
        end
        function object_paths = getObjectPaths(objs)
            n_objects = length(objs);
            object_paths = cell(1,n_objects);
            for iObj = 1:n_objects
                [~,file_name] = fileparts(objs(iObj).target_file_path);
                object_paths{iObj} = [file_name '.o'];
            end
        end
        function execute(objs)
            for iObj = 1:length(objs)
                cur_obj = objs(iObj);
                cmd_str = cur_obj.getCompileStatements(true);
                %If successful returns nothing ...
                %[status,result] = system(cmd_str);
                
                %[failed,result] = dos(cmd_str,'-echo');
                [failed,result] = system(cmd_str);
                
                if failed
                    %TODO: We need to clean up the objects ...
                    %TODO: Can we replace error points with links?
                    error(result)
                end
            end
        end
    end
    
end

function file_path_out = h__clean_target_file(caller_path,file_path_in)
%
%
%   Supported operations
%   --------------------
%   $cd
%   $cd/../../etc./folder/file_name.c


file_path_out = sl.dir.getAbsolutePath(file_path_in,caller_path);
return

%{
if ispc
    %convert file paths to unc
    keyboard
end

if length(file_path_in) > 5 && strcmp(file_path_in(1:5),'$this')
    file_path_out = caller_path;
    I = 6;
    %/../
    %4567
    %0123
    done = false;
    while ~done
        if length(file_path_in) > I + 3 && strcmp(file_path_in(I:I+3),'/../')
            I = I + 3;
            file_path_out = fileparts(file_path_out);
        else
            done = true;
        end
    end
    file_path_out = [file_path_out file_path_in(I:end)];
else
    file_path_out = file_path_in;
end
%}

end
