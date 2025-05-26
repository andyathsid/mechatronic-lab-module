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
testDuration = 30;  % Time limit for measurement in seconds (can be adjusted)
steadyStateThreshold = 0.02;  % 2% threshold for steady state

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
    
    % Create a new figure for this test with the new naming scheme
    figure('Name', ['Trainer Sistem Kontrol Radial - Pengujian #' num2str(testCounter)], 'NumberTitle', 'off', 'Position', [100 100 1000 600]);
    h_sp = animatedline('Color', 'r', 'LineStyle', '--', 'LineWidth', 2);  % Setpoint
    h_pos = animatedline('Color', 'b', 'LineWidth', 2);  % Actual position
    h_err = animatedline('Color', 'g', 'LineWidth', 1.5);  % Error line
    xlabel('Waktu (detik)');
    ylabel('Posisi (derajat)');
    title(['Respon Sistem Orde Kedua - Kp=' num2str(current_Kp, '%.1f') ' Ki=' num2str(current_Ki, '%.1f') ' Kd=' num2str(current_Kd, '%.2f')]);
    legend('Setpoint', 'Posisi Aktual', 'Error', 'Location', 'best');
    grid on;
    ylim([0 180]);
    
    % User prompt
    disp('=====================================');
    disp(['Pengukuran Kinerja PID - Pengujian #' num2str(testCounter)]);
    disp('=====================================');
    disp('Instruksi:');
    disp('1. Pastikan sistem sudah direset');
    disp('2. Ketik "ready" dan tekan Enter saat siap untuk mengukur metrik kinerja');
    disp('3. Kemudian tekan tombol "Start" pada Trainer untuk memulai pengujian');
    disp('4. Skrip akan mengumpulkan data selama 60 detik dan menghitung metrik kinerja');
    
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
        disp('Menunggu perubahan posisi...');
        
        % Reset data collection setup
        timeVector = [];
        dataSetpoint = [];
        dataPosition = [];
        dataError = [];  % Add error data array
        
        % Clear previous plot if restarting
        if needRestart
            clearpoints(h_sp);
            clearpoints(h_pos);
            clearpoints(h_err);  % Clear error line
            needRestart = false;
        end
        
        % Wait for movement to start
        movementDetected = false;
        lastPosition = NaN;
        
        % Wait for movement to begin
        while ~movementDetected
            if s.NumBytesAvailable > 0
                arduinoData = readline(s);
                try
                    vals = str2double(split(arduinoData, ','));
                    if length(vals) >= 5 && all(~isnan(vals(1:5)))
                        currentPosition = vals(2);
                        current_Kp = vals(3);
                        current_Ki = vals(4);
                        current_Kd = vals(5);
                        
                        % Update plot title with PID values instead of figure name
                        title(['Respon Sistem Orde Kedua - Kp=' num2str(current_Kp, '%.1f') ' Ki=' num2str(current_Ki, '%.1f') ' Kd=' num2str(current_Kd, '%.2f')]);
                        
                        if isnan(lastPosition)
                            lastPosition = currentPosition;
                        elseif abs(currentPosition - lastPosition) > 1  % Movement detected threshold
                            movementDetected = true;
                            disp('Pergerakan terdeteksi! Memulai pengatur waktu dan perhitungan...');
                            setpoint = vals(1);  % Capture the setpoint
                        else
                            lastPosition = currentPosition;
                        end
                    end
                catch
                    % Skip invalid data
                end
            end
            pause(0.01);
        end
        
        % Start the timer once movement is detected
        startTime = tic;
        testRunning = true;
        
        % Variables to detect reset button press
        firstMovement = true;
        nonZeroDetected = false;
        resetDetected = false;
        lastPositionValue = currentPosition;
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
                            % currentError = currentSetpoint - currentPosition;
                            
                            % Update plot title with latest PID values
                            title(['Respon Sistem Orde Kedua - Kp=' num2str(current_Kp, '%.1f') ' Ki=' num2str(current_Ki, '%.1f') ' Kd=' num2str(current_Kd, '%.2f')]);
                            
                            % Detect system reset (position suddenly back to 0 after motion)
                            if nonZeroDetected && currentPosition == 0
                                consecutiveZeros = consecutiveZeros + 1;
                                
                                % If we get multiple consecutive zeros after movement, it's likely a reset
                                if consecutiveZeros >= 3
                                    resetDetected = true;
                                    testRunning = false;
                                    disp('RESET TERDETEKSI! Posisi sistem kembali ke 0.');
                                    disp('Pengujian akan dimulai ulang. Harap tunggu...');
                                    needRestart = true;
                                    break;
                                end
                            elseif currentPosition > 0
                                nonZeroDetected = true;
                                consecutiveZeros = 0;
                            end
                            
                            % Add data to animated lines
                            addpoints(h_sp, currentTime, vals(1));  % Setpoint
                            addpoints(h_pos, currentTime, vals(2));  % Actual position
                            
                            % Calculate and add error point
                            currentError = currentSetpoint - currentPosition;
                            addpoints(h_err, currentTime, currentError);

                            % Store data for later analysis
                            timeVector(end+1) = currentTime;
                            dataSetpoint(end+1) = vals(1);
                            dataPosition(end+1) = vals(2);
                            dataError(end+1) = currentError;  % Store error data
                            
                            % Update axis limits
                            xlim([0, max(30, currentTime+2)]);
                            
                            % Store for next comparison
                            lastPositionValue = currentPosition;
                            
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
        
        if abs(targetChange) > 1  % Only calculate if there's significant change
            lowerThreshold = initialPosition + 0.1 * targetChange;
            upperThreshold = initialPosition + 0.9 * targetChange;
            
            % Find the time points where the response crosses these thresholds
            riseStartIdx = find(dataPosition >= lowerThreshold, 1, 'first');
            riseEndIdx = find(dataPosition >= upperThreshold, 1, 'first');
            
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
        max_value = max(dataPosition);
        percent_overshoot = 0; % Initialize with zero
        
        if max_value > finalSetpoint
            percent_overshoot = 100 * (max_value - finalSetpoint) / abs(targetChange);
            fprintf('Overshoot: %.2f%%\n', percent_overshoot);
        else
            fprintf('Overshoot: 0%% (Tidak ada lonjakan terdeteksi)\n');
        end
        
        % Calculate settling time (within 2% of final value)
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
        steadyStateErrorPercent = 100*steadyStateError/finalSetpoint;
        fprintf('Steady State Error: %.2f derajat (%.2f%%)\n', steadyStateError, steadyStateErrorPercent);
        
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
        
        metricsStrings{end+1} = sprintf('Kesalahan KT: %.2f derajat (%.2f%%)', steadyStateError, steadyStateErrorPercent);
        metricsStrings{end+1} = sprintf('Skor Kinerja: %.4f', performanceScore);
        
        % Add these metrics to the plot
        % annotation('textbox', [0.15, 0.7, 0.3, 0.2], 'String', metricsStrings, ...
        %     'BackgroundColor', 'white', 'FitBoxToText', 'on');
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
    writetable(resultsTable, 'PID_tuning_results_radial.csv');
    disp('Hasil disimpan ke PID_tuning_results_radial.csv');
end

% Helper function for handling Inf values in display
function result = iif(condition, trueVal, falseVal)
    if condition
        result = trueVal;
    else
        result = falseVal;
    end
end
