import lirc
import re
from gpiozero import LED

socket_path = "/var/run/lirc/lircd"

keys_lights = {
    "OK": -1,
    "KEY_1": -1,
    "KEY_2": 27,
    "KEY_3": 22,
    "KEY_4": 14,
    "KEY_5": 15,
    "KEY_6": 18
}

leds = {}

def init_leds():
    print("Initializing LEDs: {}".format(keys_lights))
    for key in keys_lights.keys():
        if keys_lights[key] != -1:
            leds[key] = LED(keys_lights[key])
            leds[key].on()


def parse_key(key):
    ret = re.findall(r"^\S+\s\S+\s(\S+)\s\S+$", key)
    if ret is None or len(ret) == 0:
        return None
    return ret[0].strip()


def process_key(key):
    print("Processing key: {}".format(key))

    if not key in keys_lights:
        return

    if keys_lights[key] == -1:
        for key in keys_lights.keys():
            if keys_lights[key] != -1:
                print("Turning LED <OFF>: {}".format(keys_lights[key]))
                leds[key].off()
        return

    led = leds[key]
    if led.is_lit:
        print("Turning LED <OFF>: {}".format(keys_lights[key]))
        led.off()
    else:
        print("Turning LED <ON>: {}".format(keys_lights[key]))
        led.on()


init_leds()

with lirc.RawConnection(socket_path) as conn:
       while True:
           print("Scanning keypress...")
           keypress = conn.readline()
           print("Received keypress: {}".format(keypress))
           process_key(parse_key(keypress))


