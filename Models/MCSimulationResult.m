classdef(Abstract) MCSimulationResult
    %MCSIMULATIONRESULT Interface for all simulation models
    %   Initialising the constructor will run the simulation, and the
    %   results will be stored as output samples

    properties
        out(1,:) Sample
    end

    properties(Dependent)
        in(1,:) Sample
    end

    properties(Access=protected)
        simulationInput(1,:) MCSimulationInput {mustBeScalarOrEmpty}
    end

    methods(Access=protected) % Constructor

        function obj = MCSimulationResult(simIn)
            %MCSIMULATIONRESULT Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                simIn(1,1) MCSimulationInput
            end
            obj.simulationInput = simIn;
            obj = obj.generateOutput;
        end

    end


    methods % Getters

        function s = get.in(obj)
            if isempty(obj.simulationInput)
                s = [];
            else
                s = obj.simulationInput.samples;
            end
        end

    end


    methods % View

        function f = viewChanges(obj,f)
            arguments
                obj(1,1) MCSimulationResult
                f(1,1) = figure
            end
            nRes = length(obj.in);
            posIn = zeros(3,nRes);
            posOut = zeros(3,nRes);
            momIn = zeros(3,nRes);
            momOut = zeros(3,nRes);
            for i = 1:nRes
                sampIn = obj.in(i);
                sampOut = obj.out(i);
                posIn(:,i) = sampIn.pos;
                posOut(:,i) = sampOut.pos;
                momIn(:,i) = sampIn.fourMomentum.vec(2:4);
                momOut(:,i) = sampOut.fourMomentum.vec(2:4);
            end
            tiledlayout(f,3,3)
            nexttile
            plot(posOut(1,:)-posIn(1,:),posOut(2,:)-posIn(2,:),"r.")
            xlabel("x position deviation (m)")
            ylabel("y position deviation (m)")
            cv = cov(posOut(1,:)-posIn(1,:),posOut(2,:)-posIn(2,:));
            str = sprintf("%d",cv);
            %text(0,0,str,HorizontalAlignment="left",VerticalAlignment="bottom")
            nexttile
            plot(momOut(1,:)-momIn(1,:),momOut(2,:)-momIn(2,:),"r.")
            xlabel("x momentum deviation (MeV/c)")
            ylabel("y momentum deviation (MeV/c)")
            nexttile
            plot(posOut(1,:)-posIn(1,:),momOut(1,:)-momIn(1,:),"r.")
            xlabel("x position deviation (m)")
            ylabel("x momentum deviation (MeV/c)")
            nexttile
            plot(posOut(2,:)-posIn(2,:),momOut(2,:)-momIn(2,:),"r.")
            xlabel("y position deviation (m)")
            ylabel("y momentum deviation (MeV/c)")
            nexttile
            plot(posOut(1,:)-posIn(1,:),momOut(2,:)-momIn(2,:),"r.")
            xlabel("x position deviation (m)")
            ylabel("y momentum deviation (MeV/c)")
            nexttile
            plot(posOut(2,:)-posIn(2,:),momOut(1,:)-momIn(1,:),"r.")
            xlabel("x position deviation (m)")
            ylabel("y momentum deviation (MeV/c)")
            nexttile
            plot(posOut(1,:)-posIn(1,:),posOut(3,:)-posIn(3,:),"r.")
            xlabel("x position deviation (m)")
            ylabel("z position deviation (MeV/c)")
            nexttile
            plot(momOut(1,:)-momIn(1,:),momOut(3,:)-momIn(3,:),"r.")
            xlabel("x momentum deviation (m)")
            ylabel("z momentum deviation (MeV/c)")
        end

    end


    methods(Abstract,Access=protected)
        obj = generateOutput(obj)
    end
end

