% funtion which converts a matrix into a cell by dividing the 3rd dim
function [ output_cell ] = mat_to_cell(input_matrix)

[N T num_of_trials] = size(input_matrix);

output_cell = cell(1);

for trial = 1:num_of_trials
    output_cell{trial} = input_matrix(:,:,trial);
end