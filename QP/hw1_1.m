clc;clear;close all;
path = ginput() * 100.0;

n_order       = 7;% 多项式最高次幂
n_seg         = size(path,1)-1;% 路段个数
n_poly_perseg = (n_order+1); %多项式未知系数的个数

ts = zeros(n_seg, 1);  %各路段所需要的时间，均是以0-ts
%根据两点之间的距离按比例计算时间分布
dist     = zeros(n_seg, 1);
dist_sum = 0;
T        = 25;
t_sum    = 0;

for i = 1:n_seg
    dist(i) = sqrt((path(i+1, 1)-path(i, 1))^2 + (path(i+1, 2) - path(i, 2))^2);
    dist_sum = dist_sum+dist(i);
end
for i = 1:n_seg-1
    ts(i) = dist(i)/dist_sum*T;
    t_sum = t_sum+ts(i);
end
ts(n_seg) = T - t_sum;

% 简单化，时间间隔均设置为1
% for i = 1:n_seg
%     ts(i) = 1.0;
% end

%x与y轴单独处理
poly_coef_x = MinimumSnapQPSolver(path(:, 1), ts, n_seg, n_order);
poly_coef_y = MinimumSnapQPSolver(path(:, 2), ts, n_seg, n_order);


% 显示轨迹
X_n = [];
Y_n = [];
k = 1;
tstep = 0.01;
for i=0:n_seg-1
    %#####################################################
    % STEP 3: 获得各路段的多项式系数
    Pxi = poly_coef_x((n_order+1)*(i)+1:(n_order+1)*(i)+n_order+1); 
    Pyi = poly_coef_y((n_order+1)*(i)+1:(n_order+1)*(i)+n_order+1);
    for t = 0:tstep:ts(i+1)
        %flip表示翻转Pxi中的元素
        %polyval（[P0,P1,P2],t）生成P0t^2+P1^t+P2,因此需要翻转原始数据
        X_n(k)  = polyval(flip(Pxi), t);
        Y_n(k)  = polyval(flip(Pyi), t);
        k = k + 1;
    end
end
 
plot(X_n, Y_n , 'Color', [0 1.0 0], 'LineWidth', 2);
hold on
%绘制散点图
scatter(path(1:size(path, 1), 1), path(1:size(path, 1), 2));