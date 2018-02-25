depends_path = 'C:\Users\RNEL\Desktop\depends22_x86\depends.exe';

file_path = 'G:\repos\matlab_git\matlab_sl_modules\plotBig_Matlab\+big_plot\private\reduce_to_width_mex.mexw6';
4
cmd = [depends_path ' /oc:tmp.txt file.dll; Import-Csv tmp.txt | Format-Table -AutoSize "' file_path '"'];

cmd = [depends_path ' /oc:tmp.txt "' file_path '"; Import-Csv tmp.txt | Format-Table -AutoSize'];

cmd = [depends_path ' /c /f:1 /oc:tmp.txt "' file_path '" ;'];

cmd = [depends_path ' /c /of:tmp.txt "' file_path '"'];


[status,result] = system(cmd);


Start-Process -PassThru calc.exe | Get-Process -Module

Start-Process -PassThru calc.exe | Get-Process -Module