% Skeleton for COGS 189 A3
% 
% Please refer to this file when the Google Doc asks you to.
% Do not modify the names of variables given to you as that will cause
% issues with autograding.
%
% You will be uploading this file to Gradescope once you are done so 
% make sure everything is executable and nothing crashes before you submit
% the assignment.
%
%
VAR_NAME = "First Last"; %" rather than ' for apostrophe last names
VAR_PID  = 'A000000';

%--------------------------------------------------------------------------
% Q1 -- What are the four classes present in this dataset?
% Change the string to your answer.
Q1_ANS = 'Enter your answer here as a string.'; % 

%--------------------------------------------------------------------------
% Q2 -- Simple "Cross-Validation"
%
% Goal: Create a 5-fold "CV" loop
Q2_data = [1, 2, 3, 4, 5];

% Create a for loop which takes Q2_data and
% prints two things every iteration:
%  1. The number of our iterator
%  2. Every other number in Q2_data
%
% Use i as your iterating variable
i = 1;

% You will find the following lines of code very useful:
%disp(i)
%disp(Q2_data(Q2_data ~= i)) % This is called logical indexing

% WRITE YOUR FOR LOOP HERE
% WRITE YOUR FOR LOOP HERE
% WRITE YOUR FOR LOOP HERE
% WRITE YOUR FOR LOOP HERE

% Output should be:
%1
%2     3     4     5
%2
%1     3     4     5
%3
%1     2     4     5
%4
%1     2     3     5
%5
%1     2     3     4

%--------------------------------------------------------------------------
% Q3 -- Using the code given in the Google Doc as a template, set Q3_Ans to
%       be the dimensionality of EEGR_train
% Please write the code rather than defining a vector of values
Q3_Ans = []; % Put your answer here

%--------------------------------------------------------------------------
% Q4 -- When k=6, how many samples are in each bin?
% Please write code for this answer rather than an integer value
Q4_Ans = [];

%--------------------------------------------------------------------------
% Q5 -- What is the value of the 3rd rand_nums?
% Please write code for this answer rather than an integer value
Q5_Ans = [];

%--------------------------------------------------------------------------
% Q6 -- Cross Validation Indices
% Follow the instructions and use the code given to you in the Google Doc 
% to create your own for loop which sets indices into the variables
% trainIdx and valIdx

% WRITE YOUR FOR LOOP HERE
% WRITE YOUR FOR LOOP HERE
% WRITE YOUR FOR LOOP HERE
% WRITE YOUR FOR LOOP HERE

%--------------------------------------------------------------------------
% Q7 -- Set the value of Q7_ANS to the number of spatial filters we choose
%       from each class
% The answer should just be an integer

Q7_ANS = []; % Integer answer here

%--------------------------------------------------------------------------
% Q8 & Q9 -- Run the main analysis and then answer the question below
% Do not modify the main analysis code, please scroll down

%
% Main Analysis (Do Not Modify)
%

% Declare useful variables
[n_subjects, n_filters] = size(EEGL_train);
train_size = bin_size * (k-1);
val_size = bin_size;
accuracy = zeros(n_subjects, k);
csp_per_class = Q7_ANS; % Dependent on student's Q7 answer

% Begin nested loops
% Subject > Fold > Band
for subject = 1:n_subjects
    for fold = 1:k
        bandScore_train = zeros(train_size*2, n_filters);
        bandScore_cv    = zeros(val_size*2,   n_filters);
        for band = 1:n_filters
            L_train = EEGL_train{subject, band}(:, :, trainIdx{fold});
            R_train = EEGR_train{subject, band}(:, :, trainIdx{fold});
            L_cv    = EEGL_train{subject, band}(:, :, valIdx{fold});
            R_cv    = EEGR_train{subject, band}(:, :, valIdx{fold});
            
            train_data{1} = mat_to_cell(L_train);
            train_data{2} = mat_to_cell(R_train);
            cv_data{1} = mat_to_cell(L_cv);
            cv_data{2} = mat_to_cell(R_cv);
            [csp_filter, all_coeff] = csp_analysis_quick(train_data, csp_per_class);
            
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

            % prepare data for LDA training (assumes balanced classes)
            X_train = cat(1, train_CSPed{1}, train_CSPed{2})';
            X_cv = cat(1, cv_CSPed{1}, cv_CSPed{2})';
            y_train = [ones(train_size, 1); -1*ones(train_size, 1)];
            y_cv = [ones(val_size, 1); -1*ones(val_size, 1)];

            % train LDA
            [train_prob, cv_prob] =  lda_train(X_train, X_cv, y_train, y_cv);

            bandScore_train(:, band) = train_prob;
            bandScore_cv(:, band) = cv_prob;
        end
        
        X_train = bandScore_train;
        y_train = [ones(train_size, 1); zeros(train_size, 1)];
        X_cv = bandScore_cv;
        y_cv = [ones(val_size, 1); zeros(val_size, 1)];
        cv_score = TA_classifier(X_train, y_train, X_cv, subject);
        accuracy(subject,fold) = sum(y_cv==round(cv_score))/(val_size*2);
    end
end

%
% Main Analysis Over
%

% Q8 -- What is the dimensionality of csp_filter? 
Q8_ANS = [];

% Q9 -- In csp_filter, are the filters defined by the rows or columns?
% For this question, index Q8_ANS with the appropriate value.
% row = Q8_ANS(1);
% col = Q8_ANS(2);
Q9_ANS = Q8_ANS(0); % Modify the integer from 0 to 1 or 2

%--------------------------------------------------------------------------
% Q10 -- What is the mean accuracy of every subject?
% Please write your answer using code rather than a float
Q10_ANS = [];
