classdef MetricTable < Table
    % METRICTABLE - Resotre metrics during identification
    %
    % table = MetricTable()
    % This class serves as an saver that collects and stores 
    % metrics over the course of identification. It provides methods 
    % to add rows of metrics and compute stats.
    %
    % Example usage:
    %   table = MetricTable();
    %   table.addMetricRow('accuracy', 0.85, 'tpr', 0.3);
    %
    % Properties:
    %   varnames - Variable names
    %   contents - Rows of contents
    
    properties
    end
    methods
        function addMetricRow(self, metricName, metricValue)
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
                self
            end
            arguments (Repeating)
                metricName
                metricValue
            end
            metricRow = cell2struct(metricValue, metricName, 2);
            self.addRows(metricRow);
        end

        function [stats] = get_stats(self, index_varname, stats_type)
            index_lia = strcmp(self.varnames, index_varname);
            index_col_id = find(index_lia);
            results = sortrows(self.contents, index_col_id, 'ascend');
            stats_varname = self.varnames(~index_lia);
            stats = cell(0, size(self.contents, 2)-1);
            index = cell(0, 1);
            if size(results, 1) == 0
                return;
            end
            group_start_row = 1;
            for i = 1 : size(results, 1)-1
                if results{i, index_col_id} ~= results{i+1, index_col_id}
                    stats = [stats; self.group_stats(results(group_start_row: i, ~index_lia), stats_type)];
                    index = [index; results{i, index_col_id}];
                    group_start_row = i + 1;
                end
            end
            index = [index; results{end, index_col_id}];
            stats = [stats; self.group_stats(results(group_start_row:end, ~index_lia), stats_type)];
            
            stats = struct(...
                index_varname={index_varname},...
                index={cell2mat(index)},...
                stats_varname={stats_varname},...
                stats={cell2mat(stats)},...
                stats_type={stats_type});
        end
        function [gstats] = group_stats(self, group, stats_type)
            gstats = cell(1, size(group,2));
            for i = 1 : size(group,2)
                if strcmp(stats_type,"mean")
                    gstats{1, i} = mean(cell2mat(group(:,i)), 'omitnan');
                elseif strcmp(stats_type,"std")
                    gstats{1, i} = std(cell2mat(group(:,i)), 'omitnan');
                else
                    error("not implemented stats type");
                end
            end
        end
    end
end
