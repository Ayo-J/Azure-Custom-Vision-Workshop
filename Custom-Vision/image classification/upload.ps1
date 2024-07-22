# Set the prediction URL and key
$predictionUrl = "image"
$predictionKey = "header"

# Prompt the user to select an image file
$imagePath = "Picture30.jpg"

# Check if the file exists
if (-Not (Test-Path $imagePath)) {
    Write-Host "File not found. Please check the path and try again."
    exit
}

# Read the file as byte array
$fileContent = [System.IO.File]::ReadAllBytes($imagePath)

# Set the headers for the request
$headers = @{}
$headers.Add("Prediction-Key", $predictionKey)
$headers.Add("Content-Type", "application/octet-stream")

# Send the request to the Custom Vision service
Write-Host "Analyzing image..."
try {
    $result = Invoke-RestMethod -Method Post -Uri $predictionUrl -Headers $headers -Body $fileContent
} catch {
    Write-Host "Error occurred while calling the Custom Vision service: $_"
    exit
}

# Check if the result is not null
if ($null -ne $result) {
    # Process the prediction result
    $prediction = $result | ConvertTo-Json -Depth 5 | ConvertFrom-Json

    # Check if predictions are available
    if ($prediction.predictions -and $prediction.predictions.Count -gt 0) {
        Write-Host ("`nPrediction: ", $prediction.predictions[0].tagName, "`nProbability: ", [math]::Round($prediction.predictions[0].probability * 100, 2), "%", "`n")
    } else {
        Write-Host "No predictions found in the response."
    }
} else {
    Write-Host "Received a null response from the Custom Vision service."
}
