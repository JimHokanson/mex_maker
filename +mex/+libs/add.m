function add(lib_name,compiler)
%
%   mex.libs.add(lib_name,compiler)

switch lib_name
    case 'openmp'
        mex.libs.openmp(compiler)
    otherwise
        error('Library name not recognized')
end
        

end