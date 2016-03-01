function makehdr_ldr_rfe()
    slow = double(imread('1-125F.jpg'));
    med = double(imread('1-30F.jpg'));
    fast = double(imread('1-8F.jpg'));
    
    weight_fun = @(z) double(128 - abs(z - 128));
    rand_points = randi(696, 2, 100);
    point_index = sparse(rand_points(1, :), rand_points(2, :), ones(1, 100)) == 1;
    
    output = zeros(size(slow));
    
    for i = 1:3
        slow_red = slow(:, :, i);
        med_red = med(:, :, i);
        fast_red = fast(:, :, i);

        slow_weight = mat2gray(weight_fun(slow_red));
        med_weight = mat2gray(weight_fun(med_red));
        fast_weight = mat2gray(weight_fun(fast_red)); 

        % Z B l w
        Z = [slow_red(point_index), med_red(point_index), fast_red(point_index)];
        B = [1/8; 1/30; 1/125];
        l = 200;
        w = weight_fun;

        [g, lE] = gsolve(Z, B, l, w);

        combined = (slow_weight .* (g(1 + slow_red) - log(1/8)) + med_weight .* (g(1 + med_red) - log(1/30)) + fast_weight .* (g(1 + fast_red) - log(1/125))) ./ (slow_weight + med_weight + fast_weight);
        output(:, :, i) = combined;
    end
    
    imshow(mat2gray(output));
end
    
    