function stepStruct = connectStepStationToLuas(xStepAll, yStepAll, xStAll, yStAll, xLuasAll, yLuasAll)
% COMPUTEHORIZONTALLENGTHSSTRUCT
%
%   Menghitung semua panjang horizontal dari titik intersection
%   antara setiap “garis step” dan semua “garis station” menuju
%   kurva “luas” terkait, lalu mengemas hasilnya ke dalam struktur
%   yang dikelompokkan per step.
%
%   OUTPUT:
%     stepStruct : struct array [1×nSteps], di mana untuk setiap i:
%       stepStruct(i).StepIndex = i
%       stepStruct(i).Lengths   = vektor panjang horizontal untuk step ke-i
%
%   INPUT:
%     xStepAll  : [nSteps    × nPointsStep]  matriks x untuk setiap “garis step”
%     yStepAll  : [nSteps    × nPointsStep]  matriks y untuk setiap “garis step”
%     xStAll    : [nStations × nPointsSt]    matriks x untuk setiap “garis station”
%     yStAll    : [nStations × nPointsSt]    matriks y untuk setiap “garis station”
%     xLuasAll  : [nStations × nPointsLuas]  matriks x untuk setiap “kurva luas”
%     yLuasAll  : [nStations × nPointsLuas]  matriks y untuk setiap “kurva luas”
%
%   Setiap baris i di (xStepAll, yStepAll) adalah step ke-i.
%   Setiap baris j di (xStAll, yStAll) & (xLuasAll, yLuasAll) adalah station index (j-1).
%
%   Cara pakai:
%     S = computeHorizontalLengthsStruct(xStepAll, yStepAll, xStAll, yStAll, xLuasAll, yLuasAll);
%     % S(i).Lengths berisi semua panjang-horizontal untuk step ke-i.
%

    nSteps    = size(xStepAll, 1);
    nStations = size(xStAll,    1);

    % Prealokasi struct array
    stepStruct(nSteps) = struct('StepIndex', [], 'Lengths', []);

    for i = 1:nSteps
        % Inisialisasi
        stepStruct(i).StepIndex = i;
        stepLengths = [];  % kumpulkan panjang untuk step i

        % Ambil data step_i, filter NaN
        xs_all = xStepAll(i, :);
        ys_all = yStepAll(i, :);
        validStep = isfinite(xs_all) & isfinite(ys_all);
        xs = xs_all(validStep);
        ys = ys_all(validStep);
        if numel(xs) < 2 || numel(ys) < 2
            % Tidak cukup titik valid
            stepStruct(i).Lengths = [];
            continue;
        end

        % Loop semua station j
        for j = 1:nStations
            % Ambil data station_j, filter NaN
            xt_all = xStAll(j, :);
            yt_all = yStAll(j, :);
            validSt = isfinite(xt_all) & isfinite(yt_all);
            xt = xt_all(validSt);
            yt = yt_all(validSt);
            if numel(xt) < 2 || numel(yt) < 2
                continue;
            end

            % Cari titik intersection antara step_i (xs,ys) dan station_j (xt,yt)
            [xi, yi] = polyxpoly(xs, ys, xt, yt);
            if isempty(xi)
                continue;
            end

            % Ambil data luas_j, filter NaN
            xu_all = xLuasAll(j, :);
            yu_all = yLuasAll(j, :);
            validLuas = isfinite(xu_all) & isfinite(yu_all);
            xu_f_all = xu_all(validLuas);
            yu_f_all = yu_all(validLuas);
            if numel(xu_f_all) < 2 || numel(yu_f_all) < 2
                continue;
            end

            % Sort ascending berbasis yu_f_all untuk interpolasi y→x
            [yu_s, sortIdx] = sort(yu_f_all);
            xu_s = xu_f_all(sortIdx);

            % Proses setiap titik intersection
            for k = 1:numel(xi)
                x_int = xi(k);
                y_int = yi(k);

                % Pastikan y_int di rentang [min(yu_s), max(yu_s)]
                if y_int < yu_s(1) || y_int > yu_s(end)
                    continue;
                end

                % Interpolasi untuk mendapat xLuasInt di y = y_int
                xLuasInt = interp1(yu_s, xu_s, y_int, 'linear');
                if isnan(xLuasInt)
                    continue;
                end



                % Plot koneksi horizontal (biru tebal)
                plot([x_int, xLuasInt], [y_int, y_int], '-b', 'LineWidth', 2, ...
                     'DisplayName', sprintf('Conn Hor S%d–Sta%d', i, j-1));

                % Hitung panjang horizontal
                panjangHor = abs(xLuasInt - x_int);

                % Tambahkan ke vektor stepLengths
                stepLengths(end+1) = panjangHor; %#ok<AGROW>
            end
        end

        % Simpan hasil ke struct
        stepStruct(i).Lengths = stepLengths;
    end
end
