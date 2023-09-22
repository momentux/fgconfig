#include <iostream>
#include <cstring>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

const int PORT = 5500;
const int BUFFER_SIZE = 1024;
const int MAX_RETRIES = 5;
const int RETRY_INTERVAL = 5; // Retry interval in seconds

int main() {
    int sockfd;
    struct sockaddr_in serverAddr, clientAddr;
    char buffer[BUFFER_SIZE];
    socklen_t addr_size;

    int retryCount = 0;

    while (true) {
        sockfd = socket(PF_INET, SOCK_DGRAM, 0);
        if (sockfd < 0) {
            std::cerr << "Error: Could not create socket. " << std::strerror(errno) << std::endl;
            if (++retryCount > MAX_RETRIES) {
                std::cerr << "Max retries reached. Exiting..." << std::endl;
                return 1;
            }
            sleep(RETRY_INTERVAL);
            continue;
        }

        serverAddr.sin_family = AF_INET;
        serverAddr.sin_port = htons(PORT);
        serverAddr.sin_addr.s_addr = INADDR_ANY;
        memset(serverAddr.sin_zero, '\0', sizeof serverAddr.sin_zero);  

        if (bind(sockfd, (struct sockaddr *) &serverAddr, sizeof(serverAddr)) < 0) {
            std::cerr << "Error: Bind failed. " << std::strerror(errno) << std::endl;
            close(sockfd);
            if (++retryCount > MAX_RETRIES) {
                std::cerr << "Max retries reached. Exiting..." << std::endl;
                return 1;
            }
            sleep(RETRY_INTERVAL);
            continue;
        }

        std::cout << "UDP server is ready to receive. Listening on port " << PORT << std::endl;

        while (true) {
            ssize_t bytesReceived = recvfrom(sockfd, buffer, BUFFER_SIZE, 0, (struct sockaddr *) &clientAddr, &addr_size);
            
            if (bytesReceived < 0) {
                std::cerr << "Error: recvfrom failed. " << std::strerror(errno) << std::endl;
                break; // Exit inner loop to attempt reinitializing the socket
            }

            buffer[bytesReceived] = '\0';
            std::cout << "Received from client: " << buffer << std::endl;
        }

        close(sockfd);
    }

    return 0;
}
