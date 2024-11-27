function e = calc_recon_error(observed, recon)

% 列向量
observed = observed(:);
recon = recon(:);

% 剔除nan值
nonnan = ~isnan(observed) & ~isnan(recon);
observed = observed(nonnan);
recon = recon(nonnan);

% 除以最大值，归一化
observed = observed ./ max(observed);
recon = recon ./ max(recon);

% 使用mean
e = mean((recon - observed).^2, 'omitnan') / (max(observed) - min(observed));

if isempty(e)
    e = nan;
end

end