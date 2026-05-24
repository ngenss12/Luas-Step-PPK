% ================================
% 1. Inisialisasi & baca Excel
% ================================
filename  = 'Bonjean.xlsx';
sheet     = 'Sketsa Bonjean';
filename1 = 'ALFAN PELUNCURAN TESSS.xlsx';
sheet1    = 'Input WL luncur';

% Baca data “Luas” (C35:N55) dan “St” (R35:AC55)
rawDataLuas = readcell(filename, 'Sheet', sheet, 'Range', 'C35:N55');
rawDataSt   = readcell(filename, 'Sheet', sheet, 'Range', 'R35:AC55');

% ====================================
% 2. Parse “Luas” → xDataLuas, yDataLuas
% ====================================
[nRowsLuas, nColsLuas] = size(rawDataLuas);
xDataLuas = nan(nRowsLuas, nColsLuas);
yDataLuas = nan(nRowsLuas, nColsLuas);
for i = 1:nRowsLuas
    for j = 1:nColsLuas
        entry = rawDataLuas{i,j};
        if ischar(entry) || isstring(entry)
            parts = strsplit(string(entry), ',');
            xDataLuas(i,j) = str2double(parts(1));
            yDataLuas(i,j) = str2double(parts(2));
        end
    end
end

% =====================================
% 3. Parse “St” → xDataSt, yDataSt
% =====================================
[nRowsSt, nColsSt] = size(rawDataSt);
xDataSt = nan(nRowsSt, nColsSt);
yDataSt = nan(nRowsSt, nColsSt);
for i = 1:nRowsSt
    for j = 1:nColsSt
        entry = rawDataSt{i,j};
        if ischar(entry) || isstring(entry)
            parts = strsplit(string(entry), ',');
            xDataSt(i,j) = str2double(parts(1));
            yDataSt(i,j) = str2double(parts(2));
        end
    end
end

% =====================================
% 4. Baca dua titik step dari file lain
% =====================================
% (karena hanya 2 titik, kita bisa assign langsung)
xDataStep = [540,0
];
yDataStep = [0,67.9817524726375
];
% Jika ingin general, bisa parse rawDataStep (tapi di contoh ini tidak perlu)

% =====================================
% 5. Hitung panjang‐panjang horizontal, 
%    hasilnya dalam struktur per‐step
% =====================================
stepStruct = luasstep( ...
    xDataStep, yDataStep, ...
    xDataSt,   yDataSt,   ...
    xDataLuas, yDataLuas  );
stepStruct= stepStruct';

% ================================================
% 6. Buat vektor stationIdx (0–24)
% ================================================
stationIdxLuas = (0:(nRowsLuas-1))';
stationIdxSt   = (0:(nRowsSt-1))';
% stationIdxStep   = (0:(nRowsStep-1))';

% ================================================
% 7. Bangun tabel (opsional)
% ================================================
TLuas = table();
TLuas.Station = stationIdxLuas;
for j = 1:nColsLuas
    TLuas.(['X_col' num2str(j)]) = xDataLuas(:,j);
    TLuas.(['Y_col' num2str(j)]) = yDataLuas(:,j);
end

TSt = table();
TSt.Station = stationIdxSt;
for j = 1:nColsSt
    TSt.(['X_col' num2str(j)]) = xDataSt(:,j);
    TSt.(['Y_col' num2str(j)]) = yDataSt(:,j);
end

% ================================================
% 8. Plot semua station (overlay)
% ================================================
% figure;
% hold on;
% % 
% % Plot “Luas” per station dengan style garis solid & marker lingkaran
% for i = 1:size(xDataLuas,1)
%     plot(xDataLuas(i,:), yDataLuas(i,:),...
%          'DisplayName', ['Luas, Station ' num2str(stationIdxLuas(i))]);
% end
% 
% % Plot “St” per station dengan style garis putus-putus & marker kotak
% for i = 1:size(xDataSt,1)
%     plot(xDataSt(i,:), yDataSt(i,:),...
%          'DisplayName', ['St, Station ' num2str(stationIdxSt(i))]);
% end
% 
% plot(xDataStep, yDataStep)
% % 
% hold off