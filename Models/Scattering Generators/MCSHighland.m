classdef MCSHighland < MCSimulationResult
    %MCS Summary of this class goes here
    %   Detailed explanation goes here

    methods
        function obj = MCSHighland(simIn)
            %MCS Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                simIn(1,1) MCSimulationInput
            end
%             obj.in = simIn.samples;
%             sampleIn = simIn.samples;
%             matFun = simIn.geometry.matFun;
%             thicknessFun = simIn.geometry.geom.thicknessFun;
% 
%             sampleOut = sampleIn;
%             ns = simIn.nSamples;
%             parfor i = 1:ns
%                 sampleOut(i) = parGenerate(sampleIn(i),matFun,thicknessFun)
%             end
%             obj.out = sampleOut;
              obj = obj@MCSimulationResult(simIn);
        end


    end
    methods(Static,Access=private)
        function [dx,dy,thetaX,thetaY] = res(s,matFun,thicknessFun)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            arguments
                s(1,1) Sample
                matFun(1,1) function_handle
                thicknessFun(1,1) function_handle
            end
            % convert GeV/c in natural units to MeV/c in natural units
            p = s.fourMomentum.vec(2:4)*1000;
            m0 = s.fourMomentum.norm*1000;
            % in natural units, there is no need to multiply beta by c
            if m0==0
                beta = 1;
            else
                % beta from p = gamma*m0*beta
                gammabeta = p./m0;
                betaVec = gammabeta./sqrt(gammabeta.^2+1);
                beta = sqrt(betaVec'*betaVec);
            end
            material = matFun(s.pos(1:2));
            X0 = material.X0./material.rho;
            X = thicknessFun(s.pos(1),s.pos(2));
            sigma = 13.6./(norm(p)*beta)*sqrt(X./X0)*(1+0.088*log10(X./X0));
            % we need two random gaussian variables for each transverse
            % plane
            % deflections in each plane are independently gaussian
            % distributed
            z = randn([1,4]);
            dy = z(1)*X*sigma./sqrt(12) + z(2)*X*sigma./2;
            dx = z(3)*X*sigma./sqrt(12) + z(4)*X*sigma./2;
            thetaY = z(2)*sigma;
            thetaX = z(4)*sigma;
        end

        function so = parGenerate(si,matFun,thicknessFun)
            arguments
                si(1,1) Sample
                matFun(1,1) function_handle
                thicknessFun(1,1) function_handle
            end
            
            [dx,dy,thetaX,thetaY] = MCSHighland.res(si,matFun,thicknessFun);
            %% TODO evaluate for the case transverse momentum is not zero
            zdirfactor = 1/sqrt(tan(thetaX)^2+tan(thetaY)^2+1);
            A = [1 0 0 0;
                0 0 0 tan(thetaX)./zdirfactor;
                0 0 0 tan(thetaY)./zdirfactor
                0 0 0 1./zdirfactor];
            fourOut = FourM(A*si.fourMomentum.vec);
            posIn = si.pos;
            posOut = posIn + [dx;dy;thicknessFun(posIn(1),posIn(2))];
            so = Sample(fourOut,posOut);
        end
    end
    methods(Access=protected)
        function obj = generateOutput(obj)
            arguments
                obj(1,1) MCSimulationResult
            end
            sampleIn = obj.in;
            matFun = obj.simulationInput.geometry.matFun;
            thicknessFun = obj.simulationInput.geometry.geom.thicknessFun;
            sampleOut = sampleIn;
            ns = obj.simulationInput.nSamples;
            %% Change back to parfor
            parfor i = 1:ns
                sampleOut(i) = MCSHighland.parGenerate(sampleIn(i),matFun,thicknessFun);
            end
            obj.out = sampleOut;

        end
    end
end

