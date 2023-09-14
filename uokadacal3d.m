function disl = uokadacal3d(faultpara,ox,oy,z,alpha,point_source)
%
% alpha is media parameter.
% Developed by Wanpeng Feng, @BJ, 2010
% Updated by Wanpeng Feng, @Ottawa, CA 2016-10 to support a Mogi-like
% inflation source
% 
DIP    = faultpara(4);
DEP    = faultpara(5)+faultpara(6)/2*sind(DIP);
strike = faultpara(3);
%disp([alpha,ox,oy,DEP,0,faultpara(7),0,faultpara(6),SD,CD,faultpara(8)]);
if point_source ~= 1
    %
    [UX,UY,UZ,UXX,UYX,UZX,UXY,UYY,UZY,UXZ,UYZ,UZZ]    =  ...
      Okada_DC3D(alpha,ox,oy,abs(z).*-1,DEP,DIP,faultpara(7)/2,faultpara(7)/2,...
      faultpara(6)/2,faultpara(6)/2,...
      faultpara(8),faultpara(9),faultpara(10));
    factor = 1;
else
    % convert to potency
    % km to m
    potency = faultpara(6) * faultpara(7) * faultpara(10) * 1e6;
    %
    [UX,UY,UZ,UXX,UYX,UZX,UXY,UYY,UZY,UXZ,UYZ,UZZ]    =  ...
    Okada_DC3D0(alpha,ox,oy,abs(z)*(-1),DEP,DIP,0,0,0,potency);
    %
    factor = 1;
end
%
% updated by Wanpeng Feng, @Ottawa, point source is ready for that...
%
% unit of UX,UY,UZ is always in meter...
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i       = sqrt(-1);
strkr   = (90-strike)*pi/180;
temp    = (UX+UY.*i).*exp(i*strkr);
disl.E  = real(temp);
disl.N  = imag(temp);
disl.V  = UZ;
disl.XX = UXX.*factor;
disl.YX = UYX.*factor;
disl.XY = UXY.*factor;
disl.YZ = UYZ.*factor;
disl.YY = UYY.*factor;
disl.ZZ = UZZ.*factor;
disl.ZY = UZY.*factor;
disl.XZ = UXZ.*factor;
disl.ZX = UZX.*factor;