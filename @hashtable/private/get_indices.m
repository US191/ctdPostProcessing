  % private function returning subscripted indices ':'
  % $Id$
  % --------------------------------------------------
  function [rows, cols] = get_indices(A, subs)
   
    if length(subs)==1
      if size(A, 1)==1 % col vector
        cols = subs{1};
        rows = 1;
      elseif size(A, 2) == 1 % row vector
        rows = subs{1};
        cols = 1;
      else
        error('must specify two indices');
      end
    else
      cols = subs{1};
      rows = subs{2};
    end
   
  end