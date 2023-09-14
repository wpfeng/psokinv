function sim_inp2cm(inpf,outinp)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
  %
  %
  %
  data = load(inpf);
  %
  inp = data;
  inp(:,3) = data(:,3).*(0.0562356424/(-4*3.14159265));
  inp(:,4) = -1.*cosd(data(:,5)).*sind(data(:,4));
  inp(:,5) =     sind(data(:,5)).*sind(data(:,4));
  inp(:,6) =                      cosd(data(:,4));
  inp(:,7) = sqrt(data(:,6)).*(0.0562356424/(4*3.14159265));
  %
  fid = fopen(outinp,'w');
  fprintf(fid,'%12.5f %12.5f %12.5f %12.5f %12.5f %12.5f %12.5f \n',inp');
  fclose(fid);
