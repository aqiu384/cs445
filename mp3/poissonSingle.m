function output = poissonSingle(im_s, mask_s, im_background)
    col_bounds = find(diff(max(mask_s)));
    row_bounds = find(diff(max(mask_s, [], 2)));
    
    START_ROW = row_bounds(1);
    END_ROW = row_bounds(2) + 1;
    START_COL = col_bounds(1);
    END_COL = col_bounds(2) + 1;
    ROW_BOUNDS = START_ROW:END_ROW;
    COL_BOUNDS = START_COL:END_COL;
    MROWS = length(ROW_BOUNDS);
    MCOLS = length(COL_BOUNDS);
    
    mask = mask_s(ROW_BOUNDS, COL_BOUNDS);
    penguin = im_s(ROW_BOUNDS, COL_BOUNDS);    
    snow = im_background(ROW_BOUNDS, COL_BOUNDS);
    
    im2var = zeros(MROWS, MCOLS);
            
    function output = img_offset(image, dh, dw)
        output = image(2 + dh:end - 1 + dh, 2 + dw:end - 1 + dw);
    end
    
    function output = four_corner(image)
        output = [
            reshape(img_offset(image, -1, 0), 1, []);
            reshape(img_offset(image, 1, 0), 1, []);
            reshape(img_offset(image, 0, -1), 1, []);
            reshape(img_offset(image, 0, 1), 1, [])
        ];
    end

    function output = four_center(image)
        center = img_offset(image, 0, 0);        
        output = [
            reshape(center - img_offset(image, -1, 0), 1, []);
            reshape(center - img_offset(image, 1, 0), 1, []);
            reshape(center - img_offset(image, 0, -1), 1, []);
            reshape(center - img_offset(image, 0, 1), 1, [])
        ];
    end

    VARS = 0;

    for j = 1:MCOLS
        for i = 1:MROWS
            if mask(i, j)
                VARS = VARS + 1;
                im2var(i, j) = VARS;
            end
        end
    end

    four_mask = four_center(mask) > 0;
    four_pen = four_center(penguin);
    four_snow = four_corner(snow);
    
    four_grad = four_pen + four_snow .* four_mask;
    four_var = four_corner(im2var);
            
    im2var = img_offset(im2var, 0, 0);
    [rows, cols] = find(im2var);
    var2im = [rows, cols]';
    
    center_mask = reshape(im2var, 1, []);
    
    total = 8 * sum(mask(:)) - sum(four_mask(:));
    
    rows = zeros(1, total);
    cols = zeros(1, total);
    vals = zeros(1, total);
    b = zeros(1, 4 * sum(mask(:)));
    
    row = 0;
    col = 0;
    temp_col = 0;
    var = 0;
    deaths = 0;
    lives = 0;
        
    MROWS = MROWS - 2;
    MCOLS = MCOLS - 2;
    SIZE = MROWS * MCOLS;
    
    for j = 1:SIZE
        col = center_mask(j);
        if col > 0
            for i = 1:4
                row = row + 1;
                var = var + 1;
                
                rows(var) = row;
                cols(var) = col;
                vals(var) = 1;
                b(row) = four_grad(i, j);
                
                lives = lives + 1;
                
                temp_col = four_var(i, j);
                if temp_col > 0
                    var = var + 1;
                    
                    deaths = deaths + 1;

                    rows(var) = row;
                    cols(var) = temp_col;
                    vals(var) = -1;
                end
            end
        end
    end
    
    COLS = sum(mask(:));
    ROWS = 4 * COLS;
    
    A = sparse(rows, cols, vals, ROWS, COLS);
    b = b';
    x = A \ b;

    START_ROW = START_ROW - 1;
    START_COL = START_COL - 1;
    
    for i = 1:COLS
        xy = var2im(:, i);
        im_background(xy(1) + START_ROW, xy(2) + START_COL) = x(i);
    end
    
    output = im_background;
end

