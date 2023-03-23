classdef PDF
    %PDF Summary of this class goes here
    %   Detailed explanation goes here

    properties(Access=private)
        distribution(1,1) function_handle = @(~,~) 1;
    end

    methods
        function obj = PDF(distributionFunction)
            %PDF Construct an instance of this class
            %   Detailed explanation goes her
            if nargin == 0
                obj.distribution = @(~,~) 1;
            end
            obj.distribution=distributionFunction;
        end

        function [P,dX,dY,totProb] = evalGrid(obj,X,Y,dX,dY)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            assert(all(size(X)==size(Y)));
            % evaluate dX
%             dX = PDF.evaldX(X);
%             dY = PDF.evaldX(Y');
%             dY = dY';
            P = obj.getPD(X,Y).*dX.*dY;
            totProb = sum(P,'all');
            P = P./totProb;
        end


        function p = getPD(obj,x,y)
            if nargin == 2
                % assume radial distribution used
                p = obj.distribution(x);
            elseif nargin == 3
                p = obj.distribution(x,y);
            end
            if any(any(p<0))
                throw(MException("PDF:NegativeProbability","Evaluation of probability function produced some negative results"))
            end
        end
    end

    methods(Access=private,Static)
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
