%clear all

%load MotorImagery_train.mat
%load MotorImagery_eval.mat
A3Load
%load BCICIV2a_loc.mat

%eeglab;
close all


folds = 1;

% reduce EEG_train to first 60 to match this old script
for i = 1:size(EEGL_train, 1)
    for j = 1:size(EEGL_train, 2)
        EEGL_train{i, j} = EEGL_train{i, j}(:, :, 1:60);
        EEGR_train{i, j} = EEGR_train{i, j}(:, :, 1:60);
    end
end

% split data into training and cross-validation by indices
[n_channel, n_time, n_sample] = size(EEGL_train{1,1});

rng(1);
permIdx = reshape(randperm(n_sample), 5, n_sample/5);

trainIdx = cell(1,5);
cvIdx = cell(1,5);
for i = 1:5
  trainIdx{i} = reshape(permIdx([1:(i-1) i+1:5],:),1,[]);
  cvIdx{i} = permIdx(i,:);
end



accuracy = zeros(9, folds);
for subject = 1:9
  
  for fold = 1:folds
    bandScore_train = zeros(n_sample*0.8*2, 11);
    bandScore_cv = zeros(n_sample*0.2*2, 11);
    for band  = 1:11
      % select training data by training indices
      L_train = EEGL_train{subject,band}(:,:,trainIdx{fold});
      R_train = EEGR_train{subject,band}(:,:,trainIdx{fold});
      % select cv data by cv indices
      L_cv = EEGL_train{subject,band}(:,:,cvIdx{fold});
      R_cv = EEGR_train{subject,band}(:,:,cvIdx{fold});
      
      % transform from matrix into cell structure for CSP
      train_data{1} = mat_to_cell(L_train);
      train_data{2} = mat_to_cell(R_train);
      cv_data{1} = mat_to_cell(L_cv);
      cv_data{2} = mat_to_cell(R_cv);
      
      % define number of eigenvalues for CSP
      csp_per_class = 3;
      [csp_filter, all_coeff] = csp_analysis_quick(train_data, csp_per_class);
  
%       % plot topoplot of csp_filter
%       figure
%       for f = 1:6
%         subplot(2,3,f)
%         topoplot(csp_filter(f,:),loc);
%       end
      
      % CSP filtering data, then calculate log power
      train_CSPed = csp_filtering(train_data,csp_filter);
      train_CSPed{1} = log_norm_BP(train_CSPed{1});
      train_CSPed{2} = log_norm_BP(train_CSPed{2});
      train_CSPed{1} = squeeze(cell2mat(train_CSPed{1}))';
      train_CSPed{2} = squeeze(cell_to_mat(train_CSPed{2}))';
      
      cv_CSPed = csp_filtering(cv_data, csp_filter);
      cv_CSPed{1} = log_norm_BP(cv_CSPed{1});
      cv_CSPed{2} = log_norm_BP(cv_CSPed{2});
      cv_CSPed{1} = squeeze(cell_to_mat(cv_CSPed{1}))';
      cv_CSPed{2} = squeeze(cell_to_mat(cv_CSPed{2}))';
      
      % prepare data for LDA training
      X_train = cat(1, train_CSPed{1}, train_CSPed{2})';
      X_cv = cat(1, cv_CSPed{1}, cv_CSPed{2})';
      y_train = [ones(size(train_CSPed{1},1),1); -1*ones(size(train_CSPed{2},1),1)];
      y_cv = [ones(size(cv_CSPed{1},1),1); -1*ones(size(cv_CSPed{2},1),1)];
      
      % train LDA
      [train_prob, cv_prob] =  lda_train(X_train, X_cv, y_train, y_cv);
      
      bandScore_train(:, band) = train_prob;
      bandScore_cv(:, band) = cv_prob;
    end
    
    X_train = bandScore_train;
    y_train = [ones(n_sample*0.8,1); zeros(n_sample*0.8,1)];
    X_cv = bandScore_cv;
    y_cv = [ones(n_sample*0.2,1); zeros(n_sample*0.2,1)];
    cv_score = TA_classifier(X_train, y_train, X_cv, subject);
    accuracy(subject,fold) = sum(y_cv==round(cv_score))/(n_sample*0.2*2);
    
  end
  
  
end