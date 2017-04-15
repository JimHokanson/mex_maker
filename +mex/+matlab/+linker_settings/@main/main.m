classdef main
    %
    %   Class:
    %   mex.matlab.linker_settings.main
    %
    %   Compiler should call this code indirectly via:
    %   mex.matlab.compile_settings.add
    %
    %   See Also
    %   --------
    %   mex.build.linker_entry
    %   mex.matlab.compile_settings.add
    %   mex.matlab.compile_settings.main
    
    properties
        compiler
    end
    
    methods

        function addFlagsToCompiler(obj,compiler)
            obj.compiler = compiler;
            compiler.addLinkerFlags(obj.getCompileFlags());
            compiler.addLinkerIncludeDirs(obj.getLibIncludePaths);
            
            %We might need to break this up into static and dynamic libs
            %...
            compiler.addLinkerDynamicLibs(obj.getLinkLibs);
            
            %compiler.addCompileDefines(obj.defines);
            %compiler.addIncludeDirs(obj.include_dirs);
            %compiler.support_files = [compiler.support_files obj.getSupportFiles()];
        end
        function paths = getLibIncludePaths(obj)
            
            if ismac()
                paths = {fullfile(matlabroot,'bin','maci64')};
                %-L"/Applications/MATLAB_R2017a.app/bin/maci64" 
            elseif ispc()
                paths = {fullfile(matlabroot,'extern','lib','win64','mingw64')};
            else
                error('Not yet implemented')
            end
        end
        function libs = getLinkLibs(obj)

            %TODO: I think this should be split into static and dynamic
            %libs
            %
            %mx and mex => dynamic
            %others => static?
            
            
            if ismac()
                %%-lmx -lmex -lmat -lc++ -o same_diff_mex.mexmaci64 
                libs = {'mx' 'mex' 'mat' 'c++'};
            elseif ispc()
                %-llibmx -llibmex -llibmat -lm -llibmwlapack -llibmwblas
                libs = {'libmx' 'libmex' 'libmat' 'm' 'libmwlapack' 'libmwblas'};
            else
                error('Not yet implemented');
            end
            
            %mac
             
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
            elseif ispc()
                
                %TODO: We'll need to switch on the selected compiler ...
                
                mex_win_path = fullfile(matlabroot,'extern','lib','win64','mingw64');
                if ~exist(mex_win_path,'dir')
                    %http://www.mathworks.com/matlabcentral/fileexchange/52848-matlab-support-for-the-mingw-w64-c-c++-compiler-from-tdm-gcc
                   error('Support files missing for compiler, likely need to download from FEX #52848')
                end
                
                ff1 = fullfile(mex_win_path,'mexFunction.def');
                f1 = sprintf('-Wl,"%s"',ff1);
                
                flags = {...
                    '-m64', ...
                    '-Wl,--no-undefined', ...
                    '-shared', ...
                    '-s',...
                    f1};
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
