classdef Material < handle
    %MATERIAL A generic material with read-only properties
    %   This class obtains material properties from a formatted spreadsheet
    %   containing data for every material under consideration, and parses
    %   the spreadsheet to list its properties in a form MATLAB can
    %   interact with.
    %   The properties are all read only constants once the material object
    %   is initialised. Some of these properties will be vectors,
    %   corresponding to the properties of the individual elements that
    %   make up the material. Scalar properties represent the bulk behavior
    %   of the material. Units are listed next to the properties below.
    %   Properties that are not available will be saved as NaN and will
    %   throw a warning in the console
    %   To add additional properties relevent to your part of the project,
    %   extend this class, and draw additional data from the protected
    %   tabValues property (these will be as strings). You may then perform input
    %   validation on this data and save it as a property in the child
    %   class
    properties(GetAccess=protected,SetAccess=private)
        tabValues(1,:) table        % All material data from file stored as string
    end
    properties(SetAccess=private)
        A(1,:) double               % AMU
        Z(1,:) double               % Dimensionless
        I(1,:) double               % Units?
        wt(1,:) double              % Dimensionless
        rho(1,1) double             % kg m^-3
        X0(1,1) double              % kg m^-2
        Tmax(1,1) double            % K
    end
    
    methods
        function obj = Material(materialName,filename)
            %MATERIAL Construct an instance of this class
            %   If no filename is provided, the default name from Teams
            %   will be used
            if nargin == 0
                materialName = "Chromox";
                filename = "Material Properties Master.xlsx";
            elseif nargin == 1
                filename = "Material Properties Master.xlsx";
            end
            matProps = Material.materialParser(filename,materialName);
            
            obj.A = Material.str2vec(matProps.AtomicWeight);
            obj.Z = Material.str2vec(matProps.AtomicNumber);
            obj.I = Material.str2vec(matProps.MeanIonisationEnergy);
            obj.wt = Material.str2vec(matProps.WeightPercentage);
            radLength = Material.str2vec(matProps.RadiationLength);
            if length(radLength)==1 % is bulk radiation length provided?
                obj.X0 = radLength;
            else
                obj.X0 = sum(obj.wt'.*radLength); % use approximation from Particle Physics Review 2012
            end
            obj.rho = Material.str2dub(matProps.Density);
            obj.Tmax = Material.str2dub(matProps.MaximumOperatingTemperature);
        end
    end

    methods(Static,Access=protected)
        function materialProps = materialParser(filename,material)
            %MATERIALPARSER Parses the provided material spreadsheet for a
            % specific material
            %   The table is read as a string so that multiple
            %   comma-separated values can be held in each spreadsheet
            %   cell. This also allows for the inclusion of non-numeric
            %   data types in the future if needed
            %   Inputs:
            %       filename        -The file location of the spreadsheet
            %                       containing the material data. It should
            %                       be saved in Excel (xlsx,xls) format.
            %       material        -The name of the material
            %                       (case-sensitive) for the data to be
            %                       drawn from
            %   Outputs:
            %       materialProps   -Table with one row corresponding to
            %                       the properties of the provided
            %                       material. All properties are stored as
            %                       strings, so later input validation is
            %                       needed to convert these to correct data
            %                       types.
            opts = detectImportOptions(filename);
            opts = opts.setvartype("string");
            materialProps = readtable(filename,opts);
            materialProps = materialProps(materialProps.Material==material,:);
            if isempty(materialProps)
                throw(MException("Material:InvalidMaterial","The material name provided could not be found in the spreadsheet. Note that the parser is case-sensitive"))
            end
        end

        function v = str2vec(s,NegativeNaN)
            arguments
                s(1,1) string
                NegativeNaN(1,1) logical = true
            end
            %STR2VEC converts a comma-separated string into a vector of
            %doubles
            %   Inputs:
            %       s               -String with comma-separated numerical
            %                       values
            %   Outputs:
            %       v               -Double vector from the input string,
            %                       NaN if string is invalid
            try
                vc = textscan(s,'%f','Delimiter',',',"ReturnOnError",false);
                v = vc{1};
                if (any(v<0)&&NegativeNaN)
                    v = NaN;
                end
            catch me
                v = NaN;
            end
            if any(isnan(v))
                warning("Some properties are NaN")
            end
        end
        function x = str2dub(s,NegativeNaN)
            arguments
                s(1,1) string
                NegativeNaN(1,1) logical = true
            end
            try
                x = double(s);
                if (x<0&&NegativeNaN)
                    x = NaN;
                end
            catch me
                x = NaN;
            end
            if isnan(x)
                warning("Some properties are NaN")
            end
        end
    end
end

