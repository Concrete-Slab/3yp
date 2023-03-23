classdef MaterialGeometry
    %MATERIALGEOMETRY Provides co
    %   Detailed explanation goes here
    
    properties(SetAccess=private)
        geom(1,1) Geometry = OffsetRectangle(1,1,1,1)
        matFun(1,1) function_handle = @(~,~) Material("Chromox")
        matMesh(:,:) Material = Material("Chromox")
    end
    
    methods
        function obj = MaterialGeometry(geometry,materialFunction)
            %MATERIALGEOMETRY Construct an instance of this class
            %   Detailed explanation goes here
            if nargin==0
                obj.geom = OffsetRectangle(1,1,1,1);
                obj.matFun = @(~,~) Material("Chromox");
                obj.matMesh = Material("Chromox");
            else
                obj.geom = geometry;
                obj.matFun = materialFunction;
                obj.matMesh = obj.materialAt(geometry.gridX,geometry.gridY);
            end
        end
        
        function m = materialAt(obj,x,y)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            arguments(Input)
                obj(1,1) MaterialGeometry
                x(:,:) double {mustBeFinite}
                y(:,:) double {mustBeFinite}
            end
            arguments(Output)
                m(:,:) Material
            end
            assert(all(size(x)==size(y)));
            sz = size(x);
            for i = sz(1):-1:1
                for j = sz(2):-1:1
                    m(i,j) = obj.matFun(x(i,j),y(i,j));
                end
            end
            if any(class(m)~="Material")
                throw(MException("MaterialGeometry:NotAMaterial","The provided material function does not return a Material object at the specified point(s)"))
            elseif any(size(m)~=size(x))
                throw(MException("MaterialGeometry:MatMatrixSize","The provided material function does not produce a grid of materials with the same dimensions as the input grid"))
            end
        end
    end

    methods(Static)
        function obj = Isotropic(geometry,material)
            arguments(Input)
                geometry(1,1) Geometry
                material(1,1) Material
            end
            arguments(Output)
                obj(1,1) MaterialGeometry
            end
            materialFunction = @(~,~) material;
            obj = MaterialGeometry(geometry,materialFunction);
        end
    end
end

