%% ALGORITMA 2E-LRP-DIRECT SHIPMENT
% ANDI MUHAMMAD FIQRI ACHMAD - 23417008
% TEKNIK DAN MANAJEMEN INDUSTRI
% INSTITUT TEKNOLOGI BANDUNG
%--------------------------------------------------------------------------
close all;
clear all;
clc;
tic;
%INISIALISASI PARAMETER
%--------------------------------------------------------------------------
% DATA TITIK PENGHASIL
data_penghasil = load('titik_penghasil.txt');
jumlah_penghasil = length(data_penghasil(:,1));
titik_penghasil = data_penghasil(:,1);
jumlah_limbah = data_penghasil(:,2);
buka_penghasil = data_penghasil(:,3);
tutup_penghasil = data_penghasil(:,4);
waktu_pelayanan_penghasil = data_penghasil(:,5);

%DATA TITIK KANDIDAT GUDANG
data_kand_gudang = load('titik_gudang.txt');
jumlah_kand_gudang = length(data_kand_gudang(:,1));
titik_kand_gudang = data_kand_gudang(:,1);
kapasitas_kand_gudang = data_kand_gudang(:,2);
jumlah_limbah2 = data_kand_gudang(:,3);
biaya_buka_gudang = data_kand_gudang(:,4);

%DATA TITIK PANGKALAN
data_pangkalan = load('titik_pangkalan.txt');
jumlah_pangkalan = length(data_pangkalan);
titik_pangkalan = data_pangkalan;

%DATA PENGOLAH
data_kand_pengolah = load('titik_plant.txt');
jumlah_kand_pengolah = length(data_kand_pengolah(:,1));
titik_kand_pengolah = data_kand_pengolah(:,1);
kapasitas_kand_pengolah = data_kand_pengolah(:,2);
biaya_buka_pengolah = data_kand_pengolah(:,3);

%DATA KENDARAAN 1
data_kendaraan_1 = load('kendaraan_e1.txt');
jumlah_kendaraan_1 = length(data_kendaraan_1(:,1));
jenis_kendaraan_1 = data_kendaraan_1(:,1);
kapasitas_kendaraan_1 = data_kendaraan_1(:,2);
biaya_kendaraan_1 = data_kendaraan_1(:,3);

%DATA KENDARAAN 2
data_kendaraan_2 = load('kendaraan_e2.txt');
jumlah_kendaraan_2 = length(data_kendaraan_2(:,1));
jenis_kendaraan_2 = data_kendaraan_2(:,1);
kapasitas_kendaraan_2 = data_kendaraan_2(:,2);
biaya_kendaraan_2 = data_kendaraan_2(:,3);

%DATA BIAYA
biaya_pangkalan_penghasil = load('data_biaya_pangkalan_penghasil.txt');
biaya_total1 = load('data_biaya_total.txt');
biaya_total2 = load('data_biaya_gudang_plant.txt');

%DATA WAKTU
waktu_total = load('data_waktu_total.txt');

status_penghasil = zeros(1,jumlah_penghasil);
status_pangkalan = zeros(1,jumlah_pangkalan);
status_pangkalan_gudang = zeros(jumlah_pangkalan,jumlah_kand_gudang);
status_pangkalan_kendaraan = zeros(jumlah_pangkalan,jumlah_kendaraan_1);
status_penghasil_kendaraan = zeros(jumlah_penghasil,jumlah_kendaraan_1);
status_gudang_kendaraan = zeros(jumlah_kand_gudang,jumlah_kendaraan_1);
status_x = zeros(jumlah_pangkalan+jumlah_penghasil+jumlah_kand_gudang+jumlah_kand_pengolah,jumlah_pangkalan+jumlah_penghasil+jumlah_kand_gudang+jumlah_kand_pengolah,jumlah_kendaraan_1);
status_r = zeros(jumlah_kand_gudang+jumlah_kand_pengolah,jumlah_kand_gudang+jumlah_kand_pengolah,jumlah_kendaraan_2);
status_gudang = zeros(1,jumlah_kand_gudang);
status_gudang = zeros(1,jumlah_kand_gudang);
status_pengolah = zeros(1,jumlah_kand_pengolah);
status_kendaraan1 = zeros(1,jumlah_kendaraan_1);
status_kendaraan2 = zeros(1,jumlah_kendaraan_2);
status_gudang_kendaraan2 = zeros(jumlah_kand_gudang,jumlah_kendaraan_2);
waktu_datang = zeros(jumlah_pangkalan+jumlah_penghasil+jumlah_kand_gudang,jumlah_kendaraan_1);
total_penghasil = zeros(1,jumlah_penghasil);
jumlah_angkut = zeros(jumlah_pangkalan+jumlah_penghasil+jumlah_kand_gudang,jumlah_kendaraan_1);
jumlah_angkut2 = zeros(jumlah_kand_gudang+jumlah_kand_pengolah,jumlah_kendaraan_2);

temp_biaya_total1 = biaya_total1;
temp_biaya_pangkalan_penghasil = biaya_pangkalan_penghasil;
temp_kapasitas_kendaraan_1 = kapasitas_kendaraan_1;
gudang_penuh = 0;

%% BUKA GUDANG dan pengolah

cari_gudang = find(status_gudang == 0);
pilih_gudang = randi([1 length(cari_gudang)]);
index_gudang = cari_gudang(pilih_gudang);

status_gudang(index_gudang) = 1;

cari_pengolah = find(status_pengolah == 0);
pilih_pengolah = randi([1 length(cari_pengolah)]);
index_pengolah = cari_pengolah(pilih_pengolah);

status_pengolah(index_pengolah) = 1;

%% PILIH PANGKALAN, PENGHASIL DAN KENDARAAN SECARA RANDOM

while sum(total_penghasil) < jumlah_penghasil
    
    while find(status_pangkalan == 0)
        e=0;
        % untuk pilihan kendaraan random
        cari_kendaraan1 = find(status_kendaraan1 == 0);
        pilih_kendaraan1 = randi([1 length(cari_kendaraan1)]);
        index_kendaraan1 = cari_kendaraan1(pilih_kendaraan1);

        cari_pangkalan_penghasil_baru = find(status_pangkalan == 0);
        cari_pangkalan_penghasil = biaya_pangkalan_penghasil(cari_pangkalan_penghasil_baru,jumlah_pangkalan+1:jumlah_pangkalan+jumlah_penghasil);
        gh = length(cari_pangkalan_penghasil_baru);
        
        if gh == 1
            pilih_pangkalan_penghasil = cari_pangkalan_penghasil;
        else
            pilih_pangkalan_penghasil = min(cari_pangkalan_penghasil);
        end
        
        pilih_penghasil = min(pilih_pangkalan_penghasil);
        index_pangkalan_penghasil = find(pilih_penghasil == pilih_pangkalan_penghasil);
        index_pangkalan = find(pilih_penghasil == cari_pangkalan_penghasil(:,index_pangkalan_penghasil));

        index_pangkalan;
        index_penghasil = index_pangkalan_penghasil;

        waktu_datang(jumlah_pangkalan+index_penghasil,index_kendaraan1) = waktu_total(index_pangkalan,jumlah_pangkalan+index_penghasil);

        waktu_buka = buka_penghasil(index_penghasil);
        waktu_tutup = tutup_penghasil(index_penghasil);

        if waktu_datang(jumlah_pangkalan+index_penghasil,index_kendaraan1) > waktu_tutup
            status_pangkalan(index_pangkalan) = 999;
            biaya_pangkalan_penghasil(index_pangkalan,jumlah_pangkalan+index_penghasil) = 9999999;
            waktu_datang(jumlah_pangkalan+index_penghasil,index_kendaraan1) = 0;
            kapasitas_kendaraan_1(index_kendaraan1) = temp_kapasitas_kendaraan_1(index_kendaraan1);
            continue
        end

        if waktu_datang(jumlah_pangkalan+index_penghasil,index_kendaraan1) < waktu_buka
            waktu_datang(jumlah_pangkalan+index_penghasil,index_kendaraan1) = waktu_buka;
        end

        if find(status_pangkalan == 999)
            status_pangkalan = 0;
        end

        jumlah_angkut(jumlah_pangkalan+index_penghasil,index_kendaraan1) = jumlah_limbah(index_penghasil);
        
        total_angkut = sum(jumlah_angkut(:,index_kendaraan1));
        kapasitas_kendaraan_1(index_kendaraan1);

        gudang = find(status_gudang == 1);
        status_gudang_kendaraan(gudang,index_kendaraan1) = 1;
        total_jumlah_angkut = transpose(sum(jumlah_angkut));
        angkut_gudang = status_gudang_kendaraan*total_jumlah_angkut;
        limbah_gudang = angkut_gudang(gudang);
        status_gudang_kendaraan(gudang,index_kendaraan1) = 0;
        
        if limbah_gudang > kapasitas_kand_gudang(gudang)
            gudang_penuh = 1;
            break
        end

        rute_sementara = [index_pangkalan index_penghasil];

        status_x(index_pangkalan,jumlah_pangkalan+index_pangkalan_penghasil,index_kendaraan1) = 1;
        biaya_pangkalan_penghasil(:,jumlah_pangkalan+index_pangkalan_penghasil) = 9999999;
        biaya_pangkalan_penghasil(index_pangkalan,:) = 9999999;
        biaya_total1(:,jumlah_pangkalan+index_pangkalan_penghasil) = 9999999;
        biaya_total1(index_pangkalan,:) = 9999999;

        status_pangkalan_kendaraan(index_pangkalan,index_kendaraan1) = 1;
        status_penghasil_kendaraan(index_penghasil,index_kendaraan1) = 1;
        status_penghasil(index_penghasil) = 1;
        status_kendaraan1(index_kendaraan1) = 1;
        status_pangkalan(index_pangkalan) = 1;
        total_penghasil(index_penghasil) = 1;

        solusi{index_kendaraan1} = rute_sementara;
        
        if find(status_pangkalan == 999)
            status_pangkalan = 0;
        end

    % mengembalikan nilai jarak penghasil yg blm terlayani
    cari_penghasil = find(status_penghasil == 0);
    biaya_pangkalan_penghasil(1:jumlah_pangkalan,jumlah_pangkalan+cari_penghasil) = temp_biaya_pangkalan_penghasil(1:jumlah_pangkalan,jumlah_pangkalan+cari_penghasil);
    rx = solusi;
    kapasitas_kendaraan1_sementara = kapasitas_kendaraan_1;
    kapasitas_kendaraan_1 = temp_kapasitas_kendaraan_1;
    
    bb = status_penghasil;
        while find(status_penghasil == 0)
        cc = status_penghasil;
            f = 0;
            for penghasil = find(status_penghasil == 0)
                penghasil;
                dd = status_penghasil;

                penghasil_sebelum = find(status_penghasil == 1);
                biaya_perjalanan1 = biaya_total1(jumlah_pangkalan+penghasil_sebelum,jumlah_pangkalan+1:jumlah_pangkalan+jumlah_penghasil);
                biaya_min = min(biaya_perjalanan1);
                biaya_min1 = min(biaya_min);
                biaya_total1;
                [penghasil2,penghasil] = find(biaya_min1 == biaya_total1(jumlah_pangkalan+1:jumlah_pangkalan+jumlah_penghasil,jumlah_pangkalan+1:jumlah_pangkalan+jumlah_penghasil));
                [titik1,titik2] = find(biaya_min1 == biaya_total1(jumlah_pangkalan+1:jumlah_pangkalan+jumlah_penghasil,jumlah_pangkalan+penghasil));
                %titik1 = lokasi baris titik sebelum, yg digunakan
                %titik2 = lokasi kolom, tidak digunakan
                t1 = titik1;
                p1 = penghasil;
                %pilih kendaraan berdasarkan titik1
%                 index_kendaraan1 = find(status_penghasil_kendaraan(titik1,:) == 1);

                titik0 = find(status_x(:,jumlah_pangkalan+titik1,index_kendaraan1) == 1);
                %titik0 = lokasi titik sebelum titik1

                waktu_pelayanan = waktu_pelayanan_penghasil(titik1);
                waktu_datang_titik_sebelum1 = waktu_datang(jumlah_pangkalan+titik1,index_kendaraan1);
                temp_waktu_datang = waktu_datang;
                waktu_total(jumlah_pangkalan+titik1,jumlah_pangkalan+penghasil);
                waktu_datang(jumlah_pangkalan+penghasil,index_kendaraan1) = waktu_total(jumlah_pangkalan+titik1,jumlah_pangkalan+penghasil)+waktu_pelayanan+waktu_datang_titik_sebelum1;
                tes_waktu = waktu_datang(jumlah_pangkalan+penghasil,index_kendaraan1);
                waktu_buka = buka_penghasil(penghasil);
                waktu_tutup = tutup_penghasil(penghasil);

                if waktu_datang(jumlah_pangkalan+penghasil,index_kendaraan1) > waktu_tutup
                    a=0;
%                     status_penghasil(penghasil) = 0;
                    waktu_datang = temp_waktu_datang;
%                     status_penghasil(titik1) = 999;
                    solusi;
                    break
                end
                c=0;
                if waktu_datang(jumlah_pangkalan+penghasil,index_kendaraan1) < waktu_buka
                    waktu_datang(jumlah_pangkalan+penghasil,index_kendaraan1) = waktu_buka;
                end

                jumlah_angkut_titik_sebelum = jumlah_angkut(jumlah_pangkalan+titik1,index_kendaraan1);
                temp_jumlah_angkut = jumlah_angkut;
                jumlah_angkut(jumlah_pangkalan+penghasil,index_kendaraan1) = jumlah_limbah(penghasil);
                total_angkut = sum(jumlah_angkut(:,index_kendaraan1));
                kapasitas_kendaraan_1(index_kendaraan1);
                
                gudang = find(status_gudang == 1);
                status_gudang_kendaraan(gudang,index_kendaraan1) = 1;
                total_jumlah_angkut = transpose(sum(jumlah_angkut));
                angkut_gudang = status_gudang_kendaraan*total_jumlah_angkut;
                limbah_gudang = angkut_gudang(gudang);
                status_gudang_kendaraan(gudang,index_kendaraan1) = 0;

                if total_angkut > kapasitas_kendaraan_1(index_kendaraan1)
                    b=1;
%                     status_penghasil(penghasil) = 0;
                    waktu_datang = temp_waktu_datang;
                    jumlah_angkut = temp_jumlah_angkut;
%                     status_penghasil(titik1) = 999;
                    break
                end
                
                if limbah_gudang > kapasitas_kand_gudang(gudang)
                    gudang_penuh = 1;
                    jumlah_angkut(jumlah_pangkalan+penghasil,index_kendaraan1) = 0;
                    break
                end

                if find(status_penghasil == 999)
                    cari1 = find(status_penghasil == 999);
                    status_penghasil(cari1) = 1;
                end

                if status_penghasil == 999
                    status_penghasil = 0;
                end
                h=0;
                biaya_pangkalan_penghasil(:,jumlah_pangkalan+penghasil) = 9999999;
                biaya_total1(:,jumlah_pangkalan+penghasil) = 9999999;
                status_x(jumlah_pangkalan+titik1,jumlah_pangkalan+penghasil,index_kendaraan1) = 1;
                status_penghasil_kendaraan(penghasil,index_kendaraan1) = 1;
                status_penghasil(titik1) = 9999999;
                status_penghasil(penghasil) = 1;
                total_penghasil(penghasil) = 1;

                solusi{index_kendaraan1} = [solusi{index_kendaraan1},penghasil];
            end
            break
        end
        
        if status_penghasil(penghasil) == 1
            titik1 = penghasil;
        end

        gudang = find(status_gudang == 1);
        biaya_perjalanan2 = biaya_total1(jumlah_pangkalan+titik1,jumlah_pangkalan+jumlah_penghasil+gudang);
        biaya_min = min(biaya_perjalanan2);
    %     [titik3,titik4] = find(biaya_min == biaya_total1(jumlah_pangkalan+1:jumlah_pangkalan+jumlah_penghasil,jumlah_pangkalan+jumlah_penghasil+gudang))
        %titik3 = lokasi baris penghasil terakhir, yg digunakan
        [titik5,titik6] = find(biaya_min == biaya_total1(jumlah_pangkalan+titik1,jumlah_pangkalan+jumlah_penghasil+1:jumlah_pangkalan+jumlah_penghasil+jumlah_kand_gudang));
        %titik6 = lokasi kolom gudang yang terdekat
        gudang_terpilih = titik6;

        status_x(jumlah_pangkalan+titik1,jumlah_pangkalan+jumlah_penghasil+gudang_terpilih,index_kendaraan1) = 1;
        status_x(jumlah_pangkalan+jumlah_penghasil+gudang_terpilih,index_pangkalan,index_kendaraan1) = 1;

        status_penghasil(titik1) = 2;
        status_gudang_kendaraan(gudang_terpilih,index_kendaraan1) = 1;
        solusi{index_kendaraan1} = [solusi{index_kendaraan1},gudang_terpilih];
        solusi{index_kendaraan1} = [solusi{index_kendaraan1},index_pangkalan];
        
        fx = find(status_penghasil ~= 0);
        ee=length(fx);
        jumlah_penghasil;
        if length(fx) == jumlah_penghasil
            break
        end
        
        if gudang_penuh == 1
            status_gudang(gudang_terpilih) = 999;
            cari_gudang = find(status_gudang == 0);
            pilih_gudang = randi([1 length(cari_gudang)]);
            index_gudang = cari_gudang(pilih_gudang);
            status_gudang(index_gudang) = 1;
            gudang_penuh = 0;
        end
    end

    total_pangkalan_kendaraan = sum(transpose(status_pangkalan_kendaraan));
    fa = total_pangkalan_kendaraan(index_pangkalan);

    if fa > 1
        status_pangkalan(1:jumlah_pangkalan) = 1;
        break
    end
    
    cari_penghasil2 = find(status_penghasil == 999);
    status_penghasil(cari_penghasil2) = 1;
    status_pangkalan(:) = 0;
    kapasitas_kendaraan_1 = kapasitas_kendaraan1_sementara;
    fgfg = status_kendaraan1;
    ww = waktu_datang;
end
gudang_buka = find(status_gudang == 999);
status_gudang(gudang_buka) = 1;
aa = find(status_penghasil == 1);
hj = status_penghasil;
sum(status_kendaraan1) <= jumlah_kendaraan_1;
kapasitas_kendaraan_1 = temp_kapasitas_kendaraan_1;

total_jumlah_angkut = transpose(sum(jumlah_angkut));
angkut_gudang = status_gudang_kendaraan*total_jumlah_angkut;
temp_status_gudang = status_gudang;
for gudang = find(status_gudang == 1)
    
    cari_kendaraan2 = find(status_kendaraan2 == 0);
    pilih_kendaraan2 = randi([1 length(cari_kendaraan2)]);
    index_kendaraan2 = cari_kendaraan2(pilih_kendaraan2);
    
    index_pengolah = find(status_pengolah == 1);
    
    jumlah_angkut2 = angkut_gudang(gudang);
    
    if jumlah_angkut2 > kapasitas_kendaraan_2(index_kendaraan2)
        status_kendaraan2 = 999;
        continue
    end
    
    if status_kendaraan2 == 999
        status_kendaraan2 = 1;
    end
    
    total_angkut_gudang = sum(angkut_gudang);
    angkut_pengolah = sum(angkut_gudang);
    total_limbah = sum(jumlah_limbah);
    total_limbah = total_angkut_gudang;
    
    
    rute_2 = [gudang index_pengolah];
    
    status_r(gudang,jumlah_kand_gudang+index_pengolah,index_kendaraan2) = 1;
    status_r(jumlah_kand_gudang+index_pengolah,gudang,index_kendaraan2) = 1;
    
    solusi2{index_kendaraan2} = rute_2;
    solusi2{index_kendaraan2} = [solusi2{index_kendaraan2},gudang];
    
end
tw = waktu_datang;
ts = solusi;
tts = solusi2;
sp = status_penghasil;
%biaya perjalanan 1
biaya_total1 = temp_biaya_total1;
seluruh_x = sum(status_x,3);
cari_x = find(seluruh_x == 1);
cari_x2 = find(seluruh_x > 1);
jumlah_x2 = seluruh_x(cari_x2);
total_x = biaya_total1(cari_x);
t_x2 = biaya_total1(cari_x2);
for i = 1:length(jumlah_x2)
    total_x2(i) = t_x2(i) * jumlah_x2(i);
end
if length(jumlah_x2) == 0
    total_x2 = 0;
end
total_biaya_x = sum(total_x) + sum(total_x2);
t_status_x = status_x;

%biaya perjalanan 2
seluruh_r = sum(status_r,3);
cari_r = find(seluruh_r == 1);
total_r = biaya_total2(cari_r);
total_biaya_r = sum(total_r);

%biaya buka gudang
status_gudang = temp_status_gudang;
biaya_gudang = status_gudang*biaya_buka_gudang;

%biaya buka pengolah
tp = status_pengolah;
biaya_pengolah = status_pengolah*biaya_buka_pengolah;

total1 = total_biaya_x + biaya_gudang + biaya_pengolah + total_biaya_r;
temp_total1 = total1;

%% ALGORITMA SIMULATED ANNEALING

%% DATA PARAMETER SIMULATED ANNEALING
% nilai suhu awal
temperatur_awal = 2000;
% nilai suhu akhir
temperatur_akhir = 0.1;
% nilai cooling rate
cooling_rate = 0.7;
% nilai iterasi tiap suhu
iterasi_maksimum = 100;


%% SOLUSI AWAL

total_biaya_awal = total1;
sa_status_x = status_x;
sa_status_r = status_r;
sa_status_plant = status_pengolah;
sa_status_gudang = status_gudang;
sa_status_gudang_kendaraan = status_gudang_kendaraan;
sa_status_gudang_kendaraan2 = status_gudang_kendaraan2;
sa_status_kendaraan1 = status_kendaraan1;
sa_status_kendaraan2 = status_kendaraan2;
sa_status_pangkalan = status_pangkalan;
sa_status_pangkalan_gudang = status_pangkalan_gudang;
sa_status_pangkalan_kendaraan = status_pangkalan_kendaraan;
sa_status_penghasil = status_penghasil;
sa_status_penghasil_kendaraan = status_penghasil_kendaraan;
sa_status_plant = status_pengolah;
sa_status_gudang = status_gudang;
sa_jumlah_angkut = jumlah_angkut;
sa_jumlah_angkut2 = jumlah_angkut2;
sa_waktu_datang = waktu_datang;
sa_solusi = solusi;
sa_solusi2 = solusi2;

%% MULAI

while temperatur_awal > temperatur_akhir
    for iterasi = 1:iterasi_maksimum
%         iterasi
        pilih_operator = randi([1 6]);
        
        total_biaya_awal = total1;
        awal_total_biaya_x = total_biaya_x;
        awal_biaya_gudang = biaya_gudang;
        awal_biaya_pengolah = biaya_pengolah;
        awal_total_biaya_r = total_biaya_r;
        
        sa_status_x = status_x;
        sa_status_r = status_r;
        sa_status_plant = status_pengolah;
        sa_status_gudang = status_gudang;
%         sa_status_gudang = [1 0 1 1];
        sa_status_gudang_kendaraan = status_gudang_kendaraan;
        sa_status_gudang_kendaraan2 = status_gudang_kendaraan2;
        sa_status_kendaraan1 = status_kendaraan1;
        sa_status_kendaraan2 = status_kendaraan2;
        sa_status_pangkalan = status_pangkalan;
        sa_status_pangkalan_gudang = status_pangkalan_gudang;
        sa_status_pangkalan_kendaraan = status_pangkalan_kendaraan;
        sa_status_penghasil = status_penghasil;
        sa_status_penghasil_kendaraan = status_penghasil_kendaraan;
        sa_status_plant = status_pengolah;
        sa_status_gudang = status_gudang;
        sa_jumlah_angkut = jumlah_angkut;
        sa_jumlah_angkut2 = jumlah_angkut2;
        sa_waktu_datang = waktu_datang;
        sa_solusi = solusi;
        sa_solusi2 = solusi2;
        
        %case 1 = tutup gudang terbuka, pilih random 1 gdg tertutup dan buka
        if pilih_operator == 1
            pilih_operator;
            sa_status_gudang;
            sa_status_gudang_kendaraan;
            if (sum(sa_status_gudang) == jumlah_kand_gudang)
                continue
            end
            
            temp_sa_status_x = sa_status_x;
            jumlah_kand_gudang_terbuka = find(sa_status_gudang == 1);
            jumlah_penghasil_terakhir = find(sa_status_penghasil == 2);
            
            % menghapus rute lama
            for i = 1:length(jumlah_kand_gudang_terbuka)
                gudang_terbuka = jumlah_kand_gudang_terbuka(i);
                for j = 1:length(jumlah_penghasil_terakhir)
                    penghasil = jumlah_penghasil_terakhir(j);
                    index_kendaraan1 = find(sa_status_penghasil_kendaraan(penghasil,:) == 1);
                    
                    pangkalan = find(sa_status_pangkalan_kendaraan(:,index_kendaraan1) == 1);
                    
                    sa_status_x(jumlah_pangkalan+penghasil,jumlah_pangkalan+jumlah_penghasil+gudang_terbuka,index_kendaraan1) = 0;
                    sa_status_x(jumlah_pangkalan+jumlah_penghasil+gudang_terbuka,pangkalan,index_kendaraan1) = 0;
                end
            end
            
            
            jumlah_gudang_terbuka = find(sa_status_gudang == 1);
            cari_gudang_terbuka = randi([1 length(jumlah_gudang_terbuka)]);
            index_gudang_terbuka = jumlah_gudang_terbuka(cari_gudang_terbuka);
            
            jumlah_gudang_tertutup = find(sa_status_gudang == 0);
            pilih_gudang_tertutup = randi([1 length(jumlah_gudang_tertutup)]);
            index_gudang_tertutup = jumlah_gudang_tertutup(pilih_gudang_tertutup);
            
            index_kendaraan1 = find(sa_status_kendaraan1 == 1);
            sa_status_gudang_kendaraan(index_gudang_terbuka,index_kendaraan1) = 0;
            sa_status_gudang_kendaraan(index_gudang_tertutup,index_kendaraan1) = 1;
            sa_total_jumlah_angkut = transpose(sum(sa_jumlah_angkut));
            sa_angkut_gudang = sa_status_gudang_kendaraan*sa_total_jumlah_angkut;
            sa_limbah_gudang = sa_angkut_gudang(index_gudang_tertutup);
            sa_status_gudang_kendaraan(index_gudang_tertutup,index_kendaraan1) = 0;
            sa_status_gudang_kendaraan(index_gudang_terbuka,index_kendaraan1) = 1;
            kj = 0;
            
            sa_status_gudang_kendaraan(index_gudang_terbuka,:) = 0;
            
            if sa_limbah_gudang > kapasitas_kand_gudang(index_gudang_tertutup)
                sa_status_x = temp_sa_status_x;
                continue
            end
                
            sa_status_gudang(index_gudang_terbuka) = 0;
            sa_status_gudang(index_gudang_tertutup) = 1;

            sa_status_gudang(index_gudang_terbuka) = 0;
            sa_status_gudang(index_gudang_tertutup) = 1;
            
            % membentuk rute baru
            for j = 1:length(jumlah_penghasil_terakhir)
                penghasil = jumlah_penghasil_terakhir(j);
                
                index_kendaraan1 = find(sa_status_penghasil_kendaraan(penghasil,:) == 1);
                    
                pangkalan = find(sa_status_pangkalan_kendaraan(:,index_kendaraan1) == 1);
                
                % temukan gudang terdekat dari penghasil
                cari_gudang = find(sa_status_gudang == 1);
                pilih_gudang = biaya_total1(jumlah_pangkalan+penghasil,jumlah_pangkalan+jumlah_penghasil+cari_gudang);
                min_gudang = min(pilih_gudang);
                buka_gudang = find(min_gudang == biaya_total1(jumlah_pangkalan+penghasil,jumlah_pangkalan+jumlah_penghasil+cari_gudang));
                index_gudang = cari_gudang(buka_gudang);
                
                % set gudang terpilih dan pangkalan jadi 1
                sa_status_x(jumlah_pangkalan+penghasil,jumlah_pangkalan+jumlah_penghasil+index_gudang,index_kendaraan1) = 1;
                sa_status_x(jumlah_pangkalan+jumlah_penghasil+index_gudang,pangkalan,index_kendaraan1) = 1;
                
                sa_status_gudang_kendaraan(index_gudang,index_kendaraan1) = 1;
                
                rute_lama = sa_solusi{index_kendaraan1};
                rute_lama(end) = [];    % untuk menghapus pangkalan terakhir dari rute
                rute_lama(end) = [];     % untuk menghapus gudang terakhir dari rute

                rute_baru = [penghasil index_gudang];

                sa_solusi{index_kendaraan1} = [rute_lama,index_gudang];
                sa_solusi{index_kendaraan1} = [sa_solusi{index_kendaraan1},pangkalan];
            end
                      
            sa_status_r = zeros(jumlah_kand_gudang+jumlah_kand_pengolah,jumlah_kand_gudang+jumlah_kand_pengolah,jumlah_kendaraan_2);
            jumlah_angkut2 = zeros(jumlah_kand_gudang+jumlah_kand_pengolah,jumlah_kendaraan_2);
            sa_solusi2 = [];
            for gudang = find(sa_status_gudang == 1)

                cari_kendaraan2 = find(sa_status_kendaraan2 == 0);
                pilih_kendaraan2 = randi([1 length(cari_kendaraan2)]);
                index_kendaraan2 = cari_kendaraan2(pilih_kendaraan2);

                index_pengolah = find(sa_status_plant == 1);

                jumlah_angkut2(index_pengolah,index_kendaraan2) = jumlah_limbah2(gudang);

                if jumlah_angkut2(index_pengolah,index_kendaraan2) > kapasitas_kendaraan_2(index_kendaraan2)
                    status_kendaraan2 = 999;
                    continue
                end

                if status_kendaraan2 == 999
                    status_kendaraan2 = 1;
                end
                
                rute_2 = [gudang index_pengolah];

                sa_status_r(gudang,jumlah_kand_gudang+index_pengolah,index_kendaraan2) = 1;
                sa_status_r(jumlah_kand_gudang+index_pengolah,gudang,index_kendaraan2) = 1;

                sa_solusi2{index_kendaraan2} = rute_2;
                sa_solusi2{index_kendaraan2} = [sa_solusi2{index_kendaraan2},gudang];
                sar1 = sa_solusi2;
            end
            sa_status_gudang;
            sa_status_gudang_kendaraan;
        
        % case 2 = pilih gudang tertutup dan buka, sehingga jlh gdg nambah
        elseif pilih_operator == 2
            pilih_operator;
            sa_status_gudang;
            sa_status_gudang_kendaraan;
            if (sum(sa_status_gudang) == jumlah_kand_gudang)
                continue
            end
            
            temp_sa_status_x = sa_status_x;
            temp_sa_status_gudang_kendaraan = sa_status_gudang_kendaraan;
            jumlah_kand_gudang_terbuka = find(sa_status_gudang == 1);
            jumlah_penghasil_terakhir = find(sa_status_penghasil == 2);
            
            % menghapus rute lama
            for i = 1:length(jumlah_kand_gudang_terbuka)
                gudang_terbuka = jumlah_kand_gudang_terbuka(i);
                for j = 1:length(jumlah_penghasil_terakhir)
                    penghasil = jumlah_penghasil_terakhir(j);
                    index_kendaraan1 = find(sa_status_penghasil_kendaraan(penghasil,:) == 1);
                    
                    pangkalan = find(sa_status_pangkalan_kendaraan(:,index_kendaraan1) == 1);
                    
                    sa_status_x(jumlah_pangkalan+penghasil,jumlah_pangkalan+jumlah_penghasil+gudang_terbuka,index_kendaraan1) = 0;
                    sa_status_x(jumlah_pangkalan+jumlah_penghasil+gudang_terbuka,pangkalan,index_kendaraan1) = 0;
                end
            end

            jumlah_gudang_tertutup = find(sa_status_gudang == 0);
            pilih_gudang_tertutup = randi([1 length(jumlah_gudang_tertutup)]);
            index_gudang_tertutup = jumlah_gudang_tertutup(pilih_gudang_tertutup);
            index_gudang_terbuka = find(sa_status_gudang == 1);
            
            index_kendaraan1 = find(sa_status_kendaraan1 == 1);
            sa_status_gudang_kendaraan(index_gudang_tertutup,index_kendaraan1) = 1;
            sa_total_jumlah_angkut = transpose(sum(sa_jumlah_angkut));
            sa_angkut_gudang = sa_status_gudang_kendaraan*sa_total_jumlah_angkut;
            sa_limbah_gudang = sa_angkut_gudang(index_gudang_tertutup);
            sa_status_gudang_kendaraan(index_gudang_tertutup,index_kendaraan1) = 0;
            
            if sa_limbah_gudang > kapasitas_kand_gudang(index_gudang_tertutup)
                sa_status_gudang_kendaraan = temp_sa_status_gudang_kendaraan;
                sa_status_x = temp_sa_status_x;
                continue
            end
            
            sa_status_gudang_kendaraan(index_gudang_terbuka,:) = 0;
                
            sa_status_gudang(index_gudang_tertutup) = 1;
            
            % membentuk rute baru
            for j = 1:length(jumlah_penghasil_terakhir)
                penghasil = jumlah_penghasil_terakhir(j);
                
                index_kendaraan1 = find(sa_status_penghasil_kendaraan(penghasil,:) == 1);
                    
                pangkalan = find(sa_status_pangkalan_kendaraan(:,index_kendaraan1) == 1);
                
                % temukan gudang terdekat dari penghasil
                cari_gudang = find(sa_status_gudang == 1);
                pilih_gudang = biaya_total1(jumlah_pangkalan+penghasil,jumlah_pangkalan+jumlah_penghasil+cari_gudang);
                min_gudang = min(pilih_gudang);
                buka_gudang = find(min_gudang == biaya_total1(jumlah_pangkalan+penghasil,jumlah_pangkalan+jumlah_penghasil+cari_gudang));
                index_gudang = cari_gudang(buka_gudang);
                
                % set gudang terpilih dan pangkalan jadi 1
                sa_status_x(jumlah_pangkalan+penghasil,jumlah_pangkalan+jumlah_penghasil+index_gudang,index_kendaraan1) = 1;
                sa_status_x(jumlah_pangkalan+jumlah_penghasil+index_gudang,pangkalan,index_kendaraan1) = 1;
                
                sa_status_gudang_kendaraan(index_gudang,index_kendaraan1) = 1;
                
                rute_lama = sa_solusi{index_kendaraan1};
                rute_lama(end) = [];    % untuk menghapus pangkalan terakhir dari rute
                rute_lama(end) = [];     % untuk menghapus gudang terakhir dari rute

                rute_baru = [penghasil index_gudang];

                sa_solusi{index_kendaraan1} = [rute_lama,index_gudang];
                sa_solusi{index_kendaraan1} = [sa_solusi{index_kendaraan1},pangkalan];
            end
            
            sa_status_r = zeros(jumlah_kand_gudang+jumlah_kand_pengolah,jumlah_kand_gudang+jumlah_kand_pengolah,jumlah_kendaraan_2);
            jumlah_angkut2 = zeros(jumlah_kand_gudang+jumlah_kand_pengolah,jumlah_kendaraan_2);
            sa_status_kendaraan2 = zeros(1,jumlah_kendaraan_2);
            sa_solusi2 = [];
            for gudang = find(sa_status_gudang == 1)

                cari_kendaraan2 = find(sa_status_kendaraan2 == 0);
                pilih_kendaraan2 = randi([1 length(cari_kendaraan2)]);
                index_kendaraan2 = cari_kendaraan2(pilih_kendaraan2);

                index_pengolah = find(sa_status_plant == 1);

                jumlah_angkut2(index_pengolah,index_kendaraan2) = jumlah_limbah2(gudang);

                if jumlah_angkut2(index_pengolah,index_kendaraan2) > kapasitas_kendaraan_2(index_kendaraan2)
                    status_kendaraan2 = 999;
                    continue
                end

                if status_kendaraan2 == 999
                    status_kendaraan2 = 1;
                end

                rute_2 = [gudang index_pengolah];
                sa_status_kendaraan2(index_kendaraan2) = 1;

                sa_status_r(gudang,jumlah_kand_gudang+index_pengolah,index_kendaraan2) = 1;
                sa_status_r(jumlah_kand_gudang+index_pengolah,gudang,index_kendaraan2) = 1;

                sa_solusi2{index_kendaraan2} = rute_2;
                sa_solusi2{index_kendaraan2} = [sa_solusi2{index_kendaraan2},gudang];

            end
            sa_status_gudang;
            sa_status_gudang_kendaraan;
            
        % case 3 = pilih gudang terbuka dan tutup
        elseif pilih_operator == 3
            pilih_operator;
            sa_status_gudang;
            sa_status_gudang_kendaraan;
            if sum(sa_status_gudang) == 1
                continue
            end
            
            temp_sa_status_gudang = sa_status_gudang;
            temp_sa_status_x = sa_status_x;
            jumlah_kand_gudang_terbuka = find(sa_status_gudang == 1);
            jumlah_penghasil_terakhir = find(sa_status_penghasil == 2);
            
            % menghapus rute lama
            for i = 1:length(jumlah_kand_gudang_terbuka)
                gudang_terbuka = jumlah_kand_gudang_terbuka(i);
                for j = 1:length(jumlah_penghasil_terakhir)
                    penghasil = jumlah_penghasil_terakhir(j);
                    index_kendaraan1 = find(sa_status_penghasil_kendaraan(penghasil,:) == 1);
                    
                    pangkalan = find(sa_status_pangkalan_kendaraan(:,index_kendaraan1) == 1);
                    
                    sa_status_x(jumlah_pangkalan+penghasil,jumlah_pangkalan+jumlah_penghasil+gudang_terbuka,index_kendaraan1) = 0;
                    sa_status_x(jumlah_pangkalan+jumlah_penghasil+gudang_terbuka,pangkalan,index_kendaraan1) = 0;
                end
            end
            
            jumlah_gudang_terbuka = find(sa_status_gudang == 1);
            cari_gudang_terbuka = randi([1 length(jumlah_gudang_terbuka)]);
            index_gudang_terbuka = jumlah_gudang_terbuka(cari_gudang_terbuka);
 
            sa_status_gudang(index_gudang_terbuka) = 0;
            
            jumlah_gudang_terbuka_b = find(sa_status_gudang == 1);
            cari_gudang_terbuka_b = randi([1 length(jumlah_gudang_terbuka_b)]);
            index_gudang_terbuka_b = jumlah_gudang_terbuka_b(cari_gudang_terbuka_b);
            
            index_kendaraan1 = find(sa_status_kendaraan1 == 1);
            sa_status_gudang_kendaraan(index_gudang_terbuka_b,index_kendaraan1) = 1;
            sa_total_jumlah_angkut = transpose(sum(sa_jumlah_angkut));
            sa_angkut_gudang = sa_status_gudang_kendaraan*sa_total_jumlah_angkut;
            sa_limbah_gudang = sa_angkut_gudang(index_gudang_terbuka_b);
            sa_status_gudang_kendaraan(index_gudang_terbuka_b,index_kendaraan1) = 0;
            
            if sa_limbah_gudang > kapasitas_kand_gudang(index_gudang_terbuka_b)
                sa_status_x = temp_sa_status_x;
                continue
            end

            % membentuk rute baru
            for j = 1:length(jumlah_penghasil_terakhir)
                penghasil = jumlah_penghasil_terakhir(j);
                
                index_kendaraan1 = find(sa_status_penghasil_kendaraan(penghasil,:) == 1);
                    
                pangkalan = find(sa_status_pangkalan_kendaraan(:,index_kendaraan1) == 1);
                
                % temukan gudang terdekat dari penghasil
                cari_gudang = find(sa_status_gudang == 1);
                pilih_gudang = biaya_total1(jumlah_pangkalan+penghasil,jumlah_pangkalan+jumlah_penghasil+cari_gudang);
                min_gudang = min(pilih_gudang);
                buka_gudang = find(min_gudang == biaya_total1(jumlah_pangkalan+penghasil,jumlah_pangkalan+jumlah_penghasil+cari_gudang));
                index_gudang = cari_gudang(buka_gudang);
                
                % set gudang terpilih dan pangkalan jadi 1
                sa_status_x(jumlah_pangkalan+penghasil,jumlah_pangkalan+jumlah_penghasil+index_gudang,index_kendaraan1) = 1;
                sa_status_x(jumlah_pangkalan+jumlah_penghasil+index_gudang,pangkalan,index_kendaraan1) = 1;
                
                rute_lama = sa_solusi{index_kendaraan1};
                rute_lama(end) = [];    % untuk menghapus pangkalan terakhir dari rute
                rute_lama(end) = [];     % untuk menghapus gudang terakhir dari rute

                rute_baru = [penghasil index_gudang];

                sa_solusi{index_kendaraan1} = [rute_lama,index_gudang];
                sa_solusi{index_kendaraan1} = [sa_solusi{index_kendaraan1},pangkalan];
            end

            sa_status_r = zeros(jumlah_kand_gudang+jumlah_kand_pengolah,jumlah_kand_gudang+jumlah_kand_pengolah,jumlah_kendaraan_2);
            jumlah_angkut2 = zeros(jumlah_kand_gudang+jumlah_kand_pengolah,jumlah_kendaraan_2);
            sa_status_kendaraan2 = zeros(1,jumlah_kendaraan_2);
            sa_status_gudang;
            sa_solusi2 = [];
            for gudang = find(sa_status_gudang == 1)

                cari_kendaraan2 = find(sa_status_kendaraan2 == 0);
                pilih_kendaraan2 = randi([1 length(cari_kendaraan2)]);
                index_kendaraan2 = cari_kendaraan2(pilih_kendaraan2);

                index_pengolah = find(sa_status_plant == 1);

                jumlah_angkut2(index_pengolah,index_kendaraan2) = jumlah_limbah2(gudang);

                if jumlah_angkut2(index_pengolah,index_kendaraan2) > kapasitas_kendaraan_2(index_kendaraan2)
                    status_kendaraan2 = 999;
                    continue
                end

                if status_kendaraan2 == 999
                    status_kendaraan2 = 1;
                end
                
                
                rute_2 = [gudang index_pengolah];
                sa_status_kendaraan2(index_kendaraan2) = 1;

                sa_status_r(gudang,jumlah_kand_gudang+index_pengolah,index_kendaraan2) = 1;
                sa_status_r(jumlah_kand_gudang+index_pengolah,gudang,index_kendaraan2) = 1;

                sa_solusi2{index_kendaraan2} = rute_2;
                sa_solusi2{index_kendaraan2} = [sa_solusi2{index_kendaraan2},gudang];

            end
            sa_status_gudang;
            sa_status_gudang_kendaraan;
            
        % case 4 = tutup pengolah terbuka, pilih random pengolah tertutup dan buka
        elseif pilih_operator == 4
            pilih_operator;
            
            jumlah_plant_terbuka = find(sa_status_plant == 1);
            cari_pengolah_terbuka = randi([1 length(jumlah_plant_terbuka)]);
            index_pengolah_terbuka = jumlah_plant_terbuka(cari_pengolah_terbuka);
            
            jumlah_plant_tertutup = find(sa_status_plant == 0);
            pilih_pengolah_tertutup = randi([1 length(jumlah_plant_tertutup)]);
            index_pengolah_tertutup = jumlah_plant_tertutup(pilih_pengolah_tertutup);
                
            sa_status_plant(index_pengolah_terbuka) = 0;
            sa_status_plant(index_pengolah_tertutup) = 1;
           
            sa_status_r = zeros(jumlah_kand_gudang+jumlah_kand_pengolah,jumlah_kand_gudang+jumlah_kand_pengolah,jumlah_kendaraan_2);
            jumlah_angkut2 = zeros(jumlah_kand_gudang+jumlah_kand_pengolah,jumlah_kendaraan_2);
            sa_solusi2 = [];
%             sa_status_plant = sa_status_plant;
            for gudang = find(sa_status_gudang == 1)

                cari_kendaraan2 = find(sa_status_kendaraan2 == 0);
                pilih_kendaraan2 = randi([1 length(cari_kendaraan2)]);
                index_kendaraan2 = cari_kendaraan2(pilih_kendaraan2);

                index_pengolah = find(sa_status_plant == 1);

                jumlah_angkut2(index_pengolah,index_kendaraan2) = jumlah_limbah2(gudang);
                angkut_pengolah = sum(jumlah_angkut2);

                if jumlah_angkut2(index_pengolah,index_kendaraan2) > kapasitas_kendaraan_2(index_kendaraan2)
                    status_kendaraan2 = 999;
                    continue
                end

                if status_kendaraan2 == 999
                    status_kendaraan2 = 1;
                end
                
                rute_2 = [gudang index_pengolah];

                sa_status_r(gudang,jumlah_kand_gudang+index_pengolah,index_kendaraan2) = 1;
                sa_status_r(jumlah_kand_gudang+index_pengolah,gudang,index_kendaraan2) = 1;

                sa_solusi2{index_kendaraan2} = rute_2;
                sa_solusi2{index_kendaraan2} = [sa_solusi2{index_kendaraan2},gudang];

            end
            
        % case 5 = pilih 2 penghasil random untuk pangkalan lalu swap
        elseif pilih_operator == 5
            pilih_operator;
            sa_status_gudang;
            sa_status_gudang_kendaraan;
            
            % set data temp
            temp_sa_jumlah_angkut = sa_jumlah_angkut;
            temp_sa_status_x = sa_status_x;
            temp_sa_waktu_datang = sa_waktu_datang;
            temp_sa_solusi = sa_solusi;
            kon = false;
            
            cari_kendaraan1 = find(sa_status_kendaraan1 == 1);
            pilih_kendaraan1 = randi([1 length(cari_kendaraan1)]);
            index_kendaraan1 = cari_kendaraan1(pilih_kendaraan1);
            sa_status_gudang_kendaraan;
            index_gudang_1 = find(sa_status_gudang_kendaraan(:,index_kendaraan1) == 1);
            semua_kendaraan_1 = find(sa_status_gudang_kendaraan(index_gudang_1,:) == 1);
            sa_status_kendaraan1(index_kendaraan1) = 0;
            
            cari_kendaraan2 = find(sa_status_kendaraan1 == 1);
            pilih_kendaraan2 = randi([1 length(cari_kendaraan2)]);
            index_kendaraan2 = cari_kendaraan2(pilih_kendaraan2);
            index_gudang_2 = find(sa_status_gudang_kendaraan(:,index_kendaraan2) == 1);
            semua_kendaraan_2 = find(sa_status_gudang_kendaraan(index_gudang_2,:) == 1);
            
            rute_swap1 = sa_solusi{index_kendaraan1};
            rute_swap2 = sa_solusi{index_kendaraan2};
            
            elemen_swap1 = randi([2 length(rute_swap1)-2]);
            elemen_swap2 = randi([2 length(rute_swap2)-2]);
            penghasil1 = rute_swap1(elemen_swap1);
            penghasil2 = rute_swap2(elemen_swap2);
            
            rute_swap1(elemen_swap1) = penghasil2;
            rute_swap2(elemen_swap2) = penghasil1;
            
            % hapus jumlah muatan pada titik sebelum
            sa_jumlah_angkut(jumlah_pangkalan+penghasil1,index_kendaraan1) = 0;
            sa_jumlah_angkut(jumlah_pangkalan+penghasil2,index_kendaraan2) = 0;
            
            % masukkan jumlah limbah baru yang diangkut
            sa_jumlah_angkut(jumlah_pangkalan+penghasil2,index_kendaraan1) = jumlah_limbah(penghasil2);
            sa_jumlah_angkut(jumlah_pangkalan+penghasil1,index_kendaraan2) = jumlah_limbah(penghasil1);
            
            total_angkut1 = sum(sa_jumlah_angkut(:,index_kendaraan1));
            total_angkut2 = sum(sa_jumlah_angkut(:,index_kendaraan2));
            kapasitas_kendaraan_1(index_kendaraan1);
            kapasitas_kendaraan_1(index_kendaraan2);
            
            if total_angkut1 > kapasitas_kendaraan_1(index_kendaraan1) | total_angkut2 > kapasitas_kendaraan_1(index_kendaraan2)
                continue
            end
            
            % hitung total limbah yang diangkut ke gudang 1
            angkut_gudang_1 = sum(sa_jumlah_angkut(:,semua_kendaraan_1));
            total_angkut_gudang_1 = sum(angkut_gudang_1);
            
            % hitung total limbah yang diangkut ke gudang 2
            angkut_gudang_2 = sum(sa_jumlah_angkut(:,semua_kendaraan_2));
            total_angkut_gudang_2 = sum(angkut_gudang_2);
            
            if total_angkut_gudang_1 > kapasitas_kand_gudang(index_gudang_1) | total_angkut_gudang_2 > kapasitas_kand_gudang(index_gudang_2)
                continue
            end

            % cari titik sebelum penghasil1
            titik_y1 = find(sa_status_x(:,jumlah_pangkalan+penghasil1,index_kendaraan1) == 1);
            %cari titik setelah penghasil1
            titik_x1 = find(sa_status_x(jumlah_pangkalan+penghasil1,:,index_kendaraan1) == 1);
            
            % cari titik sebelum penghasil2
            titik_y2 = find(sa_status_x(:,jumlah_pangkalan+penghasil2,index_kendaraan2) == 1);
            %cari titik setelah penghasil1
            titik_x2 = find(sa_status_x(jumlah_pangkalan+penghasil2,:,index_kendaraan2) == 1);

            % hapus nilai dari penghasil pada titik sebelum dan setelahnya
            sa_status_x(titik_y1,jumlah_pangkalan+penghasil1,index_kendaraan1) = 0;
            sa_status_x(jumlah_pangkalan+penghasil1,titik_x1,index_kendaraan1) = 0;
            
            sa_status_x(titik_y2,jumlah_pangkalan+penghasil2,index_kendaraan2) = 0;
            sa_status_x(jumlah_pangkalan+penghasil2,titik_x2,index_kendaraan2) = 0;           
            
            % pasangkan penghasil baru ke titik lama
            sa_status_x(titik_y1,jumlah_pangkalan+penghasil2,index_kendaraan1) = 1;
            sa_status_x(jumlah_pangkalan+penghasil2,titik_x1,index_kendaraan1) = 1;
            
            sa_status_x(titik_y2,jumlah_pangkalan+penghasil1,index_kendaraan2) = 1;
            sa_status_x(jumlah_pangkalan+penghasil1,titik_x2,index_kendaraan2) = 1;
            

            % hapuskan waktu terdahulu
            sa_waktu_datang(:,index_kendaraan1) = 0;
            sa_waktu_datang(:,index_kendaraan2) = 0;

            % perhitungan waktu untuk kendaraan1 / rute swap1
            for penghasil3 = 2:length(rute_swap1)-2
                penghasil3;
                penghasil4 = rute_swap1(penghasil3);
                % waktu penghasil 1
                titik7 = find(sa_status_x(:,jumlah_pangkalan+penghasil4,index_kendaraan1) == 1);
                %titik0 = lokasi titik sebelum titik1
                
                waktu_buka = buka_penghasil(penghasil4);
                waktu_tutup = tutup_penghasil(penghasil4);
                
                if penghasil3 > 2
                    waktu_pelayanan = waktu_pelayanan_penghasil(titik7-jumlah_pangkalan);
                    waktu_datang_titik_sebelum = sa_waktu_datang(titik7,index_kendaraan1);
                    sa_waktu_datang(jumlah_pangkalan+penghasil4,index_kendaraan1) = waktu_total(titik7,jumlah_pangkalan+penghasil4)+waktu_pelayanan+waktu_datang_titik_sebelum;
                elseif penghasil3 == 2
                    waktu_pelayanan = 0;
                    waktu_datang_titik_sebelum = sa_waktu_datang(titik7,index_kendaraan1);
                    sa_waktu_datang(jumlah_pangkalan+penghasil4,index_kendaraan1) = waktu_total(titik7,jumlah_pangkalan+penghasil4)+waktu_pelayanan+waktu_datang_titik_sebelum;
                end
                
                if sa_waktu_datang(jumlah_pangkalan+penghasil4,index_kendaraan1) > waktu_tutup
                    jumlah_angkut = temp_sa_jumlah_angkut;
                    status_x = temp_sa_status_x;
                    waktu_datang = temp_sa_waktu_datang;
                    solusi = temp_sa_solusi;
                    kon = true;
                    continue
                end
                
                if sa_waktu_datang(jumlah_pangkalan+penghasil4,index_kendaraan1) < waktu_buka
                    sa_waktu_datang(jumlah_pangkalan+penghasil4,index_kendaraan1) = waktu_buka;
                end
                
            end
            
            if (kon)
                continue
            end
            
            % perhitungan waktu untuk kendaraan2 / rute swap2
            for penghasil5 = 2:length(rute_swap2)-2
                penghasil5;
                penghasil6 = rute_swap2(penghasil5);
                % waktu penghasil 1
                titik7 = find(sa_status_x(:,jumlah_pangkalan+penghasil6,index_kendaraan2) == 1);
                %titik0 = lokasi titik sebelum titik1
                
                if penghasil5 > 2
                    waktu_pelayanan = waktu_pelayanan_penghasil(titik7-jumlah_pangkalan);
                    waktu_datang_titik_sebelum = sa_waktu_datang(titik7,index_kendaraan2);
                    sa_waktu_datang(jumlah_pangkalan+penghasil6,index_kendaraan2) = waktu_total(titik7,jumlah_pangkalan+penghasil6)+waktu_pelayanan+waktu_datang_titik_sebelum;
                elseif penghasil5 == 2
                    waktu_pelayanan = 0;
                    waktu_datang_titik_sebelum = sa_waktu_datang(titik7,index_kendaraan2);
                    sa_waktu_datang(jumlah_pangkalan+penghasil6,index_kendaraan2) = waktu_total(titik7,jumlah_pangkalan+penghasil6)+waktu_pelayanan+waktu_datang_titik_sebelum;
                end
                
                if sa_waktu_datang(jumlah_pangkalan+penghasil6,index_kendaraan2) > waktu_tutup
                    jumlah_angkut = temp_sa_jumlah_angkut;
                    status_x = temp_sa_status_x;
                    waktu_datang = temp_sa_waktu_datang;
                    solusi = temp_sa_solusi;
                    kon = true;
                    continue
                end
                
                if sa_waktu_datang(jumlah_pangkalan+penghasil6,index_kendaraan2) < waktu_buka
                    sa_waktu_datang(jumlah_pangkalan+penghasil6,index_kendaraan2) = waktu_buka;
                end
                
            end
            
            if (kon)
                continue
            end
            
            sa_solusi{index_kendaraan1} = rute_swap1;
            sa_solusi{index_kendaraan2} = rute_swap2;
            
            sa_status_kendaraan1(index_kendaraan1) = 1;
            sa_status_gudang;
            sa_status_gudang_kendaraan;
        % case 6 relocation
        elseif pilih_operator == 6
            pilih_operator;
            sa_status_gudang;
            sa_status_gudang_kendaraan;
            
            % set data temp
            temp_sa_jumlah_angkut = sa_jumlah_angkut;
            temp_sa_status_x = sa_status_x;
            temp_sa_waktu_datang = sa_waktu_datang;
            temp_sa_solusi = sa_solusi;
            kon = false;
            
            % kendaraan1 = rute1 yg pelanggannya mau direlokasikan
            % jumlah plgn hrs >= 2
            cari_kendaraan1 = find(sa_status_kendaraan1 == 1);
            pilih_kendaraan1 = randi([1 length(cari_kendaraan1)]);
            index_kendaraan1 = cari_kendaraan1(pilih_kendaraan1);
            index_gudang_1 = find(sa_status_gudang_kendaraan(:,index_kendaraan1) == 1);
            semua_kendaraan_1 = find(sa_status_gudang_kendaraan(index_gudang_1,:) == 1);
            sa_status_kendaraan1(index_kendaraan1) = 0;
            
            cari_kendaraan2 = find(sa_status_kendaraan1 == 1);
            pilih_kendaraan2 = randi([1 length(cari_kendaraan2)]);
            index_kendaraan2 = cari_kendaraan2(pilih_kendaraan2);
            index_gudang_2 = find(sa_status_gudang_kendaraan(:,index_kendaraan2) == 1);
            semua_kendaraan_2 = find(sa_status_gudang_kendaraan(index_gudang_2,:) == 1);
            
            rute_reloc1 = sa_solusi{index_kendaraan1};
            rute_reloc2 = sa_solusi{index_kendaraan2};
            temp_rute_reloc2 = rute_reloc2;
            
            rute1 = [2 length(rute_reloc1)-2];
            rute2 = [2 length(rute_reloc2)-2];

            if rute1 == length(rute_reloc1)-2
                continue
            end
            
            elemen_reloc1 = randi([2 length(rute_reloc1)-2]);
            elemen_reloc2 = length(rute_reloc2)-2;
            r = rute_reloc2;

            penghasil1 = rute_reloc1(elemen_reloc1);
            penghasil2 = rute_reloc2(elemen_reloc2);
            
            gudang_2 = [length(rute_reloc2) - 1];
            gudang_reloc = rute_reloc2(gudang_2);
            rute_reloc2(gudang_2) = [];
            
            pangkalan_2 = [length(rute_reloc2)];
            pangkalan_reloc = rute_reloc2(pangkalan_2);
            rute_reloc2(pangkalan_2) = [];
            
            rute_reloc1(elemen_reloc1) = [];
            sa_solusi{index_kendaraan2} = rute_reloc2;
            sa_solusi{index_kendaraan2} = [sa_solusi{index_kendaraan2},penghasil1];
            sa_solusi{index_kendaraan2} = [sa_solusi{index_kendaraan2},gudang_reloc];
            sa_solusi{index_kendaraan2} = [sa_solusi{index_kendaraan2},pangkalan_reloc];
            
            rute_reloc1;
            rute_reloc2 = sa_solusi{index_kendaraan2};
            
            % hapus jumlah muatan pada titik sebelum
            sa_jumlah_angkut(jumlah_pangkalan+penghasil1,index_kendaraan1) = 0;
%             sa_jumlah_angkut(jumlah_pangkalan+penghasil2,index_kendaraan2) = 0
            
            % masukkan jumlah limbah baru yang diangkut
%             sa_jumlah_angkut(jumlah_pangkalan+penghasil2,index_kendaraan1) = jumlah_limbah(penghasil2)
            sa_jumlah_angkut(jumlah_pangkalan+penghasil1,index_kendaraan2) = jumlah_limbah(penghasil1);
            
            total_angkut1 = sum(sa_jumlah_angkut(:,index_kendaraan1));
            total_angkut2 = sum(sa_jumlah_angkut(:,index_kendaraan2));
            
            if total_angkut1 > kapasitas_kendaraan_1(index_kendaraan1) | total_angkut2 > kapasitas_kendaraan_1(index_kendaraan2)
                continue
            end
            
            % hitung total limbah yang diangkut ke gudang 1
            angkut_gudang_1 = sum(sa_jumlah_angkut(:,semua_kendaraan_1));
            total_angkut_gudang_1 = sum(angkut_gudang_1);
            
            % hitung total limbah yang diangkut ke gudang 2
            angkut_gudang_2 = sum(sa_jumlah_angkut(:,semua_kendaraan_2));
            total_angkut_gudang_2 = sum(angkut_gudang_2);
            
            if total_angkut_gudang_1 > kapasitas_kand_gudang(index_gudang_1) | total_angkut_gudang_2 > kapasitas_kand_gudang(index_gudang_2)
                continue
            end
            
            % cari titik sebelum penghasil1
            titik_y1 = find(sa_status_x(:,jumlah_pangkalan+penghasil1,index_kendaraan1) == 1);
            %cari titik setelah penghasil1
            titik_x1 = find(sa_status_x(jumlah_pangkalan+penghasil1,:,index_kendaraan1) == 1);
            
            % cari titik sebelum penghasil2
            titik_y2 = find(sa_status_x(:,jumlah_pangkalan+penghasil2,index_kendaraan2) == 1);
            %cari titik setelah penghasil1
            titik_x2 = find(sa_status_x(jumlah_pangkalan+penghasil2,:,index_kendaraan2) == 1);

            % hapus nilai dari penghasil pada titik sebelum dan setelahnya
            sa_status_x(titik_y1,jumlah_pangkalan+penghasil1,index_kendaraan1) = 0;
            sa_status_x(jumlah_pangkalan+penghasil1,titik_x1,index_kendaraan1) = 0;
            
%             sa_status_x(titik_y2,jumlah_pangkalan+penghasil2,index_kendaraan2) = 0
            sa_status_x(jumlah_pangkalan+penghasil2,titik_x2,index_kendaraan2) = 0;         
            
            % pasangkan penghasil baru ke titik lama
            sa_status_x(titik_y1,titik_x1,index_kendaraan1) = 1;
%             sa_status_x(jumlah_pangkalan+penghasil2,titik_x1,index_kendaraan1) = 1
            
            sa_status_x(jumlah_pangkalan+penghasil2,jumlah_pangkalan+penghasil1,index_kendaraan2) = 1;
            sa_status_x(jumlah_pangkalan+penghasil1,titik_x2,index_kendaraan2) = 1;
            

            % hapuskan waktu terdahulu
            sa_waktu_datang(:,index_kendaraan1) = 0;
            sa_waktu_datang(:,index_kendaraan2) = 0;

            % perhitungan waktu untuk kendaraan1 / rute swap1
            for penghasil3 = 2:length(rute_reloc1)-2
                penghasil3;
                penghasil4 = rute_reloc1(penghasil3);
                % waktu penghasil 1
                titik7 = find(sa_status_x(:,jumlah_pangkalan+penghasil4,index_kendaraan1) == 1);
                %titik0 = lokasi titik sebelum titik1
                
                waktu_buka = buka_penghasil(penghasil4);
                waktu_tutup = tutup_penghasil(penghasil4);
                
                if penghasil3 > 2
                    waktu_pelayanan = waktu_pelayanan_penghasil(titik7-jumlah_pangkalan);
                    waktu_datang_titik_sebelum = sa_waktu_datang(titik7,index_kendaraan1);
                    sa_waktu_datang(jumlah_pangkalan+penghasil4,index_kendaraan1) = waktu_total(titik7,jumlah_pangkalan+penghasil4)+waktu_pelayanan+waktu_datang_titik_sebelum;
                elseif penghasil3 == 2
                    waktu_pelayanan = 0;
                    waktu_datang_titik_sebelum = sa_waktu_datang(titik7,index_kendaraan1);
                    sa_waktu_datang(jumlah_pangkalan+penghasil4,index_kendaraan1) = waktu_total(titik7,jumlah_pangkalan+penghasil4)+waktu_pelayanan+waktu_datang_titik_sebelum;
                end
                
                if sa_waktu_datang(jumlah_pangkalan+penghasil4,index_kendaraan1) > waktu_tutup
                    jumlah_angkut = temp_sa_jumlah_angkut;
                    status_x = temp_sa_status_x;
                    waktu_datang = temp_sa_waktu_datang;
                    solusi = temp_sa_solusi;
                    kon = true;
                    continue
                end
                
                if sa_waktu_datang(jumlah_pangkalan+penghasil4,index_kendaraan1) < waktu_buka
                    sa_waktu_datang(jumlah_pangkalan+penghasil4,index_kendaraan1) < waktu_buka;
                end
                
            end
            
            if (kon)
                continue
            end
            
            % perhitungan waktu untuk kendaraan2 / rute swap2
            for penghasil5 = 2:length(rute_reloc2)-2
                penghasil5;
                penghasil6 = rute_reloc2(penghasil5);
                % waktu penghasil 1
                titik7 = find(sa_status_x(:,jumlah_pangkalan+penghasil6,index_kendaraan2) == 1);
                %titik0 = lokasi titik sebelum titik1
                
                if penghasil5 > 2
                    waktu_pelayanan = waktu_pelayanan_penghasil(titik7-jumlah_pangkalan);
                    waktu_datang_titik_sebelum = sa_waktu_datang(titik7,index_kendaraan2);
                    sa_waktu_datang(jumlah_pangkalan+penghasil6,index_kendaraan2) = waktu_total(titik7,jumlah_pangkalan+penghasil6)+waktu_pelayanan+waktu_datang_titik_sebelum;
                elseif penghasil5 == 2
                    waktu_pelayanan = 0;
                    waktu_datang_titik_sebelum = sa_waktu_datang(titik7,index_kendaraan2);
                    sa_waktu_datang(jumlah_pangkalan+penghasil6,index_kendaraan2) = waktu_total(titik7,jumlah_pangkalan+penghasil6)+waktu_pelayanan+waktu_datang_titik_sebelum;
                end
                
                if sa_waktu_datang(jumlah_pangkalan+penghasil6,index_kendaraan2) > waktu_tutup
                    jumlah_angkut = temp_sa_jumlah_angkut;
                    status_x = temp_sa_status_x;
                    waktu_datang = temp_sa_waktu_datang;
                    solusi = temp_sa_solusi;
                    kon = true;
                    continue
                end
                
                if sa_waktu_datang(jumlah_pangkalan+penghasil6,index_kendaraan2) < waktu_buka
                    sa_waktu_datang(jumlah_pangkalan+penghasil6,index_kendaraan2) = waktu_buka;
                end
                
            end
            
            if (kon)
                continue
            end
            
            sa_solusi{index_kendaraan1} = rute_reloc1;
            sa_solusi{index_kendaraan2} = rute_reloc2;
            
            sa_status_kendaraan1(index_kendaraan1) = 1;
            sa_status_gudang;
            sa_status_gudang_kendaraan;
        
        end
        
        %biaya perjalanan 1
        biaya_total1 = temp_biaya_total1;
        sa_seluruh_x = sum(sa_status_x,3);
        sa_cari_x = find(sa_seluruh_x == 1);
        sa_total_x = biaya_total1(sa_cari_x);
        sa_cari_x2 = find(sa_seluruh_x > 1);
        sa_jumlah_x2 = sa_seluruh_x(sa_cari_x2);
        sa_t_x2 = biaya_total1(sa_cari_x2);
        for i = 1:length(sa_jumlah_x2)
            sa_total_x2(i) = sa_t_x2(i) * sa_jumlah_x2(i);
        end
        if length(sa_jumlah_x2) == 0
            sa_total_x2 = 0;
        end
        sa_total_biaya_x = sum(sa_total_x) + sum(sa_total_x2);

        %biaya perjalanan 2
        sa_seluruh_r = sum(sa_status_r,3);
        sa_cari_r = find(sa_seluruh_r == 1);
        sa_total_r = biaya_total2(sa_cari_r);
        sa_total_biaya_r = sum(sa_total_r);

        %biaya buka gudang
        sa_biaya_gudang = sa_status_gudang*biaya_buka_gudang;

        %biaya buka pengolah
        sa_biaya_pengolah = sa_status_plant*biaya_buka_pengolah;

        sa_total1 = sa_total_biaya_x + sa_biaya_gudang + sa_biaya_pengolah + sa_total_biaya_r;
        
        total1 = total_biaya_awal;
        
        delta = sa_total1 - total1;
        
        if delta <= 0
            total1 = sa_total1;
            total_biaya_x = sa_total_biaya_x;
            biaya_gudang = sa_biaya_gudang;
            biaya_pengolah = sa_biaya_pengolah;
            total_biaya_r = sa_total_biaya_r;
            
            status_x = sa_status_x;
            status_r = sa_status_r;
            status_pengolah = sa_status_plant;
            status_gudang = sa_status_gudang;
            status_gudang_kendaraan = sa_status_gudang_kendaraan;
            status_gudang_kendaraan2 = sa_status_gudang_kendaraan2;
            status_kendaraan1 = sa_status_kendaraan1;
            status_kendaraan2 = sa_status_kendaraan2;
            status_pangkalan = sa_status_pangkalan;
            status_pangkalan_gudang = sa_status_pangkalan_gudang;
            status_pangkalan_kendaraan = sa_status_pangkalan_kendaraan;
            status_penghasil = sa_status_penghasil;
            status_penghasil_kendaraan = sa_status_penghasil_kendaraan;
            status_pengolah = sa_status_plant;
            status_gudang = sa_status_gudang;
            jumlah_angkut = sa_jumlah_angkut;
            jumlah_angkut2 = sa_jumlah_angkut2;
            waktu_datang = sa_waktu_datang;
            solusi = sa_solusi;
            solusi2 = sa_solusi2;
            
        else
            if rand < exp(-delta/temperatur_awal)
                total1 = sa_total1;
                total_biaya_x = sa_total_biaya_x;
                biaya_gudang = sa_biaya_gudang;
                biaya_pengolah = sa_biaya_pengolah;
                total_biaya_r = sa_total_biaya_r;

                status_x = sa_status_x;
                status_r = sa_status_r;
                status_pengolah = sa_status_plant;
                status_gudang = sa_status_gudang;
                status_gudang_kendaraan = sa_status_gudang_kendaraan;
                status_gudang_kendaraan2 = sa_status_gudang_kendaraan2;
                status_kendaraan1 = sa_status_kendaraan1;
                status_kendaraan2 = sa_status_kendaraan2;
                status_pangkalan = sa_status_pangkalan;
                status_pangkalan_gudang = sa_status_pangkalan_gudang;
                status_pangkalan_kendaraan = sa_status_pangkalan_kendaraan;
                status_penghasil = sa_status_penghasil;
                status_penghasil_kendaraan = sa_status_penghasil_kendaraan;
                status_pengolah = sa_status_plant;
                status_gudang = sa_status_gudang;
                jumlah_angkut = sa_jumlah_angkut;
                jumlah_angkut2 = sa_jumlah_angkut2;
                waktu_datang = sa_waktu_datang;
                solusi = sa_solusi;
                solusi2 = sa_solusi2;
                
            end
        end
    end
    temperatur_awal = temperatur_awal * cooling_rate;
end

total_awal = temp_total1
total_sa_awal = total1
total_sa_akhir = sa_total1

if total_sa_awal < total_sa_akhir
    total_biaya_x = awal_total_biaya_x;
    biaya_gudang = awal_biaya_gudang;
    biaya_pengolah = awal_biaya_pengolah;
    total_biaya_r = awal_total_biaya_r;
    
    awal_status_x = status_x;
    awal_status_r = status_r;
    awal_status_plant = status_pengolah;
    awal_status_gudang = status_gudang;
    awal_status_gudang_kendaraan = status_gudang_kendaraan;
    awal_status_gudang_kendaraan2 = status_gudang_kendaraan2;
    awal_status_kendaraan1 = status_kendaraan1;
    awal_status_kendaraan2 = status_kendaraan2;
    awal_status_pangkalan = status_pangkalan;
    awal_status_pangkalan_gudang = status_pangkalan_gudang;
    awal_status_pangkalan_kendaraan = status_pangkalan_kendaraan;
    awal_status_penghasil = status_penghasil;
    awal_status_penghasil_kendaraan = status_penghasil_kendaraan;
    awal_status_plant = status_pengolah;
    awal_status_gudang = status_gudang;
    awal_jumlah_angkut = jumlah_angkut;
    awal_jumlah_angkut2 = jumlah_angkut2;
    awal_waktu_datang = waktu_datang;
    awal_solusi = solusi;
    awal_solusi2 = solusi2;
    
elseif total_sa_awal >= total_sa_akhir
    total_biaya_x = sa_total_biaya_x;
    biaya_gudang = sa_biaya_gudang;
    biaya_pengolah = sa_biaya_pengolah;
    total_biaya_r = sa_total_biaya_r;
    
    akhir_status_x = sa_status_x;
    akhir_status_r = sa_status_r;
    akhir_status_plant = sa_status_plant;
    akhir_status_gudang = sa_status_gudang;
    akhir_status_gudang_kendaraan = sa_status_gudang_kendaraan;
    akhir_status_gudang_kendaraan2 = sa_status_gudang_kendaraan2;
    akhir_status_kendaraan1 = sa_status_kendaraan1;
    akhir_status_kendaraan2 = sa_status_kendaraan2;
    akhir_status_pangkalan = sa_status_pangkalan;
    akhir_status_pangkalan_gudang = sa_status_pangkalan_gudang;
    akhir_status_pangkalan_kendaraan = sa_status_pangkalan_kendaraan;
    akhir_status_penghasil = sa_status_penghasil;
    akhir_status_penghasil_kendaraan = sa_status_penghasil_kendaraan;
    akhir_status_plant = sa_status_plant;
    akhir_status_gudang = sa_status_gudang;
    akhir_jumlah_angkut = sa_jumlah_angkut;
    akhir_jumlah_angkut2 = sa_jumlah_angkut2;
    akhir_waktu_datang = sa_waktu_datang;
    akhir_solusi = sa_solusi;
    akhir_solusi2 = sa_solusi2;
    
end

waktu_komputasi = toc