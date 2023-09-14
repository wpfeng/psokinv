function sim_look(ipath)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************

switch ipath
    case 'psov1'
        str = dir('D:\mdbase\dbase_1');
    case 'psov2'
        str = dir('D:\mdbase\dbase_2');
        
    case 'raw'
        str = dir('D:\mdbase\dbase_0');
end
for ni = 1: numel(str)
    tnames = str(ni).name;
    [pa,na,ex,ve] = fileparts(tnames);
    if strcmp(ex,'.m')==1
       disp(na);
    end
end
