function  [x,fval,xsimp,fvalsimp,maxtab,Loswarm] = ...
    pso_localv4(objfunc,...
    scale,...
    npoints,...
    options,...
    Simplexoptions)
%
%%%
%  objfunc       - users function for estimation of parameters
%  scale         - parameters feasible range
%  npoints       - swarm particles
%  options       - the option control paramters
%  simplexoption - the option control parameter for downhill simplex
%                   algorithm
% Created by Feng, Wanpeng, @ IGP/CEA, more details from wanpeng.feng@hotmail.com
% 1/07/2007
%          -> Completed the basic Particles Swarming Optimization.
% 23/11/2008, By Feng, Wanpeng
%          -> add a Density variable, show the convergence of current particles
% 24/11/2008, By Feng Wanpeng
%          -> Update the Global best points by the center of S points
%          historic best location
% 25/11/2008, By Feng Wanpeng
%          -> Add a rejection mechanism for any point beyond the boundary.
% 26/11/2008a, By Feng Wanpeng
%          -> Set inertia operator to descend as a linear formular with
%          iteration. w = (max_iter-i_iter)/max_iter*inertia;
% 26/11/2008b, By Feng Wanpeng
%          -> try to use exp() to update the inertia function.
% 29/11/2008, By Feng Wanpeng
%          -> add rand() into the velocity when new particle beyonds the boundary.
% 02/12/2008, By Feng, Wanpeng
%          -> use "while" loop instead of "for"
%          -> if "Density" is so little, PSO is over.
% 03/12/2008, By Feng, Wanpeng
%          -> add a convergence operator especially for Source inversion
%          -> add a keyword, partRatio, Let algarithm decide when to
%          estimate the convergence power of each dimension variable.
% 04/12/2008, By Feng, Wanpeng
%          -> add a Low and UP boundary to study operators, c1 && c2
% 05/12/2008, By Feng, Wanpeng
%          -> Change now version into a Local PSO.
% 17/12/2008, By Feng, Wanpeng
%          -> Change the program name to pso_localv1
%23/12/2008, By Feng, Wanpeng
%          -> add a new multiple peaks identification mechanism,
%          pso_localv2
%23/12/2008b,By Feng, Wanpeng
%          -> add peak identifications way to get the new global center.
%           pso_localv3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global Gbest Density WholeData Gbestswarm initialONE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ndim = size(scale,1);
if isfield(options,'iterations') == 0
    options.iterations = 20;
end
%
if isfield(options,'inertia') == 0
    options.inertia = 1.0;
end
%
if isfield(options,'correction_factor') == 0
    options.correction_factor = [1.0 1.5];
end
if isfield(options,'show') == 0
    options.show = 0;
end
if isfield(options,'vbest') == 0
    options.vbest = 10^100000;
end
if isfield(options,'DenThreshold') == 0
    options.DenThreshold = 1e-8;
end
%
if isfield(options,'inmax')==0
    options.inmax = 0;
end
%
if isfield(options,'MaxIter')==0
    options.MaxIter = 100000;
end
if isfield(options,'outmax')==0
    options.outmax =100000;
end
if isfield(options,'numcal')==0
    options.numcal = 3;
end
if isfield(options,'bigrnd')==0
    options.bigrnd = 1;
end
lowrnd = 1:ndim;
lowrnd(options.bigrnd) = [];

%%% Initial points in the n-dimension space with equal distance.
correction_factor = options.correction_factor;
swarm_size        = npoints;
numcal            = options.numcal;
vbest             = options.vbest;
show              = options.show;
DensityThreshold  = options.DenThreshold;
bigrnd            = options.bigrnd;
strind            = bigrnd;
iterations        = options.iterations;
Density           = zeros(iterations,1)+10^100;
inertia           = options.inertia;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
swarm     = zeros(swarm_size,3,ndim);
WholeData = zeros(swarm_size,iterations,ndim+1);
for ns = 1:swarm_size
    swarm(ns,1,:) = (scale(:,2)-scale(:,1)).*rand(ndim,1)+scale(:,1);%
end
%
tmpONE = swarm(end,1,:);
if numel(tmpONE(:)) == numel(initialONE(:))
    disp('Now inherit initial value...');
    swarm(end,1,:)    = initialONE(:)';
end
%
swarm(:,3,:)   = swarm(:,1,:);
swarm(:,2,:)   = swarm(:,1,:).*rand.*0.00000000001;   % initial velocity
%
%% initial
lbest       = zeros(swarm_size,1)+vbest;     % Best value so far to every particle.
Gbest       = zeros(iterations,1);           % Global best value so far.
Gbestswarm  = zeros(iterations,1,ndim);      % Save all global best points
disp(['Toltal iteration number: ' num2str(iterations)]);
%
%% Iterations
% Loop No: 1
iter     = 0;
%%%%%%%%%%% 26 June 2009, Add CDensity, Feng W.P
cx       = swarm(:,1,:);
CDensity = den_est(cx);
%%%%%%%%%%%
%iterations
% a new bug, if CDensity is enough small, by FWP, @ BJ, 2011/08/16
%
if CDensity < DensityThreshold
    CDensity = DensityThreshold;
end
while iter < iterations && CDensity >= DensityThreshold
    %
    iter = iter + 1;
    cx   = swarm(:,1,:);
    % Loop No: 2
    WholeData(:,iter,1:ndim) = cx;
    for numswarm = 1 : swarm_size
        val= feval(objfunc,swarm(numswarm,1,:));
        WholeData(numswarm,iter,ndim+1) = val;
        %
        if val < lbest(numswarm)                        % If new position is better
            swarm(numswarm,3,:) = swarm(numswarm,1,:);   % Update best x
            lbest(numswarm) = val;                   % Update the best object value
        end
        % End of No:2 Loop.
    end
    %
    [Tlbest,Tlbind]      = sort(lbest);
    Tswarm               = swarm(Tlbind,3,:);
    fval                 = Tlbest(1);         %
    x                    = Tswarm(1,1,:);     %
    Gbestswarm(iter,1,:) = x;
    Gbest(iter)          = fval;
    %
    %Simplexoptions.MaxIter = options.inmax;
    if Simplexoptions.MaxIter > 0 && options.inmax > 0
        [lb, ub]      = sim_pso2bnd(swarm,scale,numswarm);
        [tmpx tmpval] = fminsearch_band3(objfunc,x(:),lb,ub,[],Simplexoptions); %
        if tmpval < fval
            Gbest(iter)          = tmpval;
            Gbestswarm(iter,1,:) = tmpx;
            swarm(lbest == min(lbest),3,:) = tmpx;
            swarm(lbest == min(lbest),1,:) = tmpx;
        end
    end
    x    = Gbestswarm(iter,1,:);
    fval = Gbest(iter);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if iter ==1
        rawDEN = sim_swarmDEN(WholeData(:,iter,1:ndim));
        llrnd  = zeros(ndim,1)+1;
    else
        dimDEN = sim_swarmDEN(WholeData(:,iter,1:ndim));
        raiter = dimDEN./rawDEN;
        nbig   = size(bigrnd,2);
        tmpbig = zeros(nbig,1);
        %
        for nb = 1:nbig
            tmpbig(nb,1) = max(max(raiter(lowrnd)./raiter(nb)));
        end
        llrnd         = zeros(ndim,1)+1;
        llrnd(bigrnd) = 1./tmpbig.*3;
    end
    %
    glob_fac = correction_factor(1);
    loca_fac = reshape(llrnd,1,1,ndim).*correction_factor(2); 
    %
    % The "inertia" is a factor keeping the original velocity.
    % Low factor is useful to return the global minimum. The factor will be reduced
    % linearly with the iteration.
    %
    inertia  = inertia.*((iterations-iter)/iterations);
    %
    for vnum = 1:swarm_size
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        % if iter <4 || npeaks > 10
        % Use standard local pso algorithm to search parameters.
        %
        tindex  = find(Tlbind==vnum);
        reindx  = numcal;                      %
        if tindex > reindx
            Mswarm = Tswarm(1:reindx,1,:);
        else
            Mswarm = Tswarm(1:tindex,1,:);
        end
        nG     = size(Mswarm,1);
        dis    = zeros(nG,1);
        %
        for noG = 1:nG
            dis(noG) = sqrt(sum((Mswarm(noG,1,:) - swarm(vnum,1,:)).^2));
        end
        iszeros= find(dis ==0);
        if  isempty(iszeros) ==1
            MinG  = find(dis == min(dis));
        else
            MinG  = iszeros(1);
        end
        %
        % Get the nearest one of the better fit than the local one
        GSW   = Mswarm(MinG(1),1,:);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        swarm(vnum,2,:) =  inertia.*swarm(vnum,2,:)+...
            loca_fac.*rand.*(swarm(vnum,3,:)-swarm(vnum,1,:))+...
            glob_fac.*rand.*(GSW-swarm(vnum,1,:));
        %
        % Update the velocity of particles
        % End of No 3 Loop.
        % cloc - current location
        %
        cloc  = swarm(vnum,1,:) + swarm(vnum,2,:);
        ifout = sum((cloc(:) >= scale(:,2))+(cloc(:) <= scale(:,1)));
        % 
        % Infinite loop may happen sometimes due to unknown reasons.
        % Marked by Feng, W.P., @NRCan, 2015-12-02
        %
        % Add a reflection mechanism for points beyond the boundary.
        %
        while ifout >= 1
            % 
            TOUT_1                 = cloc(:) >=  scale(:,2);
            TOUT_2                 = cloc(:) <=  scale(:,1);
            %
            % Fixed a bug. By Feng W.P,2010-05-24
            %
            if sum(TOUT_1(:))>=1
                swarm(vnum,2,TOUT_1 > 0) = (swarm(vnum,2,TOUT_1 > 0)-rand).*rand ./50;%-(abs(swarm(vnum,2,TOUT_1 > 0))).*rand./40;
            end
            if sum(TOUT_2(:))>=1
                swarm(vnum,2,TOUT_2 > 0) = (swarm(vnum,2,TOUT_2 > 0)+rand).*rand ./50;%
            end
            %
            cloc   = swarm(vnum,1,:) + swarm(vnum,2,:);
            ifout  = sum((cloc(:) >= scale(:,2))+(cloc(:) <= scale(:,1)));
        end
        %
        % Update the current particle's location by current velocity
        %
        swarm(vnum, 1, :) = cloc;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [Tlbest,Tlbind]      = sort(lbest);
    Tswarm               = swarm(Tlbind,3,:);
    Gbest(iter)          = Tlbest(1);    %mean(Tlbest(1:10));
    Gbestswarm(iter,1,:) = Tswarm(1,1,:);%mean(Tswarm(1:10,1,:));
    if show ==1
        disp([iter Gbest(iter)]);
        if iter==1
            plot1=plot(iter,Gbest(iter),'--or');
        else
            set(plot1,'Ydata',Gbest(1:iter),'Xdata',linspace(1,iter,iter));
        end
        pause(0.0000000000001);
    end
    %
    % Updated by FWP, @UoG, 2013-03-01
    %
    fprintf('Iteration number: %4d %s %10.5f %s %10.5f\n', iter, '; StdDev: ', Gbest(iter),...
        '; CDensity: ',CDensity);
    %
    % End of No 1 Loop.
    %
    cx            = swarm(:,1,:);
    Density(iter) = den_est(cx);
    CDensity      = Density(iter);
    %iter = iter+1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
deta   = 20;                                           % confidence interval
strNow = WholeData(:,:,strind);
pscale = [2,2];
maxtab = [];
npeaks = [];
while isempty(npeaks) || npeaks < 1 || npeaks > 5
    [youtTMP,xoutTMP] = hist(strNow(:),20);             % get denotative dimension's histogram.
    maxtab            = peakdet(youtTMP,deta,xoutTMP);  % get peak coordinates
    npeaks            = size(maxtab,1);
    if isempty(npeaks) || npeaks < 1
        deta          = deta./pscale(1);
    end
    if npeaks > 5
        deta          = deta.*pscale(2);
    end
    
end
Loswarm           = zeros(npeaks,ndim);
%
allparticles      = reshape(WholeData(:,1:iter,:),swarm_size*iter,ndim+1);

allvalues         = allparticles(:,ndim+1);
allparticles      = allparticles(:,1:ndim);
%
[allvalues sorind]= sort(allvalues);
allparticles      = allparticles(sorind,:);
strikearr         = allparticles(:,strind);
%
for npks = 1:npeaks
    tmp    = [];
    mp_t   = [];
    lscale = 1.;
    % strikearr
    % find a bug, strikearr will be a empty, by Feng, W.P., 2011-08-16
    while isempty(tmp)==1 || isempty(mp_t)==1
        tmp     = find(strikearr >= (maxtab(npks,1)-deta*lscale/2));
        tmp_str = strikearr(tmp);
        mp_t    = find(tmp_str <= (maxtab(npks,1)+deta*lscale/2));
        lscale  = lscale*1.5;
    end
    Loswarm(npks,:) = allparticles(tmp(mp_t(1)),:);
end

%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ifval   = Gbest(iter);
%whos Loswarm
%whos Gbestswarm
tmp     = Gbestswarm(iter,1,:);
tmp     = tmp(:);
Loswarm = [Loswarm;tmp'];
npeaks  = numel(Loswarm(:,1));
%Simplexoptions.MaxIter  = options.outmax;
if Simplexoptions.MaxIter > 0 && options.outmax > 0
    lb = scale(:,1);
    ub = scale(:,2);
    %
    tmpLoswarm           = zeros(npeaks,ndim+1);
    tmpLoswarm(:,1:ndim) = Loswarm;
    %
    % Start Simplex algorith for the further search...
    % We will start the package for different points...
    %
    for npks = 1:npeaks
        ix            = Loswarm(npks,:);
        tmpx          = fminsearch_band3(objfunc,ix(:),lb(:),ub(:),[],Simplexoptions); %
        [tmpx tmpval] = fminsearch_band3(objfunc,tmpx,lb(:),ub(:),[],Simplexoptions); %
        tmpx          = tmpx(:);
        tmpLoswarm(npks,:) = [tmpx' tmpval];
        if tmpval < ifval
            Gbest(iter+1)          = tmpval;
            Gbestswarm(iter+1,1,:) = reshape(tmpx(:),1,1,ndim);
        else
            Gbest(iter+1)          = Gbest(iter);
            Gbestswarm(iter+1,1,:) = Gbestswarm(iter,1,:);
        end
        iter   = iter+1;
        ifval = Gbest(iter);
        disp(['Peak NO:' num2str(npks) '. Stddev: ' num2str(tmpval)]);
    end
    Loswarm   = tmpLoswarm;
    xsimp     = Gbestswarm(iter,1,:);
    fvalsimp  = Gbest(iter);
    if show ==1
        set(plot1,'Ydata',Gbest(1:iter),'Xdata',linspace(1,iter,iter));
    end
else
    xsimp    = Gbestswarm(iter,1,:);
    fvalsimp = Gbest(iter);
    disp(['The non-linear Inversion has finished. The stddev is ' num2str(fvalsimp) '.']);
    disp('It is time to check your results!');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [lb,ub] = sim_pso2bnd(swarm,scale,no)
%
%nps  = size(swarm,1);
ndim = size(swarm,3);
lb   = zeros(ndim,1);
ub   = lb;
for i=1:ndim
    noda = swarm(:,1,ndim);
    noda = unique(noda(:));
    numr = length(noda);
    inde = find(noda==swarm(no,1,ndim));
    if inde==1
        lb(ndim) = scale(ndim,1);
        ub(ndim) = (noda(inde)+noda(inde+1))/2;
    else if inde== numr
            lb(ndim) = (noda(inde)+noda(inde-1))/2;
            ub(ndim) = scale(ndim,2);
        else
            lb(ndim) = (noda(inde)+noda(inde-1))/2;
            ub(ndim) = (noda(inde)+noda(inde+1))/2;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  D = den_est(particles)
% Purpose:
%     Calculate the D-Power of the all points.
%     It can show the paritcles' convergence.
% particles is a s*1*n
% s is particles number
% n is the dimensions of problem
% L is the largest distance in the problem space.
% dn_est, a function for density of particles
s   = size(particles,1);
mpd = mean(particles);
D   = 0;
%
for ns = 1:s
    D  = D+sqrt(sum((particles(ns,1,:)-mpd(1,1,:)).^2));
end
D   = D/s;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



