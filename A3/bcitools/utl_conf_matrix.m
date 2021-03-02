% computes confusion matrix for given true labels and predicted labels

function [ conf_matrix ] = utl_conf_matrix(true_labels, predicted_y)

labels = unique(true_labels);
n_labels = length(labels);

if(length(true_labels) ~=length(predicted_y))
    display('Mismatch');
    return
end

conf_matrix = zeros(n_labels, n_labels);

for my_label = 1:n_labels
    
    my_index = find(true_labels == labels(my_label));
    
    for your_label = 1:n_labels
        
        n_count = sum(predicted_y(my_index) == labels(your_label));
        
        conf_matrix(my_label, your_label) = n_count;
    end
end
