function [shrink_k] = cal_shrinkage(X,Y,option)

d = size(X,2);

if option == 1
    mu = mean(X)';
    mX = bsxfun(@minus,X,mu');
    N = size(mX,1);
    W = zeros(N,d,d);
    
    for n=1:N
        W(n,:,:) = mX(n,:)' * mX(n,:);
    end
    WM = mean(W,1);
    S = squeeze((N/(N-1)) .* WM);
    
    % Target 'B' of Schafer and Strimmer; choice by Blankertz et al.
    
    VS = squeeze((N/((N-1).^3)) .* sum(bsxfun(@minus,W,WM).^2,1));
    
    v = mean(diag(S));
    
    t = triu(S,1);
    shrink_k = sum(VS(:)) / (2*sum(t(:).^2) + sum((diag(S)-v).^2));
    
elseif option == 2
    ind0 = find(Y == class_list(2));
    ind1 = find(Y == class_list(1));
    mu = mean(X(ind0,:))';
    mX = bsxfun(@minus,X(ind0,:),mu');
    N = size(mX,1);
    W = zeros(N,d,d);
    
    for n=1:N
        W(n,:,:) = mX(n,:)' * mX(n,:);
    end
    WM = mean(W,1);
    S = squeeze((N/(N-1)) .* WM);
    
    % Target 'B' of Schafer and Strimmer; choice by Blankertz et al.
    
    VS = squeeze((N/((N-1).^3)) .* sum(bsxfun(@minus,W,WM).^2,1));
    
    v = mean(diag(S));
    
    t = triu(S,1);
    shrink_k(1) = sum(VS(:)) / (2*sum(t(:).^2) + sum((diag(S)-v).^2));
    mu = mean(X(ind1,:))';
    mX = bsxfun(@minus,X(ind1,:),mu');
    N = size(mX,1);
    W = zeros(N,d,d);
    
    for n=1:N
        W(n,:,:) = mX(n,:)' * mX(n,:);
    end
    WM = mean(W,1);
    S = squeeze((N/(N-1)) .* WM);
    
    % Target 'B' of Schafer and Strimmer; choice by Blankertz et al.
    
    VS = squeeze((N/((N-1).^3)) .* sum(bsxfun(@minus,W,WM).^2,1));
    
    v = mean(diag(S));
    
    t = triu(S,1);
    shrink_k(2) = sum(VS(:)) / (2*sum(t(:).^2) + sum((diag(S)-v).^2));    
    
end
