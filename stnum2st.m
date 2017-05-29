function [ Bh, Bs, Dw, luck, last, published ] = stnum2st(num)
global maxB;
% stnum = ((((Bh*more+Bs)*(maxB+2)+Dw)*2+luck)*2+last)*more+published;
% state num must start with 1, not 0!
more = maxB+1;
published = mod(num, more);
num = floor(num/more);
last = mod(num, 2);
num = floor(num/2);
luck = mod(num, 2);
num = floor(num/2);
Dw = mod(num, more);
num = floor(num/more);
Bs = mod(num, more);
Bh = floor(num/more);
end