function [cdata,cx,cy,hdinfo,roi] = sim_readroi(rawfile,bands,intervaltype,...
                                                 byteorder,roi,type,noband)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
                                            
 %
 %
 % Usage:
 %       [cdata,cx,cy,hdinfo] = sim_readroi(rawfile,bands,offs,intervaltype,...
 %                                           byteorder)
 % Purpose:
 %      Working to input Roipac data unw data with the header info of .rsc.
 % Input:
 % 
 % Created by Feng, W.P, 2010/09/01
 %
 if exist(rawfile,'file')==0
     disp('[cdata,cx,cy,hdinfo] = sim_readroi(rawfile,bands,offs,intervaltype,byteorder)');
     disp('The file does not exist.');
     return
 end
 if nargin < 2 || isempty(bands) == 1
     bands   = 1;
 end
%  if nargin < 3
%      offs    = 0;
%  end
 if nargin < 3 || isempty(intervaltype) == 1
     intervaltype = 'bil';
 end
 if nargin < 4 || isempty(byteorder) == 1
     byteorder    = 'ieee-le';
 end
 if nargin < 6 || isempty(type) == 1
     type = 'float32';
 end
 if nargin < 7 || isempty(noband) == 1
     noband = bands;
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 rscfile = [rawfile,'.rsc'];
 hdinfo  = sim_roirsc(rscfile);
 wid     = double(hdinfo.width);
 len     = double(hdinfo.file_length);
 %%%% ROI makes function.
 lons    = [hdinfo.x_first, hdinfo.x_first + (wid-1) * hdinfo.x_step];
 lats    = [hdinfo.y_first+len* hdinfo.y_step,    hdinfo.y_first];
 if lats(1) > lats(2)
    l1 = lats(1);
    lats(1) = lats(2);
    lats(2) = l1;
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if nargin < 5 || isempty(roi) == 1
    roi = [lons lats];
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % working for offsests
 if roi(1) > lons(2) || roi(2) < lons(1) || roi(3) > lats(2) ||roi(4) < lats(1)
    disp('Your roi is beyond the region of data. Please check the input...');
    cdata  = [];
    cx     = [];
    cy     = [];
    hdinfo = [];
    return
 else
    x0 = floor((roi(1)-lons(1))/hdinfo.x_step) + 1;
    x1 = ceil((roi(2)-lons(1))/hdinfo.x_step) + 1;
    y0 = floor((roi(3)-lats(1))/abs(hdinfo.y_step)) + 1;
    y1 = ceil((roi(4)-lats(1))/abs(hdinfo.y_step)) + 1;
    %disp([x0,x1,y0,y1]);
    
    x0 = (x0 <=0 )*1 + (x0 >0) *x0;
    y0 = (y0 <=0 )*1 + (y0 >0) *y0;
    x1 = (x1 >= wid)*wid + (x1 < wid)* x1;
    y1 = (y1 >= len)*len + (y1 < len)* y1;
    y1   = len-y1+1;
    tmp  = len-y0+1;
    y0   = y1;
    y1   = tmp;
    cwid = x1 - x0 +1;
    clen = y1 - y0 +1;
    roi1 = (x0-1)*hdinfo.x_step + hdinfo.x_first;
    roi2 = cwid*hdinfo.x_step + roi1;
    roi3 = (y0-1)*hdinfo.y_step + hdinfo.y_first;
    roi4 = clen*hdinfo.y_step + roi3;
    roi  = [roi1,roi2,roi4,roi3];
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %disp([wid,len,bands]);
 cdata   = multibandread(rawfile,[len,wid,bands],type,0,...
                        intervaltype,byteorder);
 cdata   = cdata(:,:,noband);
 cdata   = cdata(:,:);
 %whos cdata
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 xfirst  = double(hdinfo.x_first);
 yfirst  = double(hdinfo.y_first);
 xstep   = double(hdinfo.x_step);
 ystep   = double(hdinfo.y_step);
 xend    = (wid-1)*xstep+xfirst;
 yend    = (len-1)*ystep+yfirst;
 [cx,cy] = meshgrid(xfirst:xstep:xend,yfirst:ystep:yend);
 %disp([x0,x1,y0,y1]);
 cx      = cx(y0:y1,x0:x1);
 cy      = cy(y0:y1,x0:x1);
 cdata   = cdata(y0:y1,x0:x1);
