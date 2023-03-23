sigma = 0.220E-6;
haloProb = 3.98942280;
protonsPerSecond = 3.6204E18;
fun = @(x,y) 1./(sigma*sqrt(2*pi))*exp(-(x.^2+y.^2)./sigma.^2)+haloProb;
% fun = @(x,y) abs(x);
pdf1 = PDF(fun);
%%
M = Material("Chromox");
G = HorizontalSymmetricGap(0.01,0.01,0.01,0.1);
G.gridSize = [10 10];
MG = MaterialGeometry.Isotropic(G,M);
inp = MCSimulationInput(100000,MG,pdf1);
inp.view;
%%
MCS = MCSHighland(inp);
%%
MCS.viewChanges;
%%
R = 0.025;
zthetaE = incidentCalculator(MCS.out,R);
% set number of z bins
zbinLims = logspace(log10(min(zthetaE(1,:))),log10(max(zthetaE(1,:))),100);
zbinCentres = 0.5*(zbinLims(1,1:end-1)+zbinLims(1,2:end));
zdBin = zbinLims(1,1:end-1)-zbinLims(1,2:end);
% set number of theta bins
thetabinLims = linspace(-pi,pi,100);
thetabinCentres = 0.5*(thetabinLims(1,1:end-1)+thetabinLims(1,2:end));
thetadBin = thetabinLims(1,1:end-1)-thetabinLims(1,2:end);
[Z,THETA] = meshgrid(zbinCentres,thetabinCentres);
BINS = zeros(size(Z));
for i = 1:length(zthetaE(1,:))
    currentVec = zthetaE(:,i);
    z = currentVec(1);
    theta = currentVec(2);
    energy = currentVec(3);
    [~,Iz] = min(abs(z-zbinCentres));
    [~,Itheta] = min(abs(theta-thetabinCentres));
    % make this line parallelizable
    BINS(Itheta,Iz) = BINS(Itheta,Iz) + energy*1.066E-10;
end

BINS = BINS./thetadBin./zdBin./R;

figure

BINS = BINS.*protonsPerSecond./double(inp.nSamples)./inp.relativeIntensity;
surface(Z,THETA,BINS)
h = gca;
set(h,"xscale","log");





