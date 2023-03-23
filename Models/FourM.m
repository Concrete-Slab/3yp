classdef FourM
    %FOURM A Minkowski space four-vector
    %   Class representing any relativistic four-vector. The first entry is
    %   treated differently to the remaining 3 spatial entries, so as to
    %   adhere to the rules of Minkowski space, which describes special
    %   relativity in a convenient vectorised form. The vector can be acted
    %   upon by a variety of methods:
    %   norm computes the Minkowski signature of the vector, which
    %   subtracts the square of the spatial component from the time/energy component
    
    properties(SetAccess = private)
        vec(4,1) double = [0;0;0;0];        %GeV/c
    end

    properties(Constant)
        metric(4,4) double = [1 0 0 0;0 -1 0 0;0 0 -1 0;0 0 0 -1];
    end
    
    methods
        function obj = FourM(p)
            %FOURM Construct an instance of this FourM
            %   Detailed explanation goes here
            if nargin>0
                obj.vec = p;
            end
        end
        
        function outputArg = norm(obj)
            %NORM Minkowski metric signature as an inner product
            %   For all timelike vectors, this is a real quantity, equal to
            %   the rest energy of the particle in cgs units, or simply
            %   the rest mass in natural units. It is subsequently
            %   invariant to Lorentz transformations
            outputArg = sqrt(obj.vec'*FourM.metric*obj.vec);
        end

        function q = mtimes(obj1,obj2)
            q = obj1.vec'*FourM.metric*obj2.vec;
        end

        function obj = trL(obj,relBeta)
            gamma = 1/sqrt(1-relBeta.^2);
            tMat = [gamma -relBeta*gamma 0 0;-relBeta*gamma gamma 0 0; 0 0 1 0; 0 0 0 1];
            obj.vec = tMat*obj.vec;
        end
    end
end

