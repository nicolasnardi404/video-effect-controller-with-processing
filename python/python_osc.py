from pythonosc import udp_client


class OscClient:
    def __init__(self, ip="127.0.0.1", port=12000):
        """Initialize OSC client with IP and port."""
        self.client = udp_client.SimpleUDPClient(ip, port)

    def send_message(self, address, value):
        """Send an OSC message to the specified address with a value."""
        self.client.send_message(address, value)
