classdef OffsetRectangle < Geometry
    %OFFSETRECTANGLE Geometry with a single rectangle offset to one side of
    %the beam
    %   Implementation of geometry that has just one rectangle offset from
    %   the origin in x and optionally y. Mesh grid generation is almost
    %   identical to that of the symmetrical two sided geometry. The offset
    %   is measured from the edge of the rectangle closest to the beam

    properties(SetAccess=private)                   % all measurements in m
        width(1,1) double {mustBePositive} = 1      % width (x dir) of rectangle
        height(1,1) double {mustBePositive} = 1     % height (y dir) of rectangle
        xOffset(1,1) double {mustBeFinite} = 0 % x offset from beam center
        yOffset(1,1) double {mustBeFinite} = 0 % y offset from beam center
    end

    methods
        function obj = OffsetRectangle(width,height,thicknessFunction,xOffset,yOffset)
            %OFFSETRECTANGLE Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                width(1,1) double {mustBePositive}
                height(1,1) double {mustBePositive}
                thicknessFunction(1,1)
                xOffset(1,1) double {mustBeFinite}
                yOffset(1,1) double {mustBeFinite} = 0;
            end
            %             if nargin == 4
            %                 yOffset = 0;
            %             end
            if xOffset == 0
                xv = [-width/2 width/2 width/2 -width/2 -width/2];
            elseif xOffset < 0
                xv = [xOffset-width xOffset xOffset xOffset-width xOffset-width];
            else
                xv = [xOffset xOffset+width xOffset+width xOffset xOffset];
            end

            if yOffset == 0
                yv = [-height/2 -height/2 height/2 height/2 -height/2];
            elseif yOffset < 0
                yv = [yOffset-height yOffset-height yOffset yOffset yOffset-height];
            else
                yv = [yOffset yOffset yOffset+height yOffset+height yOffset];
            end

            obj@Geometry(xv,yv,thicknessFunction);
            obj.width = width;
            obj.height = height;
            obj.xOffset = xOffset;
            obj.yOffset = yOffset;
        end
    end
    methods(Access=protected)
        function [X,Y,Dx,Dy] = generateMesh(obj)
            %GENERATEMESH Summary of this method goes here
            %   Detailed explanation goes here
            arguments(Input)
                obj(1,1) Geometry
            end
            arguments(Output)
                X(:,:) double {mustBeFinite}
                Y(:,:) double {mustBeFinite}
                Dx(:,:) double {mustBeNonnegative}
                Dy(:,:) double {mustBeNonnegative}
            end
            nx = obj.gridSize(1);
            ny = obj.gridSize(2);
            x = linspace(min(obj.xv),max(obj.xv),nx+1);
            x = 0.5*(x(2:end)+x(1:end-1));
            y = linspace(min(obj.yv),max(obj.yv),ny+1);
            y = 0.5*(y(2:end)+y(1:end-1));
            [X,Y] = meshgrid(x,y);
            Dx = Geometry.evaldX(X);
            Dy = Geometry.evaldX(Y');
            Dy = Dy';
            %             X = x;
            %             Y = y;
        end
    end
end