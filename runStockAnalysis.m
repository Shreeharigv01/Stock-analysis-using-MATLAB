function [forecastData, technicalData] = runStockAnalysis(ticker, fromDate, toDate)
% runStockAnalysis  Load data, run ARIMA or LSTM based on period,
% calculate technical indicators, and return all results in structs.
%
% DISCLAIMER: Educational purposes only. Do your own research before investing.

%% 1. Load & preprocess
filename = sprintf('%s.csv', upper(ticker));
dataTbl = readtable(filename, 'PreserveVariableNames', true);
dataTbl.Properties.VariableNames = {'Date','Close','Volume','Open','High','Low'};
for c = {'Close','Open','High','Low'}
    dataTbl.(c{1}) = str2double(erase(dataTbl.(c{1}), '$'));
end
dataTbl.Date = datetime(dataTbl.Date, 'InputFormat','MM/dd/yyyy');
dataTbl = sortrows(dataTbl, 'Date');

mask = dataTbl.Date >= fromDate & dataTbl.Date <= toDate;
dataTbl = dataTbl(mask,:);
allDates  = dataTbl.Date;
allPrices = fillmissing(dataTbl.Close, 'linear');

%% 2. Train/test split
train_size = round(0.8 * numel(allPrices));
train_data = allPrices(1:train_size);

%% 3. Choose model
durationDays = days(toDate - fromDate);
if durationDays <= 183
    % Short-term → ARIMA
    analysisType = 'Short-term';
    chosenModel  = 'ARIMA';
    m            = arima(2,1,2);
    fit          = estimate(m, train_data, 'Display','off');
    [fc,~]       = forecast(fit,1,'Y0',train_data);
    forecastValue = fc(1);
else
    % Long-term → LSTM
    analysisType = 'Long-term';
    chosenModel  = 'LSTM';

    n = 30;
    % Build sliding window data
    N = numel(train_data);
    if N <= n
        % Not enough for LSTM → fallback
        warning('Not enough data for LSTM. Falling back to ARIMA');
        analysisType = 'Short-term';
        chosenModel  = 'ARIMA (fallback)';
        m            = arima(2,1,2);
        fit          = estimate(m, train_data, 'Display','off');
        [fc,~]       = forecast(fit,1,'Y0',train_data);
        forecastValue = fc(1);
    else
        X = zeros(N-n, n);
        Y = zeros(N-n, 1);
        for i = n+1:N
            X(i-n, :) = train_data(i-n:i-1)';
            Y(i-n)     = train_data(i);
        end
        % Normalize
        [Xn, xPS] = mapminmax(X');  % X' is [n x (N-n)]
        [Yn, yPS] = mapminmax(Y');
        Xn = Xn'; Yn = Yn';

        % Sequences as 1×n rows
        seq = cell(size(Xn,1),1);
        for i=1:size(Xn,1)
            seq{i} = Xn(i,:);
        end

        % Train LSTM
        layers = [ ...
          sequenceInputLayer(1)
          lstmLayer(50,'OutputMode','last')
          fullyConnectedLayer(1)
          regressionLayer ];
        opts = trainingOptions('adam', ...
          'MaxEpochs',350,'MiniBatchSize',16,'Shuffle','every-epoch','Verbose',false);
        net = trainNetwork(seq, Yn, layers, opts);

        % Prepare final test sequence [1×n]
        testSeqRow = train_data(end-n+1:end)';  % [1×n]
        % Normalize: mapminmax expects column, so transpose twice
        testSeqNormCol = mapminmax('apply', testSeqRow', xPS);  % [n×1]
        testSeqNormRow = testSeqNormCol';                        % [1×n]

        % Sanity check
        if ~isequal(size(testSeqNormRow), [1 n])
            warning('LSTM input shape mismatch (%dx%d). Falling back to ARIMA.', ...
                    size(testSeqNormRow,1), size(testSeqNormRow,2));
            analysisType = 'Short-term';
            chosenModel  = 'ARIMA (fallback)';
            m            = arima(2,1,2);
            fit          = estimate(m, train_data, 'Display','off');
            [fc,~]       = forecast(fit,1,'Y0',train_data);
            forecastValue = fc(1);
        else
            % Predict
            fcNorm = predict(net, {testSeqNormRow});
            fcVal  = mapminmax('reverse', fcNorm, yPS);
            forecastValue = fcVal(1);
        end
    end
end

%% 4. Next trading day
lastD = max(allDates);
nd = lastD + caldays(1);
while ismember(weekday(nd),[1 7])
    nd = nd + caldays(1);
end

%% 5. Technical indicators
sma20 = movmean(allPrices, [19 0]);
sma50 = movmean(allPrices, [49 0]);
if exist('rsindex','file')==2
    rsiValues = rsindex(allPrices,14);
else
    d = diff(allPrices);
    up = max(d,0); dn = max(-d,0);
    g = movmean(up,[13 0]); l = movmean(dn,[13 0]);
    rs = g./l; rsiVals = 100 - (100./(1+rs));
    rsiValues = [NaN; rsiVals];
end
lastRSI = rsiValues(end);
if lastRSI < 30
    rec = 'BUY';
elseif lastRSI > 70
    rec = 'SELL';
else
    rec = 'HOLD';
end

%% 6. Package outputs
forecastData.allDates      = allDates;
forecastData.allPrices     = allPrices;
forecastData.analysisType  = analysisType;
forecastData.chosenModel   = chosenModel;
forecastData.nextDate      = nd;
forecastData.forecastValue = forecastValue;

technicalData.sma20         = sma20;
technicalData.sma50         = sma50;
technicalData.rsiValues     = rsiValues;
technicalData.lastRSI       = lastRSI;
technicalData.recommendation= rec;
end
