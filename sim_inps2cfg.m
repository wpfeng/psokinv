function sim_inps2cfg(outcfg,varargin)
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
% 
% Created by FWP, @ GU, 2013-03-01
%
%

if nargin < 1
    disp('sim_inps2cfg(output_cfg,inp1,inp2,...,inpn);');
    return
end
%
inps = cell(nargin-1,1);
%
for ni = 1:nargin-1
    % disp(varargin{ni})
    inps{ni}   = varargin{ni};
    inpids(ni) = 1;
end
%
ninps             = numel(inps);
psokinv.inps      = inps;
psokinv.inpids    = 1;
psokinv.locals    = 0;
psokinv.isinv     = zeros(1,10) + 1;
psokinv.particles = 300;
psokinv.lambda    = 3.2*10*8;
psokinv.mu        = 3.2*10*8;
psokinv.outoksar  = 'eq.simp';
psokinv.outmat    = 'eq.mat';
psokinv.psoiteration    = 20;
psokinv.sampleinfoshow  = 0;
psokinv.simpleiteration = 1000;
psokinv.restartnum      = 5;
psokinv.mcinversionloop = 100;
psokinv.convermindis    = 1;
psokinv.outdir          = 'result';
psokinv.mcinpdir        = 'perts';
psokinv.inpabc          = zeros(ninps,3);
psokinv.inpmc           = zeros(ninps,1);
psokinv.isvcm           = zeros(ninps,1);
psokinv.weight          = zeros(ninps,1) + 1;
%
%
faultintpara         = zeros(1,10,3);
psokinv.faultintpara = faultintpara;
psokinv.rake         = 0;
psokinv.faultid      = 1;
psokinv.cfg          = outcfg;
%
psokinv = psokinv_psokinv_from_inp2initoksar(psokinv);
%
psokinv.inpids = linspace(1,ninps,ninps);
psokinv_psokinv_create_cfg(psokinv);
%
