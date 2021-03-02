% Split L and R train
%load MotorImagery_train.mat
%load MotorImagery_eval.mat
DIR = uigetdir;
for i = 1:size(EEGL_train, 1)
    L = EEGL_train(i, :);
    R = EEGR_train(i, :);
    save([DIR '/data/tr_EEGL_' num2str(i) '.mat'], 'L');
    save([DIR '/data/tr_EEGR_' num2str(i) '.mat'], 'R');
end

for i = 1:size(EEGL_eval, 1)
    L = EEGL_eval(i, :);
    R = EEGR_eval(i, :);
    save([DIR '/data/ev_EEGL_' num2str(i) '.mat'], 'L');
    save([DIR '/data/ev_EEGR_' num2str(i) '.mat'], 'R');
end

for i = 1:size(EEG_eval, 1)
    E = EEG_eval(i, :);
    save([DIR '/data/ev_EEG_' num2str(i) '.mat'], 'E');
end