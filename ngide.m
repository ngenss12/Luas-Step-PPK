% ================================
% 1. Inisialisasi
% ================================
filename = 'ALFAN BONJEAN.xlsx';
sheet    = 'Sketsa Bonjean';

filename1 = 'ALFAN PELUNCURAN TESSS.xlsx';
sheet1    = 'Input WL luncur';

% ====================================
% 2. Baca raw data dari Excel
%    – C35:N59 untuk “Luas”
%    – R35:AC59 untuk “St”
% ====================================
rangeStrLuas = 'C35:N55';
rawDataLuas  = readcell(filename, 'Sheet', sheet, 'Range', rangeStrLuas);

rangeStrSt = 'R35:AC55';
rawDataSt  = readcell(filename, 'Sheet', sheet, 'Range', rangeStrSt);

rangeStrStep = 'B41:C52';
rawDataStep  = readcell(filename1, 'Sheet', sheet1, 'Range', rangeStrStep);


% ====================================
% 3. Hitung ukuran blok
% ====================================
[nRowsLuas, nColsLuas] = size(rawDataLuas);
[nRowsSt,   nColsSt]   = size(rawDataSt);
[nRowsStep,   nColsStep]   = size(rawDataStep);

% ================================================
% 4. Parse setiap sel "30,0.195" → xDataLuas & yDataLuas
% ================================================
xDataLuas = zeros(nRowsLuas, nColsLuas);
yDataLuas = zeros(nRowsLuas, nColsLuas);
for i = 1:nRowsLuas
    for j = 1:nColsLuas
        entry = rawDataLuas{i,j};
        if ischar(entry) || isstring(entry)
            parts = strsplit(string(entry), ',');
            xDataLuas(i,j) = str2double(parts(1));
            yDataLuas(i,j) = str2double(parts(2));
        else
            xDataLuas(i,j) = NaN;
            yDataLuas(i,j) = NaN;
        end
    end
end

% =============================================
% 5. Parse setiap sel untuk “St” → xDataSt & yDataSt
% =============================================
xDataSt = zeros(nRowsSt, nColsSt);
yDataSt = zeros(nRowsSt, nColsSt);
for i = 1:nRowsSt
    for j = 1:nColsSt
        entry = rawDataSt{i,j};
        if ischar(entry) || isstring(entry)
            parts = strsplit(string(entry), ',');
            xDataSt(i,j) = str2double(parts(1));
            yDataSt(i,j) = str2double(parts(2));
        else
            xDataSt(i,j) = NaN;
            yDataSt(i,j) = NaN;
        end
    end
end

% =============================================
% 5. Parse setiap sel untuk “St” → xDataSt & yDataSt
% =============================================
xDataStep = [0, 326.354339340692];
yDataStep = [85.5175309211486, 0];
% for i = 1:nRowsStep
%     for j = 1:nColsStep
%         entry = rawDataStep{i,j};
%         if ischar(entry) || isstring(entry)
%             parts = strsplit(string(entry), ',');
%             xDataStep(i,j) = str2double(parts(1));
%             yDataStep(i,j) = str2double(parts(2));
%         else
%             xDataStep(i,j) = NaN;
%             yDataStep(i,j) = NaN;
%         end
%     end
% end



% ================================================
% 6. Buat vektor stationIdx (0–24)
% ================================================
stationIdxLuas = (0:(nRowsLuas-1))';
stationIdxSt   = (0:(nRowsSt-1))';
stationIdxStep   = 0;

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

TStep = table();
TStep.Station = stationIdxStep;
for j = 1:size(xDataStep,2)
    TStep.(['X_col' num2str(j)]) = xDataStep(:,j);
    TStep.(['Y_col' num2str(j)]) = yDataStep(:,j);
end

% ================================================
% 8. Plot semua station (overlay)
% ================================================
figure;
hold on;

% Plot “Luas” per station dengan style garis solid & marker lingkaran
for i = 1:size(xDataLuas,1)
    plot(xDataLuas(i,:), yDataLuas(i,:),...
         'DisplayName', ['Luas, Station ' num2str(stationIdxLuas(i))]);
end

% Plot “St” per station dengan style garis putus-putus & marker kotak
for i = 1:size(xDataSt,1)
    plot(xDataSt(i,:), yDataSt(i,:),...
         'DisplayName', ['St, Station ' num2str(stationIdxSt(i))]);
end

% Plot “St” per station dengan style garis putus-putus & marker kotak
for i = 1:size(xDataStep,1)
    plot(xDataStep(i,:), yDataStep(i,:),...
         'DisplayName', ['St, Station ' num2str(stationIdxStep(i))]);
end
stepStruct = connectStepStationToLuas(xDataStep, yDataStep, xDataSt, yDataSt, xDataLuas, yDataLuas);


xlabel('x');
ylabel('y');
title('Overlay: Data Luas vs Data St per Station');
legend('Location','eastoutside');
grid on;
hold off;
