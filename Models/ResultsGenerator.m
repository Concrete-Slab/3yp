classdef(Abstract) ResultsGenerator
    %RESULTSGENERATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Input(1,:) Sample = [];
        Output(1,:) Sample = [];
    end
    
    methods
        function obj = ResultsGenerator(samples)
            %RESULTSGENERATOR Construct an instance of this class
            %   Detailed explanation goes here
            obj.Input = samples;
            
            for i = length(samples):-1:1
                obj.Output(i) = Sample
            end

        end
       
    end

    methods(Abstract,Access = private)
        [transverseDisplacement,] = model(obj)
    end
end

