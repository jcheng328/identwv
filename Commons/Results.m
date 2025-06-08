classdef Results < handle
    properties
        varnames = cell(0,0)
        results = cell(0,0)
    end
    methods
        function self=Results()
        end
        function create_empty_rows(self, sz)
            self.results = [self.results; cell(sz, size(self.results,2))];
        end
        function create_empty_columns(self, sz)
            self.results = [self.results, cell(size(self.results,1), sz)];
        end
        function fill_data_to_last_row(self, result)
            [~, loc] = ismember(keys(result), self.varnames);
            self.results(end, loc) = values(result, "cell");
        end
        function add_result(self, result)
            arguments
                self
                result dictionary
            end
            self.configure_table_for_result(keys(result));
            self.create_empty_rows(1);
            self.fill_data_to_last_row(result)
        end
        function configure_table_for_result(self, varnames)
            [lia, ~] = ismember(varnames, self.varnames);
            self.varnames = [self.varnames; varnames(~lia)];
            num_new_varnames = sum(~lia, "all");
            self.create_empty_columns(num_new_varnames);
        end
        function [stats] = get_stats(self, index_varname, stats_type)
            index_lia = strcmp(self.varnames, index_varname);
            index_col_id = find(index_lia);
            results = sortrows(self.results, index_col_id, 'ascend');
            stats_varname = self.varnames(~index_lia);
            stats = cell(0, size(self.results, 2)-1);
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
                    gstats{1, i} = mean(cell2mat(group(:,i)));
                elseif strcmp(stats_type,"std")
                    gstats{1, i} = std(cell2mat(group(:,i)));
                else
                    error("not implemented stats type");
                end
            end
        end
    end
end