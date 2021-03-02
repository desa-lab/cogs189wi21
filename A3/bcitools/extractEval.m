clear all
load MI_Comp_LR_eval.mat
EEGL_eval = cell(9, 11);
EEGR_eval = cell(9, 11);
EEG_eval = cell(9, 11);

for i = 1:size(EEGL, 1)
    for j = 1:size(EEGL, 2)
        EEGL_eval(i, j) = {EEGL(i, j).data(:,:,1:60)};
        EEGR_eval(i, j) = {EEGR(i, j).data(:,:,1:60)};
        EEG_eval(i, j) = {cat(3, EEGL(i, j).data(:,:,61:end), EEGR(i, j).data(:,:,61:end))};
        
        % Shuffle 3rd dimension to classes aren't perfect
        A = randperm(size(EEG_eval{i, j}, 3));
        EEG_eval{i, j} = EEG_eval{i, j}(:, :, A);
    end
end

clear EEGL
clear EEGR
clear i
clear j
clear A

EEGL_new = cell(9, 11);
EEGR_new = cell(9, 11);
for i = 1:9
    for j = 1:11
        EEGL_new(i, j) = {cat(3, EEGL_train{i, j}, EEGL_eval{i, j})};
        EEGR_new(i, j) = {cat(3, EEGR_train{i, j}, EEGR_eval{i, j})};
    end
end

clear EEGL_train
clear EEGR_train

EEGL_train = EEGL_new;
EEGR_train = EEGR_new;

clear EEGL_new
clear EEGR_new