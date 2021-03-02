function A3Load
    % Select A3 directory
    DIR = uigetdir;
    
    disp('Loading files...');
    % Load the train data and format it
    EEGL_train = cell(9, 11);
    EEGR_train = cell(9, 11);
    for i = 1:9
        load([DIR '/data/tr_EEGL_' num2str(i) '.mat'], 'L');
        load([DIR '/data/tr_EEGR_' num2str(i) '.mat'], 'R');
        EEGL_train(i, :) = L;
        EEGR_train(i, :) = R;
    end
    
    % Load labeled eval data and format it
    EEGL_eval = cell(9, 11);
    EEGR_eval = cell(9, 11);
    for i = 1:9
        load([DIR '/data/ev_EEGL_' num2str(i) '.mat'], 'L');
        load([DIR '/data/ev_EEGR_' num2str(i) '.mat'], 'R');
        EEGL_eval(i, :) = L;
        EEGR_eval(i, :) = R;
    end
    
    % Load unlabeled eval data and format it
    EEG_eval = cell(9, 11);
    for i = 1:9
        load([DIR '/data/ev_EEG_' num2str(i) '.mat'], 'E');
        EEG_eval(i, :) = E;
    end
    
    % Load channel locations
    load('BCICIV2a_loc.mat', 'loc');
    
    % Add variables to workspace
    assignin('base', 'DIR', DIR);
    assignin('base', 'loc', loc);
    assignin('base', 'EEG_eval', EEG_eval);
    assignin('base', 'EEGL_eval', EEGL_eval);
    assignin('base', 'EEGR_eval', EEGR_eval);
    assignin('base', 'EEGL_train', EEGL_train);
    assignin('base', 'EEGR_train', EEGR_train);
    disp('Completed!');
end