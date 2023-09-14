function out = sim_inp2cov_sub(indata,inpdata,cx,cy,outd,ni,lamda)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
    %
    %fid = fopen('tmp.list','u');
    X = outd((ni-1)*5+1:(ni-1)*5+5,1);
    Y = outd((ni-1)*5+1:(ni-1)*5+5,2);
    xr=[min(X(:)),max(X(:))];
    yr=[min(Y(:)),max(Y(:))];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %cdata = sim_subtract(unwfile,xr,yr);
    %imagesc(cx-xr(1));
    ind1 = abs((cx-xr(1)))==min(abs((cx(:)-xr(1))));
    ind2 = abs((cy-yr(2)))==min(abs((cy(:)-yr(2))));
    ind  = ind1.*ind2;
    [r1,c1] = find(ind==1);
    ind1 = abs(cx-xr(2))==min(abs(cx(:)-xr(2)));
    ind2 = abs(cy-yr(1))==min(abs(cy(:)-yr(1)));
    ind  = ind1.*ind2;
    [r2,c2] = find(ind==1);
    %whos indata
    minr    = (r1>=r2)*r2+(r1<r2)*r1;
    maxr    = (r1>=r2)*r1+(r1<r2)*r2;
    minc    = (c1>=c2)*c2+(c1<c2)*c1;
    maxc    = (c1>=c2)*c1+(c1<c2)*c2;
    cdata   = indata(minr:maxr,minc:maxc);
    dist    = sqrt((inpdata(:,1)-mean(X(:))).^2+...
                   (inpdata(:,2)-mean(Y(:))).^2);
    index   = find(dist == min(dist(:)));
    cov     = std(cdata(cdata(:)~=0).*lamda./(4*pi));
    area    = sqrt((xr(2)-xr(1)).^2 + (yr(2)-yr(1)).^2);
    out     = [index,cov,area];
    %fprintf(fid,'%f %f\n',index,cov);
    %fclose(fid);
    %disp([index,mean(cdata(cdata(:)~=0)) inpdata(index,7)]);
