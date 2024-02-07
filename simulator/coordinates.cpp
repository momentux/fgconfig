#include <iostream>
#include <iomanip>
#include <fstream>
#include <windows.h>

int main() {
    // User input for initial latitude, longitude, and altitude
    double initialLati, initialLongi, altitude;
    std::cout << "Enter initial latitude: ";
    std::cin >> initialLati;
    std::cout << "Enter initial longitude: ";
    std::cin >> initialLongi;
    std::cout << "Enter altitude: ";
    std::cin >> altitude;

    // User input for the number of targets and waypoints
    int numTargets, numWaypoints;
    std::cout << "Enter the number of targets: ";
    std::cin >> numTargets;
    std::cout << "Enter the number of waypoints: ";
    std::cin >> numWaypoints;

    // User input for the filename
    std::string filename;
    std::cout << "Enter the filename (without extension): ";
    std::cin >> filename;

    // Get the current working directory
    char buffer[MAX_PATH];
    GetCurrentDirectoryA(MAX_PATH, buffer);
    std::string currentPath(buffer);

    // Combine the filename with the document directory path
    std::string filePathString = currentPath + "\\" + filename + ".txt";

    // Open a file for writing
    std::ofstream outputFile(filePathString);

    if (!outputFile.is_open()) {
        std::cerr << "Error opening the file for writing.\n";
        return 1;
    }

// Increment values for latitude and longitude
const double latIncrement = 0.001; // Adjusted for better precision
const double longIncrement = 0.001; // Adjusted for better precision
const int noofrows = numTargets / numWaypoints;

// Initialize initialLat and initialLong
double initialLat = initialLati;
double initialLong = initialLongi;

// Write the coordinates to the file
for (int k = 0; k < noofrows ; ++k) {
    double prevLat = initialLat;  // Store previous latitude
    double prevLong = initialLong;  // Store previous longitude

    for (int i = 0; i < 5 ; ++i) {
        for (int j = 0; j < numWaypoints; ++j) {
            // Write latitude, longitude, altitude, and additional information to the file
            outputFile << std::fixed << std::setprecision(6);
            outputFile << prevLat + j * latIncrement - k * 0.004 << "\t";
            outputFile << prevLong + i * longIncrement - k * 0.005 << "\t";
            outputFile << std::fixed << std::setprecision(2) << altitude << "\n";
        }
    }

    // Update initialLat and initialLong for the next iteration
    initialLat = prevLat + (numWaypoints - 1) * latIncrement - k * 0.004;
    initialLong = prevLong + (noofrows - 1) * longIncrement - k * 0.005;
}


    // Close the file
    outputFile.close();

    std::cout << "Coordinates have been saved to " << filePathString << ".\n";

    // Delay for 5 seconds on Windows
    Sleep(3000); // Sleep for 5000 milliseconds (5 seconds)

    // Close the application
    return 0;
}
