classdef compiler_entry < handle
    %
    %   Class
    %   mex.build.compiler_entry
    
    properties
        compiler
        verbose
        cmd_path
        target_file_path
        params
    end
    
    methods
        function obj = compiler_entry(target_file_path,compiler)
            %
            %   obj = mex.build.compiler_entry(target_file, compiler)
            
            
            obj.compiler = compiler; %saving for reference
            obj.verbose = compiler.verbose;
            obj.cmd_path = compiler.compiler_path;
            caller_path = compiler.caller_path;
            obj.target_file_path = h__clean_target_file(caller_path,target_file_path);
            
            
            params = compiler.compile_flags;
            
            defines = compiler.compile_defines;
            params = [params cellfun(@(x) ['-D' x],defines,'un',0)];
            
            includes = compiler.compile_include_dirs;
            params = [params cellfun(@(x) ['-I"' x '"'],includes,'un',0)];
            
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
                %This should be a util function
                safe_output_name = ['"' obj.target_file_path '"'];
                safe_cmd_path = ['"' obj.cmd_path '"'];
                %strings{iObj} = mex.sl.cellstr.join([{obj.cmd_path} obj.params {safe_output_name}],'d',' ');
                [~,file_name] = fileparts(obj.target_file_path);
                %strings{iObj} = mex.sl.cellstr.join([{safe_cmd_path} obj.params {safe_output_name}],'d',' ');
                
                output_command = sprintf('-o "%s.o"',file_name);
                strings{iObj} = mex.sl.cellstr.join([{safe_cmd_path} obj.params {safe_output_name} {output_command}],'d',' ');
            end
            if as_char
                strings = strings{1};
            end
        end
        function object_paths = getObjectPaths(objs,return_full)
            
            if nargin == 1
                return_full = false;
            end
            %Is it OK to 
            n_objects = length(objs);
            object_paths = cell(1,n_objects);
            for iObj = 1:n_objects
                if return_full
                    [file_root,file_name] = fileparts(objs(iObj).target_file_path);
                    object_paths{iObj} = fullfile(file_root,[file_name '.o']);
                else
                    [~,file_name] = fileparts(objs(iObj).target_file_path);
                    object_paths{iObj} = [file_name '.o'];
                end
                
            end
        end
        function execute(objs)
            %
            %
            %   Called by:
            %   mex.build.main_spec
            
            for iObj = 1:length(objs)
                cur_obj = objs(iObj);
                cmd_str = cur_obj.getCompileStatements(true);
                %If successful returns nothing ...
                %[status,result] = system(cmd_str);
                
                %[failed,result] = dos(cmd_str,'-echo');
                if cur_obj.verbose
                    fprintf('%s\n',cmd_str);
                end
                [failed,result] = system(cmd_str);
                
                if failed
                    %not yet implemented, very close to being done
                    %just needs testing
                    
%                     try
%                         for i2 = 1:iObj
%                            object_path = getObjectPaths(objs(i2),return_full);
%                            delete(object_path)
%                         end
%                     catch ME
%                         fprintf(2,'Failed to delete object files\n')
%                     end
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
%   .
%   ./../../etc./folder/file_name.c

file_path_out = mex.sl.dir.getAbsolutePath(file_path_in,caller_path);

end

