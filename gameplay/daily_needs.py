"""Daily simulation rules for Pixel Farm Seasons (engine-independent)."""
from dataclasses import dataclass

@dataclass
class Farmer:
    minute: int = 7 * 60
    energy: float = 100.0
    hunger: float = 0.0
    last_meal: int = 7 * 60

    @property
    def clock(self):
        return f"{(self.minute // 60) % 24:02d}:{self.minute % 60:02d}"

    def advance(self, minutes: int, activity: str = "idle") -> list[str]:
        if minutes < 0:
            raise ValueError("minutes must be non-negative")
        events = []
        for _ in range(minutes):
            self.minute += 1
            self.hunger = min(100.0, self.hunger + 0.045)
            drain = {"idle": 0.005, "walking": 0.025, "farming": 0.06}.get(activity)
            if drain is None:
                raise ValueError(f"unknown activity: {activity}")
            self.energy = max(0.0, self.energy - drain)
            if self.hunger >= 65:
                self.energy = max(0.0, self.energy - 0.035)
            if self.minute % 60 == 0 and self.hunger >= 65:
                events.append("Estou com fome! Preciso comer alguma coisa.")
            if self.minute % 1440 == 11 * 60 and self.minute - self.last_meal >= 180:
                events.append("Eita, já são 11 horas! Tenho que pensar no almoço.")
        return events

    def eat(self, nutrition: float = 55.0) -> None:
        self.hunger = max(0.0, self.hunger - max(0.0, nutrition))
        self.energy = min(100.0, self.energy + 8.0)
        self.last_meal = self.minute

    def sleep(self, hours: int = 8) -> list[str]:
        events = self.advance(hours * 60, "idle")
        self.energy = min(100.0, self.energy + hours * 10.0)
        return events
