clear all;
close all;
clc;

% Setup serial connection
arduinoPort = 'COM4';  % Change to your Arduino COM port
baudRate = 9600;       % Make sure this matches your Arduino setting

% Create serial object
s = serialport(arduinoPort, baudRate);
flush(s);

% Performance measurement settings
testDuration = 60;  % Time limit for measurement in seconds (can be adjusted)
steadyStateThreshold = 0.05;  % 5% threshold for steady state (increased for precision system)

% Initialize PID parameters
current_Kp = 0;
current_Ki = 0;
current_Kd = 0;

% Initialize test counter and results log
testCounter = 0;
resultsLog = struct('TestNum', {}, 'Kp', {}, 'Ki', {}, 'Kd', {}, ...
                   'RiseTime', {}, 'Overshoot', {}, 'SettlingTime', {}, ...
                   'SteadyStateError', {}, 'PerformanceScore', {});

% Main loop to allow multiple tests
continueRunning = true;

while continueRunning
    testCounter = testCounter + 1;
    
    % Figure
    figure('Name', ['Trainer Sistem Kontrol Linear - Pengujian #' num2str(testCounter)], 'NumberTitle', 'off', 'Position', [100 100 1000 600]);
    h_sp = animatedline('Color', 'r', 'LineStyle', '--', 'LineWidth', 2);  % Setpoint
    h_pos = animatedline('Color', 'b', 'LineWidth', 2);  % Actual position
    h_err = animatedline('Color', 'g', 'LineWidth', 1.5);  % Error line
    xlabel('Waktu (detik)');
    ylabel('Posisi (desimal)');
    title(['Respon Sistem Orde Kedua - Kp=' num2str(current_Kp, '%.1f') ' Ki=' num2str(current_Ki, '%.1f') ' Kd=' num2str(current_Kd, '%.2f')]);
    legend('Setpoint', 'Posisi Aktual', 'Error', 'Location', 'best');
    grid on;
    ylim([-10 10]);  % Changed Y-axis limits to match -9 to 9 range
    
    % User prompt
    disp('=====================================');
    disp(['Pengukuran Kinerja PID - Pengujian #' num2str(testCounter)]);
    disp('=====================================');
    disp('Instruksi:');
    disp('1. Pastikan sistem sudah direset dan berada pada posisi awal');
    disp('2. Ketik "ready" dan tekan Enter saat siap untuk mengukur metrik kinerja');
    disp('3. Kemudian tekan tombol "Start" pada Trainer untuk memulai pengujian');
    disp(['4. Skrip akan mengumpulkan data selama ' num2str(testDuration) ' detik dan menghitung metrik kinerja']);
    
    % Flag to track if we need to restart the test
    needRestart = false;
    
    % Outer loop to handle restarts when reset button is pressed
    while true
        % Wait for user to be ready
        userInput = '';
        while ~strcmpi(userInput, 'ready')
            userInput = input('Ketik "ready" jika ingin memulai pengujian: ', 's');
        end
        
        % Flush buffer after user inputs "ready"
        flush(s);
        disp('Buffer serial dibersihkan. Data pengujian sebelumnya dihapus.');
        disp('Tekan tombol "Start" pada Trainer sekarang!');
        
        % Reset data collection setup
        timeVector = [];
        dataSetpoint = [];
        dataPosition = [];
        dataError = [];  
        
        % Clear previous plot if restarting
        if needRestart
            clearpoints(h_sp);
            clearpoints(h_pos);
            clearpoints(h_err);  
            needRestart = false;
        end
        
        % Record initial position and setpoint
        initialPositionSet = false;
        initialPosition = NaN;
        initialSetpoint = NaN;
        baselineReadings = 0;
        
        % Wait for initial readings to establish baseline
        disp('Mendapatkan pembacaan dasar...');
        while baselineReadings < 5
            if s.NumBytesAvailable > 0
                arduinoData = readline(s);
                try
                    vals = str2double(split(arduinoData, ','));
                    if length(vals) >= 5 && all(~isnan(vals(1:5)))
                        if ~initialPositionSet
                            initialPosition = vals(2);
                            initialSetpoint = vals(1);
                            initialPositionSet = true;
                            disp(['Posisi awal: ' num2str(initialPosition) ', Setpoint awal: ' num2str(initialSetpoint)]);
                        end
                        baselineReadings = baselineReadings + 1;
                        
                        % Update PID values
                        current_Kp = vals(3);
                        current_Ki = vals(4);
                        current_Kd = vals(5);
                    end
                catch
                    % Skip invalid data
                end
            end
            pause(0.01);
        end
        
        % Start monitoring for significant changes in setpoint or position
        disp('Dasar telah ditetapkan. Memantau perubahan pergerakan...');
        movementDetected = false;
        setpointChangeDetected = false;
        changeDetectionTime = tic; % Timer to detect if no changes occur
        
        while ~movementDetected && ~setpointChangeDetected && toc(changeDetectionTime) < 30
            if s.NumBytesAvailable > 0
                arduinoData = readline(s);
                try
                    vals = str2double(split(arduinoData, ','));
                    if length(vals) >= 5 && all(~isnan(vals(1:5)))
                        currentSetpoint = vals(1);
                        currentPosition = vals(2);
                        
                        % Check for setpoint change (command signal change)
                        if abs(currentSetpoint - initialSetpoint) > 0.5
                            setpointChangeDetected = true;
                            disp(['Perubahan setpoint terdeteksi! Dari ' num2str(initialSetpoint) ' ke ' num2str(currentSetpoint)]);
                        end
                        
                        % Check for position change (system movement)
                        if abs(currentPosition - initialPosition) > 0.3
                            movementDetected = true;
                            disp(['Pergerakan terdeteksi! Posisi berubah dari ' num2str(initialPosition) ' ke ' num2str(currentPosition)]);
                        end
                        
                        % Update PID values
                        current_Kp = vals(3);
                        current_Ki = vals(4);
                        current_Kd = vals(5);
                        
                        % Update plot title with PID values
                        title(['Respon Sistem Orde Kedua - Kp=' num2str(current_Kp, '%.1f') ' Ki=' num2str(current_Ki, '%.1f') ' Kd=' num2str(current_Kd, '%.2f')]);
                    end
                catch
                    % Skip invalid data
                end
            end
            pause(0.01);
        end
        
        % Check if we detected a change or timed out
        if ~movementDetected && ~setpointChangeDetected
            disp('Tidak ada pergerakan atau perubahan setpoint terdeteksi dalam 30 detik.');
            disp('Silakan periksa koneksi Trainer dan coba lagi.');
            userRetry = input('Apakah ingin mencoba lagi? (y/n): ', 's');
            if ~strcmpi(userRetry(1), 'y')
                break; % Exit the restart loop
            else
                continue; % Restart the detection process
            end
        end
        
        % Start the timer for data collection
        disp('Memulai pengatur waktu dan pengumpulan data...');
        startTime = tic;
        testRunning = true;
        
        % Variables to detect reset button press
        nonZeroDetected = false;
        resetDetected = false;
        consecutiveZeros = 0;
        
        % Main data collection loop
        disp('Mengumpulkan data...');
        try
            while testRunning
                % Read data from serial port
                if s.NumBytesAvailable > 0
                    arduinoData = readline(s);
                    
                    % Parse the data (format: "setpoint,position,Kp,Ki,Kd")
                    try
                        vals = str2double(split(arduinoData, ','));
                        if length(vals) >= 5 && all(~isnan(vals(1:5)))
                            currentTime = toc(startTime);
                            currentSetpoint = vals(1);
                            currentPosition = vals(2);
                            current_Kp = vals(3);
                            current_Ki = vals(4);
                            current_Kd = vals(5);
                            
                            % Update plot title with latest PID values
                            title(['Respon Sistem Orde Kedua - Kp=' num2str(current_Kp, '%.1f') ' Ki=' num2str(current_Ki, '%.1f') ' Kd=' num2str(current_Kd, '%.2f')]);
                            
                            % Detect system reset (position suddenly back to -9 after motion)
                            if nonZeroDetected && abs(currentPosition + 9) < 0.5
                                consecutiveZeros = consecutiveZeros + 1;
                                
                                % If we get multiple consecutive readings near -9, it's likely a reset
                                if consecutiveZeros >= 3
                                    resetDetected = true;
                                    testRunning = false;
                                    disp('RESET TERDETEKSI! Posisi sistem kembali ke -9.');
                                    disp('Pengujian akan dimulai ulang. Harap tunggu...');
                                    needRestart = true;
                                    break;
                                end
                            elseif abs(currentPosition + 9) > 0.5
                                nonZeroDetected = true;
                                consecutiveZeros = 0;
                            end
                            
                            % Add data to animated lines
                            addpoints(h_sp, currentTime, vals(1));  % Setpoint
                            addpoints(h_pos, currentTime, vals(2));  % Actual position
                            
                            % Calculate and add error point
                            error = vals(1) - vals(2);  % Setpoint - Position
                            addpoints(h_err, currentTime, error);
                            
                            % Store data for later analysis
                            timeVector(end+1) = currentTime;
                            dataSetpoint(end+1) = vals(1);
                            dataPosition(end+1) = vals(2);
                            dataError(end+1) = error;  % Store error data
                            
                            % Update axis limits
                            xlim([0, max(30, currentTime+2)]);
                            
                            % Check if we've reached the time limit
                            if currentTime >= testDuration
                                testRunning = false;
                                disp('Durasi pengujian selesai. Menghitung metrik...');
                            end
                            
                            % Refresh plot
                            drawnow limitrate;
                        end
                    catch
                        % Skip this reading if parsing fails
                    end
                end
                pause(0.01);  % Small pause to reduce CPU usage
            end
        catch ME
            % Handle errors during data collection
            fprintf('Pengumpulan data dihentikan: %s\n', ME.message);
        end
        
        % If reset was detected, restart the test loop
        if resetDetected
            disp('Sistem direset selama pengumpulan data.');
            pause(2);
            continue;
        end
        
        % Check if we have enough data for analysis
        if length(dataPosition) < 10
            disp('PERINGATAN: Titik data yang terkumpul tidak cukup untuk analisis.');
            disp('Pengujian mungkin gagal atau berakhir terlalu cepat.');
            userRetry = input('Apakah ingin mencoba lagi? (y/n): ', 's');
            if strcmpi(userRetry(1), 'y')
                continue;  % Restart the test
            end
        end
        
        % If we reach here, the test completed successfully, so break from the restart loop
        break;
    end
    
    % Calculate performance metrics
    if ~isempty(dataPosition) && ~isempty(dataSetpoint) && length(dataPosition) > 10
        disp('=======================================');
        disp('Metrik Kinerja Pengendali PID:');
        disp('=======================================');
        
        % Get the final setpoint value (should be constant but take the mode to be safe)
        finalSetpoint = mode(dataSetpoint);
        
        % Initial position
        initialPosition = dataPosition(1);
        
        % Calculate rise time (10% to 90% of final value)
        targetChange = finalSetpoint - initialPosition;
        riseTime = NaN; % Initialize with NaN in case it can't be calculated

        % Display PID values
        fprintf('Nilai PID saat ini: Kp=%.1f, Ki=%.1f, Kd=%.2f\n', current_Kp, current_Ki, current_Kd);
        
        if abs(targetChange) > 0.1  % Reduced threshold for precision system
            lowerThreshold = initialPosition + 0.1 * targetChange;
            upperThreshold = initialPosition + 0.9 * targetChange;
            
            % Find the time points where the response crosses these thresholds
            if targetChange > 0
                riseStartIdx = find(dataPosition >= lowerThreshold, 1, 'first');
                riseEndIdx = find(dataPosition >= upperThreshold, 1, 'first');
            else
                riseStartIdx = find(dataPosition <= lowerThreshold, 1, 'first');
                riseEndIdx = find(dataPosition <= upperThreshold, 1, 'first');
            end
            
            if ~isempty(riseStartIdx) && ~isempty(riseEndIdx)
                riseTime = timeVector(riseEndIdx) - timeVector(riseStartIdx);
                fprintf('Rise Time (10%% hingga 90%%): %.3f detik\n', riseTime);
            else
                fprintf('Rise Time: Tidak dapat dihitung (ambang batas tidak tercapai)\n');
                riseTime = Inf;  % Use Inf for metrics that couldn't be calculated
            end
        else
            fprintf('Rise Time: Tidak dapat dihitung (perubahan setpoint tidak cukup)\n');
            riseTime = Inf;
        end
        
        % Calculate maximum overshoot
        steady_state_value = mean(dataPosition(end-min(10,length(dataPosition)-1):end));
        
        % Calculate overshoot based on movement direction
        if targetChange > 0
            extreme_value = max(dataPosition);
            if extreme_value > finalSetpoint
                percent_overshoot = 100 * (extreme_value - finalSetpoint) / abs(targetChange);
            else
                percent_overshoot = 0;
            end
        else
            extreme_value = min(dataPosition);
            if extreme_value < finalSetpoint
                percent_overshoot = 100 * (finalSetpoint - extreme_value) / abs(targetChange);
            else
                percent_overshoot = 0;
            end
        end
        
        fprintf('Overshoot Maksimum: %.2f%%\n', percent_overshoot);
        
        % Calculate settling time (within threshold of final value)
        settlingTime = NaN; % Initialize with NaN
        settlingBand = abs(finalSetpoint * steadyStateThreshold);
        for i = length(dataPosition):-1:1
            if abs(dataPosition(i) - finalSetpoint) > settlingBand
                settlingTime = timeVector(min(i+1, length(timeVector)));
                break;
            end
            if i == 1  % If we got all the way to the beginning
                settlingTime = timeVector(1);
            end
        end
        if isnan(settlingTime)
            settlingTime = Inf;  % Use Inf for metrics that couldn't be calculated
        end
        fprintf('Settling Time (dalam %.0f%%): %.3f detik\n', steadyStateThreshold*100, settlingTime);
        
        % Calculate steady-state error
        steadyStateError = abs(finalSetpoint - steady_state_value);
        
        % Handle division by zero for percent calculation when setpoint is zero
        if abs(finalSetpoint) < 0.001
            steadyStateErrorPercent = steadyStateError * 100; % Just use absolute error * 100 when setpoint is near zero
        else
            steadyStateErrorPercent = 100 * steadyStateError / abs(finalSetpoint);
        end
        
        fprintf('Steady-State Error: %.3f desimal (%.2f%%)\n', steadyStateError, steadyStateErrorPercent);
        
        % Calculate overall performance score (lower is better)
        % Normalize each metric to 0-1 range and combine with weightings
        performanceScore = 0;
        
        % Weights for each metric (adjust these based on your priorities)
        w_riseTime = 0.25;
        w_overshoot = 0.25; 
        w_settlingTime = 0.25;
        w_steadyStateError = 0.25;
        
        % Add weighted normalized metrics to score (lower is better for all metrics)
        if ~isinf(riseTime)
            performanceScore = performanceScore + w_riseTime * riseTime;
        else
            performanceScore = performanceScore + w_riseTime * 10;  % Penalty for invalid rise time
        end
        
        performanceScore = performanceScore + w_overshoot * percent_overshoot/100;
        
        if ~isinf(settlingTime)
            performanceScore = performanceScore + w_settlingTime * settlingTime/10;  % Normalize settling time
        else
            performanceScore = performanceScore + w_settlingTime * 10;  % Penalty for invalid settling time
        end
        
        performanceScore = performanceScore + w_steadyStateError * steadyStateErrorPercent/100;
        
        fprintf('Skor Kinerja Keseluruhan: %.4f (semakin rendah semakin baik)\n', performanceScore);
        
        % Log this test's results
        resultsLog(testCounter).TestNum = testCounter;
        resultsLog(testCounter).Kp = current_Kp;
        resultsLog(testCounter).Ki = current_Ki;
        resultsLog(testCounter).Kd = current_Kd;
        resultsLog(testCounter).RiseTime = riseTime;
        resultsLog(testCounter).Overshoot = percent_overshoot;
        resultsLog(testCounter).SettlingTime = settlingTime;
        resultsLog(testCounter).SteadyStateError = steadyStateErrorPercent;
        resultsLog(testCounter).PerformanceScore = performanceScore;
        
        % Create metrics strings based on what was calculated
        metricsStrings = {};
        
        % Add PID values to metrics strings
        metricsStrings{end+1} = sprintf('Kp=%.1f, Ki=%.1f, Kd=%.2f', current_Kp, current_Ki, current_Kd);
        
        if ~isinf(riseTime)
            metricsStrings{end+1} = sprintf('Rise Time: %.3fs', riseTime);
        else
            metricsStrings{end+1} = 'Rise Time: N/A';
        end
        
        metricsStrings{end+1} = sprintf('Overshoot: %.2f%%', percent_overshoot);
        
        if ~isinf(settlingTime)
            metricsStrings{end+1} = sprintf('Settling Time: %.3fs', settlingTime);
        else
            metricsStrings{end+1} = 'Settling Time: N/A';
        end
        
        metricsStrings{end+1} = sprintf('Kesalahan KT: %.3f desimal (%.2f%%)', steadyStateError, steadyStateErrorPercent);
        metricsStrings{end+1} = sprintf('Skor Kinerja: %.4f', performanceScore);
    end
    
    % Display comparative results table if we have multiple tests
    if testCounter > 1
        % Find the best parameters based on performance score
        [bestScore, bestIdx] = min([resultsLog.PerformanceScore]);
        
        % Create a comparison figure
        figure('Name', 'Perbandingan Parameter PID', 'Position', [150 150 900 400]);
        
        % Convert struct to table for easy display
        resultsTable = struct2table(resultsLog);
        
        % Handle Inf values for display
        resultsTable.RiseTime = cellfun(@(x) iif(isinf(x), 'N/A', num2str(x, '%.3f')), num2cell(resultsTable.RiseTime), 'UniformOutput', false);
        resultsTable.SettlingTime = cellfun(@(x) iif(isinf(x), 'N/A', num2str(x, '%.3f')), num2cell(resultsTable.SettlingTime), 'UniformOutput', false);
        
        % Display the table
        uitable('Data', table2cell(resultsTable), 'ColumnName', resultsTable.Properties.VariableNames, ...
                'Position', [20 50 860 320]);
        
        % Display the best parameters
        title(sprintf('Parameter PID Terbaik: Kp=%.1f, Ki=%.1f, Kd=%.2f (Pengujian #%d, Skor: %.4f)', ...
              resultsLog(bestIdx).Kp, resultsLog(bestIdx).Ki, resultsLog(bestIdx).Kd, ...
              resultsLog(bestIdx).TestNum, bestScore));
    end
    
    % Ask the user if they want to run another test
    disp('Pengujian selesai.');
    userContinue = input('Apakah ingin menjalankan pengujian lain? (y/n): ', 's');
    if ~strcmpi(userContinue(1), 'y')
        continueRunning = false;
    end
end

% After all tests, create a final comparison if we have multiple tests
if testCounter > 1
    % Find the best parameters based on performance score
    [bestScore, bestIdx] = min([resultsLog.PerformanceScore]);
    
    disp('=======================================');
    disp('PARAMETER PID TERBAIK DITEMUKAN:');
    disp('=======================================');
    fprintf('Kp = %.1f\n', resultsLog(bestIdx).Kp);
    fprintf('Ki = %.1f\n', resultsLog(bestIdx).Ki);
    fprintf('Kd = %.2f\n', resultsLog(bestIdx).Kd);
    fprintf('Skor Kinerja: %.4f\n', bestScore);
    fprintf('Dari Pengujian #%d\n', resultsLog(bestIdx).TestNum);
    
    % Save results to CSV file
    resultsTable = struct2table(resultsLog);
    writetable(resultsTable, 'PID_tuning_results.csv');
    disp('Hasil disimpan ke PID_tuning_results.csv');
end

% Helper function for handling Inf values in display
function result = iif(condition, trueVal, falseVal)
    if condition
        result = trueVal;
    else
        result = falseVal;
    end
end

% Clean up
clear s;
disp('Skrip selesai. Semua gambar akan tetap terbuka untuk perbandingan.');