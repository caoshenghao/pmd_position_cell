function output = kalmanfilter_predict(z, states, A, H, W, Q)
% states预测的状态量，第一个值设为真实值
state = states(:, 1);

p = zeros(size(states, 1), size(states, 1));
for j=1:size(states, 2) - 1
    % 时间更新
    p_m = A * p * A' + W;
    state_m = A * state;
    
    % 状态更新
    K = p_m * H' / (H * p_m * H' + Q);
    p = (eye(size(states, 1)) - K * H) * p_m;
    state = state_m + K * (z(:, j + 1) - H * state_m);
    states(:, j + 1) = state;
end

output = states;

end