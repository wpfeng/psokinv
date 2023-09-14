function cinf = sim_remcinpf(cinf,mcdir,fismc,noloops)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
  %
  % Developed by fWP, @IGP/CEA & GU, 2009/05/01
  % Improved by FWP, @GU, 2014-05-18
  %
  %
  nf = numel(cinf);
  t  = cell(1,1);
  %
  for ni=1:nf
      if fismc(ni)==1
        fname = cinf{ni};
        [~,bname,postfix] = fileparts(fname{1});
        fname = fullfile(mcdir{1}{1},[bname '_MC_' num2str(noloops) postfix]);
        t{1}  = fname;
        cinf{ni} = t;
      end
  end
