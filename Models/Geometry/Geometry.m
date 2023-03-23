classdef(Abstract) Geometry <handle
    %GEOMETRY Geometrical representation of a screen
    %   The mesh grid and polygonal vertices correspond to the projection
    %   of the screen area along the beam (z) axis. The angle that the
    %   actual screen lies at relative to the beam axis is stored
    %   separately, and is used to determine the coordinates of particles
    %   that emerge from the screen. Implicit in this method is the
    %   assumption that the thickness function produces a thickness
    %   variation on the upstream side of the screen such that the
    %   downstream side of the screen is completely flat. This aids in
    %   further calculation. The effect of this assumption is yet to be
    %   quantified, yet could be done by making the inverse assumption that
    %   the thickness varies on the downstream side, leaving the upstream
    %   flat. Likewise, the thickness does not change upon rotation - the
    %   thickness function provided is interpreted as providing the
    %   thickness evaluated in the global z direction, not in the z
    %   direction of the screen. Step changes in thickness in the y
    %   direction on a vertical screen cannot be accurately represented due
    %   to the possibility of a particle being able to leave and re-enter
    %   the material without scattering through any angle at all. Finally,
    %   another assumption implicit in the solver is that the additional
    %   path length traversed from changes in thickness and material is
    %   small due to small scattering angles and offsets.
    %   generateMesh is an abstract method that must be implemented in
    %   all geometry interfaces. It should internally set the values of

    properties(SetAccess=private)               % all lengths in metres (m)
        xv(1,:) double                          % x vertices of polygon. Regions joined by NaN
        yv(1,:) double                          % y vertices of polygon. Regions joined by NaN
        thicknessFun(1,1) function_handle = @(~,~) 1  % function of x,y to determine thickness
        xRotation(1,1) double = 0               % clockwise rotation on x axis relative to vertical screen
        gridZ(:,:) double {mustBeFinite}        % grid z points
        gridX(:,:) double {mustBeFinite}        % grid x points
        gridY(:,:) double {mustBeFinite}        % grid y points
        gridDz(:,:) double {mustBeNonnegative}  % thickness at each grid point
        gridDx(:,:) double {mustBeNonnegative}  % change in x at each grid point
        gridDy(:,:) double {mustBeNonnegative}  % change in y at each grid point
    end

    properties
        gridSize(1,2)                       % dimensions of mesh grid
    end

    methods(Access=protected)
        function obj = Geometry(xv,yv,thickness,gridSize)
            %GEOMETRY Construct an instance of this class
            %   Abstract class requires an implementation of generateMesh
            %   and the grid properties. Optional input gridSize determines
            %   the amount of grid points. thickness can either be a double
            %   for a constant thickness or a function handle that takes
            %   two matrices of equal size and outputs a matrix of doubles
            %   with the same dimensions.
            arguments
                xv(1,:) double                      % x vertices
                yv(1,:) double                      % y vertices
                thickness(1,1)                      % constant double / function of grid (x,y)
                gridSize(1,:) double {mustBeFinite} = [10,10] % dimensions of grid
            end
            % save polygon values
            obj.xv = xv;
            obj.yv = yv;

            % input validation on the thickness variable
            if class(thickness)=="double" && all(size(thickness)==[1,1])
                obj.thicknessFun = @(X,~) thickness*ones(size(X));
            elseif class(thickness) == "function_handle"
                try
                    tester = thickness(1,1);
                    if class(tester)~="double"||any(size(tester)~=[1,1])
                        throw(MException("Geometry:InvalidOutput","Output type of thickness function is not a double of same size as inputs"))
                    end
                catch me
                    if me.identifier~="Geometry:InvalidOutput"
                        throw(MException("Geometry:InvalidInputs","Thickness function provided does not accept two doubles as input"))
                    else
                        throw(me)
                    end
                end
                obj.thicknessFun = thickness;
            else
                throw(MException("Geometry:InvalidThickness","Thickness variable provided is not a (1,1) double or an appropriate function handle"))
            end
            obj.gridSize = gridSize;
            %             % create an initial mesh grid
            %             obj = obj.updateGrid();
        end

    end

    methods(Access=private)
        function obj = updateGrid(obj)
            [X,Y,Dx,Dy] = obj.generateMesh();
            obj.gridX = X;
            obj.gridY = Y;
            obj.gridZ = Y.*tan(obj.xRotation);
            obj.gridDz = obj.thicknessFun(X,Y);
            obj.gridDx = Dx;
            obj.gridDy = Dy;
        end
    end

    methods

        function set.gridSize(obj,gridSize)
            arguments
                obj(1,1) Geometry                   % instance
                gridSize(1,:) double {mustBeFinite} % new grid sizes
            end
            disp("run.set.gridSize")
            sz = size(gridSize);
            if sz(2) == 1
                gridSize = [gridSize(1) gridSize(1)];
            elseif sz(2)>2
                throw(MException("Geometry:InvalidGridDimensions","Grid size variable can only be (1,1) or (1,2)"))
            end
            obj.gridSize = gridSize;
            obj.updateGrid();
        end

        function deg = get.xRotation(obj)
            deg = obj.xRotation./(2*pi).*360;
        end

        function set.xRotation(obj,deg)
            arguments
                obj(1,1) Geometry               % instance
                deg(1,1) double {mustBeFinite}  % rotation angle in degrees
            end
            obj.xRotation = deg./360.*2.*pi;
        end

        function in = isIncident(obj,xq,yq)
            arguments(Input)
                obj(1,1) Geometry               % instance
                xq(:,:) double {mustBeFinite}   % x values to query
                yq(:,:) double {mustBeFinite}   % y values to query
            end
            arguments(Output)
                in(:,:) logical                 % logical grid, 1 where xq,yq is inside geometry
            end
            sz = size(xq);
            in = zeros(sz);
            for yVal = 1:sz(1)
                in(yVal,:) = inpolygon(xq(yVal,:),yq(yVal,:),obj.xv,obj.yv);
            end
        end

        %         function f = view(obj)
        %             f = figure;
        %             if ~(isempty(obj.gridX)||isempty(obj.Y))
        %                 if isempty(obj.Z)
        %                     zVals = zeros(size(obj.X));
        %                 else
        %                     zVals = obj.Z;
        %                 end
        %                 plot3(obj.X,obj.Y,zVals);
        %             end
        %             hold on
        %             plot3(obj.xv,obj.yv,zeros(length(obj.xv)))
        %             hold off
        %         end

    end

    methods(Abstract,Access=protected)
        [X,Y,Dx,Dy] = generateMesh(obj)
    end
    
    methods(Static,Access=protected)
        % function that may or may not be used by implementations to
        % calculate dX
        function dX = evaldX(X)
            lnX = size(X);
            lnX = lnX(2);
            if lnX<=1
                dX = 1;
            elseif lnX == 2
                dX = [(X(:,2)-X(:,1)), (X(:,2)-X(:,1))];
            else
                dX = [(X(:,2)-X(:,1)), 0.5*(X(:,3:end)-X(:,1:lnX-2)) (X(:,lnX)-X(:,lnX-1))];
            end
            dX = abs(dX);
        end
    end
end

