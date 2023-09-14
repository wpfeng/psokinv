function [lon,lat] = map_afault(infile)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
 %
 %+Name:
 %    Map_afault, a maping tool to input a active fault data into the PC.
 %Input:
 %    infile, the active fault file (formatted by Feng Wanpeng);
 %Outout:
 %    lon, the longitude of the coordinate, in degree
 %    lat, the latitude of the coordinate,  in degree
 %Log:
 %    Created by Feng Wanpeng 26/02/09,fengwp@cea-igp.ac.cn
 %
 if nargin < 1
    infile = 'ChinaFault.inp';
    lon = [];
    lat = [];
    return
 end
 %
 finfo  = dir(infile);
 ninfo  = size(finfo,1);
 if ninfo ==0
    disp('Please set a corrected full data file path!');
    lat = [];
    lon = [];
    return
 end
 %
 data = load(infile);
 lat  = data(:,2);
 lon  = data(:,1);
    
    
    
