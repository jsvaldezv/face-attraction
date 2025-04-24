# Face Attraction: Remote Sound Interaction – Processing + SuperCollider + OSC

This project is an interactive audio system that uses facial tracking and head movement to control sound parameters in real time. Developed with Processing and SuperCollider, it enables remote sound interaction through OSC (Open Sound Control) messages.

🧠 How It Works:

- Processing tracks facial features (eyes, eyebrows, mouth) and head position using a webcam.
- The positional data is sent via OSC messages to SuperCollider.
- SuperCollider responds to these inputs by generating or modifying audio accordingly.

🌐 Remote Mode:

- You can test the system locally using a local OSC server.
- For remote interaction, we use Hamachi VPN to establish a virtual private network and assign a shared IP.
- Make sure to update the IP address in both Processing and SuperCollider to match the new VPN IP.

🎛️ Requirements:

- Processing (with a facial tracking library such as OpenCV)
- SuperCollider
- OSC communication libraries
- Hamachi (for remote interaction)

This project explores new forms of embodied sound control, merging movement, facial expression, and remote interaction into a unified sonic experience.

### Installation

1. Supercollider: You can download it from official website https://supercollider.github.io/
2. Processing IDE: Just download from official website https://processing.org/
3. Hamachi: You can download it from official website https://www.vpn.net/
