function add(compiler)
%
%   mex.matlab.compile_settings.add(compiler)
%
%   See Also
%   --------
%   mex.matlab.compile_settings.main
%   mex.matlab.linker_settings.main

compile_settings = mex.matlab.compile_settings.main.create();
compile_settings.addFlagsToCompiler(compiler);
linker_settings = mex.matlab.linker_settings.main.create();
linker_settings.addFlagsToCompiler(compiler);

end