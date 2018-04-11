function child_mut = mutation(child, chromosome_size, M, j, mut_prob,num_buildings,num_techs)
total_steps=15*60;

for i = 1:chromosome_size
    
    mut_rand = rand(1);
    if mut_rand < mut_prob
        alpha = (1-(j-1)/M)^0;
       
        if i <= chromosome_size-num_buildings-num_techs
            x_min = 1;
            x_max = 6;
            r = ceil(x_max*rand(1));
            y = dynamic_mut(x_min, x_max, r, alpha, child(i));
        elseif i >= chromosome_size-num_buildings-num_techs
            x_min = 1;
            x_max = total_steps;
            r = ceil(x_max*rand(1));
            y = dynamic_mut(x_min, x_max, r, alpha, child(i));
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
        y = round(x_min + (r-x_min)^(alpha)*(child-x_min)^(1-alpha));
    else
        y = round(x_max - (x_max-r)^(alpha)*(x_max-child)^(1-alpha)); 
    end
end