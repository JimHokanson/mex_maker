classdef main_spec
    %
    %   Class
    %   mex.build.main_spec
    %
    %   This is the nearly final version of how the code should be built.
    %   The entries themselves can be modified manually if needed.
    %
    %   Usage approach 1:
    %   -----------------
    %   spec = compiler.getBuildSpec()
    %   %make modifications 
    %   spec.build()
    %   
    %
    %   Usage approach 2:
    %   -----------------
    %   compiler.build %this class isn't seen by the user
    %   
    
    properties
        cmd
        verbose
        compile_entries     %   mex.build.compiler_entry
        linker_entry        %   mex.build.linker_entry
    end
    
    methods
        function obj = main_spec(verbose, compile_entries,linker_entry)
            %
            %   Inputs
            %   ------
            %   
            %
            %   See Also
            %   --------
            
            obj.verbose = verbose;
            obj.compile_entries = compile_entries;
            obj.linker_entry = linker_entry;
        end
        function cmds = getCompileStatments(obj)
            cmds = obj.compile_entries.getCompileStatements();
        end
        function build(obj)
            %
            %   TODO: Link to known build calls in the compilers (currently
            %   only gcc only)
            %   
            %   See Also
            %   --------
            %   mex.build.compiler_entry
            %   mex.build.linker_entry
            
            %TODO: On failure cleanup
            
            obj.compile_entries.execute();
            obj.linker_entry.execute();
            
            %Output file redirection ...
            %? Put in linker but build clearing support
            
            %Cleanup
            %-------
            objects = obj.compile_entries.getObjectPaths();
            cellfun(@delete,objects);
        end
    end
    
end

