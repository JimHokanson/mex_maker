classdef main
    %
    %   mex.matlab.linker_settings.main
    %
    %   See Also
    %   --------
    %   mex.matlab.compile_settings.add
    %   mex.matlab.compile_settings.main
    
    properties
    end
    
    methods
%         function obj = main()
%             
%         end
        function addFlagsToCompiler(obj,compiler)
            flags = obj.getCompileFlags();
            compiler.addLinkerFlags(flags);
            compiler.addLinkerIncludeDirs(obj.getLibIncludePaths);
            compiler.addLinkerLibs(obj.getLinkLibs);
            
            %compiler.addCompileDefines(obj.defines);
            %compiler.addIncludeDirs(obj.include_dirs);
            %compiler.support_files = [compiler.support_files obj.getSupportFiles()];
        end
        function paths = getLibIncludePaths(obj)
            paths = {fullfile(matlabroot,'bin','maci64')};
            %-L"/Applications/MATLAB_R2017a.app/bin/maci64" 
        end
        function libs = getLinkLibs(obj)

            if ismac()
                libs = {'mx' 'mex' 'mat' 'c++'};
            else
                error('Not yet implemented');
            end
            
            %mac
            %-lmx -lmex -lmat -lc++ -o same_diff_mex.mexmaci64  
        end
        function flags = getCompileFlags(obj)
            
            if ismac
                mex_mac_path = fullfile(matlabroot,'extern','lib','maci64');
                
                ff1 = fullfile(mex_mac_path,'mexFunction.map');
                ff2 = fullfile(mex_mac_path,'c_exportsmexfileversion.map');
                f1 = sprintf('-Wl,-exported_symbols_list,"%s"',ff1);
                f2 = sprintf('-Wl,-exported_symbols_list,"%s"',ff2);
                
                [~,temp] = system('sw_vers -productVersion');
                mac_version = regexp(temp,'\d+\.\d+','match','once');
                mac_version_flag = sprintf('-mmacosx-version-min=%s',mac_version);
                
                flags = {...
                    '-Wl,-twolevel_namespace', ...
                    '-undefined error',...
                    '-bundle',...
                    '-O',... %optimize?
                    f1,...
                    f2,...
                    mac_version_flag};

                %-Wl,-exported_symbols_list,"/Applications/MATLAB_R2017a.app/extern/lib/maci64/mexFunction.map" 
                %-Wl,-exported_symbols_list,"/Applications/MATLAB_R2017a.app/extern/lib/maci64/c_exportsmexfileversion.map"  
            else
                error('Not yet implemented')
            end
        end
    end
    
    methods (Static)
        function obj = create()
            %For now we'll pass this class ...
            obj = mex.matlab.linker_settings.main;
        end
    end
end

%/usr/bin/xcrun 
%-sdk macosx10.12 clang 


%-arch x86_64  %I think this is xcode specific???

%-Wl,-syslibroot,/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk 
%-Wl,-exported_symbols_list,"/Applications/MATLAB_R2017a.app/extern/lib/maci64/mexFunction.map" 

%/var/folders/9q/cmrfj0px5jz8hq7lpym6vxc40000gn/T/mex_6626246672350_28289/same_diff_mex.o 
%/var/folders/9q/cmrfj0px5jz8hq7lpym6vxc40000gn/T/mex_6626246672350_28289/c_mexapi_version.o  

%-lmx -lmex -lmat -lc++ 

%This will need to be added on at the end ...
%-o same_diff_mex.mexmaci64
