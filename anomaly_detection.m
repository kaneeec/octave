1;
format long g;

%epsilon = 1e-6  % one feature
epsilon = 1e-12  % two features
  
%%%%%
% function definitions
%%%%%
function retval = ifelse (expression, true, false) 
  if (expression) 
    retval = true; 
  else 
    retval = false; 
  endif 
endfunction

calc_mis = @(feature_vectors) arrayfun(@(i) mean(feature_vectors(:,i)), 1:size(feature_vectors,2));
calc_sigma_square = @(feature_vector, mi) mean(arrayfun (@(value, mi) (value - mi)^2, feature_vector, mi));
calc_sigma_squares = @(feature_vectors, mis) arrayfun(@(i) calc_sigma_square(feature_vectors(:,i), mis(i)), 1:size(feature_vectors,2));

% the lower the probability is, the higher chance we hit an anomaly
calc_p_of_value = @(value, mi, sigma_square) (1/(sqrt(2*pi)*sqrt(sigma_square))) * exp(-((value - mi)^2)/(2*sigma_square));
calc_ps_of_feature_vector = @(feature_vector, mi, sigma_square) arrayfun(calc_p_of_value, feature_vector, mi, sigma_square);
calc_ps_of_feature_vectors = @(feature_vectors, mis, sigma_squares) \
  prod(cell2mat(arrayfun(@(i) calc_ps_of_feature_vector(feature_vectors(:,i), mis(i), sigma_squares(i)), 1:size(feature_vectors,2), "UniformOutput", 0)), 2);  
  
find_anomaly_items = @(input_data, probabilities) input_data(find(arrayfun(@(p) ifelse(p <= epsilon, 1, 0), probabilities)),:);

%%%%%
% FLOW ON *-FEATURES DATA
%%%%%
load("train_two_features");
train_data = [train_two_features(:,2) ./ train_two_features(:,1), train_two_features(:,3)];

mis = calc_mis(train_data)
sigma_squares = calc_sigma_squares(train_data, mis)

load("sold");
feature_vectors = [sold(:,2) ./ sold(:,1), sold(:,3)];

anomalies = find_anomaly_items(sold, calc_ps_of_feature_vectors(feature_vectors, mis, sigma_squares));

plot(sold(:,1), sold(:,2), ".5", "markersize", 10);
hold on;
plot(anomalies(:,1), anomalies(:,2), "@1", "markersize", 20);
for i = 1 : size(anomalies,1)
    text(anomalies(i,1), anomalies(i,2), ['[' num2str(anomalies(i,1)) 'm2, ' num2str(anomalies(i,2)) 'Kc, ' num2str(anomalies(i,3)) 'm <> centre]'], "fontweight", "bold");
end

