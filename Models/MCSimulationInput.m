classdef MCSimulationInput < handle
    %MCINPUT Summary of this class goes here
    %   Detailed explanation goes here

    properties(SetAccess=private)
        nSamples(1,1) uint64 = 100;
        geometry(1,1) MaterialGeometry;
        dP(:,:) double
        samples(1,:) Sample
        relativeIntensity(1,1) double;
    end

    properties(Constant)
        initialFourM(1,1) FourM {mustBeScalarOrEmpty} = FourM([7000;0;0;7000])
    end

    properties(Dependent)
        bins
    end

    methods
        function obj = MCSimulationInput(nSamples,materialGeometry,radialHaloDistribution)
            %MCINPUT Construct an instance of this class
            %   Detailed explanation goes here
            obj.nSamples = nSamples;
            obj.geometry = materialGeometry;
            [dP,~,~,totProb] = radialHaloDistribution.evalGrid(materialGeometry.geom.gridX,materialGeometry.geom.gridY,materialGeometry.geom.gridDx,materialGeometry.geom.gridDy);
            obj.dP = dP;
            obj.relativeIntensity = 1/totProb;
            % generate samples
            sz = size(obj.dP);
            cumP = zeros(sz);
            P = 0;
            % cumulative probability added up over column, then onto next
            % row, and so on
            tic
            for i = 1:prod(sz)
                deltaP = obj.dP(i);
                P = P + deltaP;
                cumP(i) = P;
            end
            toc
            % now we know cumulative probability, evaluate random
            % positions
            tic
            gridx = obj.geometry.geom.gridX;
            gridy = obj.geometry.geom.gridY;
            gridz = obj.geometry.geom.gridZ;
            gridDz = obj.geometry.geom.gridDz;
            samples = repmat(Sample(),1,nSamples);
            toc
            tic
            parfor i = 1:nSamples
                samples(i) = Sample(MCSimulationInput.initialFourM,MCSimulationInput.parGenerate(gridx,gridy,gridz,gridDz,cumP));
            end
            obj.samples=samples;
            toc
        end


        function f = view(obj)
            f = figure;

            surf(obj.geometry.geom.gridX,obj.geometry.geom.gridY,obj.bins)
            hold on
            plot(obj.geometry.geom.xv,obj.geometry.geom.yv)
            hold off
        end

        function bins = get.bins(obj)
            X = obj.geometry.geom.gridX;
            Y = obj.geometry.geom.gridY;
            bins = zeros(size(obj.dP));
            for i = 1:length(obj.samples)
                s = obj.samples(i);
                transPos = s.pos(1:2);
                [~,col] = find(transPos(1)==X,1);
                [row,~] = find(transPos(2)==Y,1);
                bins(row,col) = bins(row,col) + 1;
            end
            
            assert(sum(sum(bins))==obj.nSamples);
        end


    end

    methods(Static)
        function PointSource(nSamples,thickness,materialfun)

        end

        function pos = parGenerate(gridx,gridy,gridz,gridDz,cumP)
            z = rand;
            loopvar = true;
            j = 0;
            while loopvar
                j = j+1;
                delta = z-cumP;
                if j == 1
                    prev = 1;
                else
                    prev = delta(j-1);
                end
                if delta(j)<=0 && prev>0
                    loopvar = false;
                end
            end

            posXY = [gridx(j), gridy(j)];
            % subtracting dz so the downstream edge is flat
            posZ = gridz(j)-gridDz(j);
            pos = [posXY,posZ];
        end

    end
end

