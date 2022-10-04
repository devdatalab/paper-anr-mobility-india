function slope = fun_reg_coef_max(p);

% create X matrix
X = [ones(100, 1) (1:100)'];
X = [ones(100, 1) (.01:.01:1)'];

% calculate regression solution
coefs = ((inv(X'*X))*X'*p');

slope = -coefs(2);
