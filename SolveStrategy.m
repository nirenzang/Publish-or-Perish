global alphaPower maxB rou numOfStates superOverride lowerBoundPolicy;

more = maxB+1;
numOfStates=((((maxB*more+maxB)*more+maxB)*2+1)*2+1)*more+maxB;
disp(['numOfStates: ' num2str(numOfStates)]);
choices = 5;
adopt = 1; override = 2; match = 3; even = 4; hide = 5;
lastH = 0; lastS = 1;

P = cell(1,choices);
% Rs is the reward for selfish miner
Rs = cell(1,choices);
% Rh is the reward for honest miners
Rh = cell(1,choices);
Wrou = cell(1,choices);
for i = 1:choices
    P{i} = sparse(numOfStates, numOfStates);
    Rs{i} = sparse(numOfStates, numOfStates);
    Rh{i} = sparse(numOfStates, numOfStates);
    Wrou{i} = sparse(numOfStates, numOfStates);
end

Psb = alphaPower;
Phb = 1-alphaPower;
baseState = st2stnum(1, 0, 1, 0, lastH, 0);
baseStateS = st2stnum(0, 1, 0, 0, lastS, 0);

% define adopt
P{adopt}(:, baseState) = Phb;
P{adopt}(:, baseStateS) = Psb;
for i = 1:numOfStates
    if mod(i, 2000)==0
        disp(['processing state: ' num2str(i)]);
    end
    [Bh, Bs, Dw, luck, last, published] = stnum2st(i);
    Rh{adopt}(i, baseState) = Bh;
    Rh{adopt}(i, baseStateS) = Bh;
    
    % illegal states, force adoption
    % always decide whether to publish the latest selfish block at the
    %     beginning of the next step!
    % ensure that if lucky == 1, Bh>0, Bs>=Bh and when lastS, Bs>Bh
    if published > Bs-last || Dw > Bh+1 || last == lastH && Bh == 0 ...
            || last == lastS && Bs == 0 || (luck == 1 && (Bh == 0 || Bs < Bh ...
            || Bs == Bh && last == lastS))
        P{override}(i, baseState) = 1;
        Rh{override}(i, baseState) = 10000;
        P{match}(i, baseState) = 1;
        Rh{match}(i, baseState) = 10000;
        P{even}(i, baseState) = 1;
        Rh{even}(i, baseState) = 10000;
        P{hide}(i, baseState) = 1;
        Rh{hide}(i, baseState) = 10000;
        continue;
    end
    
    % luckyOne: the selfish miner earns two points in weight by publishing this one
    % newLuckHnext: if the next block is honest, whether luck remains 1
    luckyOne = -1; newLuckHnext = 0;
    if luck == 1
        if last == lastH
            luckyOne = Bh;
        else
            luckyOne = Bh+1;
            newLuckHnext = 1;
        end
    end
    % newLuckSnext: if the next block is selfish, whether it could be a lucky
    %     one
    if Bs == Bh && Bh > 0
        newLuckSnext = 1;
    else
        newLuckSnext = 0;
    end
    % calculate if the selfish miner publishes everything, the minDw
    % next: the next selfish block that can earn weight
    next = published+1;
    if next < Bh && last == lastH
        next = Bh;
    elseif next < Bh+1 && last == lastS
        next = Bh+1;
    end
    if Bs < next % nothing to publish
        minDw = Dw;
    else
        minDw = Dw-(Bs-next+1+luck);
    end
    
    % define override
    if minDw < 0 || Bs-Bh >= superOverride
        publishUntil = Bs+minDw+1;
		if publishUntil-Bh > superOverride
		    publishUntil = Bh+superOverride;
		end
        % impossible to override without publishing the lucky one
        if publishUntil < luckyOne
            publishUntil = luckyOne;
        end
        P{override}(i, st2stnum(0, Bs-publishUntil+1, 0, 0, lastS, 0)) = Psb;
        Rs{override}(i, st2stnum(0, Bs-publishUntil+1, 0, 0, lastS, 0)) = publishUntil;
        P{override}(i, st2stnum(1, Bs-publishUntil, 1, 0, lastH, 0)) = Phb;
        Rs{override}(i, st2stnum(1, Bs-publishUntil, 1, 0, lastH, 0)) = publishUntil;
    else
        P{override}(i, baseState) = 1;
        Rh{override}(i, baseState) = 10000;
    end
    
    if minDw <= 0
        matchPublishUntil = Bs+minDw;
        if matchPublishUntil == Bh-1 && luckyOne == Bh+1
            matchPublishUntil = Bh;
        elseif luck == 1 && matchPublishUntil == luckyOne-1
            matchPublishUntil = -1;
        end
    else
        matchPublishUntil = -1;
    end

    % define match: make two chains the same weight or at least try
    if matchPublishUntil ~= -1 && Bs < maxB && Bh < maxB
        % honestLuck: if the Bh-th selfish block is published, the new honest
        %     block would earn two points
        if matchPublishUntil >= Bh && Bh > 0
            honestLuck = 2;
        else
            honestLuck = 1;
        end
        % my block on my branch
		if luckyOne == Bh+1 && matchPublishUntil == Bh % preserve the secret luckyOne
		    P{match}(i, st2stnum(Bh, Bs+1, 0, 1, lastS, matchPublishUntil)) = Psb;
		else
            P{match}(i, st2stnum(Bh, Bs+1, 0, newLuckSnext, lastS, matchPublishUntil)) = Psb;
		end
        % honest block on honest branch
        P{match}(i, st2stnum(Bh+1, Bs, honestLuck, newLuckHnext, lastH, matchPublishUntil)) = Phb*0.5;
        % honest block on my branch
		if Bs > matchPublishUntil
            P{match}(i, st2stnum(1, Bs-matchPublishUntil, honestLuck, 0, lastH, 0)) = ...
                P{match}(i, st2stnum(1, Bs-matchPublishUntil, honestLuck, 0, lastH, 0)) + Phb*0.5;
			Rs{match}(i, st2stnum(1, Bs-matchPublishUntil, honestLuck, 0, lastH, 0)) = matchPublishUntil;
		else % the next selfish block can still be lucky, no point to introduce "honestLuck"
		    P{match}(i, st2stnum(1, 0, 1, 0, lastH, 0)) = ...
                P{match}(i, st2stnum(1, 0, 1, 0, lastH, 0)) + Phb*0.5;
			Rs{match}(i, st2stnum(1, 0, 1, 0, lastH, 0)) = matchPublishUntil;
		end
        
    elseif matchPublishUntil == -1 && Bs < maxB && Bh < maxB % impossible to maintain same weight, publish everything
        P{match}(i, st2stnum(Bh, Bs+1, minDw, newLuckSnext, lastS, Bs)) = Psb;
        P{match}(i, st2stnum(Bh+1, Bs, minDw+honestLuck, 0, lastH, Bs)) = Phb;
    else
        P{match}(i, baseState) = 1;
        Rh{match}(i, baseState) = 10000;
    end
    
    evenPublishUntil = -1;
    if Bs >= Bh && Dw > 0 % enough blocks to publish, possible to have honest miners work on own chain
        if published >= Bh % no more blocks need to be published
            evenPublishUntil = published;
            newDw = Dw;
        elseif last == lastH
            evenPublishUntil = Bh;
            newDw = Dw-1;
            if luckyOne == Bh
                newDw = newDw -1;
            end
        else % if last == lastS, publishing till Bh won't get the selfish miner any reward
            evenPublishUntil = Bh;
            newDw = Dw;
        end
    end

    % define even: publish until at least Bh but make sure Dw>0
    if evenPublishUntil ~= -1 && Bs < maxB
        if Bh > 0
            honestLuck = 2;
        else
            honestLuck = 1;
        end
		if luckyOne == Bh+1 % preserve the secret luckyOne
            P{even}(i, st2stnum(Bh, Bs+1, newDw, 1, lastS, evenPublishUntil)) = Psb;
		else
		    P{even}(i, st2stnum(Bh, Bs+1, newDw, newLuckSnext, lastS, evenPublishUntil)) = Psb;
		end
        P{even}(i, st2stnum(Bh+1, Bs, newDw+honestLuck, newLuckHnext, lastH, evenPublishUntil)) = Phb;
    else
        P{even}(i, baseState) = 1;
        Rh{even}(i, baseState) = 10000;
    end
    
    % define hide: publish until Bh-1
    if published < Bh && Bh >= 1 && Bs < maxB && Bh < maxB
        if Bs >= Bh-1
            hidePublishUntil = Bh-1;
        else
            hidePublishUntil = Bs;
        end
		if luckyOne == Bh+1 % preserve the secret luckyOne
            P{hide}(i, st2stnum(Bh, Bs+1, Dw, 1, lastS, hidePublishUntil)) = Psb;
		else
			P{hide}(i, st2stnum(Bh, Bs+1, Dw, newLuckSnext, lastS, hidePublishUntil)) = Psb;
		end
        P{hide}(i, st2stnum(Bh+1, Bs, Dw+1, newLuckHnext, lastH, hidePublishUntil)) = Phb;
    else
        P{hide}(i, baseState) = 1;
        Rh{hide}(i, baseState) = 10000;
    end
end

% for i=1:5
%     sumP2 = sum(P{i},2);
%     for j=1:numOfStates
%         if sumP2(j) ~= 1
%             disp([num2str(i) ' ' num2str(j) ' sum ' num2str(sumP2(j))]);
%         end
%     end
% end

disp(mdp_check(P, Rs));

epsilon = 0.0001;

lowRou = 0;
highRou = 1;
while(highRou - lowRou > epsilon/8)
    rou = (highRou + lowRou) / 2;
    for i = 1:choices
        Wrou{i} = (1-rou).*Rs{i} - rou.*Rh{i};
    end
    [lowerBoundPolicy reward cpuTime] = mdp_relative_value_iteration(P, Wrou, epsilon/8);
    if(reward > 0)
        lowRou = rou;
    else
        highRou = rou;
    end
end
format long
disp(['alpha: ' num2str(alphaPower) ' lowerBoundReward: ']);
disp(rou);

% lowRou = rou;
% highRou = min(rou + 0.1, 1);
% while(highRou - lowRou > epsilon/8)
    % rou = (highRou + lowRou) / 2;
    % for i=1:numOfStates
        % [Bh, Bs, Dw, luck, last, published] = stnum2st(i);
        % if Bs == maxB
            % mid1 = (1-rou)*alphaPower*(1-alphaPower)/(1-2*alphaPower)^2+0.5*((Bs-Bh)/(1-2*alphaPower)+Bs+Bh);
            % Rs{adopt}(i, baseState) = mid1;
            % Rs{adopt}(i, baseStateS) = mid1;
            % Rh{adopt}(i, baseState) = 0;
            % Rh{adopt}(i, baseStateS) = 0;
        % elseif Bh == maxB
            % mid1=alphaPower*(1-alphaPower)/((1-2*alphaPower)^2);
            % mid2=(alphaPower/(1-alphaPower))^(Bh-Bs);
            % mid3=(1-mid2)*(0-rou)*Bh+mid2*(1-rou)*(mid1+(Bh-Bs)/(1-2*alphaPower));
            % Rs{adopt}(i, baseState) = mid3;
            % Rs{adopt}(i, baseStateS) = mid3;
            % Rh{adopt}(i, baseState) = 0;
            % Rh{adopt}(i, baseStateS) = 0;
        % end
    % end
	% for i = 1:choices
        % Wrou{i} = (1-rou).*Rs{i} - rou.*Rh{i};
    % end
    % rouPrime = max(lowRou-epsilon/4, 0);
    % [upperBoundPolicy reward cpuTime] = mdp_relative_value_iteration(P, Wrou, epsilon/8);
    % if(reward > 0)
        % lowRou = rou;
    % else
        % highRou = rou;
    % end
% end
% disp('upperBoundReward: ');
% disp(rou);