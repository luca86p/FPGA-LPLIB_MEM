#!/usr/bin/env octave

# Quantization of a Function for ROM data
# Used to build a LUT (Look Up Table)

clc
clear
% close all
disp("");

# Selectable Function (selfun): 
# 1. Sinusoid           f(x) = sin(x)
# 2. Sigmoid logistic   f(x) = 1 / 1+e^{-x}
# 3. Hyperbolic tangent f(x) = tanh(x) = e^{x}-e^{-x} / e^{x}+e^{-x}

# PARAMETERS
selfun = 1;
disp(["selfun : " num2str(selfun)]);
c2balanced = 0; # 0: unbalanced    1: balanced    for x
disp(["c2balanced : " num2str(c2balanced)]);

# Input range 
# (use simmetrical for better conversion)
# -------------------------
# Recommended:
# 1. Sinusoid           x in [-pi:pi]
# 2. Sigmoid logistic   x in [-4:4]
# 3. Hyperbolic tangent x in [-2:2]
if selfun == 1
    x_min = -pi;
    x_max = pi;
elseif selfun == 2
    x_min = -4;
    x_max = 4;
elseif selfun == 3
    x_min = -2;
    x_max = 2;
endif

# Quantization on x: xq depth
# -------------------------
b_x = 4; # bit
disp(["b_x : " num2str(b_x)]);

MIN_SG_xq = -2^(b_x-1);
MAX_SG_xq =  2^(b_x-1)-1;

xq = MIN_SG_xq:MAX_SG_xq;

# xq scaling for real values
# -------------------------
if c2balanced == 0 # unbalanced C2
    LSB_xq = (x_max-x_min)/abs(2*MIN_SG_xq);
else # balanced C2
    LSB_xq = (x_max-x_min)/abs(2*MAX_SG_xq);
    #x(1)   = x(2); 
endif
x      = xq*LSB_xq;

# Real y values
# -------------------------
if selfun == 1
    y = sin(x);
elseif selfun == 2
    y = 1./(1+exp(-x));
elseif selfun == 3
    y = (exp(x)-exp(-x))./(exp(x)+exp(-x));
endif

# plot
% figure
% plot(xq, y, "-o")
% grid on
% xlim([MIN_SG_xq MAX_SG_xq])

# Quantization on y: yq depth
# -------------------------
b_y = 4;
disp(["b_y : " num2str(b_y)]);

MIN_SG_yq = -2^(b_y-1);
MAX_SG_yq =  2^(b_y-1)-1;

# yq scaling from real values
# -------------------------
# y always balanced C2
LSB_yq = max(abs(y))/abs(MAX_SG_yq);
yq     = round(y/LSB_yq);

if c2balanced == 1 # balanced correction
    yq(1) = yq(2);
endif

yq_scaled = yq*LSB_yq;

# plot on x-quantized y-quantized
% figure
% plot(xq, y/LSB_yq, "-o")
% hold on
% plot(xq, yq, "-s")
% grid on
% xlim([MIN_SG_xq MAX_SG_xq])
% ylim([MIN_SG_yq -MIN_SG_yq])

# plot on x-quantized y-real
% figure
% plot(xq, y, "-o")
% hold on
% plot(xq, yq_scaled, "-s")
% grid on
% xlim([MIN_SG_xq MAX_SG_xq])

# printf("%3d => %3d ,\n", [mod(xq,2^b_x); yq])
disp("");
printf("%4d => %6d ,\n", [xq; yq])