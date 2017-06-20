0;

function retval = ifelse (expression, true, false) 
  if (expression) 
    retval = true; 
  else 
    retval = false; 
  endif 
endfunction 
  
%%%%%
% function definitions
%%%%%
f_mi = @(data) mean(data);
f_sigma_square = @(data, mi) mean(arrayfun (@(value, mi) (value - mi)^2, data, mi));
f_probability = @(value, mi, sigma_square) (1/(sqrt(2*pi)*sqrt(sigma_square))) * exp(-((value - mi)^2)/(2*sigma_square));

%%%%%
% load data about houses
%%%%%
load("sold_training");
train_data = sold_training(:,2) ./ sold_training(:,1);  % we take one feature which is price-2-area ratio
%plot(train_data);

%%%%%
% fit parameteres
%%%%%
mi = f_mi(train_data);
sigma_square = f_sigma_square(train_data, mi);

%%%%%
% find anomalies from real data
%%%%%
load("sold");
areas = sold(:,1);
prices = sold(:,2);
data =  prices ./ areas;  % we take one feature which is price-2-area ratio

probabilities = arrayfun(f_probability, data, mi, sigma_square);
anomalies = sold(find(arrayfun(@(p) ifelse(p <= 1e-7, 1, 0), probabilities)),:)

plot(areas, prices, ".3", "markersize", 10);
hold on;
plot(anomalies(:,1), anomalies(:,2), "@1", "markersize", 20);
