function angular_wrap()
    image = double(imread('temple.jpg'));
    red_image = image(:, :, 1);
    
    LENGTH = length(image);
    RADIUS = (LENGTH - 1) / 2;
    INCREMENT = 1 / RADIUS;
    [X, Y] = meshgrid(-1:INCREMENT:1, -1:INCREMENT:1);
    Y = -Y;
    Z = (1 - X.^2 - Y.^2);
    CIRCLE = (Z >= 0);
    NOT_CIRCLE = (Z < 0);
    
    X(NOT_CIRCLE) = 0;
    Y(NOT_CIRCLE) = 0;
    Z(NOT_CIRCLE) = 0;
    Z = Z.^0.5;
    
    NORMALS = cat(2, reshape(X, [], 1), reshape(Y, [], 1), reshape(Z, [], 1));
    CAMERA = [0, 0, -1];
    REFLECTIONS = bsxfun(@minus, CAMERA, bsxfun(@times, NORMALS * CAMERA' * 2, NORMALS));
    REFLECTIONS = reshape(REFLECTIONS, LENGTH, LENGTH, 3);
    
    PHI = atan2(REFLECTIONS(:, :, 2), REFLECTIONS(:, :, 1));
    PHI(PHI < 0) = PHI(PHI < 0) + 2*pi;    
    THETA = pi/2 - acos(REFLECTIONS(:, :, 3));
    
    PHI_TEST = reshape(PHI(CIRCLE), [], 1);
    THETA_TEST = reshape(THETA(CIRCLE), [], 1);
    IMG_TEST = reshape(red_image(CIRCLE), [], 1);
    
    F = scatteredInterpolant(PHI_TEST, THETA_TEST, IMG_TEST);
    
    [Xer, Yer] = meshgrid(-pi:pi/180:pi, -pi:pi/180:pi);
    
    PHITER = atan2(Yer, Xer);
    PHITER(PHITER < 0) = PHITER(PHITER < 0) + 2*pi;
    PHITER = 2*pi - PHITER;
    
    THETER = pi/2 - (Xer.^2 + Yer.^2).^0.5;
    THETER(THETER > pi) = 0;
    
    imshow(uint8(F(PHITER, THETER));
    axis equal;
%     
%     [phis, thetas] = meshgrid([pi:pi/360:2*pi 0:pi/360:pi], 0:pi/360:pi);
%     TRIED = F(phis, thetas);
%     TRIED(TRIED > 255) = 255;
%     TRIED(TRIED < 0) = 0;
%     
%     % imshow(uint8(TRIED));
%     disp(min(THETA_TEST));
%     disp(max(THETA_TEST));
%     imshow(mat2gray(PHI));
end

