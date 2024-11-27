function mean_vector_length = calc_mean_vector_length(count_curve, time_curve, abin)
% 计算mean vector length
% 原先用于判定head direction cell

amax = pi;
amin = -pi;
% 用每个bin的中间值指代这个bin内的角度
ang = amin:abin:amax;
ang = ang + abin / 2;
ang(end) = [];

curve_length = length(count_curve);
tmp = count_curve ./ time_curve;
tmp = repmat(tmp, 1, 3);
r = smoothdata(tmp, 'gaussian', 7);
r = r(curve_length + 1:curve_length * 2);

mean_vector_length = abs(sum(exp(1i * ang) .* r) / sum(r));
end