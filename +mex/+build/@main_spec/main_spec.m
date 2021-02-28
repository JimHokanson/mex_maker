classdef main_spec
    %
    %   Class:
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
            %   compile_entries : mex.build.compiler_entry
            %   linker_entry : mex.build.linker_entry
            %
            %   
            %   
            %
            %   See Also
            %   --------
            %   mex.build.compiler_entry
            %   mex.build.linker_entry
            %   mex.compilers.gcc.getBuildSpec
            
            obj.verbose = verbose;
            obj.compile_entries = compile_entries;
            obj.linker_entry = linker_entry;
        end
        function cmds = getCompileStatments(obj)
            cmds = obj.compile_entries.getCompileStatements();
        end
        function cmd = getLinkerStatement(obj)
            cmd = obj.linker_entry.getCompileStatement();
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
            
            %Note, in one case '.o' files were missing and I think 
            %that's because the bin folder was not on the path ...
            
            %To see what's on the path in Windows:
            %paths = split(getenv('PATH'),';')
            
            
            %Cleanup
            %-------
            return_full = false;
            objects = obj.compile_entries.getObjectPaths(return_full);
            %try
            cellfun(@delete,objects);
            %catch
            %    fprintf(2,'Object cleanup failed')
            %end
        end
    end
    
end

