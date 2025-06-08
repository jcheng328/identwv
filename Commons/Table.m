classdef Table < handle
    properties (Access=protected)
        varnames
        contents
    end
    methods
        function obj = Table(varnames, contents)
            % METRICTABLE - Constructs an empty table
            %
            % Constructor initializes an empty structure to store metrics.
            arguments
                varnames = cell(0,0);
                contents = cell(0,0);
            end
            obj.varnames = varnames(:);
            obj.contents = contents;
        end
        function log(self)
            fprintf('varnames \n\t%s\n');
            self.varnames
            fprintf('contents \n');
            self.contents
        end
        function addVariables(self, varnames)
            %
            % Syntax:
            %   table.addVariables({"name1", "name2"})
            [lia, ~] = ismember(varnames, self.varnames);
            self.varnames = [self.varnames; varnames(~lia)];
            num_new_varnames = sum(~lia, "all");
            self.createEmptyColumns(num_new_varnames);
        end
        function fillDataToRow(self, row, rowNumber)
            %
            % Syntax:
            %   table.fillDataToRow(struct()) % Append to the last row.
            %   table.fillDataToRow(struct(), 10) % fill 10th line
            arguments
                self
                row
                rowNumber = size(self.contents, 1)+1;
            end
            if rowNumber > size(self.contents, 1)
                self.createEmptyRows(1);
            end
            if true
                self.addVariables(fieldnames(row))
            end
            [lia, loc] = ismember(fieldnames(row), self.varnames);
            rowvalues = struct2cell(row);
            self.contents(rowNumber, loc(lia)) = rowvalues(lia);
        end
        function addRows(self, rows)
            % Syntax:
            %   table.addRows(struct1, struct2, ...)
            arguments
                self
            end
            arguments (Repeating)
                rows struct
            end
            for i=1:numel(rows)
                self.fillDataToRow(rows{i});
            end
        end
        function delRows(self, rowNumbers)
            self.contents(rowNumbers, :) = [];
        end
    end
    methods (Access=protected)
        function createEmptyRows(self, sz)
            self.contents = [self.contents; cell(sz, size(self.contents,2))];
        end
        function createEmptyColumns(self, sz)
            self.contents = [self.contents, cell(size(self.contents,1), sz)];
        end
    end
end