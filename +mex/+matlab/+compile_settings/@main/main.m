classdef main
    %
    %   Class:
    %   mex.matlab.compile_settings.main
    %
    %   Compiler should call this code indirectly via:
    %   mex.matlab.compile_settings.add
    %
    %   See Also
    %   --------
    %   mex.matlab.linker_settings.main
    
    properties
       compiler 
    end
    
    methods
        function addFlagsToCompiler(obj,compiler)
            obj.compiler = compiler;
            compiler.addCompileFlags(obj.getCompileFlags());
            compiler.addCompileDefines(obj.getDefines());
            compiler.addCompileIncludeDirs(obj.getIncludeDirs());
            compiler.addFiles(obj.getSupportFiles());
        end
        function defines = getDefines(obj)
            
            defines = {'MATLAB_MEX_FILE','NDEBUG'};
            if ismac()
                defines = [defines {'TARGET_API_VERSION=700','USE_MEX_CMD'}];
            elseif ispc()
                defines = [defines {'MX_COMPAT_32'}];
                
            else
                error('Not yet implemented')
            end
        end
        function paths = getIncludeDirs(obj)
            
            paths = {fullfile(matlabroot,'extern','include')};
            
            if ismac
                %This is from the xocde command line tools and requires
                %running the following command in the terminal.
                %
                %   xcode-select --install
                %
                %   Alternatively, if xcode is installed, then it might
                %   be possible to point to xcode, something like
                %   /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk
                
                    cpath = '/usr/include/';
                    if ~exist(cpath,'dir')
                        error('Include path missing, xcode command line tools required, although pointing to xcode might work')
                    end
                    paths = [paths {cpath}];
            elseif ispc()
                paths = [paths {fullfile(matlabroot,'extern','lib','win64','mingw64')}];
            else
                error('Not yet implemented')
            end
        end
        function support_files = getSupportFiles(obj)
                support_files = {fullfile(matlabroot,'extern','version','c_mexapi_version.c')};
%             if ismac()
%                 
%             else
%                 support_files = {}; 
%             end
            %"C:\Program Files\MATLAB\R2016b\extern\version\c_mexapi_version.c"
            %/Applications/MATLAB_R2017a.app/extern/version/c_mexapi_version.c 
        end
        function flags = getCompileFlags(obj)
            
            %We might need to also switch on the compiler as well :/
            %or we could then bump those switches to the defaults in the 
            %compiler, removing them from this list if they are not shared
            if ismac
                [~,temp] = system('sw_vers -productVersion');
                mac_version = regexp(temp,'\d+\.\d+','match','once');
                mac_version_flag = sprintf('-mmacosx-version-min=%s',mac_version);
                flags = {...
                    '-c', ... %compile but do not link
                    '-isysroot',... %?????
                    '-fexceptions',... %allow exceptions for C code
                    '-fno-common', ... %places globals in data section of the object file
                    ...                %this may improve performance?
                    ...
                    '-fwrapv',...      %signed integers wrap
                    '-O3',...
                    mac_version_flag};
            elseif ispc()
                flags = {...
                    '-c',...
                    '-fexceptions',...
                    '-fno-omit-frame-pointer',...
                    '-std=c11',... %TODO: We should expose this to the user ...
                    '-O3'};
            else
                error('Not yet implemented')
            end
        end
%I think this is specific to xcode ...
% -arch x86_64 
        
    end
    
    methods (Static)
        function obj = create()
            %For now we'll pass this class ...
            obj = mex.matlab.compile_settings.main;
        end
    end
    
%https://gcc.gnu.org/onlinedocs/gcc/Darwin-Options.html

% Compile command
%---------------
% /usr/bin/xcrun -sdk macosx10.12 clang -c 
% -I"/Applications/MATLAB_R2017a.app/extern/include" 

%I think this is specific to xcode ...
% -arch x86_64 
%I'm skipping this
% /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk 

% /Users/jim/Documents/repos/matlab_git/matlab_sl_modules/plotBig_Matlab/+big_plot/private/same_diff_mex.c 
% -o /var/folders/9q/cmrfj0px5jz8hq7lpym6vxc40000gn/T/mex_43588753477594_28289/same_diff_mex.o
%     

%/usr/bin/xcrun -sdk macosx10.12 clang -c -DTARGET_API_VERSION=700  -DUSE_MEX_CMD   
%-DMATLAB_MEX_FILE -I"/Applications/MATLAB_R2017a.app/extern/include" 
%-I"/Applications/MATLAB_R2017a.app/simulink/include" -fno-common -arch x86_64 
%-mmacosx-version-min=10.9 -fexceptions -isysroot 
%/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk -O2 
%-fwrapv -DNDEBUG /Applications/MATLAB_R2017a.app/extern/version/c_mexapi_version.c 
%-o /var/folders/9q/cmrfj0px5jz8hq7lpym6vxc40000gn/T/mex_1555485473126_28289/c_mexapi_version.o

end

