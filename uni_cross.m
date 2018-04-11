function [child_1, child_2] = uni_cross(cross_prob,mother,father)
n = length(mother);
child_1 = zeros(1,n);
child_2 = zeros(1,n);

for count = 1:n
    r = rand(1);
    if r <= cross_prob
        child_1(count) = mother(count);
        child_2(count) = father(count);
    else
        child_1(count) = father(count);
        child_2(count) = mother(count);
    end
end

% if count==n
%     disp 'lol'
% end