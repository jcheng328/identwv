classdef RandomPick < handle
    % RANDOMPICK - Random pick with weight
    %
    % rp = RandomPick()
    % This class random pick with a 1-indexed array of positive integers w
    % where w[i] describes the weight of the i-th index. It randomly picks
    % an index in the range [1, len(w)]  (inclusive) and returns it. The
    % probability of picking an index i is w[i] / sum(w).
    %
    %
    properties
        aliasTable
        weight
        prob
        n
    end
    methods
        function obj = RandomPick(w)
            % RANDOMPICK - Constructs the object
            %
            % Constructor initializes with the weight, and construct the
            % hash table for the random pick
            aliasTable = obj.create_aliasTable(w);
            
        end
        function aliasTable = create_aliasTable(self, w)
            function bool = close(a,b)
                if abs(a-b) < 1e-6
                    bool = true;
                else
                    bool = false;
                end
            end
            self.prob = w / sum(w);
            n = length(w);
            self.n = n;
            w = w/sum(w)*n;
            underfull = [];
            overfull = [];
            aliasTable = [];
            for i = 1:length(w)
                if ~close(w(i), 1)
                    if w(i) < 1
                        underfull = [underfull, i];
                    elseif w(i) > 1
                        overfull = [overfull, i];
                    end
                end
                aliasTable = [aliasTable,i];
            end
            while length(underfull) > 0
                i = underfull(1);
                j = overfull(1);
                underfull = underfull(2:end);
                overfull = overfull(2:end);
%                 w(i) = 1/n;
                w(j) = w(i) + w(j) - 1;
                aliasTable(i) = j;
                if ~close(w(j), 1)
                    if w(j) < 1
                        underfull = [underfull, j];
                    elseif w(j) > 1
                        overfull = [overfull, j];
                    end
                end
            end
            self.weight = w;
            self.aliasTable = aliasTable;
        end
        function [id] = pickIndex(self)
            p = rand(1);
            i = floor(self.n*p+1);
            resid = self.n * p + 1 - i;
            if resid > self.weight(i)
                id = self.aliasTable(i);
            else
                id = i;
            end
        end
        function [ids] = sample(self, m)
            p = rand(1,m);
            i = floor(self.n*p+1);
            resid = self.n * p + 1 - i;
            ids = i;
            aliasIds = self.aliasTable(i);
            ids(resid>self.weight(i)) = aliasIds(resid>self.weight(i));
        end
        function [res] = collectFreq(self, ids)
            [cnt, a] = hist(ids, unique(ids));
            freq = cnt / sum(cnt);
            res = [a;freq]';
        end
    end
end