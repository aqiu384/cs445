function sphere_warp()
    image = im2double(imread('temple.jpg'));
    red_image = image(:, :, 1);
    
    LENGTH = length(image);
    RADIUS = (LENGTH - 1) / 2;
    INCREMENT = 1 / RADIUS;
    [X, Y] = meshgrid(-1:INCREMENT:1, -1:INCREMENT:1);
    
    F = scatteredInterpolant(reshape(X, [], 1), reshape(Y, [], 1), reshape(red_image, [], 1));
    
    [new_x, new_y] = meshgrid(-0.5:INCREMENT:0.5, -0.5:INCREMENT:0.5);
    imshow(F(new_x, new_y));
    
%     LENGTH = length(image);
%     RADIUS = (LENGTH - 1) / 2;
%     INCREMENT = 1 / RADIUS;
%     [X, Y] = meshgrid(-1:INCREMENT:1, -1:INCREMENT:1);
%    
%     RADIUS = (X.^2 + Y.^2);
%     CIRCLE = RADIUS > 1;
%     
%     RADIUS(CIRCLE) = 0;
%     RADIUS = RADIUS.^0.5;
%     THETA = atan(Y ./ X);
%     THETA(CIRCLE) = 0;
%     PHI = asin(RADIUS);
%         
%     imagesc(PHI);
%     axis equal;
end