function stnum = st2stnum(Bh, Bs, Dw, luck, last, published)
global maxB;
% Bh is the number of honest blocks
% Bs is the number of selfish blocks
% Dw is the published Weight_honest-W_s, max: maxB, min: 0 (Dw<0 then override)
%     note that when Dw>maxB, impossible for selfish miner to override or
%     match
% luck means whether the Bh+1-th selfish block is mined after Bh-th honest block
% last indicates whether the last found block is by honest or selfish miner
% published is the number of selfish blocks that are published
more = maxB+1;
stnum = ((((Bh*more+Bs)*more+Dw)*2+luck)*2+last)*more+published;
end