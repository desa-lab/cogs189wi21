function [train_prob, test_prob] =  lda_study_prob(train_x, test_x, train_y, test_y)

% n_ch = length(train_x(:,1,1));
% 
% [train_mat] = erp_feature(train_x,win_size);
% [test_mat] = erp_feature(test_x,win_size);
% 
% [n_ch n_bin n_trials_train] = size(train_mat);
% [n_ch n_bin n_trials_test] = size(test_mat);

% all_predicted_y = zeros(length(test_y),n_ch);


X = train_x';
Y = train_y;
test_set = test_x';
    
% [W B class_means] = check_lda_train_reg_auto([train_set], [train_y], cov_type, bal_type, 0);
%[ X_LDA predicted_y acc conf_matrix ] = lda_apply([test_set], W, B, [test_y]);

class_list = unique(train_y);

% extract a few useful things
ind0 = find(Y == class_list(2));
ind1 = find(Y == class_list(1));
num0 = length(ind0);
num1 = length(ind1);

% first find the mean for each class
m0 = mean(X(ind0, :), 1)';
m1 = mean(X(ind1, :), 1)';

% shrink covariance matrix
x0 = X(ind0,:) - repmat(m0',num0,1);
x1 = X(ind1,:) - repmat(m1',num1,1);

new_X = cat(1,x0,x1);
S = cov(new_X,1);
k_reg = cal_shrinkage(new_X,[],1);
k_d = mean(diag(S));
S_W = (1-k_reg)*S + eye(size(S,1))*k_reg*k_d;

% solve for optimal projection
W = pinv(S_W) * (m0 - m1);

B = (m0'*W+m1'*W)/2;

x0 = X(ind0,:);
x1 = X(ind1,:);

X_bal = X;

ind0 = find(Y == class_list(2));
ind1 = find(Y == class_list(1));

% project the data onto this line
X_LDA = X_bal  * W;  % same as (w' * X')'
X_LDA = X_LDA-B;

class_mv(1,1) = mean(X_LDA(ind0,:));
class_mv(1,2) = mean(X_LDA(ind1,:));
class_mv(2,1) = std(X_LDA(ind0,:));
class_mv(2,2) =  std(X_LDA(ind1,:));




[ X_LDA predicted_y acc conf_matrix pred_prob ] = lda_apply_prob(X, W, B, class_mv, Y);    
train_prob = pred_prob(:,1);
[ X_LDA predicted_y acc conf_matrix pred_prob ] = lda_apply_prob([test_set], W, B, class_mv, [test_y]);    
test_prob = pred_prob(:,1);

end