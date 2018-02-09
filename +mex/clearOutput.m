function clearOutput(file_path_or_name)
%
%   mex.clearOutput(file_path_or_name)

%   Options
%   -------
%   - relative path
%   - absolute path
%   - file_name

if exist(file_path_or_name,'file')
    clear(file_path_or_name);
end

end

