function result = getDependencies(file_path)
%x 
%
%   output = mex.file.getDependencies(file_path)

%This is for mac
cmd = sprintf('otool -L "%s"',file_path);
[~,result] = system(cmd);

%depends.exe for Windows
%Any .NET options????

end

