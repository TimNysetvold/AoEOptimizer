function child_mut = blockMutation2(child,chromosome_size,total_generations,current_generation,mut_prob,num_buildings,num_techs,num_vil_divisions)

num_blocks=num_vil_divisions+2;
%1 block per vil division, plus one block per building/tech unit
total_steps=15*60;
size_vil_division=(chromosome_size-16)/num_vil_divisions;
child_mut=child;

for i = 1:num_blocks

    mut_rand = rand(1);

    if mut_rand < mut_prob
        if i<=num_vil_divisions
            x_max = 6;
            new_block=ceil(x_max*rand(size_vil_division,1));
            child_mut((i-1)*size_vil_division+1:i*size_vil_division)=new_block;
        else
            x_max = total_steps;
            new_block=ceil(x_max*rand(num_buildings,1));
            child_mut(end-8*(num_blocks-i+1)+1:end-8*(num_blocks-i))=new_block;
        end
    end
end

mut_prob = mut_prob*3;
mut_rand = rand(1);
if mut_rand < mut_prob
    x_max = 6;
    new_block=ceil(x_max*rand(size_vil_division,1));
    block_to_mut = (floor(current_generation*num_vil_divisions/total_generations));   
    
    if (block_to_mut==num_vil_divisions)
        %This only happens on the last iteration, but it can still break
        %the program.
        block_to_mut=block_to_mut-1;
    end
    
    child_mut(block_to_mut*size_vil_division+1:(block_to_mut+1)*size_vil_division)=new_block;
end

if length(child_mut)>172
    disp 'bad'
end