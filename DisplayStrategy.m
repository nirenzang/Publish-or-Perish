global maxBsBh alphaPower maxAheadLen m;
global numOfStates lowerBoundPolicy;
inactive=0; active=1;
sLead=0; hLead=1;
adopt = 1; override = 2; match = 3; wait = 4;

for i=1:numOfStates
    if lowerBoundPolicy(i) == adopt
        continue;
    end
    [Bs Bh activeness lead ahead]=stnum2st(i);
    if lead==sLead && length(ahead)>0
        continue;
    end
    disp([num2str(Bs) ', ' num2str(Bh) ', ' num2str(activeness) ', ' num2str(lead) ',']);
    disp(ahead);
    if lowerBoundPolicy(i) == override
        disp('override');
    elseif lowerBoundPolicy(i) == match
        disp('match');
    else
        disp('wait');
    end
end