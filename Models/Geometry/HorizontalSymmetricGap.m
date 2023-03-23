classdef HorizontalSymmetricGap < Geometry
    %HORIZONTALSYMMETRICGAP Summary of this class goes here
    %   Detailed explanation goes here

    properties(SetAccess=private)
        width(1,1) double {mustBePositive} = 0.01
        height(1,1) double {mustBePositive} = 0.01
        centralGap(1,1) double {mustBeNonnegative} = 0
    end

    methods
        function obj = HorizontalSymmetricGap(width,height,centralGap,thicknessFunction)
            arguments
                width(1,1) double {mustBePositive}
                height(1,1) double {mustBePositive}
                centralGap(1,1) double {mustBeNonnegative}
                thicknessFunction(1,1)
            end
            %HORIZONTALSYMMETRICGAP Construct an instance of this class
            %   Detailed explanation goes here
            leftRectX = [(-centralGap/2), (-centralGap/2-width), (-centralGap/2-width), (-centralGap/2), (-centralGap/2)];
            leftRectY = [-height/2, -height/2, height/2, height/2, -height/2];
            rightRectX = [(centralGap/2 + width), (centralGap/2), (centralGap/2), (centralGap/2 + width), (centralGap/2 + width)];
            rightRectY = leftRectY;
            xv = [leftRectX,NaN,rightRectX];
            yv = [leftRectY,NaN,rightRectY];
            obj@Geometry(xv,yv,thicknessFunction);
            obj.width = width;
            obj.height = height;
            obj.centralGap = centralGap;
        end
    end

    methods(Access=protected)
        function [X,Y,Dx,Dy] = generateMesh(obj)
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
            x1 = linspace(-obj.centralGap./2-obj.width,-obj.centralGap./2,nx+1);
            x1 = 0.5*(x1(2:end)+x1(1:end-1));
            y = linspace(-obj.height/2,obj.height./2,ny+1);
            y = 0.5*(y(2:end)+y(1:end-1));
            x2 = linspace(obj.centralGap./2,obj.width+obj.centralGap./2,nx+1);
            x2 = 0.5*(x2(2:end)+x2(1:end-1));
            [X1,~] = meshgrid(x1,y);
            [X2,Y] = meshgrid(x2,y);
            Dx1 = Geometry.evaldX(X1);
            Dx2 = Geometry.evaldX(X2);
            X = [X1 X2];
            Y = [Y Y];
            Dx = [Dx1 Dx2];
            Dy = Geometry.evaldX(Y');
            Dy = Dy';
            %             X = [x1 x2];
            %             Y = [y y];
        end
    end
end