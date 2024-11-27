function [A, H, W, Q] = kalmanfilter_fit(X, Z)
% X kf中的状态量，已经经过zero-center处理，第二维是时间
% Z kf中的观测量，已经经过z-score处理

if length(X)==3
    X1 = X{1};
    X2 = X{2};
    X = X{3};
else
    X1 = X(:, 1:end-1);
    X2 = X(:, 2:end);
end

A = X2 * X1' / (X1 * X1');
H = Z * X' / (X * X');
W = (X2 - A * X1) * (X2 - A * X1)' / (size(X, 2) - 1);
Q = (Z - H * X) * (Z - H * X)' / size(X, 2);

end