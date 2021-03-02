% funtion which converts a cell with equal sized matrices to a matrix with
% an extra dimension
function [ output_matrix ] = cell_to_mat(input_cell)

num_of_mat = length(input_cell);

[N T] = size(input_cell{1});

output_matrix = zeros(N,T, num_of_mat);

for mat = 1:num_of_mat
    output_matrix(:,:,mat) = cell2mat(input_cell(mat));
end