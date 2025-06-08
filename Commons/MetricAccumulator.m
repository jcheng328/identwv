classdef MetricAccumulator < handle
    % METRICACCUMULATOR - Accumulates metrics during identification
    %
    % accumulator = MetricAccumulator()
    % This class serves as an accumulator that collects and stores 
    % metrics over the course of identification. It provides methods 
    % to add metrics and compute averages.
    %
    % Example usage:
    %   accumulator = MetricAccumulator();
    %   accumulator.addMetric('accuracy', 0.85);
    %   accumulator.addMetric('loss', 0.35);
    %   avg_acc = accumulator.getAverage('accuracy');
    %
    % Properties:
    %   metrics - A structure storing arrays of accumulated metrics
    
    properties
        metrics % Structure to store accumulated metrics
        buffer % Cache
    end
    methods
        function obj = MetricAccumulator()
            % METRICACCUMULATOR - Constructs an empty accumulator
            %
            % Constructor initializes an empty structure to store metrics.
            obj.metrics = struct();
            obj.buffer = {};
        end
        function addMetric(obj, metricName, metricValue)
            % ADDMETRIC - Adds one or more metrics to the accumulator
            %
            % obj.addMetric(metricName1, metricValue1, metricName2, metricValue2, ...)
            % Adds multiple metric values to the accumulator under the given name.
            %
            % Inputs:
            %   metricName  - The name of the metric (e.g., 'accuracy', 'loss')
            %   metricValue - The value of the metric to accumulate
            %
            % Example:
            %   obj.addMetric('accuracy', 0.85);
            arguments
                obj
            end
            arguments (Repeating)
                metricName
                metricValue
            end
            for i = 1:numel(metricValue)
                if ~isfield(obj.metrics, metricName{i})
                    obj.metrics.(metricName{i}) = [];  % Initialize if not present
                end
                obj.metrics.(metricName{i})(end+1) = metricValue{i};  % Append value
            end
        end

        function avgMetric = getAverage(obj, metricName)
            % GETAVERAGE - Returns the average of a metric
            %
            % avgMetric = obj.getAverage(metricName)
            % Returns the average value of the accumulated metric values.
            %
            % Inputs:
            %   metricName - The name of the metric to compute the average for
            %
            % Outputs:
            %   avgMetric  - The average of the accumulated metric values
            %
            % Example:
            %   avg_acc = obj.getAverage('accuracy');
            
            if isfield(obj.metrics, metricName)
                avgMetric = mean(obj.metrics.(metricName));  % Calculate average
            else
                error('Metric "%s" not found.', metricName);
            end
        end

        function stdMetric = getStdDev(obj, metricName)
            % GETSTDDEV - Returns the standard deviation of a metric
            %
            % stdMetric = obj.getStdDev(metricName)
            % Returns the standard deviation of the accumulated metric values.
            %
            % Inputs:
            %   metricName - The name of the metric to compute the standard deviation for
            %
            % Outputs:
            %   stdMetric  - The standard deviation of the accumulated metric values
            %
            % Example:
            %   std_acc = obj.getStdDev('accuracy');
            
            if isfield(obj.metrics, metricName)
                stdMetric = std(obj.metrics.(metricName));  % Calculate standard deviation
            else
                error('Metric "%s" not found.', metricName);
            end
        end
        function stats = getAllStats(obj)
            % GETALLSTATS - Returns the average and standard deviation for all metrics
            %
            % stats = obj.getAllStats()
            % Returns a structure with averages and standard deviations for
            % each metric stored in the accumulator.
            %
            % Outputs:
            %   stats - A structure containing average and standard deviation
            %           for all accumulated metrics.
            %
            % Example:
            %   stats = obj.getAllStats();
            %   avg_accuracy = stats.accuracy.average;
            %   std_accuracy = stats.accuracy.stdDev;
            
            metricNames = fieldnames(obj.metrics);
            stats = struct();
            
            for i = 1:length(metricNames)
                name = metricNames{i};
                stats.(name).average = mean(obj.metrics.(name));  % Average for each metric
                stats.(name).stdDev = std(obj.metrics.(name));    % Std Dev for each metric
            end
        end
        function stats = getAllStatsAndClear(obj)
            % GETALLSTATSANDCLEAR - Returns stats and clears the accumulator
            %
            % stats = obj.getAllStatsAndClear()
            % Returns the average and standard deviation for all metrics and 
            % then clears the accumulator (resets all stored metrics).
            %
            % Outputs:
            %   stats - A structure containing average and standard deviation
            %           for all accumulated metrics.
            %
            % Example:
            %   stats = obj.getAllStatsAndClear();
            
            stats = obj.getAllStats();  % Get all stats (average and std)
            obj.clear();                % Clear the accumulator
        end
        function [str]=printAllStats(obj, indexValue)
            % PRINTALLSTATS - Returns a string that print stats
            %
            % Syntax:
            %   obj.printAllStats()
            %   Print the average with standard deviation (e.g. avg+-std)
            %   for all metrics.
            %
            % Inputs:
            %   indexValue - Index value 
            %
            % Outputs:
            %   str - a string that includes the metrics.
            arguments
                obj
                indexValue = []
            end
            metricNames = fieldnames(obj.metrics);
            str = sprintf('%-10s', sprintf('%0.2f', indexValue));
            for i = 1:length(metricNames)
                name = metricNames{i};
                average = mean(obj.metrics.(name));  % Average for each metric
                stdDev = std(obj.metrics.(name));    % Std Dev for each metric
                entry = sprintf('%0.2f%s%0.2f,', average, char(177), stdDev);
                str = [str, sprintf('%-18s', entry)];
            end
        end
        function str=printMetricNames(obj, indexName)
            arguments
                obj
                indexName = []
            end
            metricNames = fieldnames(obj.metrics);
            str = sprintf('%-18s', indexName, metricNames{:});
        end
        function str=printAllStatsAndClear(obj, indexValue)

            % GETALLSTATSANDCLEAR - Returns stats and clears the accumulator
            %
            % stats = obj.printAllStatsAndClear([], true)
            % Returns the average and standard deviation for all metrics and 
            % then clears the accumulator (resets all stored metrics).
            %
            % Inputs:
            %   indexValue - index value.
            %
            % Outputs:
            %   str - a line of stats.
            %
            % Example:
            %   stats = obj.printAllStatsAndClear();
            
            arguments
                obj
                indexValue = []
            end
            str = obj.printAllStats(indexValue);  % Print all stats (average and std)
            obj.clear();                % Clear the accumulator
        end
        function bufferAllStatsAndClear(obj, indexName, indexValue)
            arguments
                obj
                indexName = []
                indexValue = []
            end
            if isempty(obj.buffer)
                obj.buffer = [obj.buffer; obj.printMetricNames(indexName)];
            end
            obj.buffer = [obj.buffer; obj.printAllStatsAndClear(indexValue)];
        end
        function [buffer] = flushBuffer(obj)
            buffer = obj.buffer;
            obj.buffer = {};
        end
        function clear(obj)
            % CLEAR - Resets the accumulator
            %
            % obj.clear()
            % Resets the accumulator by clearing all stored metrics.
            %
            % Example:
            %   obj.clear();
            
            obj.metrics = struct();  % Reset all metrics
        end
    end
end
