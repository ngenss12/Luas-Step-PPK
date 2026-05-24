function stepStruct = luasstep( ...
        xStepAll, yStepAll, xStAll, yStAll, xLuasAll, yLuasAll)
    nSteps    = size(xStepAll, 1);
    nStations = size(xStAll,    1);

    % Prealokasi struct array
    stepStruct(nSteps) = struct('StepIndex', [], 'Lengths', []);

    for i = 1:nSteps
        stepStruct(i).StepIndex = i;
        stepLengths = [];

        % Filter NaN pada satu‐satu titik step
        xs_all = xStepAll(i, :);
        ys_all = yStepAll(i, :);
        validStep = isfinite(xs_all) & isfinite(ys_all);
        xs = xs_all(validStep);
        ys = ys_all(validStep);
        if numel(xs) < 2 || numel(ys) < 2
            stepStruct(i).Lengths = [];
            continue;
        end

        for j = 1:nStations
            % Filter NaN pada station_j
            xt_all = xStAll(j, :);
            yt_all = yStAll(j, :);
            validSt = isfinite(xt_all) & isfinite(yt_all);
            xt = xt_all(validSt);
            yt = yt_all(validSt);
            if numel(xt) < 2 || numel(yt) < 2
                continue;
            end

            % Dapatkan titik intersection
            [xi, yi] = polyxpoly(xs, ys, xt, yt);
            if isempty(xi)
                continue;
            end

            % Filter NaN pada kurva luas_j
            xu_all = xLuasAll(j, :);
            yu_all = yLuasAll(j, :);
            validLuas = isfinite(xu_all) & isfinite(yu_all);
            xu_f_all = xu_all(validLuas);
            yu_f_all = yu_all(validLuas);
            if numel(xu_f_all) < 2 || numel(yu_f_all) < 2
                continue;
            end

            % Sort ascending berdasarkan yu_f_all untuk interpolasi y→x
            [yu_s, sortIdx] = sort(yu_f_all);
            xu_s = xu_f_all(sortIdx);

            % Hitung panjang tiap intersection
            for k = 1:numel(xi)
                x_int = xi(k);
                y_int = yi(k);
                if y_int < yu_s(1) || y_int > yu_s(end)
                    continue;
                end
                xLuasInt = interp1(yu_s, xu_s, y_int, 'linear');
                if isnan(xLuasInt)
                    continue;
                end


                %                 % Plot koneksi horizontal (biru tebal)
                % plot([x_int, xLuasInt], [y_int, y_int], '-b', 'LineWidth', 2, ...
                %      'DisplayName', sprintf('Conn Hor S%d–Sta%d', i, j-1));

                % Panjang horizontal
                panjangHor = abs(xLuasInt - x_int);
                stepLengths(end+1) = panjangHor; %#ok<AGROW>
            end
        end

        stepStruct(i).Lengths = stepLengths;
    end
end
