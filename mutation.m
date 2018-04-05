function child_mut = mutation(child, chromosome_size, M, j, mut_prob)

for i = 1:chromosome_size
    
    mut_rand = rand(1);
    if mut_rand < mut_prob
        alpha = (1-(j-1)/M)^mut_prob;
       
        if i <= 39
            x_min = 1;
            x_max = 6;
            r = ceil(x_max*rand(1));
            y = dynamic_mut(x_min, x_max, r, alpha, child(i));
        elseif i >= 40
            x_min = 1;
            x_max = 36;
            r = ceil(x_max*rand(1));
            y = dynamic_mut(x_min, x_max, r, alpha, child(i));
%         elseif i >= 48
%             x_min = 1;
%             x_max = 2;
%             r = ceil(x_max*rand(1));
%             y = dynamic_mut(x_min, x_max, r, alpha, child(i));
        end
        child(i) = y;
    else
        child(i) = child(i);
    end
end
child_mut = child;
end

function y = dynamic_mut(x_min, x_max, r, alpha, child)
    if r <= child
        y = x_min + (r-x_min)^(alpha)*(child-x_min)^(1-alpha);
    else
        y = x_max - (x_max-r)^(alpha)*(x_max-child)^(1-alpha); 
    end
end