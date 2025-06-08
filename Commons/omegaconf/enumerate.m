classdef enumerate < handle
   properties(Access = private)
      IterationList;
      verbose
      description
      fid
   end
   %{
        usage:
            for t = enumerate(iterable)
                step = t.num; snr = t.item;
            end
        
        optional parameters:
            verbose: show progress bar if set true.

   %}
   methods 
       function self = enumerate(in,NameValueArgs)
            arguments
                in
                NameValueArgs.verbose=true
                NameValueArgs.description='Progress'
                NameValueArgs.fid=1
            end
            self.verbose=NameValueArgs.verbose;
            self.description=NameValueArgs.description;
            self.fid=NameValueArgs.fid;
            if size(in,2) == 1
                in = in';
            end
            self.IterationList = in;
       end
       function [varargout] = subsref(self, S)
           item = subsref(self.IterationList,S);
           num = S.subs{2};
           if ~self.verbose
              log_progress(num, self.length, self.description, self.fid)
           end
           if ~iscell(item)
                out.item = item;
           else
                out.item = item{1};
           end
           out.num = num;
           varargout = {out};
       end
       function [m,n] = size(self)
           [m,n] = size(self.IterationList);
       end
       function [l] = length(self)
           l = numel(self.IterationList);
       end
   end
end
function log_progress(iter_counter, total_iter, prog_title, fid)
    arguments
        iter_counter
        total_iter
        prog_title='Progress'
        fid=1
    end
    preString  = '%s:  %03.0f%%  ';
                
    centerString = '|%s|';
    
    postString = '%i/%i';
    
    format = [preString, centerString, postString];

    currentProgress = iter_counter / total_iter;

    MaxBarWidth = 90 - length(preString) - length(postString);
    barString = repmat(' ', 1, MaxBarWidth);
    blocks = [
            char(9615), ...
            char(9614), ...
            char(9613), ...
            char(9612), ...
            char(9611), ...
            char(9610), ...
            char(9609), ...
            char(9608) ...
            ];
    blockIndex = ceil(currentProgress*MaxBarWidth);
    barString(1:blockIndex-1) = blocks(end);
    subBlockIndex = ceil((currentProgress*MaxBarWidth - blockIndex+1)*8);
    barString(blockIndex) = blocks(subBlockIndex);

    argList = {
        prog_title, ...
        floor(currentProgress * 100), ...
        barString, ...
        iter_counter, ...
        total_iter, ...
        };
    fprintf(fid, [format,'\n'], argList{:});
end