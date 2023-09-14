%
%
%************** FWP Work ************************
%Developed by FWP, @GU/BJ, 2007-2014
%  contact by wanpeng.feng@hotmail.com
%************** Good Luck ***********************
%
%
%Regular the input
%
invf = 'wenchuan.inp';
[psoPS,insfile,symbols,outoksar,outmatf,fpara,lamda,...
                       myu,scamin,scamax,Inv,locals] = ...
                       sim_readconfig(invf);
%
mf   = 'zhli_eqModel.inp';
fpara= sim_oksar2SIM(mf);
%sim_fig3d(fpara,[],[],[],[],1,1);
%
f    = sim_fparaconv(fpara(1,:),0,1);
disp('Fault-1:');
[f(1) f(2) f(4) f(6)]
f    = sim_fparaconv(fpara(2,:),0,0);
disp('Fault-2:');
[f(1) f(2) f(4) f(6)]
f    = sim_fparaconv(fpara(3,:),0,0);
disp('Fault-3:');
[f(1) f(2) f(4) f(6)]
f    = sim_fparaconv(fpara(4,:),0,2);
disp('Fault-4:');
[f(1) f(2) f(4) f(6)]
