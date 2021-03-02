% perform LDA on some data
% based on "Fisher Linear Discriminant Analysis" -- Max Welling
% and misc. random stuff I found on the internet ...
% modified version of Pual Hammon's code
%
% INPUT
% X: test data design matrix -- row vectors
% w: weight vector
% true_labels(optional): class1=1, class2=-1(needed for confusion matrix)
% and accuracy
%
% OUTPUTS
% X_LDA: projected results
% predicted_y: prediction based on X_LDA
% acc: classification accuracy
% conf_matrix: confusion matrix
% 09/28/07 -- created
% 02/17/09 -- updated for current classification format
%
% function X_LDA = lda_apply(X, w)
function [ X_LDA predicted_y acc conf_matrix P] = lda_apply_prob(X, w, B, class_mv, varargin)

optargin = size(varargin,2);

if(optargin == 1)
    true_labels = varargin{1};
else
    true_labels = [];
end
    

% project the data onto this line
% X_LDA = w' * X';
X_LDA = X  * w;  % same as (w' * X')'

X_LDA = X_LDA-B;



%{
% initialize probs to -1 
P = -1 * ones(size(X_LDA, 1), size(class_means, 1));

% loop over test points
for i = 1 : length(X_LDA)
    
    % grab the current datapoint
    xx = X_LDA(i, :);
    
    % loop over classes and compute squared distances (don't bother to square root)
    d = [];
    for j = 1 : length(class_means)
        d(1,j) = norm(xx - class_means(j));
    end
    
    % compute prob as 1 - d_i/d_tot
    d_tot = sum(d);
    for j = 1 : size(class_means, 1)
        P(i, j) = 1 - (d(j) / d_tot);
    end
end
%}

% estimate CDF

P = [pdf('Normal',X_LDA,class_mv(1,1), class_mv(2,1)) pdf('Normal',X_LDA,class_mv(1,2), class_mv(2,2))];

P = P./repmat(sum(P,2),1,2);
predicted_y = sign(P(:,1)-P(:,2));

if(~isempty(true_labels))
    % get the list of classes
    class_list = unique(true_labels);

    % extract a few useful things
    % class 0: 1, class 1: -1
    ind0 = find(true_labels == class_list(2));
    ind1 = find(true_labels == class_list(1));
    
    Y = zeros(length(true_labels),1);
    
    Y(ind0) = 1;
    Y(ind1) = -1;
    
    [ conf_matrix ] = utl_conf_matrix(Y, predicted_y);
    acc = sum( predicted_y == Y)/length(Y);
end