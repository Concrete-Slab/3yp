classdef Sample
    %SAMPLE Summary of this class goes here
    %   Detailed explanation goes here

    properties(SetAccess=private)
        fourMomentum(1,1) FourM         % Four momentum of the proton, GeV/c, natural units
        pos(3,1) double                 % x,y transverse, z=0 at initial plane of screen in lab frame, metres
        relFrameVelocity(3,1) double    % relative velocity of the current frame of reference to the lab frame
    end

    methods
        function obj = Sample(fourMomentum,position,relFrameVelocity)
            %SAMPLE Construct an instance of this class
            %   Detailed explanation goes here
            arguments
                fourMomentum(1,1) FourM = FourM([7000;0;0;7000])
                position(3,1) double = zeros(3,1)
                relFrameVelocity(3,1) double = zeros(3,1)
            end
            switch nargin
                case 0
                    obj.fourMomentum = FourM([7000;0;0;7000]); % assume negligible rest mass, natural units
                    obj.pos = zeros(3,1);
                    obj.relFrameVelocity = zeros(3,1);
                case 1
                    obj.fourMomentum = fourMomentum;
                    obj.pos = zeros(3,1);
                    obj.relFrameVelocity = zeros(3,1);
                case 2
                    obj.fourMomentum = fourMomentum;
                    obj.pos = position;
                    obj.relFrameVelocity = zeros(3,1);
                case 3
                    obj.fourMomentum = fourMomentum;
                    obj.pos = position;
                    obj.relFrameVelocity = relFrameVelocity;
            end
        end

        function newFrame(obj,newFrameVelocity)
            % transform to a new FOR with frameVelocity in z direction
        end
    end
end

