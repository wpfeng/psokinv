function  [x,y] = ll2utm(Lat,Lon,zone)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
% -------------------------------------------------------------------------
% [x,y,utmzone] = deg2utm(Lat,Lon)
%
% Description: Function to convert lat/lon vectors into UTM coordinates (WGS84).
% Some code has been extracted from UTM.m function by Gabriel Ruiz Martinez.
%
% Inputs:
%    Lat: Latitude  vector.   Degrees.  +ddd.ddddd  WGS84
%    Lon: Longitude vector.  Degrees.  +ddd.ddddd  WGS84
%
% Outputs:
%    x, y , utmzone.   See example
%
% Example 1:
%    Lat=[40.3154333; 46.283900; 37.577833; 28.645650; 38.855550; 25.061783];
%    Lon=[-3.4857166; 7.8012333; -119.95525; -17.759533; -94.7990166; 121.640266];
%    [x,y,utmzone] = deg2utm(Lat,Lon);
%    fprintf('%7.0f ',x)
%       458731  407653  239027  230253  343898  362850
%    fprintf('%7.0f ',y)
%      4462881 5126290 4163083 3171843 4302285 2772478
%    utmzone =
%       30 T
%       32 T
%       11 S
%       28 R
%       15 S
%       51 R
%
% Example 2: If you have Lat/Lon coordinates in Degrees, Minutes and Seconds
%    LatDMS=[40 18 55.56; 46 17 2.04];
%    LonDMS=[-3 29  8.58;  7 48 4.44];
%    Lat=dms2deg(mat2dms(LatDMS)); %convert into degrees
%    Lon=dms2deg(mat2dms(LonDMS)); %convert into degrees
%    [x,y,utmzone] = deg2utm(Lat,Lon)
%
% Author: 
%   Rafael Palacios
%   Universidad Pontificia Comillas
%   Madrid, Spain
% Version: Apr/06, Jun/06, Aug/06, Aug/06
% Aug/06: fixed a problem (found by Rodolphe Dewarrat) related to southern 
%    hemisphere coordinates. 
% Aug/06: corrected m-Lint warnings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% June 2009, Feng W.P 
% Change the program into ll2utm, now the code can process a matrix...
%
%-------------------------------------------------------------------------
format long
la = Lat;
lo = Lon;
if nargin <3||isempty(zone)==1
   %Huso = fix(mean(lo(:))+180)/6+1;
   Huso = fix( ( mean(lo(:)) / 6 ) + 31);
else
   tmp  = textscan(zone,'%f %s');
   Huso = tmp{1};
end
sa   = 6378137.000000;
sb   = 6356752.314245;
pi   = 3.1415926535897932;
%
e2         = (((sa^2)-( sb ^ 2 )).^ 0.5)./sb;
e2cuadrada = e2^2;
c          = (sa^ 2)./sb;
%
lat        = la.* (pi./180 );
lon        = lo.* (pi./180 );
S          = ((Huso .* 6 )-183 );
deltaS     = lon - (S .*( pi ./180 ) );
a          = cos(lat).* sin(deltaS);
epsilon    = 0.5.* log((1 + a)./(1- a));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nu   = atan(tan(lat)./cos(deltaS)) - lat;
v    = (c./((1+ (e2cuadrada .* (cos(lat)).^2))).^0.5 ) .* 0.9996;
ta   = (e2cuadrada ./2) .* epsilon .^ 2 .* ( cos(lat) ) .^ 2;
a1   = sin(2 .* lat );
a2   = a1.*(cos(lat)).^ 2;
j2   = lat+(a1./2);
j4   = ((3.*j2 ) + a2) ./ 4;
j6   = ((5.*j4 ) + (a2.* ( cos(lat) ) .^ 2) ) ./ 3;
alfa = (3./4 ) .* e2cuadrada;
beta = (5./3) .* alfa.^2;
gama = (35 ./27) .* alfa.^3;
Bm   = 0.9996.*c .*(lat- alfa .*j2+beta .*j4-gama .* j6 );
x    = epsilon .* v .*(1+(ta ./ 3))+ 500000;
y    = nu .* v .* ( 1 + ta ) + Bm;
y    = (y < 0).*(9999999+y)+(y >=0).*y;


