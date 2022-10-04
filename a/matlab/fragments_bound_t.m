% constraints. what does a constraint matrix look like now that i have a matrix of outcomes rather than a vector?
% do i just stack it?

% old monotonicity matrix (for decile matrix:
% A_pos_slope = [1 -1  0  0  0  0  0  0  0  0;
%                0 1 -1  0  0  0  0  0  0  0;
%                0  0 1 -1  0  0  0  0  0  0;
%                       .....

% each row is 100 valued, and applies to the whole CEF for one component.

% sample non-monotonic transition matrix:
% [ 0.33 0.33 0.34 ;
%   0.25 0.50 0.25 ]
% monotonicity assumption = row 1, sum 1 --> X >= row 2, sum 1 --> X

% matrix format: [ -1 -1 -1  0  0  0  0  0 .... ;
%                   1  1  1  0  0  0  0  0 .... ;
%                   0  0  0  0  0  0  0  0 .... ;]
% this applies to whole transition matrix, and operationalizes a single constraint.
% we need one of these for each pair of rows (n=99), and one of these for each of 99 columns.
% this is 9801 constraint vectors :-(

% parameter object is a matrix T, 100x100. If we stack it, it's a 10,000 column vector.
% So this matrix should be 9801 * 10,000, and gets compared to a 10,000 column zero vector.

% m1 = [-1 0 ...
%        1 0 ...];
% 
% m2 = [-1 -1 ...
%        1  1 ...];

% A_monotone = [];
% 
% % don't need 100th column, as each row must sum to 100
% % outer loop is over columns. first we do -1; then -1 -1; then -1 -1 -1.
% for c = 1:99
%     tic
% 
%     % inner loop is over rows. first iteration hits top two rows. Then next two, etc.
%     for r = 1:99
% 
%         if r ~= 1
%             m_before = zeros(r-1, 100);
%         else
%             m_before = [];
%         end
% 
%         m_current = [-ones(1, c)  zeros(1, 100 - c);
%                       ones(1, c)  zeros(1, 100 - c)];
%     
%         if r ~= 99
%             m_after = zeros(99 - r, 100);
%         else
%             m_after = [];
%         end
%         
%         A_monotone = [A_monotone; [m_before; m_current; m_after](:)];
%     end
%     [c toc]
% end
% 
% % that's a major fail -- will take half an hour to build.

