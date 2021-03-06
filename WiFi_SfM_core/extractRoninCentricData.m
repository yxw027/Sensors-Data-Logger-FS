function [RoninIO] = extractRoninCentricData(datasetDirectory, roninInterval, roninYawRotation, accuracyThreshold)

% parse ronin.txt file / compute RoNIN velocity and speed
RoninIO = parseRoninTextFile([datasetDirectory '/ronin.txt'], roninInterval, roninYawRotation);
RoninIO = computeRoninVelocity(RoninIO);
RoninIOTime = [RoninIO.timestamp];


% parse wifi.txt file / find the closest WiFi Scan data
wifiScan = parseWiFiTextFile([datasetDirectory '/wifi.txt']);
numWifiScan = size(wifiScan,2);
for k = 1:numWifiScan
    
    % current WiFi Scan data
    timestamp = wifiScan(k).timestamp;
    wifiAPsResult = wifiScan(k).wifiAPsResult;
    
    
    % save WiFi Scan data in RoNIN IO
    [timeDifference, indexRoninIO] = min(abs(timestamp - RoninIOTime));
    if (timeDifference < 0.5)
        RoninIO(indexRoninIO).wifiAPsResult = wifiAPsResult;
    end
end


% parse FLP.txt / find the closest Google FLP data
GoogleFLP = parseGoogleFLPTextFile([datasetDirectory '/FLP.txt']);
numGoogleFLP = size(GoogleFLP,2);
for k = 1:numGoogleFLP
    
    % current Google FLP data
    timestamp = GoogleFLP(k).timestamp;
    locationDegree = GoogleFLP(k).locationDegree;
    locationMeter = GoogleFLP(k).locationMeter;
    accuracyMeter = GoogleFLP(k).accuracyMeter;
    
    
    % save Google FLP data in RoNIN IO
    [timeDifference, indexRoninIO] = min(abs(timestamp - RoninIOTime));
    if (timeDifference < 0.5)
        RoninIO(indexRoninIO).FLPLocationDegree = locationDegree;
        RoninIO(indexRoninIO).FLPLocationMeter = locationMeter;
        RoninIO(indexRoninIO).FLPAccuracyMeter = accuracyMeter;
    end
end


% refine invalid RoNIN result from Google FLP
numRonin = size(RoninIO,2);
for k = 1:numRonin
    if (RoninIO(k).FLPAccuracyMeter > accuracyThreshold)
        RoninIO(k).FLPLocationDegree = [];
        RoninIO(k).FLPLocationMeter = [];
        RoninIO(k).FLPAccuracyMeter = [];
    end
end


end


