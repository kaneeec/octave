1;
format long g;

%epsilon = 1e-6  % one feature
epsilon = 1e-12  % more features
  
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

f_mi = @(feature_vector) mean(feature_vector);
f_mis = @(feature_vectors) arrayfun(@(i) f_mi(feature_vectors(:,i)), 1:size(feature_vectors,2));
f_sigma_square = @(feature_vector, mi) mean(arrayfun (@(value, mi) (value - mi)^2, feature_vector, mi));
f_sigma_squares = @(feature_vectors, mis) arrayfun(@(i) f_sigma_square(feature_vectors(:,i), mis(i)), 1:size(feature_vectors,2));

% the lower the probability is, the higher chance we hit an anomaly
f_p_value = @(value, mi, sigma_square) (1/(sqrt(2*pi)*sqrt(sigma_square))) * exp(-((value - mi)^2)/(2*sigma_square));
f_p_feature = @(feature_vector, mi, sigma_square) arrayfun(f_p_value, feature_vector, mi, sigma_square);
  
f_find_anomaly_items = @(input_data, probabilities) input_data(find(arrayfun(@(p) ifelse(p <= epsilon, 1, 0), probabilities)),:);

%%%%%%
%% FLOW ON ONE-FEATURE DATA
%%%%%%
%% load data about houses
%load("train_one_feature");
%train_data = train_one_feature(:,2) ./ train_one_feature(:,1);  % we take one feature which is price-2-area ratio
%
%% fit parameteres
%mi = f_mi(train_data);
%sigma_square = f_sigma_square(train_data, mi);
%
%% find anomalies from real data
%load("sold");
%areas = sold(:,1);
%prices = sold(:,2);
%anomalies = f_find_anomaly_items(sold, f_p_feature(prices ./ areas, mi, sigma_square));
%
%% show anomalies in graph
%plot(areas, prices, ".3", "markersize", 10);
%hold on;
%plot(anomalies(:,1), anomalies(:,2), "@1", "markersize", 20);

%%%%%
% FLOW ON *-FEATURES DATA
%%%%%
load("train_two_features");
train_data = [train_two_features(:,2) ./ train_two_features(:,1), train_two_features(:,3)];

mis = f_mis(train_data)
sigma_squares = f_sigma_squares(train_data, mis)

load("sold");
feature_vectors = [sold(:,2) ./ sold(:,1), sold(:,3)];

% TODO: make a function
p = [];
for i = 1:size(feature_vectors, 2)
  p = [p f_p_feature(feature_vectors(:,i), mis(i), sigma_squares(i))];
endfor
p = prod(p, 2);

anomalies = f_find_anomaly_items(sold, p)

plot(sold(:,1), sold(:,2), ".5", "markersize", 10);
hold on;
plot(anomalies(:,1), anomalies(:,2), "@1", "markersize", 20);
for i = 1 : size(anomalies,1)
    text(anomalies(i,1), anomalies(i,2), ['(' num2str(anomalies(i,1)) ',' num2str(anomalies(i,2)) ',' num2str(anomalies(i,3)) ')'], "fontweight", "bold");
end

