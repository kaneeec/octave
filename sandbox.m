load("switch_data");

time = switch_data(2:end, 1);
in_deltas = diff(switch_data(:, 4:51));
out_deltas = diff(switch_data(:, 59:106));

plot(time, in_deltas(:, 5));

diff([1 2 3; 2 4 7; 4 8 11])