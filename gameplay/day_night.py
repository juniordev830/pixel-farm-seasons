"""Visual day/night state calculated from the in-game clock.

Renderer-agnostic: game clients can use these values for sky, ambient lighting,
house windows and stars without tying gameplay to a particular graphics engine.
"""
from dataclasses import dataclass
from math import cos, pi

@dataclass(frozen=True)
class Lighting:
    hour: float
    phase: str
    daylight: float
    ambient: float
    stars: float
    house_lights: bool
    sky_rgb: tuple[int, int, int]

def _mix(a, b, t):
    return tuple(round(x + (y - x) * t) for x, y in zip(a, b))

def lighting_at(minute: int) -> Lighting:
    """Return continuous lighting values for an arbitrary game minute."""
    hour = (minute % 1440) / 60
    if 5 <= hour < 7:
        phase = "sunrise"
        daylight = (hour - 5) / 2
        sky = _mix((19, 28, 66), (255, 175, 115), daylight)
    elif 7 <= hour < 17:
        phase = "day"
        daylight = 1.0
        sky = (111, 191, 244)
    elif 17 <= hour < 19:
        phase = "sunset"
        daylight = (19 - hour) / 2
        sky = _mix((22, 26, 61), (255, 147, 94), daylight)
    else:
        phase = "night"
        daylight = 0.0
        sky = (19, 26, 58)
    ambient = round(0.18 + 0.82 * daylight, 3)
    stars = round(max(0.0, 1.0 - daylight * 2), 3)
    return Lighting(hour, phase, round(daylight, 3), ambient, stars,
                    hour >= 18.5 or hour < 5.5, sky)
