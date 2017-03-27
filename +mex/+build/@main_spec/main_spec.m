classdef main_spec
    %
    %   Class
    %   mex.build.main_spec
    
    properties
        cmd
        verbose
        compiler
        compile_entries
        linker_entry
    end
    
    methods
        function obj = main_spec(compile_entries,linker_entry)
            %
            %   Inputs
            %   ------
            %   
            %
            %   See Also
            %   --------
            
            
            obj.compile_entries = compile_entries;
            obj.linker_entry = linker_entry;
        end
        function cmds = getCompileStatments(obj)
            cmds = obj.compile_entries.getCompileStatements();
        end
        function build(obj)
            obj.compile_entries.execute();
            obj.linker_entry.execute();
            
            %Cleanup
            %-------
            objects = obj.compile_entries.getObjectPaths();
            cellfun(@delete,objects);
        end
    end
    
end

