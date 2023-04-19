classdef partition
    %PARTITION set of pivots to form nsimplex and related info
    %   Detailed explanation goes here

    properties
        dimensions
        nsimp
        proj
        coeff
        adj_data
        centiles
    end

    methods
        function obj = partition(pivots,dimensions,metric)
            %PARTITION Construct an instance of this class
            %   Detailed explanation goes here
            % stupid fucking language requries default construtor to
            % initialise array
            if nargin > 0
                obj.dimensions = dimensions;
                obj.nsimp = NsimpProjection(pivots,dimensions,metric);
            end
        end

        function outliers = getOutliers(obj, data )
            % data is an array of data
            % outliers is a column vector of booleans
            projected = zeros(size(data,1),obj.dimensions);
            for i = 1 : size(data,1)
                % this may be inefficent if the same distances are calculated
                % multiple times, change to projection from distances
                projected(i,:) = obj.nsimp.project(data(i,:));
            end
            projected = projected * obj.coeff;
            lefty = projected(:,1) < obj.centiles(10);
            righty = projected(:,1) > obj.centiles(90);
            outliers = or(lefty, righty);
        end

        function centsPerObject = getCentiles(obj, data )
            % data is an array of data
            % outliers is a column vector of booleans
            projected = zeros(size(data,1),obj.dimensions);
            for i = 1 : size(data,1)
                % this may be inefficent if the same distances are calculated
                % multiple times, change to projection from distances
                projected(i,:) = obj.nsimp.project(data(i,:));
            end
            projected = projected * obj.coeff;

            %x values after rotation, size(data,1) x 1 column vector
            x_coords = projected(:,1);

            %obj.centiles is 100x1 double
            centsPerObject = sum(x_coords > obj.centiles',2);
            
        end

        function excluded = getExcluded(obj, data, threshold )
            % data is an array of data
            % outliers is a column vector of booleans
            projected = zeros(size(data,1),obj.dimensions);
            for i = 1 : size(data,1)
                % this is inefficent as the same distances are calculated
                % multiple times
                projected(i,:) = obj.nsimp.project(data(i,:));
            end

            projected = projected * obj.coeff;

            excluded = zeros(1,size(data,1));
            for i = 1 : size(data,1)
                distsToWitnesses = euc(projected(i,:),obj.adj_data);
                excluded(i) = sum(distsToWitnesses > threshold);
            end
        end

        function obj = setWitnesses(obj,witnesses)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.proj = zeros(size(witnesses,1), obj.dimensions);
            for i = 1 : size(witnesses,1)
                obj.proj(i,:) = obj.nsimp.project(witnesses(i,:));
            end
            obj.coeff = pca( obj.proj );
            obj.adj_data = obj.proj * obj.coeff;
            sorted_xs = sort( obj.adj_data(:,1));
            obj.centiles = sorted_xs(1:5:496);
        end
    end
end

